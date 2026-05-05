import { Router } from 'express';
import { z } from 'zod';
import { db } from '../db';
import { notifications } from '../db/schema';
import { authMiddleware } from '../middleware/auth';
import { asyncHandler } from '../middleware/errorHandler';

const router = Router();

const PushTokenSchema = z.object({
  token: z.string().min(20),
  platform: z.string().min(2).max(40),
});

router.use(authMiddleware);

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
