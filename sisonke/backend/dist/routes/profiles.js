"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
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
    const [profile] = existing.length
        ? await db_1.db.update(schema_1.userProfiles).set(payload).where((0, drizzle_orm_1.eq)(schema_1.userProfiles.userId, req.user.id)).returning()
        : await db_1.db.insert(schema_1.userProfiles).values({ ...payload, userId: req.user.id }).returning();
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
exports.default = router;
//# sourceMappingURL=profiles.js.map