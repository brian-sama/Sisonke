import { Router } from 'express';
import { sql } from 'drizzle-orm';
import { db } from '../db';
import { analyticsEvents } from '../db/schema';
import { authMiddleware, adminOnly } from '../middleware/auth';
import { asyncHandler } from '../middleware/errorHandler';
import { AnalyticsEventSchema } from '../types';

const router = Router();

router.post('/events', asyncHandler(async (req, res) => {
  const input = AnalyticsEventSchema.parse(req.body);

  await db.insert(analyticsEvents).values({
    event: input.event,
    resourceId: input.resourceId,
    category: input.category,
    platform: input.platform,
    appVersion: input.appVersion,
    locale: input.locale,
    metadata: input.metadata,
  });

  res.status(202).json({ success: true });
}));

// GET /api/analytics/cohort-moods — mood distribution by age_group and day_of_week (admin)
router.get('/cohort-moods', authMiddleware, adminOnly, asyncHandler(async (req, res) => {
  // Join mood_checkins with user_profiles to get age_group, then aggregate
  const rows = await db.execute(sql`
    SELECT
      up.age_group,
      TO_CHAR(mc.checkin_date, 'Dy') AS day_of_week,
      EXTRACT(DOW FROM mc.checkin_date)::int AS day_of_week_num,
      mc.mood,
      COUNT(*)::int AS mood_count
    FROM mood_checkins mc
    JOIN user_profiles up ON up.user_id = mc.user_id
    WHERE mc.checkin_date >= NOW() - INTERVAL '90 days'
    GROUP BY up.age_group, day_of_week, day_of_week_num, mc.mood
    ORDER BY up.age_group, day_of_week_num, mc.mood
  `);

  res.json({ success: true, data: rows.rows ?? rows });
}));

// GET /api/analytics/resource-engagement — per-resource view counts and avg read time (admin)
router.get('/resource-engagement', authMiddleware, adminOnly, asyncHandler(async (req, res) => {
  const rows = await db.execute(sql`
    SELECT
      r.id AS resource_id,
      r.title,
      r.category,
      COUNT(rv.id)::int AS view_count,
      ROUND(AVG(rv.duration_seconds))::int AS avg_duration_seconds
    FROM resources r
    LEFT JOIN resource_views rv ON rv.resource_id = r.id
    GROUP BY r.id, r.title, r.category
    ORDER BY view_count DESC
    LIMIT 100
  `);

  res.json({ success: true, data: rows.rows ?? rows });
}));

// GET /api/analytics/geo-risk — count high-risk events grouped by location (admin)
router.get('/geo-risk', authMiddleware, adminOnly, asyncHandler(async (req, res) => {
  // Uses user_profiles.location (province/district string) joined to counselor cases
  // flagged as high risk
  const rows = await db.execute(sql`
    SELECT
      COALESCE(up.location, 'Unknown') AS location,
      COUNT(cc.id)::int AS high_risk_count
    FROM counselor_cases cc
    LEFT JOIN user_profiles up ON up.user_id = cc.user_id
    WHERE cc.risk_level = 'high'
    GROUP BY up.location
    ORDER BY high_risk_count DESC
  `);

  res.json({ success: true, data: rows.rows ?? rows });
}));

export default router;
