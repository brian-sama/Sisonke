import { Router } from 'express';
import { z } from 'zod';
import { eq, desc } from 'drizzle-orm';
import { db } from '../db';
import { notifications } from '../db/schema';
import { authMiddleware } from '../middleware/auth';
import { asyncHandler } from '../middleware/errorHandler';

const router = Router();

router.use(authMiddleware);

router.get('/', asyncHandler(async (req, res) => {
  const list = await db
    .select()
    .from(notifications)
    .where(eq(notifications.userId, req.user!.id))
    .orderBy(desc(notifications.createdAt))
    .limit(100);

  res.json({ success: true, data: list });
}));

router.post('/:id/read', asyncHandler(async (req, res) => {
  await db
    .update(notifications)
    .set({ readAt: new Date() })
    .where(eq(notifications.id, req.params.id));

  res.json({ success: true });
}));

const PushTokenSchema = z.object({
  token: z.string().min(20),
  platform: z.string().min(2).max(40),
});

router.post('/push-token', asyncHandler(async (req, res) => {
  const input = PushTokenSchema.parse(req.body);

  await db.insert(notifications).values({
    userId: req.user!.id,
    channel: 'push-token',
    title: 'Push token registered',
    body: 'Device can receive counselor and safety updates.',
    metadata: {
      token: input.token,
      platform: input.platform,
      updatedAt: new Date().toISOString(),
    },
  });

  res.status(204).send();
}));

export default router;
