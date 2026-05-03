import { Router } from 'express';
import { and, desc, eq } from 'drizzle-orm';
import { db } from '../db';
import { analyticsEvents, communityPosts, reports } from '../db/schema';
import { authMiddleware } from '../middleware/auth';
import { asyncHandler } from '../middleware/errorHandler';
import { CommunityPostSchema } from '../types';
import { detectRiskLevel } from '../services/riskService';

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

  res.status(201).json({ success: true, data: report });
}));

export default router;
