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
router.use(auth_1.authMiddleware, auth_1.adminOnly);
router.get('/me', (0, errorHandler_1.asyncHandler)(async (req, res) => {
    res.json({ success: true, data: { user: req.user } });
}));
router.get('/overview', (0, errorHandler_1.asyncHandler)(async (_req, res) => {
    const [allResources, allContacts, allQuestions, events] = await Promise.all([
        db_1.db.select().from(schema_1.resources).where((0, drizzle_orm_1.isNull)(schema_1.resources.deletedAt)),
        db_1.db.select().from(schema_1.emergencyContacts).where((0, drizzle_orm_1.isNull)(schema_1.emergencyContacts.deletedAt)),
        db_1.db.select().from(schema_1.questions).where((0, drizzle_orm_1.isNull)(schema_1.questions.deletedAt)),
        db_1.db.select().from(schema_1.analyticsEvents).orderBy((0, drizzle_orm_1.desc)(schema_1.analyticsEvents.occurredAt)).limit(500),
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
            resources: { total: allResources.length, byStatus: countBy(allResources) },
            emergencyContacts: { total: allContacts.length, byStatus: countBy(allContacts) },
            questions: { total: allQuestions.length, byStatus: countBy(allQuestions) },
            analytics: eventCounts,
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
    const rows = await db_1.db.select().from(schema_1.analyticsEvents).where((0, drizzle_orm_1.gte)(schema_1.analyticsEvents.occurredAt, since));
    const byEvent = rows.reduce((acc, event) => {
        acc[event.event] = (acc[event.event] || 0) + 1;
        return acc;
    }, {});
    const byCategory = rows.reduce((acc, event) => {
        if (event.category)
            acc[event.category] = (acc[event.category] || 0) + 1;
        return acc;
    }, {});
    res.json({ success: true, data: { total: rows.length, byEvent, byCategory } });
}));
exports.default = router;
//# sourceMappingURL=admin.js.map