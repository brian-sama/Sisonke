"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const drizzle_orm_1 = require("drizzle-orm");
const db_1 = require("../db");
const schema_1 = require("../db/schema");
const auth_1 = require("../middleware/auth");
const errorHandler_1 = require("../middleware/errorHandler");
const types_1 = require("../types");
const socketService_1 = require("../services/socketService");
const router = (0, express_1.Router)();
router.post('/requests', auth_1.authMiddleware, (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const input = types_1.CounselorRequestSchema.parse(req.body);
    const availableCounselors = await db_1.db
        .select()
        .from(schema_1.users)
        .where((0, drizzle_orm_1.sql) `${schema_1.users.roles} && ARRAY['counselor', 'admin', 'super-admin']::varchar(40)[]`)
        .limit(1);
    const [createdCase] = await db_1.db.insert(schema_1.counselorCases).values({
        userId: req.user.id,
        counselorId: availableCounselors[0]?.id,
        issueCategory: input.issueCategory,
        summary: input.summary,
        riskLevel: input.riskLevel,
        status: availableCounselors.length ? 'assigned' : 'requested',
        source: 'mobile',
        updatedAt: new Date(),
    }).returning();
    socketService_1.SocketService.broadcastDashboardUpdate({ type: 'counselor_case', action: 'created' });
    res.status(201).json({
        success: true,
        data: {
            case: createdCase,
            connected: availableCounselors.length > 0,
            message: availableCounselors.length
                ? 'A counselor has been assigned.'
                : 'No counselor is available right now. A request has been created.',
        },
    });
}));
router.use(auth_1.authMiddleware);
router.get('/cases', (0, errorHandler_1.asyncHandler)(async (req, res) => {
    if (!(0, auth_1.hasAnyRole)(req.user, ['counselor', 'admin', 'super-admin'])) {
        return res.status(403).json({ success: false, error: 'Counselor access required.' });
    }
    const rows = await db_1.db
        .select()
        .from(schema_1.counselorCases)
        .orderBy((0, drizzle_orm_1.desc)(schema_1.counselorCases.createdAt))
        .limit(100);
    res.json({ success: true, data: rows });
}));
router.post('/cases/:id/messages', (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const content = String(req.body.content || '').trim();
    if (!content)
        return res.status(400).json({ success: false, error: 'Message is required.' });
    const [message] = await db_1.db.insert(schema_1.counselingMessages).values({
        caseId: req.params.id,
        senderUserId: req.user.id,
        senderRole: req.user.role,
        content,
    }).returning();
    res.status(201).json({ success: true, data: message });
}));
router.post('/cases/:id/notes', (0, errorHandler_1.asyncHandler)(async (req, res) => {
    if (!(0, auth_1.hasAnyRole)(req.user, ['counselor', 'admin', 'super-admin'])) {
        return res.status(403).json({ success: false, error: 'Counselor access required.' });
    }
    const note = String(req.body.note || '').trim();
    if (!note)
        return res.status(400).json({ success: false, error: 'Note is required.' });
    const [created] = await db_1.db.insert(schema_1.counselorNotes).values({
        caseId: req.params.id,
        counselorId: req.user.id,
        note,
    }).returning();
    res.status(201).json({ success: true, data: created });
}));
router.post('/cases/:id/status', (0, errorHandler_1.asyncHandler)(async (req, res) => {
    if (!(0, auth_1.hasAnyRole)(req.user, ['counselor', 'admin', 'super-admin'])) {
        return res.status(403).json({ success: false, error: 'Counselor access required.' });
    }
    const status = String(req.body.status || '');
    const allowed = ['requested', 'assigned', 'live', 'follow-up', 'resolved', 'emergency'];
    if (!allowed.includes(status))
        return res.status(400).json({ success: false, error: 'Invalid case status.' });
    const [updated] = await db_1.db.update(schema_1.counselorCases).set({
        status: status,
        followUpAt: req.body.followUpAt ? new Date(req.body.followUpAt) : undefined,
        resolvedAt: status === 'resolved' ? new Date() : undefined,
        updatedAt: new Date(),
    }).where((0, drizzle_orm_1.eq)(schema_1.counselorCases.id, req.params.id)).returning();
    socketService_1.SocketService.broadcastDashboardUpdate({ type: 'counselor_case', action: 'status_updated' });
    res.json({ success: true, data: updated });
}));
exports.default = router;
//# sourceMappingURL=counselor.js.map