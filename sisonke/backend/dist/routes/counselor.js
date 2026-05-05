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
const authService_1 = require("../services/authService");
const router = (0, express_1.Router)();
const isAssignedCounselor = async (caseId, userId) => {
    const [item] = await db_1.db.select().from(schema_1.counselorCases).where((0, drizzle_orm_1.eq)(schema_1.counselorCases.id, caseId)).limit(1);
    return item && item.counselorId === userId ? item : null;
};
router.post('/requests', auth_1.authMiddleware, (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const input = types_1.CounselorRequestSchema.parse(req.body);
    const staffUsers = await db_1.db
        .select()
        .from(schema_1.users);
    // Filter users who have counselor or admin roles
    const counselors = [];
    for (const user of staffUsers) {
        const userRoles = await authService_1.AuthService.getUserRoles(user.id);
        const roleNames = userRoles.map(r => r.name.toLowerCase().replace(/_/g, '-'));
        if (roleNames.some((role) => ['counselor', 'admin', 'system-admin', 'super-admin'].includes(role))) {
            counselors.push(user);
        }
    }
    const preferredContactMethod = input.preferredContactMethod;
    const activeStatuses = ['assigned', 'accepted', 'live', 'waiting_for_client', 'callback_requested', 'follow_up'];
    const activeCases = await db_1.db
        .select()
        .from(schema_1.counselorCases);
    const workloadFor = (id) => activeCases.filter((item) => item.counselorId === id && activeStatuses.includes(item.status)).length;
    const matchesCategory = (counselor) => {
        const specs = counselor.counselorSpecializations ?? [];
        return specs.length === 0 || specs.some((spec) => input.issueCategory.toLowerCase().includes(spec.toLowerCase()));
    };
    const availableCounselors = counselors
        .filter((counselor) => counselor.counselorStatus === 'online' || counselor.isOnCall)
        .filter(matchesCategory)
        .sort((a, b) => workloadFor(a.id) - workloadFor(b.id));
    const autoAssign = input.riskLevel === 'high' && availableCounselors.length > 0;
    const initialStatus = preferredContactMethod === 'callback'
        ? 'callback_requested'
        : autoAssign
            ? 'assigned'
            : 'requested';
    const [createdCase] = await db_1.db.insert(schema_1.counselorCases).values({
        userId: req.user.id,
        counselorId: autoAssign ? availableCounselors[0]?.id : undefined,
        issueCategory: input.issueCategory,
        summary: input.summary,
        riskLevel: input.riskLevel,
        status: initialStatus,
        source: preferredContactMethod,
        callbackPhone: input.callbackPhone,
        preferredContactMethod,
        callbackStatus: preferredContactMethod === 'callback' ? 'requested' : undefined,
        updatedAt: new Date(),
    }).returning();
    await db_1.db.insert(schema_1.auditLogs).values({
        actorId: req.user.id,
        action: 'case_created',
        entityType: 'counselor_case',
        entityId: createdCase.id,
        metadata: {
            riskLevel: createdCase.riskLevel,
            status: createdCase.status,
            assignment: autoAssign ? 'auto_high_risk' : 'queue_claiming',
            counselorId: createdCase.counselorId,
        },
    });
    socketService_1.SocketService.emitCaseEvent(createdCase.id, createdCase.userId, 'case:created', { case: createdCase });
    if (createdCase.counselorId) {
        socketService_1.SocketService.emitCaseEvent(createdCase.id, createdCase.userId, 'case:assigned', { case: createdCase });
    }
    if (preferredContactMethod === 'callback') {
        socketService_1.SocketService.emitCaseEvent(createdCase.id, createdCase.userId, 'callback:requested', { case: createdCase });
    }
    if (input.riskLevel === 'high') {
        socketService_1.SocketService.notifyCounselors('case:escalated', { case: createdCase, assignment: autoAssign ? 'auto_assigned' : 'needs_claim' });
    }
    res.status(201).json({
        success: true,
        data: {
            case: createdCase,
            connected: Boolean(createdCase.counselorId),
            message: createdCase.counselorId
                ? 'A counselor has been assigned.'
                : 'Your request has been added to the counselor queue.',
        },
    });
}));
router.use(auth_1.authMiddleware);
router.post('/me/availability', (0, errorHandler_1.asyncHandler)(async (req, res) => {
    if (!(0, auth_1.hasAnyRole)(req.user, ['counselor'])) {
        return res.status(403).json({ success: false, error: 'Counselor access required.' });
    }
    const status = String(req.body.status || 'offline');
    if (!['online', 'busy', 'offline'].includes(status)) {
        return res.status(400).json({ success: false, error: 'Invalid counselor status.' });
    }
    const [updated] = await db_1.db.update(schema_1.users).set({
        counselorStatus: status,
        isOnCall: typeof req.body.isOnCall === 'boolean' ? req.body.isOnCall : undefined,
        lastActiveAt: new Date(),
        updatedAt: new Date(),
    }).where((0, drizzle_orm_1.eq)(schema_1.users.id, req.user.id)).returning();
    await db_1.db.insert(schema_1.auditLogs).values({
        actorId: req.user.id,
        action: 'counselor_availability_changed',
        entityType: 'user',
        entityId: req.user.id,
        metadata: { status, isOnCall: updated?.isOnCall },
    });
    socketService_1.SocketService.notifyStaff(status === 'online' ? 'counselor:online' : 'counselor:offline', {
        counselorId: req.user.id,
        status,
        isOnCall: updated?.isOnCall,
    });
    socketService_1.SocketService.broadcastDashboardUpdate({ type: 'counselor', action: 'availability_changed', counselorId: req.user.id });
    res.json({ success: true, data: updated });
}));
router.get('/my-cases', (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const rows = await db_1.db
        .select()
        .from(schema_1.counselorCases)
        .where((0, drizzle_orm_1.eq)(schema_1.counselorCases.userId, req.user.id))
        .orderBy((0, drizzle_orm_1.desc)(schema_1.counselorCases.createdAt))
        .limit(50);
    res.json({ success: true, data: rows });
}));
router.get('/my-cases/:id', (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const rows = await db_1.db
        .select()
        .from(schema_1.counselorCases)
        .where((0, drizzle_orm_1.sql) `${schema_1.counselorCases.id} = ${req.params.id} and ${schema_1.counselorCases.userId} = ${req.user.id}`)
        .limit(1);
    if (!rows[0])
        return res.status(404).json({ success: false, error: 'Case not found.' });
    res.json({ success: true, data: rows[0] });
}));
router.get('/cases', (0, errorHandler_1.asyncHandler)(async (req, res) => {
    if (!(0, auth_1.hasAnyRole)(req.user, ['counselor', 'admin', 'system-admin', 'super-admin'])) {
        return res.status(403).json({ success: false, error: 'Counselor access required.' });
    }
    const rows = await db_1.db
        .select()
        .from(schema_1.counselorCases)
        .orderBy((0, drizzle_orm_1.desc)(schema_1.counselorCases.createdAt))
        .limit(100);
    const visibleRows = (0, auth_1.hasAnyRole)(req.user, ['admin', 'system-admin', 'super-admin'])
        ? rows.map((item) => ({
            id: item.id,
            issueCategory: item.issueCategory,
            status: item.status,
            riskLevel: item.riskLevel,
            source: item.source,
            counselorId: item.counselorId,
            createdAt: item.createdAt,
            updatedAt: item.updatedAt,
        }))
        : rows.filter((item) => item.counselorId === req.user.id);
    res.json({ success: true, data: visibleRows });
}));
router.post('/cases/:id/messages', (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const [messageCase] = await db_1.db.select().from(schema_1.counselorCases).where((0, drizzle_orm_1.eq)(schema_1.counselorCases.id, req.params.id)).limit(1);
    const isAssigned = messageCase?.counselorId === req.user.id;
    const isClient = messageCase?.userId === req.user.id;
    if (!messageCase || (!isAssigned && !isClient)) {
        return res.status(403).json({ success: false, error: 'You cannot message this case.' });
    }
    const content = String(req.body.content || '').trim();
    const messageType = String(req.body.messageType || 'text');
    const mediaUrl = req.body.mediaUrl ? String(req.body.mediaUrl) : undefined;
    if (!content && !mediaUrl)
        return res.status(400).json({ success: false, error: 'Message or media is required.' });
    const [message] = await db_1.db.insert(schema_1.counselingMessages).values({
        caseId: req.params.id,
        senderUserId: req.user.id,
        senderRole: req.user.role,
        messageType,
        mediaUrl,
        content: content || 'Voice note uploaded',
    }).returning();
    socketService_1.SocketService.emitCaseEvent(req.params.id, messageCase.userId, 'case:message', { caseId: req.params.id, message });
    if (messageType === 'voice_note') {
        socketService_1.SocketService.emitCaseEvent(req.params.id, messageCase.userId, 'voice_note:uploaded', { caseId: req.params.id, message });
    }
    res.status(201).json({ success: true, data: message });
}));
router.post('/cases/:id/callback', (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const callbackPhone = String(req.body.callbackPhone || '').trim();
    if (!callbackPhone)
        return res.status(400).json({ success: false, error: 'Callback phone is required.' });
    const [updated] = await db_1.db.update(schema_1.counselorCases).set({
        status: 'callback_requested',
        callbackPhone,
        callbackStatus: 'requested',
        preferredContactMethod: 'callback',
        updatedAt: new Date(),
    }).where((0, drizzle_orm_1.eq)(schema_1.counselorCases.id, req.params.id)).returning();
    if (!updated)
        return res.status(404).json({ success: false, error: 'Case not found.' });
    socketService_1.SocketService.emitCaseEvent(req.params.id, updated.userId, 'callback:requested', { case: updated });
    socketService_1.SocketService.emitCaseEvent(req.params.id, updated.userId, 'case:status_changed', { case: updated });
    res.json({ success: true, data: updated });
}));
router.post('/cases/:id/notes', (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const caseRow = await isAssignedCounselor(req.params.id, req.user.id);
    if (!caseRow) {
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
    const caseRow = await isAssignedCounselor(req.params.id, req.user.id);
    if (!caseRow && !(0, auth_1.hasAnyRole)(req.user, ['system-admin', 'super-admin'])) {
        return res.status(403).json({ success: false, error: 'Counselor access required.' });
    }
    const status = String(req.body.status || '');
    const allowed = ['requested', 'assigned', 'accepted', 'live', 'waiting_for_client', 'callback_requested', 'follow_up', 'resolved', 'escalated', 'closed'];
    if (!allowed.includes(status))
        return res.status(400).json({ success: false, error: 'Invalid case status.' });
    const [updated] = await db_1.db.update(schema_1.counselorCases).set({
        status: status,
        followUpAt: req.body.followUpAt ? new Date(req.body.followUpAt) : undefined,
        resolvedAt: status === 'resolved' || status === 'closed' ? new Date() : undefined,
        updatedAt: new Date(),
    }).where((0, drizzle_orm_1.eq)(schema_1.counselorCases.id, req.params.id)).returning();
    const event = status === 'escalated'
        ? 'case:escalated'
        : status === 'accepted'
            ? 'case:accepted'
            : 'case:status_changed';
    socketService_1.SocketService.emitCaseEvent(req.params.id, updated?.userId, event, { case: updated });
    res.json({ success: true, data: updated });
}));
exports.default = router;
//# sourceMappingURL=counselor.js.map