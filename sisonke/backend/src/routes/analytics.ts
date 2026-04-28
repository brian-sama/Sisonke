import { Router } from 'express';
import { db } from '../db';
import { analyticsEvents } from '../db/schema';
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

export default router;
