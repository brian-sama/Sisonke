"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const zod_1 = require("zod");
const drizzle_orm_1 = require("drizzle-orm");
const db_1 = require("../db");
const schema_1 = require("../db/schema");
const auth_1 = require("../middleware/auth");
const errorHandler_1 = require("../middleware/errorHandler");
const types_1 = require("../types");
const router = (0, express_1.Router)();
function ageGroupFromAge(age) {
    if (!age)
        return '18-24';
    if (age <= 15)
        return '13-15';
    if (age <= 17)
        return '16-17';
    if (age <= 24)
        return '18-24';
    return '25+';
}
router.use(auth_1.authMiddleware);
router.get('/me', (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const [profile] = await db_1.db
        .select()
        .from(schema_1.userProfiles)
        .where((0, drizzle_orm_1.eq)(schema_1.userProfiles.userId, req.user.id))
        .limit(1);
    res.json({ success: true, data: profile || null });
}));
router.put('/me', (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const input = types_1.OnboardingProfileSchema.parse(req.body);
    if (!input.consentAccepted) {
        return res.status(400).json({ success: false, error: 'Consent is required to create a profile.' });
    }
    const ageGroup = ageGroupFromAge(input.age);
    const existing = await db_1.db
        .select()
        .from(schema_1.userProfiles)
        .where((0, drizzle_orm_1.eq)(schema_1.userProfiles.userId, req.user.id))
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
        id: schema_1.userProfiles.id,
        nickname: schema_1.userProfiles.nickname,
        chatbotPersona: schema_1.userProfiles.chatbotPersona,
    };
    const [profile] = existing.length
        ? await db_1.db.update(schema_1.userProfiles).set(payload).where((0, drizzle_orm_1.eq)(schema_1.userProfiles.userId, req.user.id)).returning(selectFields)
        : await db_1.db.insert(schema_1.userProfiles).values({ ...payload, userId: req.user.id }).returning(selectFields);
    res.json({ success: true, data: profile });
}));
router.patch('/me/safety', (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const payload = {
        pinEnabled: Boolean(req.body.pinEnabled),
        biometricEnabled: Boolean(req.body.biometricEnabled),
        autoLockMinutes: Number(req.body.autoLockMinutes || 5),
        hideJournalPreview: Boolean(req.body.hideJournalPreview),
        updatedAt: new Date(),
    };
    const [updated] = await db_1.db
        .update(schema_1.userProfiles)
        .set(payload)
        .where((0, drizzle_orm_1.eq)(schema_1.userProfiles.userId, req.user.id))
        .returning();
    if (!updated) {
        return res.status(404).json({ success: false, error: 'Profile not found. Complete onboarding first.' });
    }
    res.json({ success: true, data: updated });
}));
const TrustedContactSchema = zod_1.z.object({
    name: zod_1.z.string().min(1).max(120),
    phone: zod_1.z.string().min(7).max(50),
});
// POST /api/profiles/trusted-contact — save or update trusted contact
router.post('/trusted-contact', (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const input = TrustedContactSchema.parse(req.body);
    const existing = await db_1.db
        .select()
        .from(schema_1.trustedContacts)
        .where((0, drizzle_orm_1.eq)(schema_1.trustedContacts.userId, req.user.id))
        .limit(1);
    const [contact] = existing.length
        ? await db_1.db
            .update(schema_1.trustedContacts)
            .set({ name: input.name, phone: input.phone, updatedAt: new Date() })
            .where((0, drizzle_orm_1.eq)(schema_1.trustedContacts.userId, req.user.id))
            .returning()
        : await db_1.db
            .insert(schema_1.trustedContacts)
            .values({ userId: req.user.id, name: input.name, phone: input.phone })
            .returning();
    res.json({ success: true, data: contact });
}));
// POST /api/profiles/check-on-me — notify trusted contact (logs an outreach notification)
router.post('/check-on-me', (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const [contact] = await db_1.db
        .select()
        .from(schema_1.trustedContacts)
        .where((0, drizzle_orm_1.eq)(schema_1.trustedContacts.userId, req.user.id))
        .limit(1);
    if (!contact) {
        return res.status(404).json({
            success: false,
            error: 'No trusted contact saved. Add one first via POST /api/profiles/trusted-contact.',
        });
    }
    // Log an in-app outreach notification for the requesting user
    // In production you would also trigger an SMS/push to contact.phone here
    await db_1.db.insert(schema_1.notifications).values({
        userId: req.user.id,
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
exports.default = router;
//# sourceMappingURL=profiles.js.map