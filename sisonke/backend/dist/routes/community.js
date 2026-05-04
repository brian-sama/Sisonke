"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const drizzle_orm_1 = require("drizzle-orm");
const db_1 = require("../db");
const schema_1 = require("../db/schema");
const auth_1 = require("../middleware/auth");
const errorHandler_1 = require("../middleware/errorHandler");
const types_1 = require("../types");
const riskService_1 = require("../services/riskService");
const socketService_1 = require("../services/socketService");
const router = (0, express_1.Router)();
const blockedTerms = ['suicide', 'kill myself', 'rape', 'abuse', 'violence'];
router.get('/posts', auth_1.authMiddleware, (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const ageGroup = String(req.query.ageGroup || '');
    if (!['13-15', '16-17', '18-24', '25+'].includes(ageGroup)) {
        return res.status(400).json({ success: false, error: 'Valid ageGroup is required.' });
    }
    const rows = await db_1.db
        .select()
        .from(schema_1.communityPosts)
        .where((0, drizzle_orm_1.and)((0, drizzle_orm_1.eq)(schema_1.communityPosts.ageGroup, ageGroup), (0, drizzle_orm_1.eq)(schema_1.communityPosts.status, 'approved')))
        .orderBy((0, drizzle_orm_1.desc)(schema_1.communityPosts.createdAt))
        .limit(50);
    res.json({ success: true, data: rows });
}));
router.post('/posts', auth_1.authMiddleware, (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const input = types_1.CommunityPostSchema.parse(req.body);
    const normalized = input.content.toLowerCase();
    const riskLevel = (0, riskService_1.detectRiskLevel)(input.content);
    const blocked = blockedTerms.some((term) => normalized.includes(term));
    const [post] = await db_1.db.insert(schema_1.communityPosts).values({
        userId: req.user.id,
        ageGroup: input.ageGroup,
        content: input.content,
        status: blocked || riskLevel !== 'low' ? 'pending' : 'pending',
        moderationReason: blocked ? 'Safety review required' : undefined,
    }).returning();
    socketService_1.SocketService.broadcastDashboardUpdate({ type: 'community_post', action: 'created' });
    await db_1.db.insert(schema_1.analyticsEvents).values({
        event: 'community_post_submitted',
        category: input.ageGroup,
        metadata: { riskLevel },
    });
    res.status(201).json({
        success: true,
        data: {
            post,
            message: 'Post submitted for moderation before it appears in the public feed.',
        },
    });
}));
router.post('/reports', auth_1.authMiddleware, (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const reason = String(req.body.reason || '').trim();
    if (!reason)
        return res.status(400).json({ success: false, error: 'Report reason is required.' });
    const [report] = await db_1.db.insert(schema_1.reports).values({
        type: 'community_post',
        resourceId: req.body.resourceId,
        reason,
        description: req.body.description,
        reporterDeviceId: req.user.deviceId,
    }).returning();
    socketService_1.SocketService.broadcastDashboardUpdate({ type: 'report', action: 'created' });
    res.status(201).json({ success: true, data: report });
}));
exports.default = router;
//# sourceMappingURL=community.js.map