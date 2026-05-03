import { Router } from 'express';
import { eq } from 'drizzle-orm';
import { db } from '../db';
import { userProfiles } from '../db/schema';
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

  const [profile] = existing.length
    ? await db.update(userProfiles).set(payload).where(eq(userProfiles.userId, req.user!.id)).returning()
    : await db.insert(userProfiles).values({ ...payload, userId: req.user!.id }).returning();

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

export default router;
