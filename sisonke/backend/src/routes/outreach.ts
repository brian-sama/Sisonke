import { Router } from 'express';
import { z } from 'zod';
import { desc, eq, count, sql } from 'drizzle-orm';
import { db } from '../db';
import {
  outreachCampaigns,
  notifications,
  users,
  userProfiles,
  counselorCases,
} from '../db/schema';
import { authMiddleware, adminOnly } from '../middleware/auth';
import { asyncHandler } from '../middleware/errorHandler';

const router = Router();

// All outreach routes require authentication + admin role
router.use(authMiddleware, adminOnly);

const CreateCampaignSchema = z.object({
  title: z.string().min(1).max(255),
  message: z.string().min(1),
  segment: z.enum(['all', 'inactive', 'high-risk', 'age-group']),
  ageGroup: z.string().max(20).optional(),
  scheduledAt: z.string().datetime().optional(),
});

// GET /api/admin/outreach — list all campaigns
router.get('/', asyncHandler(async (req, res) => {
  const campaigns = await db
    .select()
    .from(outreachCampaigns)
    .orderBy(desc(outreachCampaigns.createdAt))
    .limit(100);

  res.json({ success: true, data: campaigns });
}));

// POST /api/admin/outreach — create a new campaign
router.post('/', asyncHandler(async (req, res) => {
  const input = CreateCampaignSchema.parse(req.body);

  const [campaign] = await db.insert(outreachCampaigns).values({
    title: input.title,
    message: input.message,
    segment: input.segment,
    ageGroup: input.ageGroup,
    scheduledAt: input.scheduledAt ? new Date(input.scheduledAt) : undefined,
    createdBy: req.user!.id,
  }).returning();

  res.status(201).json({ success: true, data: campaign });
}));

// POST /api/admin/outreach/:id/send — trigger sending the campaign
router.post('/:id/send', asyncHandler(async (req, res) => {
  const { id } = req.params;

  const [campaign] = await db
    .select()
    .from(outreachCampaigns)
    .where(eq(outreachCampaigns.id, id))
    .limit(1);

  if (!campaign) {
    return res.status(404).json({ success: false, error: 'Campaign not found.' });
  }

  if (campaign.sentAt) {
    return res.status(409).json({ success: false, error: 'Campaign has already been sent.' });
  }

  // Resolve target user IDs based on segment
  let targetUserIds: string[] = [];

  if (campaign.segment === 'all') {
    const rows = await db.select({ id: users.id }).from(users);
    targetUserIds = rows.map((r) => r.id);
  } else if (campaign.segment === 'inactive') {
    // Users who haven't been active in the last 14 days
    const cutoff = new Date(Date.now() - 14 * 24 * 60 * 60 * 1000);
    const rows = await db
      .select({ id: users.id })
      .from(users)
      .where(sql`${users.lastActiveAt} < ${cutoff} OR ${users.lastActiveAt} IS NULL`);
    targetUserIds = rows.map((r) => r.id);
  } else if (campaign.segment === 'high-risk') {
    const rows = await db
      .select({ userId: counselorCases.userId })
      .from(counselorCases)
      .where(eq(counselorCases.riskLevel, 'high'));
    targetUserIds = rows
      .map((r) => r.userId)
      .filter((id): id is string => id !== null);
  } else if (campaign.segment === 'age-group' && campaign.ageGroup) {
    const rows = await db
      .select({ userId: userProfiles.userId })
      .from(userProfiles)
      .where(eq(userProfiles.ageGroup, campaign.ageGroup as any));
    targetUserIds = rows.map((r) => r.userId);
  }

  // Insert an in-app notification for every resolved user
  // In production, also fire push tokens here via existing push infrastructure
  if (targetUserIds.length > 0) {
    const notificationRows = targetUserIds.map((userId) => ({
      userId,
      channel: 'outreach' as const,
      title: campaign.title,
      body: campaign.message,
      metadata: { campaignId: campaign.id, segment: campaign.segment },
    }));

    // Batch insert in chunks of 500 to avoid query size limits
    const chunkSize = 500;
    for (let i = 0; i < notificationRows.length; i += chunkSize) {
      await db.insert(notifications).values(notificationRows.slice(i, i + chunkSize));
    }
  }

  // Mark as sent
  const [updated] = await db
    .update(outreachCampaigns)
    .set({ sentAt: new Date() })
    .where(eq(outreachCampaigns.id, id))
    .returning();

  res.json({
    success: true,
    data: { campaign: updated, recipientCount: targetUserIds.length },
  });
}));

// GET /api/admin/export/report — JSON summary for PDF generation
router.get('/export/report', asyncHandler(async (req, res) => {
  const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);

  // Total active (non-deleted) users
  const [{ totalUsers }] = await db
    .select({ totalUsers: count() })
    .from(users)
    .where(sql`${users.deletedAt} IS NULL`);

  // Mood distribution last 30 days
  const moodDistribution = await db.execute(sql`
    SELECT mood, COUNT(*)::int AS mood_count
    FROM mood_checkins
    WHERE checkin_date >= ${thirtyDaysAgo}
    GROUP BY mood
    ORDER BY mood_count DESC
  `);

  // Crisis / high-risk case count
  const [{ crisisCount }] = await db
    .select({ crisisCount: count() })
    .from(counselorCases)
    .where(eq(counselorCases.riskLevel, 'high'));

  // Average counselor response time in minutes (time from case creation to first counselor message)
  const avgResponseTime = await db.execute(sql`
    SELECT
      ROUND(AVG(
        EXTRACT(EPOCH FROM (cm.created_at - cc.created_at)) / 60
      ))::int AS avg_response_minutes
    FROM counselor_cases cc
    JOIN counseling_messages cm ON cm.case_id = cc.id AND cm.sender_role = 'counselor'
    WHERE cc.created_at >= ${thirtyDaysAgo}
      AND cm.created_at = (
        SELECT MIN(cm2.created_at)
        FROM counseling_messages cm2
        WHERE cm2.case_id = cc.id AND cm2.sender_role = 'counselor'
      )
  `);

  const avgMinutes =
    (avgResponseTime as any)[0]?.avg_response_minutes ?? null;

  res.json({
    success: true,
    data: {
      generatedAt: new Date().toISOString(),
      periodDays: 30,
      totalUsers: Number(totalUsers),
      moodDistribution: moodDistribution,
      crisisCount: Number(crisisCount),
      counselorAvgResponseMinutes: avgMinutes,
    },
  });
}));

export default router;
