import { Router } from 'express';
import { and, desc, eq } from 'drizzle-orm';
import { db } from '../db';
import { analyticsEvents, communityPosts, reports } from '../db/schema';
import { authMiddleware, adminOnly } from '../middleware/auth';
import { asyncHandler } from '../middleware/errorHandler';
import { CommunityPostSchema } from '../types';
import { detectRiskLevel } from '../services/riskService';
import { SocketService } from '../services/socketService';

const router = Router();

const blockedTerms = ['suicide', 'kill myself', 'rape', 'abuse', 'violence'];

router.get('/posts', authMiddleware, asyncHandler(async (req, res) => {
  const ageGroup = String(req.query.ageGroup || '');
  if (!['13-15', '16-17', '18-24', '25+'].includes(ageGroup)) {
    return res.status(400).json({ success: false, error: 'Valid ageGroup is required.' });
  }

  const rows = await db
    .select()
    .from(communityPosts)
    .where(and(eq(communityPosts.ageGroup, ageGroup as any), eq(communityPosts.status, 'approved')))
    .orderBy(desc(communityPosts.createdAt))
    .limit(50);

  res.json({ success: true, data: rows });
}));

router.post('/posts', authMiddleware, asyncHandler(async (req, res) => {
  const input = CommunityPostSchema.parse(req.body);
  const normalized = input.content.toLowerCase();
  const riskLevel = detectRiskLevel(input.content);
  const blocked = blockedTerms.some((term) => normalized.includes(term));

  const [post] = await db.insert(communityPosts).values({
    userId: req.user!.id,
    ageGroup: input.ageGroup,
    content: input.content,
    status: blocked || riskLevel !== 'low' ? 'pending' : 'pending',
    moderationReason: blocked ? 'Safety review required' : undefined,
  }).returning();
  
  SocketService.broadcastDashboardUpdate({ type: 'community_post', action: 'created' });

  await db.insert(analyticsEvents).values({
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

router.post('/reports', authMiddleware, asyncHandler(async (req, res) => {
  const reason = String(req.body.reason || '').trim();
  if (!reason) return res.status(400).json({ success: false, error: 'Report reason is required.' });
  const [report] = await db.insert(reports).values({
    type: 'community_post',
    resourceId: req.body.resourceId,
    reason,
    description: req.body.description,
    reporterDeviceId: req.user!.deviceId,
  }).returning();

  SocketService.broadcastDashboardUpdate({ type: 'report', action: 'created' });

  res.status(201).json({ success: true, data: report });
}));

// GET /api/community/pending — posts awaiting moderation (admin only)
router.get('/pending', authMiddleware, adminOnly, asyncHandler(async (req, res) => {
  const rows = await db
    .select()
    .from(communityPosts)
    .where(eq(communityPosts.status, 'pending'))
    .orderBy(desc(communityPosts.createdAt))
    .limit(100);

  res.json({ success: true, data: rows });
}));

// POST /api/community/:id/approve — approve a pending post (admin only)
router.post('/:id/approve', authMiddleware, adminOnly, asyncHandler(async (req, res) => {
  const { id } = req.params;

  const [post] = await db
    .select()
    .from(communityPosts)
    .where(eq(communityPosts.id, id))
    .limit(1);

  if (!post) {
    return res.status(404).json({ success: false, error: 'Post not found.' });
  }

  const [updated] = await db
    .update(communityPosts)
    .set({ status: 'approved', reviewedAt: new Date(), reviewedBy: req.user!.id })
    .where(eq(communityPosts.id, id))
    .returning();

  SocketService.broadcastDashboardUpdate({ type: 'community_post', action: 'approved' });

  res.json({ success: true, data: updated });
}));

// POST /api/community/:id/reject — reject and soft-remove a post (admin only)
router.post('/:id/reject', authMiddleware, adminOnly, asyncHandler(async (req, res) => {
  const { id } = req.params;
  const moderationReason = String(req.body.reason || 'Rejected by moderator').trim();

  const [post] = await db
    .select()
    .from(communityPosts)
    .where(eq(communityPosts.id, id))
    .limit(1);

  if (!post) {
    return res.status(404).json({ success: false, error: 'Post not found.' });
  }

  const [updated] = await db
    .update(communityPosts)
    .set({
      status: 'removed',
      moderationReason,
      reviewedAt: new Date(),
      reviewedBy: req.user!.id,
      removedAt: new Date(),
    })
    .where(eq(communityPosts.id, id))
    .returning();

  SocketService.broadcastDashboardUpdate({ type: 'community_post', action: 'rejected' });

  res.json({ success: true, data: updated });
}));

export default router;
