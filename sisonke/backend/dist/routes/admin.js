"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const bcryptjs_1 = __importDefault(require("bcryptjs"));
const drizzle_orm_1 = require("drizzle-orm");
const db_1 = require("../db");
const schema_1 = require("../db/schema");
const auth_1 = require("../middleware/auth");
const errorHandler_1 = require("../middleware/errorHandler");
const types_1 = require("../types");
const riskService_1 = require("../services/riskService");
const zimbabweRagKnowledge_1 = require("../data/zimbabweRagKnowledge");
const router = (0, express_1.Router)();
router.use(auth_1.authMiddleware, auth_1.adminOnly);
router.get('/me', (0, errorHandler_1.asyncHandler)(async (req, res) => {
    res.json({ success: true, data: { user: req.user } });
}));
router.get('/overview', (0, errorHandler_1.asyncHandler)(async (_req, res) => {
    const [allUsers, allResources, allContacts, allQuestions, events, allCases, allChatbotSessions, pendingCommunityPosts] = await Promise.all([
        db_1.db.select().from(schema_1.users),
        db_1.db.select().from(schema_1.resources).where((0, drizzle_orm_1.isNull)(schema_1.resources.deletedAt)),
        db_1.db.select().from(schema_1.emergencyContacts).where((0, drizzle_orm_1.isNull)(schema_1.emergencyContacts.deletedAt)),
        db_1.db.select().from(schema_1.questions).where((0, drizzle_orm_1.isNull)(schema_1.questions.deletedAt)),
        db_1.db.select().from(schema_1.analyticsEvents).orderBy((0, drizzle_orm_1.desc)(schema_1.analyticsEvents.occurredAt)).limit(500),
        db_1.db.select().from(schema_1.counselorCases),
        db_1.db.select().from(schema_1.chatbotSessions),
        db_1.db.select().from(schema_1.communityPosts).where((0, drizzle_orm_1.eq)(schema_1.communityPosts.status, 'pending')),
    ]);
    const countBy = (items) => items.reduce((acc, item) => {
        acc[item.status] = (acc[item.status] || 0) + 1;
        return acc;
    }, {});
    const eventCounts = events.reduce((acc, event) => {
        acc[event.event] = (acc[event.event] || 0) + 1;
        return acc;
    }, {});
    res.json({
        success: true,
        data: {
            users: {
                total: allUsers.length,
                guests: allUsers.filter((user) => user.isGuest).length,
                admins: allUsers.filter((user) => user.roles?.includes('admin') || user.roles?.includes('super-admin') || user.role === 'admin').length,
            },
            resources: { total: allResources.length, byStatus: countBy(allResources) },
            emergencyContacts: { total: allContacts.length, byStatus: countBy(allContacts) },
            questions: { total: allQuestions.length, byStatus: countBy(allQuestions) },
            analytics: eventCounts,
            chatbotSessions: { total: allChatbotSessions.length, highRisk: allChatbotSessions.filter((item) => item.riskLevel === 'high').length },
            counselorCases: {
                total: allCases.length,
                waiting: allCases.filter((item) => ['requested', 'assigned', 'emergency'].includes(item.status)).length,
                highRisk: allCases.filter((item) => item.riskLevel === 'high' || item.status === 'emergency').length,
            },
            communityPosts: { pending: pendingCommunityPosts.length },
        },
    });
}));
router.get('/resources', (0, errorHandler_1.asyncHandler)(async (_req, res) => {
    const rows = await db_1.db
        .select()
        .from(schema_1.resources)
        .where((0, drizzle_orm_1.isNull)(schema_1.resources.deletedAt))
        .orderBy((0, drizzle_orm_1.desc)(schema_1.resources.updatedAt), (0, drizzle_orm_1.desc)(schema_1.resources.createdAt));
    res.json({ success: true, data: rows });
}));
router.post('/resources', (0, errorHandler_1.asyncHandler)(async (req, res) => {
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
router.put('/resources/:id', (0, errorHandler_1.asyncHandler)(async (req, res) => {
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
router.post('/resources/:id/publish', (0, errorHandler_1.asyncHandler)(async (req, res) => {
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
router.post('/resources/:id/archive', (0, errorHandler_1.asyncHandler)(async (req, res) => {
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
router.get('/emergency-contacts', (0, errorHandler_1.asyncHandler)(async (_req, res) => {
    const rows = await db_1.db
        .select()
        .from(schema_1.emergencyContacts)
        .where((0, drizzle_orm_1.isNull)(schema_1.emergencyContacts.deletedAt))
        .orderBy(schema_1.emergencyContacts.category, schema_1.emergencyContacts.name);
    res.json({ success: true, data: rows });
}));
router.post('/emergency-contacts', (0, errorHandler_1.asyncHandler)(async (req, res) => {
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
router.put('/emergency-contacts/:id', (0, errorHandler_1.asyncHandler)(async (req, res) => {
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
router.get('/analytics', (0, errorHandler_1.asyncHandler)(async (req, res) => {
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
    const byCategory = rows.reduce((acc, event) => {
        if (event.category)
            acc[event.category] = (acc[event.category] || 0) + 1;
        return acc;
    }, {});
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
            byCategory,
            ageRangeDistribution: countByKey(profiles, (profile) => profile.ageGroup),
            genderDistribution: countByKey(profiles, (profile) => profile.gender || 'unspecified'),
            moodTrendsByMood: countByKey(moodRows, (mood) => mood.mood),
            chatbotSessions: chatRows.length,
            counselorEscalations: cases.filter((item) => item.source === 'chatbot' || item.riskLevel === 'high').length,
            issueCategories: countByKey(cases, (item) => item.issueCategory),
        },
    });
}));
router.get('/counselor-cases', (0, errorHandler_1.asyncHandler)(async (_req, res) => {
    const rows = await db_1.db
        .select()
        .from(schema_1.counselorCases)
        .orderBy((0, drizzle_orm_1.desc)(schema_1.counselorCases.createdAt))
        .limit(100);
    res.json({ success: true, data: rows });
}));
router.post('/counselor-cases/:id/status', (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const status = String(req.body.status || '');
    const allowed = ['requested', 'assigned', 'live', 'follow-up', 'resolved', 'emergency'];
    if (!allowed.includes(status))
        return res.status(400).json({ success: false, error: 'Invalid status' });
    const [updated] = await db_1.db.update(schema_1.counselorCases).set({
        status: status,
        followUpAt: req.body.followUpAt ? new Date(req.body.followUpAt) : undefined,
        resolvedAt: status === 'resolved' ? new Date() : undefined,
        updatedAt: new Date(),
    }).where((0, drizzle_orm_1.eq)(schema_1.counselorCases.id, req.params.id)).returning();
    res.json({ success: true, data: updated });
}));
router.post('/counselor-cases/:id/notes', (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const note = String(req.body.note || '').trim();
    if (!note)
        return res.status(400).json({ success: false, error: 'Note is required' });
    await db_1.db.insert(schema_1.securityLogs).values({
        userId: req.user.id,
        event: 'counselor_note_added',
        ipAddress: req.ip,
        userAgent: req.get('user-agent'),
        metadata: { caseId: req.params.id },
    });
    res.status(201).json({ success: true });
}));
router.get('/community-posts', (0, errorHandler_1.asyncHandler)(async (_req, res) => {
    const rows = await db_1.db
        .select()
        .from(schema_1.communityPosts)
        .orderBy((0, drizzle_orm_1.desc)(schema_1.communityPosts.createdAt))
        .limit(100);
    res.json({ success: true, data: rows });
}));
router.post('/community-posts/:id/moderate', (0, errorHandler_1.asyncHandler)(async (req, res) => {
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
    res.json({ success: true, data: updated });
}));
router.get('/reports', (0, errorHandler_1.asyncHandler)(async (_req, res) => {
    const rows = await db_1.db.select().from(schema_1.reports).orderBy((0, drizzle_orm_1.desc)(schema_1.reports.createdAt)).limit(100);
    res.json({ success: true, data: rows });
}));
router.post('/reports/:id/status', (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const status = String(req.body.status || '');
    if (!['pending', 'reviewed', 'resolved', 'dismissed'].includes(status)) {
        return res.status(400).json({ success: false, error: 'Invalid report status' });
    }
    const [updated] = await db_1.db.update(schema_1.reports).set({
        status: status,
        reviewedAt: new Date(),
        reviewedBy: req.user.id,
    }).where((0, drizzle_orm_1.eq)(schema_1.reports.id, req.params.id)).returning();
    res.json({ success: true, data: updated });
}));
router.get('/cms-content', (0, errorHandler_1.asyncHandler)(async (_req, res) => {
    const rows = await db_1.db.select().from(schema_1.cmsContent).orderBy((0, drizzle_orm_1.desc)(schema_1.cmsContent.createdAt)).limit(100);
    res.json({ success: true, data: rows });
}));
router.get('/faqs', (0, errorHandler_1.asyncHandler)(async (_req, res) => {
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
router.get('/safety-rules', (0, errorHandler_1.asyncHandler)(async (_req, res) => {
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
router.post('/safety-rules/test', (0, errorHandler_1.asyncHandler)(async (req, res) => {
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
router.post('/cms-content', (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const input = types_1.CmsContentSchema.parse(req.body);
    const [created] = await db_1.db.insert(schema_1.cmsContent).values({
        ...input,
        createdBy: req.user.id,
        publishedAt: input.status === 'published' ? new Date() : undefined,
        updatedAt: new Date(),
    }).returning();
    res.status(201).json({ success: true, data: created });
}));
router.put('/cms-content/:id', (0, errorHandler_1.asyncHandler)(async (req, res) => {
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
router.get('/users', (0, errorHandler_1.asyncHandler)(async (_req, res) => {
    const rows = await db_1.db.select().from(schema_1.users).orderBy((0, drizzle_orm_1.desc)(schema_1.users.createdAt)).limit(100);
    res.json({
        success: true,
        data: rows.map((user) => ({
            id: user.id,
            email: user.email,
            role: user.role,
            roles: user.roles?.length ? user.roles : [user.role || 'guest'],
            isGuest: user.isGuest,
            isSuspended: user.isSuspended,
            suspensionReason: user.suspensionReason,
            createdAt: user.createdAt,
            lastActiveAt: user.lastActiveAt,
        })),
    });
}));
const primaryRoleFor = (roles) => {
    if (roles.includes('admin') || roles.includes('super-admin'))
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
        role: primaryRole,
        roles: input.roles,
        isGuest: input.isGuest,
        updatedAt: new Date(),
    }).returning();
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
            role: created.role,
            roles: created.roles,
            isGuest: created.isGuest,
            createdAt: created.createdAt,
        },
    });
}));
router.put('/users/:id/roles', auth_1.superAdminOnly, (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const input = types_1.UpdateUserRolesSchema.parse(req.body);
    if (req.params.id === req.user.id && !input.roles.includes('super-admin')) {
        return res.status(400).json({ success: false, error: 'You cannot remove your own super-admin role.' });
    }
    const primaryRole = primaryRoleFor(input.roles);
    const [updated] = await db_1.db.update(schema_1.users).set({
        role: primaryRole,
        roles: input.roles,
        isGuest: input.roles.includes('guest') && input.roles.length === 1,
        updatedAt: new Date(),
    }).where((0, drizzle_orm_1.eq)(schema_1.users.id, req.params.id)).returning();
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
    res.json({
        success: true,
        data: {
            id: updated.id,
            email: updated.email,
            role: updated.role,
            roles: updated.roles,
            isGuest: updated.isGuest,
            updatedAt: updated.updatedAt,
        },
    });
}));
router.post('/users/:id/suspension', (0, errorHandler_1.asyncHandler)(async (req, res) => {
    if (!(0, auth_1.hasRole)(req.user, 'super-admin')) {
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
router.get('/security-logs', (0, errorHandler_1.asyncHandler)(async (_req, res) => {
    const rows = await db_1.db.select().from(schema_1.securityLogs).orderBy((0, drizzle_orm_1.desc)(schema_1.securityLogs.createdAt)).limit(100);
    res.json({ success: true, data: rows });
}));
exports.default = router;
//# sourceMappingURL=admin.js.map