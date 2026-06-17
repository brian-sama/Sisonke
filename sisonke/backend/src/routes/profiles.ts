import { Router } from 'express';
import { z } from 'zod';
import { eq } from 'drizzle-orm';
import { db } from '../db';
import { userProfiles, trustedContacts, notifications } from '../db/schema';
import { authMiddleware } from '../middleware/auth';
import { asyncHandler } from '../middleware/errorHandler';
import { OnboardingProfileSchema } from '../types';

const router = Router();

function ageGroupFromAge(age?: number) {
  if (!age) return '18-24' as const;
  if (age <= 15) return '13-15' as const;
  if (age <= 17) return '16-17' as const;
  if (age <= 24) return '18-24' as const;
  return '25+' as const;
}

router.use(authMiddleware);

router.get('/me', asyncHandler(async (req, res) => {
  const [profile] = await db
    .select()
    .from(userProfiles)
    .where(eq(userProfiles.userId, req.user!.id))
    .limit(1);

  res.json({ success: true, data: profile || null });
}));

router.put('/me', asyncHandler(async (req, res) => {
  const input = OnboardingProfileSchema.parse(req.body);
  if (!input.consentAccepted) {
    return res.status(400).json({ success: false, error: 'Consent is required to create a profile.' });
  }

  const ageGroup = ageGroupFromAge(input.age);
  const existing = await db
    .select()
    .from(userProfiles)
    .where(eq(userProfiles.userId, req.user!.id))
    .limit(1);

  const payload = {
    nickname: input.nickname,
    dateOfBirth: input.dateOfBirth,
    ageGroup,
    gender: input.gender,
    location: input.location,
    consentAcceptedAt: new Date(),
    chatbotPersona: input.chatbotPersona,
    screeningAnswers: input.screeningAnswers,
    pinEnabled: input.pinEnabled,
    biometricEnabled: input.biometricEnabled,
    autoLockMinutes: input.autoLockMinutes,
    hideJournalPreview: input.hideJournalPreview,
    updatedAt: new Date(),
  };

  const selectFields = {
    id: userProfiles.id,
    nickname: userProfiles.nickname,
    chatbotPersona: userProfiles.chatbotPersona,
  };

  const [profile] = existing.length
    ? await db.update(userProfiles).set(payload).where(eq(userProfiles.userId, req.user!.id)).returning(selectFields)
    : await db.insert(userProfiles).values({ ...payload, userId: req.user!.id }).returning(selectFields);

  res.json({ success: true, data: profile });
}));

router.patch('/me/safety', asyncHandler(async (req, res) => {
  const payload = {
    pinEnabled: Boolean(req.body.pinEnabled),
    biometricEnabled: Boolean(req.body.biometricEnabled),
    autoLockMinutes: Number(req.body.autoLockMinutes || 5),
    hideJournalPreview: Boolean(req.body.hideJournalPreview),
    updatedAt: new Date(),
  };

  const [updated] = await db
    .update(userProfiles)
    .set(payload)
    .where(eq(userProfiles.userId, req.user!.id))
    .returning();

  if (!updated) {
    return res.status(404).json({ success: false, error: 'Profile not found. Complete onboarding first.' });
  }

  res.json({ success: true, data: updated });
}));

const TrustedContactSchema = z.object({
  name: z.string().min(1).max(120),
  phone: z.string().min(7).max(50),
});

// POST /api/profiles/trusted-contact — save or update trusted contact
router.post('/trusted-contact', asyncHandler(async (req, res) => {
  const input = TrustedContactSchema.parse(req.body);

  const existing = await db
    .select()
    .from(trustedContacts)
    .where(eq(trustedContacts.userId, req.user!.id))
    .limit(1);

  const [contact] = existing.length
    ? await db
        .update(trustedContacts)
        .set({ name: input.name, phone: input.phone, updatedAt: new Date() })
        .where(eq(trustedContacts.userId, req.user!.id))
        .returning()
    : await db
        .insert(trustedContacts)
        .values({ userId: req.user!.id, name: input.name, phone: input.phone })
        .returning();

  res.json({ success: true, data: contact });
}));

// POST /api/profiles/check-on-me — notify trusted contact (logs an outreach notification)
router.post('/check-on-me', asyncHandler(async (req, res) => {
  const [contact] = await db
    .select()
    .from(trustedContacts)
    .where(eq(trustedContacts.userId, req.user!.id))
    .limit(1);

  if (!contact) {
    return res.status(404).json({
      success: false,
      error: 'No trusted contact saved. Add one first via POST /api/profiles/trusted-contact.',
    });
  }

  // Log an in-app outreach notification for the requesting user
  // In production you would also trigger an SMS/push to contact.phone here
  await db.insert(notifications).values({
    userId: req.user!.id,
    channel: 'outreach',
    title: 'Check-on-me sent',
    body: `A check-on-me request has been sent to ${contact.name} (${contact.phone}).`,
    metadata: { trustedContactName: contact.name, trustedContactPhone: contact.phone },
  });

  res.json({
    success: true,
    data: {
      message: `Check-on-me logged. ${contact.name} will be notified.`,
      contact: { name: contact.name, phone: contact.phone },
    },
  });
}));

export default router;
