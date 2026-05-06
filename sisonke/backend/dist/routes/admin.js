"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const bcryptjs_1 = __importDefault(require("bcryptjs"));
const drizzle_orm_1 = require("drizzle-orm");
const db_1 = require("../db");
const authService_1 = require("../services/authService");
const schema_1 = require("../db/schema");
const auth_1 = require("../middleware/auth");
const errorHandler_1 = require("../middleware/errorHandler");
const types_1 = require("../types");
const riskService_1 = require("../services/riskService");
const zimbabweRagKnowledge_1 = require("../data/zimbabweRagKnowledge");
const socketService_1 = require("../services/socketService");
const router = (0, express_1.Router)();
router.use(auth_1.authMiddleware);
const roleList = (user) => (user?.roles?.length ? user.roles : ['guest']).map((role) => String(role).toLowerCase().replace(/_/g, '-'));
const hasAny = (user, roles) => {
    const current = roleList(user);
    return roles.some((role) => current.includes(role));
};
const requireRoles = (roles) => {
    return (req, res, next) => {
        if (!hasAny(req.user, roles)) {
            return res.status(403).json({ success: false, error: 'Insufficient permissions' });
        }
        next();
    };
};
const canSeePrivateCase = (user, item) => {
    return hasAny(user, ['counselor']) && item.counselorId === user.id;
};
const sanitizeCaseForUser = (user, item) => {
    if (canSeePrivateCase(user, item))
        return item;
    return {
        id: item.id,
        issueCategory: item.issueCategory,
        status: item.status,
        riskLevel: item.riskLevel,
        source: item.source,
        preferredContactMethod: item.preferredContactMethod,
        callbackStatus: item.callbackStatus,
        counselorId: item.counselorId,
        createdAt: item.createdAt,
        updatedAt: item.updatedAt,
        followUpAt: item.followUpAt,
        resolvedAt: item.resolvedAt,
    };
};
router.get('/me', (0, errorHandler_1.asyncHandler)(async (req, res) => {
    res.json({ success: true, data: { user: req.user } });
}));
router.get('/analytics/health', requireRoles(['admin', 'super-admin', 'system-admin', 'analyst']), (0, errorHandler_1.asyncHandler)(async (_req, res) => {
    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);
    const stats = await db_1.db.select({
        date: (0, drizzle_orm_1.sql) `DATE(${schema_1.analyticsEvents.occurredAt})`,
        count: (0, drizzle_orm_1.count)()
    })
        .from(schema_1.analyticsEvents)
        .where((0, drizzle_orm_1.gte)(schema_1.analyticsEvents.occurredAt, sevenDaysAgo))
        .groupBy((0, drizzle_orm_1.sql) `DATE(${schema_1.analyticsEvents.occurredAt})`)
        .orderBy((0, drizzle_orm_1.sql) `DATE(${schema_1.analyticsEvents.occurredAt})`);
    res.json({ success: true, data: stats });
}));
router.get('/overview', auth_1.dashboardAccess, (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const isAdmin = hasAny(req.user, ['admin', 'system-admin', 'super-admin']);
    const results = await Promise.all([
        db_1.db.select({ value: (0, drizzle_orm_1.count)() }).from(schema_1.users),
        db_1.db.select({ value: (0, drizzle_orm_1.count)() }).from(schema_1.resources).where((0, drizzle_orm_1.isNull)(schema_1.resources.deletedAt)),
        db_1.db.select({ value: (0, drizzle_orm_1.count)() }).from(schema_1.emergencyContacts).where((0, drizzle_orm_1.isNull)(schema_1.emergencyContacts.deletedAt)),
        db_1.db.select({ value: (0, drizzle_orm_1.count)() }).from(schema_1.questions).where((0, drizzle_orm_1.isNull)(schema_1.questions.deletedAt)),
        isAdmin
            ? db_1.db.select({ value: (0, drizzle_orm_1.count)() }).from(schema_1.counselorCases)
            : db_1.db.select({ value: (0, drizzle_orm_1.count)() }).from(schema_1.counselorCases).where((0, drizzle_orm_1.eq)(schema_1.counselorCases.counselorId, req.user.id)),
        db_1.db.select({ value: (0, drizzle_orm_1.count)() }).from(schema_1.chatbotSessions),
        db_1.db.select({ value: (0, drizzle_orm_1.count)() }).from(schema_1.communityPosts).where((0, drizzle_orm_1.eq)(schema_1.communityPosts.status, 'pending')),
        isAdmin
            ? db_1.db.select({ value: (0, drizzle_orm_1.count)() }).from(schema_1.counselorCases).where((0, drizzle_orm_1.eq)(schema_1.counselorCases.riskLevel, 'high'))
            : db_1.db.select({ value: (0, drizzle_orm_1.count)() }).from(schema_1.counselorCases).where((0, drizzle_orm_1.and)((0, drizzle_orm_1.eq)(schema_1.counselorCases.counselorId, req.user.id), (0, drizzle_orm_1.eq)(schema_1.counselorCases.riskLevel, 'high'))),
        db_1.db.select().from(schema_1.analyticsEvents).orderBy((0, drizzle_orm_1.desc)(schema_1.analyticsEvents.occurredAt)).limit(10),
    ]);
    const userCount = Number(results[0][0]?.value ?? 0);
    const resourceCount = Number(results[1][0]?.value ?? 0);
    const contactCount = Number(results[2][0]?.value ?? 0);
    const questionCount = Number(results[3][0]?.value ?? 0);
    const caseCount = Number(results[4][0]?.value ?? 0);
    const sessionCount = Number(results[5][0]?.value ?? 0);
    const pendingPostsCount = Number(results[6][0]?.value ?? 0);
    const highRiskCasesCount = Number(results[7][0]?.value ?? 0);
    const latestEvents = results[8];
    res.json({
        success: true,
        data: {
            users: { total: isAdmin ? userCount : 1 }, // If counselor, just show '1' (themselves)
            resources: { total: resourceCount },
            emergencyContacts: { total: contactCount },
            questions: { total: questionCount },
            counselorCases: {
                total: caseCount,
                highRisk: highRiskCasesCount
            },
            chatbotSessions: { total: sessionCount },
            communityPosts: { pending: pendingPostsCount },
            latestEvents: isAdmin ? latestEvents : [] // Hide system events from counselors
        },
    });
}));
router.get('/community-posts', requireRoles(['admin', 'super-admin', 'system-admin', 'moderator']), (0, errorHandler_1.asyncHandler)(async (_req, res) => {
    const rows = await db_1.db
        .select()
        .from(schema_1.communityPosts)
        .orderBy((0, drizzle_orm_1.desc)(schema_1.communityPosts.createdAt))
        .limit(100);
    res.json({ success: true, data: rows });
}));
router.post('/community-posts/:id/moderate', requireRoles(['admin', 'super-admin', 'system-admin', 'moderator']), (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const status = String(req.body.status || '');
    if (!['approved', 'removed'].includes(status)) {
        return res.status(400).json({ success: false, error: 'Status must be approved or removed.' });
    }
    const [updated] = await db_1.db.update(schema_1.communityPosts).set({
        status: status,
        moderationReason: req.body.reason,
        reviewedAt: new Date(),
        reviewedBy: req.user.id,
        removedAt: status === 'removed' ? new Date() : undefined,
    }).where((0, drizzle_orm_1.eq)(schema_1.communityPosts.id, req.params.id)).returning();
    if (!updated)
        return res.status(404).json({ success: false, error: 'Post not found' });
    socketService_1.SocketService.broadcastDashboardUpdate({ type: 'community_post', action: 'moderated' });
    res.json({ success: true, data: updated });
}));
router.get('/reports', requireRoles(['admin', 'super-admin', 'system-admin', 'moderator', 'analyst']), (0, errorHandler_1.asyncHandler)(async (_req, res) => {
    const rows = await db_1.db
        .select()
        .from(schema_1.reports)
        .orderBy((0, drizzle_orm_1.desc)(schema_1.reports.createdAt))
        .limit(100);
    res.json({ success: true, data: rows });
}));
router.post('/reports/:id/status', requireRoles(['admin', 'super-admin', 'system-admin', 'moderator']), (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const status = String(req.body.status || '');
    if (!['pending', 'reviewed', 'resolved', 'dismissed'].includes(status)) {
        return res.status(400).json({ success: false, error: 'Invalid report status' });
    }
    const [updated] = await db_1.db.update(schema_1.reports).set({
        status: status,
        reviewedAt: new Date(),
        reviewedBy: req.user.id,
    }).where((0, drizzle_orm_1.eq)(schema_1.reports.id, req.params.id)).returning();
    if (!updated)
        return res.status(404).json({ success: false, error: 'Report not found' });
    socketService_1.SocketService.broadcastDashboardUpdate({ type: 'report', action: 'resolved' });
    res.json({ success: true, data: updated });
}));
router.get('/resources', auth_1.dashboardAccess, (0, errorHandler_1.asyncHandler)(async (_req, res) => {
    const rows = await db_1.db
        .select()
        .from(schema_1.resources)
        .where((0, drizzle_orm_1.isNull)(schema_1.resources.deletedAt))
        .orderBy((0, drizzle_orm_1.desc)(schema_1.resources.updatedAt), (0, drizzle_orm_1.desc)(schema_1.resources.createdAt));
    res.json({ success: true, data: rows });
}));
router.post('/resources', requireRoles(['admin', 'super-admin', 'system-admin', 'content-manager', 'content-admin']), (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const input = types_1.CreateResourceSchema.parse(req.body);
    const isPublished = input.status === 'published';
    const [created] = await db_1.db.insert(schema_1.resources).values({
        ...input,
        authorId: req.user.id,
        isPublished,
        publishedAt: isPublished ? new Date() : null,
        updatedAt: new Date(),
    }).returning();
    res.status(201).json({ success: true, data: created });
}));
router.put('/resources/:id', requireRoles(['admin', 'super-admin', 'system-admin', 'content-manager', 'content-admin']), (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const input = types_1.UpdateResourceSchema.parse(req.body);
    const isPublishing = input.status === 'published';
    const [updated] = await db_1.db
        .update(schema_1.resources)
        .set({
        ...input,
        isPublished: input.status ? input.status === 'published' : undefined,
        publishedAt: isPublishing ? new Date() : undefined,
        updatedAt: new Date(),
    })
        .where((0, drizzle_orm_1.eq)(schema_1.resources.id, req.params.id))
        .returning();
    if (!updated) {
        return res.status(404).json({ success: false, error: 'Resource not found' });
    }
    res.json({ success: true, data: updated });
}));
router.post('/resources/:id/publish', requireRoles(['admin', 'super-admin', 'system-admin', 'content-manager', 'content-admin']), (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const [updated] = await db_1.db
        .update(schema_1.resources)
        .set({ status: 'published', isPublished: true, publishedAt: new Date(), updatedAt: new Date() })
        .where((0, drizzle_orm_1.eq)(schema_1.resources.id, req.params.id))
        .returning();
    if (!updated) {
        return res.status(404).json({ success: false, error: 'Resource not found' });
    }
    res.json({ success: true, data: updated });
}));
router.post('/resources/:id/archive', requireRoles(['admin', 'super-admin', 'system-admin', 'content-manager', 'content-admin']), (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const [updated] = await db_1.db
        .update(schema_1.resources)
        .set({ status: 'archived', isPublished: false, deletedAt: new Date(), updatedAt: new Date() })
        .where((0, drizzle_orm_1.eq)(schema_1.resources.id, req.params.id))
        .returning();
    if (!updated) {
        return res.status(404).json({ success: false, error: 'Resource not found' });
    }
    res.json({ success: true, data: updated });
}));
router.get('/emergency-contacts', auth_1.dashboardAccess, (0, errorHandler_1.asyncHandler)(async (_req, res) => {
    const rows = await db_1.db
        .select()
        .from(schema_1.emergencyContacts)
        .where((0, drizzle_orm_1.isNull)(schema_1.emergencyContacts.deletedAt))
        .orderBy(schema_1.emergencyContacts.category, schema_1.emergencyContacts.name);
    res.json({ success: true, data: rows });
}));
router.post('/emergency-contacts', requireRoles(['admin', 'super-admin', 'system-admin', 'content-manager', 'content-admin']), (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const input = types_1.CreateEmergencyContactSchema.parse(req.body);
    const isPublished = input.status === 'published';
    const [created] = await db_1.db.insert(schema_1.emergencyContacts).values({
        ...input,
        isActive: input.isActive,
        publishedAt: isPublished ? new Date() : null,
        updatedAt: new Date(),
    }).returning();
    res.status(201).json({ success: true, data: created });
}));
router.put('/emergency-contacts/:id', requireRoles(['admin', 'super-admin', 'system-admin', 'content-manager', 'content-admin']), (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const input = types_1.UpdateEmergencyContactSchema.parse(req.body);
    const [updated] = await db_1.db
        .update(schema_1.emergencyContacts)
        .set({
        ...input,
        publishedAt: input.status === 'published' ? new Date() : undefined,
        updatedAt: new Date(),
    })
        .where((0, drizzle_orm_1.eq)(schema_1.emergencyContacts.id, req.params.id))
        .returning();
    if (!updated) {
        return res.status(404).json({ success: false, error: 'Emergency contact not found' });
    }
    res.json({ success: true, data: updated });
}));
router.get('/analytics', requireRoles(['admin', 'super-admin', 'system-admin', 'analyst']), (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const days = Number(req.query.days || 30);
    const since = new Date(Date.now() - Math.max(1, Math.min(days, 365)) * 24 * 60 * 60 * 1000);
    const [rows, profiles, moodRows, chatRows, cases] = await Promise.all([
        db_1.db.select().from(schema_1.analyticsEvents).where((0, drizzle_orm_1.gte)(schema_1.analyticsEvents.occurredAt, since)),
        db_1.db.select().from(schema_1.userProfiles),
        db_1.db.select().from(schema_1.moodCheckins).where((0, drizzle_orm_1.gte)(schema_1.moodCheckins.createdAt, since)),
        db_1.db.select().from(schema_1.chatbotSessions).where((0, drizzle_orm_1.gte)(schema_1.chatbotSessions.createdAt, since)),
        db_1.db.select().from(schema_1.counselorCases).where((0, drizzle_orm_1.gte)(schema_1.counselorCases.createdAt, since)),
    ]);
    const byEvent = rows.reduce((acc, event) => {
        acc[event.event] = (acc[event.event] || 0) + 1;
        return acc;
    }, {});
    // Time Series Aggregation
    const timeSeries = {};
    for (let i = 0; i < days; i++) {
        const d = new Date(Date.now() - i * 24 * 60 * 60 * 1000).toISOString().split('T')[0];
        timeSeries[d] = { appUse: 0, urgent: 0 };
    }
    rows.forEach((event) => {
        if (event.occurredAt) {
            const d = event.occurredAt.toISOString().split('T')[0];
            if (timeSeries[d])
                timeSeries[d].appUse++;
        }
    });
    cases.forEach((c) => {
        if (c.createdAt) {
            const d = c.createdAt.toISOString().split('T')[0];
            if (timeSeries[d] && (c.riskLevel === 'high' || c.status === 'escalated')) {
                timeSeries[d].urgent++;
            }
        }
    });
    const timeSeriesList = Object.entries(timeSeries)
        .map(([date, counts]) => ({ date, ...counts }))
        .sort((a, b) => a.date.localeCompare(b.date));
    const countByKey = (items, picker) => items.reduce((acc, item) => {
        const key = picker(item);
        if (key)
            acc[key] = (acc[key] || 0) + 1;
        return acc;
    }, {});
    res.json({
        success: true,
        data: {
            total: rows.length,
            byEvent,
            timeSeries: timeSeriesList,
            ageRangeDistribution: countByKey(profiles, (profile) => profile.ageGroup),
            genderDistribution: countByKey(profiles, (profile) => profile.gender || 'unspecified'),
            moodTrendsByMood: countByKey(moodRows, (mood) => mood.mood),
            chatbotSessions: chatRows.length,
            counselorEscalations: cases.filter((item) => item.source === 'chatbot' || item.riskLevel === 'high').length,
            issueCategories: countByKey(cases, (item) => item.issueCategory),
        },
    });
}));
router.get('/counselor-cases', auth_1.dashboardAccess, (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const isAdmin = hasAny(req.user, ['admin', 'system-admin', 'super-admin']);
    let query = db_1.db
        .select()
        .from(schema_1.counselorCases);
    if (!isAdmin) {
        // @ts-ignore - Ensure counselorId type compatibility
        query = query.where((0, drizzle_orm_1.eq)(schema_1.counselorCases.counselorId, req.user.id));
    }
    const rows = await query.orderBy((0, drizzle_orm_1.desc)(schema_1.counselorCases.createdAt)).limit(100);
    const visibleRows = rows.map((item) => sanitizeCaseForUser(req.user, item));
    res.json({ success: true, data: visibleRows });
}));
router.get('/counselor-operations', auth_1.dashboardAccess, (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const [cases, counselors, auditRows] = await Promise.all([
        db_1.db.select().from(schema_1.counselorCases).orderBy((0, drizzle_orm_1.desc)(schema_1.counselorCases.createdAt)).limit(100),
        db_1.db.select().from(schema_1.users),
        db_1.db
            .select()
            .from(schema_1.auditLogs)
            .where((0, drizzle_orm_1.eq)(schema_1.auditLogs.entityType, 'counselor_case'))
            .orderBy((0, drizzle_orm_1.desc)(schema_1.auditLogs.createdAt))
            .limit(50),
    ]);
    const visibleCases = hasAny(req.user, ['admin', 'system-admin', 'super-admin'])
        ? cases.map((item) => sanitizeCaseForUser(req.user, item))
        : cases
            .filter((item) => item.counselorId === req.user.id)
            .map((item) => sanitizeCaseForUser(req.user, item));
    const activeStatuses = ['assigned', 'accepted', 'live', 'waiting_for_client', 'callback_requested', 'follow_up'];
    const staffRoles = ['counselor', 'admin', 'super-admin', 'system-admin'];
    // Filter users who have counselor or admin roles using new role system
    const staffUsers = [];
    for (const user of counselors) {
        const userRoles = await authService_1.AuthService.getUserRoles(user.id);
        const roleNames = userRoles.map(r => r.name.toLowerCase().replace(/_/g, '-'));
        if (roleNames.some((role) => staffRoles.includes(role))) {
            staffUsers.push(user);
        }
    }
    const workloadFor = (id) => cases.filter((item) => item.counselorId === id && activeStatuses.includes(item.status)).length;
    const operationsCounselors = staffUsers.map((counselor) => ({
        id: counselor.id,
        email: counselor.email,
        status: counselor.counselorStatus || 'offline',
        isOnCall: counselor.isOnCall,
        specializations: counselor.counselorSpecializations || [],
        workload: workloadFor(counselor.id),
        lastActiveAt: counselor.lastActiveAt,
    }));
    const metrics = {
        activeCases: visibleCases.filter((item) => activeStatuses.includes(item.status)).length,
        highRiskAlerts: visibleCases.filter((item) => item.riskLevel === 'high' || item.status === 'escalated').length,
        counselorsOnline: operationsCounselors.filter((item) => item.status === 'online').length,
        pendingRequests: visibleCases.filter((item) => item.status === 'requested').length,
    };
    res.json({
        success: true,
        data: {
            metrics,
            cases: visibleCases,
            counselors: operationsCounselors,
            auditLogs: auditRows,
            assignmentPolicy: {
                low: 'queue_claiming',
                medium: 'queue_claiming',
                high: 'auto_assign_lowest_workload_available_or_on_call',
            },
        },
    });
}));
router.post('/counselor-cases/:id/assign', auth_1.dashboardAccess, (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const counselorId = String(req.body.counselorId || '').trim();
    if (!counselorId)
        return res.status(400).json({ success: false, error: 'Counselor is required' });
    const [existing] = await db_1.db.select().from(schema_1.counselorCases).where((0, drizzle_orm_1.eq)(schema_1.counselorCases.id, req.params.id)).limit(1);
    if (!existing)
        return res.status(404).json({ success: false, error: 'Case not found' });
    const canReassign = hasAny(req.user, ['admin', 'system-admin', 'super-admin'])
        || (hasAny(req.user, ['counselor']) && existing.counselorId === req.user.id);
    if (!canReassign) {
        return res.status(403).json({ success: false, error: 'You cannot reassign this case' });
    }
    const [updated] = await db_1.db.update(schema_1.counselorCases).set({
        counselorId,
        status: 'assigned',
        updatedAt: new Date(),
    }).where((0, drizzle_orm_1.eq)(schema_1.counselorCases.id, req.params.id)).returning();
    if (!updated)
        return res.status(404).json({ success: false, error: 'Case not found' });
    await db_1.db.insert(schema_1.auditLogs).values({
        actorId: req.user.id,
        action: 'case_assigned',
        entityType: 'counselor_case',
        entityId: updated.id,
        metadata: { counselorId, previousStatus: req.body.previousStatus },
    });
    socketService_1.SocketService.emitCaseEvent(req.params.id, updated.userId, 'case:assigned', { case: updated });
    res.json({ success: true, data: updated });
}));
router.post('/counselors/:id/availability', auth_1.dashboardAccess, (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const status = String(req.body.status || 'offline');
    if (!['online', 'busy', 'offline'].includes(status)) {
        return res.status(400).json({ success: false, error: 'Invalid counselor status' });
    }
    const updateData = {
        lastActiveAt: new Date(),
        updatedAt: new Date(),
    };
    try {
        await db_1.db.update(schema_1.users).set({
            ...updateData,
            counselorStatus: status,
            isOnCall: typeof req.body.isOnCall === 'boolean' ? req.body.isOnCall : undefined,
            counselorSpecializations: Array.isArray(req.body.specializations) ? req.body.specializations : undefined,
        }).where((0, drizzle_orm_1.eq)(schema_1.users.id, req.params.id));
    }
    catch (err) {
        await db_1.db.update(schema_1.users).set(updateData).where((0, drizzle_orm_1.eq)(schema_1.users.id, req.params.id));
    }
    const [updated] = await db_1.db.select({
        id: schema_1.users.id,
        email: schema_1.users.email,
    }).from(schema_1.users).where((0, drizzle_orm_1.eq)(schema_1.users.id, req.params.id)).limit(1);
    if (!updated)
        return res.status(404).json({ success: false, error: 'Counselor not found' });
    const isOnCall = typeof req.body.isOnCall === 'boolean' ? req.body.isOnCall : false;
    const specializations = Array.isArray(req.body.specializations) ? req.body.specializations : [];
    await db_1.db.insert(schema_1.auditLogs).values({
        actorId: req.user.id,
        action: 'counselor_availability_changed',
        entityType: 'user',
        entityId: updated.id,
        metadata: { status, isOnCall, specializations },
    });
    socketService_1.SocketService.notifyStaff(status === 'online' ? 'counselor:online' : 'counselor:offline', {
        counselorId: updated.id,
        status,
        isOnCall,
    });
    socketService_1.SocketService.broadcastDashboardUpdate({ type: 'counselor', action: 'availability_changed', counselorId: updated.id });
    res.json({ success: true, data: updated });
}));
router.post('/counselor-cases/:id/status', auth_1.dashboardAccess, (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const status = String(req.body.status || '');
    const allowed = [
        'requested',
        'assigned',
        'accepted',
        'live',
        'waiting_for_client',
        'callback_requested',
        'follow_up',
        'resolved',
        'escalated',
        'closed',
    ];
    if (!allowed.includes(status))
        return res.status(400).json({ success: false, error: 'Invalid status' });
    const [existing] = await db_1.db.select().from(schema_1.counselorCases).where((0, drizzle_orm_1.eq)(schema_1.counselorCases.id, req.params.id)).limit(1);
    if (!existing)
        return res.status(404).json({ success: false, error: 'Case not found' });
    const canManageCase = hasAny(req.user, ['system-admin', 'super-admin'])
        || (hasAny(req.user, ['counselor']) && existing.counselorId === req.user.id);
    if (!canManageCase) {
        return res.status(403).json({ success: false, error: 'Only the assigned counselor can manage private case status' });
    }
    const [updated] = await db_1.db.update(schema_1.counselorCases).set({
        status: status,
        followUpAt: req.body.followUpAt ? new Date(req.body.followUpAt) : undefined,
        resolvedAt: status === 'resolved' || status === 'closed' ? new Date() : undefined,
        updatedAt: new Date(),
    }).where((0, drizzle_orm_1.eq)(schema_1.counselorCases.id, req.params.id)).returning();
    if (!updated)
        return res.status(404).json({ success: false, error: 'Case not found' });
    await db_1.db.insert(schema_1.auditLogs).values({
        actorId: req.user.id,
        action: status === 'escalated' ? 'case_escalated' : status === 'resolved' || status === 'closed' ? 'case_closed' : 'case_status_changed',
        entityType: 'counselor_case',
        entityId: updated.id,
        metadata: { status, followUpAt: req.body.followUpAt },
    });
    const event = status === 'escalated'
        ? 'case:escalated'
        : status === 'accepted'
            ? 'case:accepted'
            : 'case:status_changed';
    socketService_1.SocketService.emitCaseEvent(req.params.id, updated?.userId, event, { case: updated });
    res.json({ success: true, data: updated });
}));
router.post('/counselor-cases/:id/notes', auth_1.dashboardAccess, (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const note = String(req.body.note || '').trim();
    if (!note)
        return res.status(400).json({ success: false, error: 'Note is required' });
    const [existing] = await db_1.db.select().from(schema_1.counselorCases).where((0, drizzle_orm_1.eq)(schema_1.counselorCases.id, req.params.id)).limit(1);
    if (!existing)
        return res.status(404).json({ success: false, error: 'Case not found' });
    if (!hasAny(req.user, ['counselor']) || existing.counselorId !== req.user.id) {
        return res.status(403).json({ success: false, error: 'Only the assigned counselor can add private notes' });
    }
    await db_1.db.insert(schema_1.securityLogs).values({
        userId: req.user.id,
        event: 'counselor_note_added',
        ipAddress: req.ip,
        userAgent: req.get('user-agent'),
        metadata: { caseId: req.params.id },
    });
    await db_1.db.insert(schema_1.auditLogs).values({
        actorId: req.user.id,
        action: 'case_note_added',
        entityType: 'counselor_case',
        entityId: req.params.id,
        metadata: { noteLength: note.length },
    });
    res.status(201).json({ success: true });
}));
router.get('/cms-content', auth_1.dashboardAccess, (0, errorHandler_1.asyncHandler)(async (_req, res) => {
    const rows = await db_1.db.select().from(schema_1.cmsContent).orderBy((0, drizzle_orm_1.desc)(schema_1.cmsContent.createdAt)).limit(100);
    res.json({ success: true, data: rows });
}));
router.get('/faqs', auth_1.dashboardAccess, (0, errorHandler_1.asyncHandler)(async (_req, res) => {
    res.json({
        success: true,
        data: zimbabweRagKnowledge_1.goldFaqCards.map((card) => ({
            id: card.id,
            question: card.title,
            goldAnswer: card.content,
            topic: card.category,
            riskLevel: card.riskLevel,
            language: 'en',
            tags: card.tags,
            status: 'published',
        })),
    });
}));
router.get('/safety-rules', auth_1.dashboardAccess, (0, errorHandler_1.asyncHandler)(async (_req, res) => {
    res.json({
        success: true,
        data: zimbabweRagKnowledge_1.safetyRules.map((rule, index) => ({
            id: `${rule.route}-${index}`,
            route: rule.route,
            risk: rule.risk,
            terms: rule.terms,
            responseTemplate: rule.risk === 'red'
                ? 'Stop normal AI response. Show local emergency contacts and route to a human supporter immediately.'
                : 'Offer grounding, check safety, and suggest human support if distress continues.',
            active: true,
        })),
    });
}));
router.post('/safety-rules/test', auth_1.dashboardAccess, (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const message = String(req.body.message || '');
    const detection = (0, riskService_1.detectRisk)(message);
    res.json({
        success: true,
        data: {
            detected: detection.level === 'high',
            riskLevel: detection.level,
            route: detection.route,
            rule: detection.route ? { route: detection.route } : null,
        },
    });
}));
router.post('/cms-content', requireRoles(['admin', 'super-admin', 'system-admin', 'content-manager', 'content-admin']), (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const input = types_1.CmsContentSchema.parse(req.body);
    const [created] = await db_1.db.insert(schema_1.cmsContent).values({
        ...input,
        createdBy: req.user.id,
        publishedAt: input.status === 'published' ? new Date() : undefined,
        updatedAt: new Date(),
    }).returning();
    res.status(201).json({ success: true, data: created });
}));
router.put('/cms-content/:id', requireRoles(['admin', 'super-admin', 'system-admin', 'content-manager', 'content-admin']), (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const input = types_1.CmsContentSchema.partial().parse(req.body);
    const [updated] = await db_1.db.update(schema_1.cmsContent).set({
        ...input,
        publishedAt: input.status === 'published' ? new Date() : undefined,
        updatedAt: new Date(),
    }).where((0, drizzle_orm_1.eq)(schema_1.cmsContent.id, req.params.id)).returning();
    if (!updated)
        return res.status(404).json({ success: false, error: 'CMS content not found' });
    res.json({ success: true, data: updated });
}));
router.get('/users', auth_1.adminOnly, (0, errorHandler_1.asyncHandler)(async (_req, res) => {
    const rows = await db_1.db
        .select({
        id: schema_1.users.id,
        email: schema_1.users.email,
        name: schema_1.users.name,
        avatarUrl: schema_1.users.avatarUrl,
        isGuest: schema_1.users.isGuest,
        isSuspended: schema_1.users.isSuspended,
        suspensionReason: schema_1.users.suspensionReason,
        mustChangePassword: schema_1.users.mustChangePassword,
        createdAt: schema_1.users.createdAt,
        lastActiveAt: schema_1.users.lastActiveAt,
    })
        .from(schema_1.users)
        .orderBy((0, drizzle_orm_1.desc)(schema_1.users.createdAt))
        .limit(100);
    const usersWithRoles = await Promise.all(rows.map(async (user) => {
        const userRoles = await authService_1.AuthService.getUserRoles(user.id);
        const roleNames = userRoles.map(r => r.name);
        return {
            id: user.id,
            email: user.email,
            name: user.name,
            avatarUrl: user.avatarUrl,
            roles: roleNames,
            isGuest: user.isGuest,
            isSuspended: user.isSuspended,
            suspensionReason: user.suspensionReason,
            mustChangePassword: user.mustChangePassword,
            createdAt: user.createdAt,
            lastActiveAt: user.lastActiveAt,
        };
    }));
    res.json({
        success: true,
        data: usersWithRoles,
    });
}));
const primaryRoleFor = (roles) => {
    if (roles.includes('admin') || roles.includes('super-admin') || roles.includes('system-admin'))
        return 'admin';
    if (roles.includes('counselor'))
        return 'counselor';
    if (roles.includes('moderator'))
        return 'moderator';
    if (roles.includes('user'))
        return 'user';
    return 'guest';
};
router.post('/users', auth_1.superAdminOnly, (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const input = types_1.CreateAdminUserSchema.parse(req.body);
    const email = input.email.trim().toLowerCase();
    const existing = await db_1.db.select().from(schema_1.users).where((0, drizzle_orm_1.eq)(schema_1.users.email, email)).limit(1);
    if (existing.length) {
        return res.status(409).json({ success: false, error: 'A user with this email already exists.' });
    }
    const passwordHash = await bcryptjs_1.default.hash(input.password, 12);
    const primaryRole = primaryRoleFor(input.roles);
    const [created] = await db_1.db.insert(schema_1.users).values({
        email,
        passwordHash,
        name: input.name,
        avatarUrl: input.avatarUrl,
        isGuest: input.isGuest,
        mustChangePassword: input.mustChangePassword,
        updatedAt: new Date(),
    }).returning();
    // Assign roles to the new user
    if (input.roles && input.roles.length > 0) {
        for (const roleName of input.roles) {
            await authService_1.AuthService.assignRole(created.id, roleName, req.user.id);
        }
    }
    await db_1.db.insert(schema_1.securityLogs).values({
        userId: req.user.id,
        event: 'admin_user_created',
        ipAddress: req.ip,
        userAgent: req.get('user-agent'),
        metadata: { targetUserId: created.id, roles: input.roles },
    });
    res.status(201).json({
        success: true,
        data: {
            id: created.id,
            email: created.email,
            name: created.name,
            avatarUrl: created.avatarUrl,
            roles: input.roles,
            isGuest: created.isGuest,
            mustChangePassword: created.mustChangePassword,
            createdAt: created.createdAt,
        },
    });
}));
router.put('/users/:id', auth_1.superAdminOnly, (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const input = types_1.UpdateAdminUserSchema.parse(req.body);
    if (req.params.id === req.user.id && input.roles && !input.roles.some((role) => ['super-admin', 'system-admin'].includes(role))) {
        return res.status(400).json({ success: false, error: 'You cannot remove your own top-level access.' });
    }
    // Update roles using new role system if provided
    if (input.roles && input.roles.length > 0) {
        // First, remove all existing roles
        await db_1.db.delete(schema_1.userRoles).where((0, drizzle_orm_1.eq)(schema_1.userRoles.userId, req.params.id));
        // Then assign new roles
        for (const roleName of input.roles) {
            await authService_1.AuthService.assignRole(req.params.id, roleName, req.user.id);
        }
    }
    const [updated] = await db_1.db.update(schema_1.users).set({
        isGuest: input.roles ? (input.roles.includes('guest') && input.roles.length === 1) : undefined,
        email: input.email ? input.email.trim().toLowerCase() : undefined,
        name: input.name !== undefined ? input.name : undefined,
        avatarUrl: input.avatarUrl !== undefined ? input.avatarUrl : undefined,
        isSuspended: input.isSuspended,
        suspensionReason: input.isSuspended ? input.suspensionReason || 'Paused by an admin' : input.isSuspended === false ? null : undefined,
        suspendedAt: input.isSuspended === true ? new Date() : input.isSuspended === false ? null : undefined,
        mustChangePassword: input.mustChangePassword,
        updatedAt: new Date(),
    }).where((0, drizzle_orm_1.eq)(schema_1.users.id, req.params.id)).returning();
    if (!updated) {
        return res.status(404).json({ success: false, error: 'User not found.' });
    }
    await db_1.db.insert(schema_1.securityLogs).values({
        userId: req.user.id,
        event: 'user_updated',
        ipAddress: req.ip,
        userAgent: req.get('user-agent'),
        metadata: { targetUserId: req.params.id },
    });
    // Fetch full user with roles for the response
    const userRolesList = await authService_1.AuthService.getUserRoles(updated.id);
    const roleNames = userRolesList.map(r => r.name);
    res.json({
        success: true,
        data: {
            id: updated.id,
            email: updated.email,
            name: updated.name,
            avatarUrl: updated.avatarUrl,
            roles: roleNames,
            isGuest: updated.isGuest,
            isSuspended: updated.isSuspended,
            suspensionReason: updated.suspensionReason,
            mustChangePassword: updated.mustChangePassword,
            updatedAt: updated.updatedAt,
        },
    });
}));
router.put('/users/:id/password', auth_1.superAdminOnly, (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const input = types_1.AdminSetPasswordSchema.parse(req.body);
    const passwordHash = await bcryptjs_1.default.hash(input.password, 12);
    const [updated] = await db_1.db.update(schema_1.users).set({
        passwordHash,
        mustChangePassword: input.mustChangePassword,
        updatedAt: new Date(),
    }).where((0, drizzle_orm_1.eq)(schema_1.users.id, req.params.id)).returning();
    if (!updated) {
        return res.status(404).json({ success: false, error: 'User not found.' });
    }
    await db_1.db.insert(schema_1.securityLogs).values({
        userId: req.user.id,
        event: 'user_password_set',
        ipAddress: req.ip,
        userAgent: req.get('user-agent'),
        metadata: { targetUserId: req.params.id, mustChangePassword: input.mustChangePassword },
    });
    res.json({ success: true, data: { id: updated.id, mustChangePassword: updated.mustChangePassword } });
}));
router.put('/users/:id/roles', auth_1.superAdminOnly, (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const input = types_1.UpdateUserRolesSchema.parse(req.body);
    if (req.params.id === req.user.id && !input.roles.some((role) => ['super-admin', 'system-admin'].includes(role))) {
        return res.status(400).json({ success: false, error: 'You cannot remove your own top-level role.' });
    }
    const primaryRole = primaryRoleFor(input.roles);
    // Update user properties (excluding roles which are now managed separately)
    const [updated] = await db_1.db.update(schema_1.users).set({
        isGuest: input.roles.includes('guest') && input.roles.length === 1,
        updatedAt: new Date(),
    }).where((0, drizzle_orm_1.eq)(schema_1.users.id, req.params.id)).returning();
    // Update roles using new role system
    if (input.roles && input.roles.length > 0) {
        // First, remove all existing roles
        await db_1.db.delete(schema_1.userRoles).where((0, drizzle_orm_1.eq)(schema_1.userRoles.userId, req.params.id));
        // Then assign new roles
        for (const roleName of input.roles) {
            await authService_1.AuthService.assignRole(req.params.id, roleName, req.user.id);
        }
    }
    if (!updated) {
        return res.status(404).json({ success: false, error: 'User not found.' });
    }
    await db_1.db.insert(schema_1.securityLogs).values({
        userId: req.user.id,
        event: 'user_roles_updated',
        ipAddress: req.ip,
        userAgent: req.get('user-agent'),
        metadata: { targetUserId: req.params.id, roles: input.roles },
    });
    // Fetch full user with roles for the response
    const userRolesList = await authService_1.AuthService.getUserRoles(updated.id);
    const roleNames = userRolesList.map(r => r.name);
    res.json({
        success: true,
        data: {
            id: updated.id,
            email: updated.email,
            roles: roleNames,
            isGuest: updated.isGuest,
            mustChangePassword: updated.mustChangePassword,
            updatedAt: updated.updatedAt,
        },
    });
}));
router.post('/users/:id/suspension', (0, errorHandler_1.asyncHandler)(async (req, res) => {
    if (!(0, auth_1.hasRole)(req.user, 'super-admin') && !(0, auth_1.hasRole)(req.user, 'system-admin')) {
        return res.status(403).json({ success: false, error: 'Super admin access required.' });
    }
    const suspended = Boolean(req.body.suspended);
    const [updated] = await db_1.db.update(schema_1.users).set({
        isSuspended: suspended,
        suspensionReason: suspended ? String(req.body.reason || 'Suspended by admin') : null,
        suspendedAt: suspended ? new Date() : null,
        updatedAt: new Date(),
    }).where((0, drizzle_orm_1.eq)(schema_1.users.id, req.params.id)).returning();
    await db_1.db.insert(schema_1.securityLogs).values({
        userId: req.user.id,
        event: suspended ? 'user_suspended' : 'user_unsuspended',
        ipAddress: req.ip,
        userAgent: req.get('user-agent'),
        metadata: { targetUserId: req.params.id },
    });
    res.json({ success: true, data: updated });
}));
router.get('/security-logs', auth_1.adminOnly, (0, errorHandler_1.asyncHandler)(async (_req, res) => {
    const rows = await db_1.db.select().from(schema_1.securityLogs).orderBy((0, drizzle_orm_1.desc)(schema_1.securityLogs.createdAt)).limit(100);
    res.json({ success: true, data: rows });
}));
router.get('/audit-logs', auth_1.adminOnly, (0, errorHandler_1.asyncHandler)(async (_req, res) => {
    const rows = await db_1.db.select().from(schema_1.auditLogs).orderBy((0, drizzle_orm_1.desc)(schema_1.auditLogs.createdAt)).limit(100);
    res.json({ success: true, data: rows });
}));
exports.default = router;
//# sourceMappingURL=admin.js.map