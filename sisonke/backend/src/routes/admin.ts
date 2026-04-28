import { Router } from 'express';
import { desc, eq, gte, isNull } from 'drizzle-orm';
import { db } from '../db';
import { analyticsEvents, emergencyContacts, questions, resources } from '../db/schema';
import { authMiddleware, adminOnly } from '../middleware/auth';
import { asyncHandler } from '../middleware/errorHandler';
import {
  CreateEmergencyContactSchema,
  CreateResourceSchema,
  UpdateEmergencyContactSchema,
  UpdateResourceSchema,
} from '../types';

const router = Router();

router.use(authMiddleware, adminOnly);

router.get('/me', asyncHandler(async (req, res) => {
  res.json({ success: true, data: { user: req.user } });
}));

router.get('/overview', asyncHandler(async (_req, res) => {
  const [allResources, allContacts, allQuestions, events] = await Promise.all([
    db.select().from(resources).where(isNull(resources.deletedAt)),
    db.select().from(emergencyContacts).where(isNull(emergencyContacts.deletedAt)),
    db.select().from(questions).where(isNull(questions.deletedAt)),
    db.select().from(analyticsEvents).orderBy(desc(analyticsEvents.occurredAt)).limit(500),
  ]);

  const countBy = <T extends { status: string }>(items: T[]) =>
    items.reduce<Record<string, number>>((acc, item) => {
      acc[item.status] = (acc[item.status] || 0) + 1;
      return acc;
    }, {});

  const eventCounts = events.reduce<Record<string, number>>((acc, event) => {
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

router.get('/resources', asyncHandler(async (_req, res) => {
  const rows = await db
    .select()
    .from(resources)
    .where(isNull(resources.deletedAt))
    .orderBy(desc(resources.updatedAt), desc(resources.createdAt));

  res.json({ success: true, data: rows });
}));

router.post('/resources', asyncHandler(async (req, res) => {
  const input = CreateResourceSchema.parse(req.body);
  const isPublished = input.status === 'published';
  const [created] = await db.insert(resources).values({
    ...input,
    authorId: req.user!.id,
    isPublished,
    publishedAt: isPublished ? new Date() : null,
    updatedAt: new Date(),
  }).returning();

  res.status(201).json({ success: true, data: created });
}));

router.put('/resources/:id', asyncHandler(async (req, res) => {
  const input = UpdateResourceSchema.parse(req.body);
  const isPublishing = input.status === 'published';
  const [updated] = await db
    .update(resources)
    .set({
      ...input,
      isPublished: input.status ? input.status === 'published' : undefined,
      publishedAt: isPublishing ? new Date() : undefined,
      updatedAt: new Date(),
    })
    .where(eq(resources.id, req.params.id))
    .returning();

  if (!updated) {
    return res.status(404).json({ success: false, error: 'Resource not found' });
  }
  res.json({ success: true, data: updated });
}));

router.post('/resources/:id/publish', asyncHandler(async (req, res) => {
  const [updated] = await db
    .update(resources)
    .set({ status: 'published', isPublished: true, publishedAt: new Date(), updatedAt: new Date() })
    .where(eq(resources.id, req.params.id))
    .returning();

  if (!updated) {
    return res.status(404).json({ success: false, error: 'Resource not found' });
  }
  res.json({ success: true, data: updated });
}));

router.post('/resources/:id/archive', asyncHandler(async (req, res) => {
  const [updated] = await db
    .update(resources)
    .set({ status: 'archived', isPublished: false, deletedAt: new Date(), updatedAt: new Date() })
    .where(eq(resources.id, req.params.id))
    .returning();

  if (!updated) {
    return res.status(404).json({ success: false, error: 'Resource not found' });
  }
  res.json({ success: true, data: updated });
}));

router.get('/emergency-contacts', asyncHandler(async (_req, res) => {
  const rows = await db
    .select()
    .from(emergencyContacts)
    .where(isNull(emergencyContacts.deletedAt))
    .orderBy(emergencyContacts.category, emergencyContacts.name);

  res.json({ success: true, data: rows });
}));

router.post('/emergency-contacts', asyncHandler(async (req, res) => {
  const input = CreateEmergencyContactSchema.parse(req.body);
  const isPublished = input.status === 'published';
  const [created] = await db.insert(emergencyContacts).values({
    ...input,
    isActive: input.isActive,
    publishedAt: isPublished ? new Date() : null,
    updatedAt: new Date(),
  }).returning();

  res.status(201).json({ success: true, data: created });
}));

router.put('/emergency-contacts/:id', asyncHandler(async (req, res) => {
  const input = UpdateEmergencyContactSchema.parse(req.body);
  const [updated] = await db
    .update(emergencyContacts)
    .set({
      ...input,
      publishedAt: input.status === 'published' ? new Date() : undefined,
      updatedAt: new Date(),
    })
    .where(eq(emergencyContacts.id, req.params.id))
    .returning();

  if (!updated) {
    return res.status(404).json({ success: false, error: 'Emergency contact not found' });
  }
  res.json({ success: true, data: updated });
}));

router.get('/analytics', asyncHandler(async (req, res) => {
  const days = Number(req.query.days || 30);
  const since = new Date(Date.now() - Math.max(1, Math.min(days, 365)) * 24 * 60 * 60 * 1000);
  const rows = await db.select().from(analyticsEvents).where(gte(analyticsEvents.occurredAt, since));

  const byEvent = rows.reduce<Record<string, number>>((acc, event) => {
    acc[event.event] = (acc[event.event] || 0) + 1;
    return acc;
  }, {});
  const byCategory = rows.reduce<Record<string, number>>((acc, event) => {
    if (event.category) acc[event.category] = (acc[event.category] || 0) + 1;
    return acc;
  }, {});

  res.json({ success: true, data: { total: rows.length, byEvent, byCategory } });
}));

export default router;
