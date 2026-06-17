import { Router } from 'express';
import { z } from 'zod';
import { eq, desc, count } from 'drizzle-orm';
import { db } from '../db';
import { circles, circleMembers, circleMessages } from '../db/schema';
import { authMiddleware, adminOnly } from '../middleware/auth';
import { asyncHandler } from '../middleware/errorHandler';

const router = Router();

const CreateCircleSchema = z.object({
  theme: z.enum(['grief', 'anxiety', 'exam-stress', 'loneliness', 'anger', 'sobriety']),
  descriptionEn: z.string().min(1).max(1000),
  descriptionSn: z.string().max(1000).optional(),
  descriptionNd: z.string().max(1000).optional(),
  maxMembers: z.number().int().min(2).max(50).default(8),
});

const PostMessageSchema = z.object({
  content: z.string().min(1).max(2000),
});

// GET /api/circles — list all circles with member count
router.get('/', asyncHandler(async (req, res) => {
  const rows = await db.select().from(circles).orderBy(circles.createdAt);

  // Fetch member counts for all circles
  const memberCounts = await db
    .select({ circleId: circleMembers.circleId, memberCount: count() })
    .from(circleMembers)
    .groupBy(circleMembers.circleId);

  const countMap = new Map(memberCounts.map((r) => [r.circleId, Number(r.memberCount)]));

  const data = rows.map((circle) => ({
    ...circle,
    memberCount: countMap.get(circle.id) ?? 0,
  }));

  res.json({ success: true, data });
}));

// POST /api/circles — create a new circle (admin only)
router.post('/', authMiddleware, adminOnly, asyncHandler(async (req, res) => {
  const input = CreateCircleSchema.parse(req.body);

  const [circle] = await db.insert(circles).values({
    theme: input.theme,
    descriptionEn: input.descriptionEn,
    descriptionSn: input.descriptionSn,
    descriptionNd: input.descriptionNd,
    maxMembers: input.maxMembers,
  }).returning();

  res.status(201).json({ success: true, data: circle });
}));

// POST /api/circles/:id/join — join a circle (auth required)
router.post('/:id/join', authMiddleware, asyncHandler(async (req, res) => {
  const { id } = req.params;

  // Verify circle exists
  const [circle] = await db.select().from(circles).where(eq(circles.id, id)).limit(1);
  if (!circle) {
    return res.status(404).json({ success: false, error: 'Circle not found.' });
  }

  // Check member capacity
  const [{ memberCount }] = await db
    .select({ memberCount: count() })
    .from(circleMembers)
    .where(eq(circleMembers.circleId, id));

  if (Number(memberCount) >= circle.maxMembers) {
    return res.status(409).json({ success: false, error: 'This circle is full.' });
  }

  // Check if already a member (upsert-style)
  const existing = await db
    .select()
    .from(circleMembers)
    .where(eq(circleMembers.circleId, id))
    .limit(50);

  const alreadyMember = existing.some((m) => m.userId === req.user!.id);
  if (alreadyMember) {
    return res.json({ success: true, data: { joined: false, message: 'Already a member of this circle.' } });
  }

  await db.insert(circleMembers).values({ circleId: id, userId: req.user!.id });

  res.status(201).json({ success: true, data: { joined: true } });
}));

// GET /api/circles/:id/messages — paginated messages (auth required)
router.get('/:id/messages', authMiddleware, asyncHandler(async (req, res) => {
  const { id } = req.params;
  const limit = Math.min(Number(req.query.limit) || 50, 100);
  const offset = Number(req.query.offset) || 0;

  const [circle] = await db.select().from(circles).where(eq(circles.id, id)).limit(1);
  if (!circle) {
    return res.status(404).json({ success: false, error: 'Circle not found.' });
  }

  const messages = await db
    .select()
    .from(circleMessages)
    .where(eq(circleMessages.circleId, id))
    .orderBy(desc(circleMessages.createdAt))
    .limit(limit)
    .offset(offset);

  res.json({ success: true, data: messages });
}));

// POST /api/circles/:id/messages — post anonymous message (auth required, identity stripped)
router.post('/:id/messages', authMiddleware, asyncHandler(async (req, res) => {
  const { id } = req.params;
  const input = PostMessageSchema.parse(req.body);

  const [circle] = await db.select().from(circles).where(eq(circles.id, id)).limit(1);
  if (!circle) {
    return res.status(404).json({ success: false, error: 'Circle not found.' });
  }

  // Confirm the user is a member before allowing posts
  const membership = await db
    .select()
    .from(circleMembers)
    .where(eq(circleMembers.circleId, id))
    .limit(50);

  const isMember = membership.some((m) => m.userId === req.user!.id);
  if (!isMember) {
    return res.status(403).json({ success: false, error: 'You must join this circle before posting.' });
  }

  // Insert WITHOUT user_id — fully anonymous
  const [message] = await db.insert(circleMessages).values({
    circleId: id,
    content: input.content,
  }).returning();

  res.status(201).json({ success: true, data: message });
}));

export default router;
