import { Router } from 'express';
import { desc, eq, inArray } from 'drizzle-orm';
import { db } from '../db';
import { counselingMessages, counselorCases, counselorNotes, users } from '../db/schema';
import { authMiddleware } from '../middleware/auth';
import { asyncHandler } from '../middleware/errorHandler';
import { CounselorRequestSchema } from '../types';

const router = Router();

router.post('/requests', authMiddleware, asyncHandler(async (req, res) => {
  const input = CounselorRequestSchema.parse(req.body);
  const availableCounselors = await db
    .select()
    .from(users)
    .where(inArray(users.role, ['counselor', 'admin']))
    .limit(1);

  const [createdCase] = await db.insert(counselorCases).values({
    userId: req.user!.id,
    counselorId: availableCounselors[0]?.id,
    issueCategory: input.issueCategory,
    summary: input.summary,
    riskLevel: input.riskLevel,
    status: availableCounselors.length ? 'assigned' : 'requested',
    source: 'mobile',
    updatedAt: new Date(),
  }).returning();

  res.status(201).json({
    success: true,
    data: {
      case: createdCase,
      connected: availableCounselors.length > 0,
      message: availableCounselors.length
        ? 'A counselor has been assigned.'
        : 'No counselor is available right now. A request has been created.',
    },
  });
}));

router.use(authMiddleware);

router.get('/cases', asyncHandler(async (req, res) => {
  if (!['counselor', 'admin'].includes(req.user!.role)) {
    return res.status(403).json({ success: false, error: 'Counselor access required.' });
  }

  const rows = await db
    .select()
    .from(counselorCases)
    .orderBy(desc(counselorCases.createdAt))
    .limit(100);

  res.json({ success: true, data: rows });
}));

router.post('/cases/:id/messages', asyncHandler(async (req, res) => {
  const content = String(req.body.content || '').trim();
  if (!content) return res.status(400).json({ success: false, error: 'Message is required.' });

  const [message] = await db.insert(counselingMessages).values({
    caseId: req.params.id,
    senderUserId: req.user!.id,
    senderRole: req.user!.role,
    content,
  }).returning();

  res.status(201).json({ success: true, data: message });
}));

router.post('/cases/:id/notes', asyncHandler(async (req, res) => {
  if (!['counselor', 'admin'].includes(req.user!.role)) {
    return res.status(403).json({ success: false, error: 'Counselor access required.' });
  }

  const note = String(req.body.note || '').trim();
  if (!note) return res.status(400).json({ success: false, error: 'Note is required.' });

  const [created] = await db.insert(counselorNotes).values({
    caseId: req.params.id,
    counselorId: req.user!.id,
    note,
  }).returning();

  res.status(201).json({ success: true, data: created });
}));

router.post('/cases/:id/status', asyncHandler(async (req, res) => {
  if (!['counselor', 'admin'].includes(req.user!.role)) {
    return res.status(403).json({ success: false, error: 'Counselor access required.' });
  }

  const status = String(req.body.status || '');
  const allowed = ['requested', 'assigned', 'live', 'follow-up', 'resolved', 'emergency'];
  if (!allowed.includes(status)) return res.status(400).json({ success: false, error: 'Invalid case status.' });

  const [updated] = await db.update(counselorCases).set({
    status: status as any,
    followUpAt: req.body.followUpAt ? new Date(req.body.followUpAt) : undefined,
    resolvedAt: status === 'resolved' ? new Date() : undefined,
    updatedAt: new Date(),
  }).where(eq(counselorCases.id, req.params.id)).returning();

  res.json({ success: true, data: updated });
}));

export default router;
