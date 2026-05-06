import { Router } from 'express';
import { desc, eq, sql } from 'drizzle-orm';
import { db } from '../db';
import { auditLogs, counselingMessages, counselorCases, counselorNotes, users } from '../db/schema';
import { authMiddleware, hasAnyRole } from '../middleware/auth';
import { asyncHandler } from '../middleware/errorHandler';
import { CounselorRequestSchema } from '../types';
import { SocketService } from '../services/socketService';
import { AuthService } from '../services/authService';
import {
  deterministicRiskReview,
  generateCounselorDraftReply,
  generateCounselorSummary,
} from '../ai/counselorCopilot';

const router = Router();

const isAssignedCounselor = async (caseId: string, userId: string) => {
  const [item] = await db.select().from(counselorCases).where(eq(counselorCases.id, caseId)).limit(1);
  return item && item.counselorId === userId ? item : null;
};

const canUseCounselorAi = async (caseId: string, user: NonNullable<Express.Request['user']>) => {
  const [item] = await db.select().from(counselorCases).where(eq(counselorCases.id, caseId)).limit(1);
  if (!item) return null;
  if (item.counselorId === user.id) return item;
  if (hasAnyRole(user, ['admin', 'system-admin', 'super-admin'])) return item;
  return null;
};

const loadCaseMessages = async (caseId: string) => {
  const rows = await db
    .select()
    .from(counselingMessages)
    .where(eq(counselingMessages.caseId, caseId))
    .orderBy(desc(counselingMessages.createdAt))
    .limit(20);
  return rows.reverse();
};

router.post('/requests', authMiddleware, asyncHandler(async (req, res) => {
  const input = CounselorRequestSchema.parse(req.body);
  const staffUsers = await db
    .select({
      id: users.id,
      email: users.email,
    })
    .from(users);
  // Filter users who have counselor or admin roles
  const counselors: typeof staffUsers = [];
  for (const user of staffUsers) {
    const userRoles = await AuthService.getUserRoles(user.id);
    const roleNames = userRoles.map(r => r.name.toLowerCase().replace(/_/g, '-'));
    if (roleNames.some((role: string) => ['counselor', 'admin', 'system-admin', 'super-admin'].includes(role))) {
      counselors.push(user);
    }
  }

  const preferredContactMethod = input.preferredContactMethod;
  const activeStatuses = ['assigned', 'accepted', 'live', 'waiting_for_client', 'callback_requested', 'follow_up'];
  const activeCases = await db
    .select()
    .from(counselorCases);
  const workloadFor = (id: string) => activeCases.filter((item) => item.counselorId === id && activeStatuses.includes(item.status)).length;
  
  const availableCounselors = counselors
    .filter((counselor) => {
      // Safely handle missing columns
      const status = (counselor as any).counselorStatus || 'offline';
      const onCall = (counselor as any).isOnCall || false;
      return status === 'online' || onCall;
    })
    .sort((a, b) => workloadFor(a.id) - workloadFor(b.id));
  const autoAssign = input.riskLevel === 'high' && availableCounselors.length > 0;
  const initialStatus = preferredContactMethod === 'callback'
    ? 'callback_requested'
    : autoAssign
      ? 'assigned'
      : 'requested';

  const [createdCase] = await db.insert(counselorCases).values({
    userId: req.user!.id,
    counselorId: autoAssign ? availableCounselors[0]?.id : undefined,
    issueCategory: input.issueCategory,
    summary: input.summary,
    riskLevel: input.riskLevel,
    status: initialStatus as any,
    source: preferredContactMethod,
    callbackPhone: input.callbackPhone,
    preferredContactMethod,
    callbackStatus: preferredContactMethod === 'callback' ? 'requested' : undefined,
    updatedAt: new Date(),
  }).returning();

  await db.insert(auditLogs).values({
    actorId: req.user!.id,
    action: 'case_created',
    entityType: 'counselor_case',
    entityId: createdCase.id,
    metadata: {
      riskLevel: createdCase.riskLevel,
      status: createdCase.status,
      assignment: autoAssign ? 'auto_high_risk' : 'queue_claiming',
      counselorId: createdCase.counselorId,
    },
  });
  
  SocketService.emitCaseEvent(createdCase.id, createdCase.userId, 'case:created', { case: createdCase });
  if (createdCase.counselorId) {
    SocketService.emitCaseEvent(createdCase.id, createdCase.userId, 'case:assigned', { case: createdCase });
  }
  if (preferredContactMethod === 'callback') {
    SocketService.emitCaseEvent(createdCase.id, createdCase.userId, 'callback:requested', { case: createdCase });
  }
  if (input.riskLevel === 'high') {
    SocketService.notifyCounselors('case:escalated', { case: createdCase, assignment: autoAssign ? 'auto_assigned' : 'needs_claim' });
  }

  res.status(201).json({
    success: true,
    data: {
      case: createdCase,
      connected: Boolean(createdCase.counselorId),
      message: createdCase.counselorId
        ? 'A counselor has been assigned.'
        : 'Your request has been added to the counselor queue.',
    },
  });
}));

router.use(authMiddleware);

router.post('/me/availability', asyncHandler(async (req, res) => {
  if (!hasAnyRole(req.user, ['counselor'])) {
    return res.status(403).json({ success: false, error: 'Counselor access required.' });
  }

  const status = String(req.body.status || 'offline');
  if (!['online', 'busy', 'offline'].includes(status)) {
    return res.status(400).json({ success: false, error: 'Invalid counselor status.' });
  }

  const updateData: any = {
    lastActiveAt: new Date(),
    updatedAt: new Date(),
  };

  // Only try to update these if we are sure they exist or handle the potential error
  try {
    await db.update(users).set({
      ...updateData,
      counselorStatus: status,
      isOnCall: typeof req.body.isOnCall === 'boolean' ? req.body.isOnCall : undefined,
    }).where(eq(users.id, req.user!.id));
  } catch (err) {
    // If columns are missing, just update the basic fields
    await db.update(users).set(updateData).where(eq(users.id, req.user!.id));
  }

  const [updated] = await db.select({ id: users.id }).from(users).where(eq(users.id, req.user!.id)).limit(1);

  const isOnCall = typeof req.body.isOnCall === 'boolean' ? req.body.isOnCall : false;

  await db.insert(auditLogs).values({
    actorId: req.user!.id,
    action: 'counselor_availability_changed',
    entityType: 'user',
    entityId: req.user!.id,
    metadata: { status, isOnCall },
  });

  SocketService.notifyStaff(status === 'online' ? 'counselor:online' : 'counselor:offline', {
    counselorId: req.user!.id,
    status,
    isOnCall,
  });
  SocketService.broadcastDashboardUpdate({ type: 'counselor', action: 'availability_changed', counselorId: req.user!.id });

  res.json({ success: true, data: updated });
}));

router.get('/my-cases', asyncHandler(async (req, res) => {
  const rows = await db
    .select()
    .from(counselorCases)
    .where(eq(counselorCases.userId, req.user!.id))
    .orderBy(desc(counselorCases.createdAt))
    .limit(50);

  res.json({ success: true, data: rows });
}));

router.get('/my-cases/:id', asyncHandler(async (req, res) => {
  const rows = await db
    .select()
    .from(counselorCases)
    .where(sql`${counselorCases.id} = ${req.params.id} and ${counselorCases.userId} = ${req.user!.id}`)
    .limit(1);

  if (!rows[0]) return res.status(404).json({ success: false, error: 'Case not found.' });
  res.json({ success: true, data: rows[0] });
}));

router.get('/cases', asyncHandler(async (req, res) => {
  if (!hasAnyRole(req.user, ['counselor', 'admin', 'system-admin', 'super-admin'])) {
    return res.status(403).json({ success: false, error: 'Counselor access required.' });
  }

  const rows = await db
    .select()
    .from(counselorCases)
    .orderBy(desc(counselorCases.createdAt))
    .limit(100);

  const visibleRows = hasAnyRole(req.user, ['admin', 'system-admin', 'super-admin'])
    ? rows.map((item) => ({
        id: item.id,
        issueCategory: item.issueCategory,
        status: item.status,
        riskLevel: item.riskLevel,
        source: item.source,
        counselorId: item.counselorId,
        createdAt: item.createdAt,
        updatedAt: item.updatedAt,
      }))
    : rows.filter((item) => item.counselorId === req.user!.id);

  res.json({ success: true, data: visibleRows });
}));

router.post('/cases/:id/messages', asyncHandler(async (req, res) => {
  const [messageCase] = await db.select().from(counselorCases).where(eq(counselorCases.id, req.params.id)).limit(1);
  const isAssigned = messageCase?.counselorId === req.user!.id;
  const isClient = messageCase?.userId === req.user!.id;
  if (!messageCase || (!isAssigned && !isClient)) {
    return res.status(403).json({ success: false, error: 'You cannot message this case.' });
  }

  const content = String(req.body.content || '').trim();
  const messageType = String(req.body.messageType || 'text');
  const mediaUrl = req.body.mediaUrl ? String(req.body.mediaUrl) : undefined;
  if (!content && !mediaUrl) return res.status(400).json({ success: false, error: 'Message or media is required.' });

  const [message] = await db.insert(counselingMessages).values({
    caseId: req.params.id,
    senderUserId: req.user!.id,
    senderRole: req.user!.roles[0] || 'user',
    messageType,
    mediaUrl,
    content: content || 'Voice note uploaded',
  }).returning();

  SocketService.emitCaseEvent(req.params.id, messageCase.userId, 'case:message', { caseId: req.params.id, message });
  if (messageType === 'voice_note') {
    SocketService.emitCaseEvent(req.params.id, messageCase.userId, 'voice_note:uploaded', { caseId: req.params.id, message });
  }

  res.status(201).json({ success: true, data: message });
}));

router.get('/cases/:id/ai-summary', asyncHandler(async (req, res) => {
  const caseRow = await canUseCounselorAi(req.params.id, req.user!);
  if (!caseRow) {
    return res.status(403).json({ success: false, error: 'Counselor case access required.' });
  }

  const messages = await loadCaseMessages(req.params.id);
  const summary = await generateCounselorSummary({
    issueCategory: caseRow.issueCategory,
    riskLevel: caseRow.riskLevel,
    status: caseRow.status,
    summary: caseRow.summary,
    messages: messages.map((message) => ({
      senderRole: message.senderRole,
      content: message.content,
      createdAt: message.createdAt,
    })),
  });

  await db.insert(auditLogs).values({
    actorId: req.user!.id,
    action: 'counselor_ai_summary_generated',
    entityType: 'counselor_case',
    entityId: caseRow.id,
    metadata: { riskLevel: caseRow.riskLevel },
  });

  res.json({ success: true, data: { summary, draftOnly: true } });
}));

router.post('/cases/:id/ai-draft-reply', asyncHandler(async (req, res) => {
  const caseRow = await canUseCounselorAi(req.params.id, req.user!);
  if (!caseRow) {
    return res.status(403).json({ success: false, error: 'Counselor case access required.' });
  }

  const messages = await loadCaseMessages(req.params.id);
  const draft = await generateCounselorDraftReply({
    issueCategory: caseRow.issueCategory,
    riskLevel: caseRow.riskLevel,
    status: caseRow.status,
    summary: caseRow.summary,
    messages: messages.map((message) => ({
      senderRole: message.senderRole,
      content: message.content,
      createdAt: message.createdAt,
    })),
  });

  await db.insert(auditLogs).values({
    actorId: req.user!.id,
    action: 'counselor_ai_draft_generated',
    entityType: 'counselor_case',
    entityId: caseRow.id,
    metadata: { riskLevel: caseRow.riskLevel, draftOnly: true },
  });

  res.json({ success: true, data: { draft, draftOnly: true } });
}));

router.post('/cases/:id/ai-risk-review', asyncHandler(async (req, res) => {
  const caseRow = await canUseCounselorAi(req.params.id, req.user!);
  if (!caseRow) {
    return res.status(403).json({ success: false, error: 'Counselor case access required.' });
  }

  const messages = await loadCaseMessages(req.params.id);
  const review = deterministicRiskReview({
    issueCategory: caseRow.issueCategory,
    riskLevel: caseRow.riskLevel,
    status: caseRow.status,
    summary: caseRow.summary,
    messages: messages.map((message) => ({
      senderRole: message.senderRole,
      content: message.content,
      createdAt: message.createdAt,
    })),
  });

  await db.insert(auditLogs).values({
    actorId: req.user!.id,
    action: 'counselor_ai_risk_review_generated',
    entityType: 'counselor_case',
    entityId: caseRow.id,
    metadata: review,
  });

  res.json({ success: true, data: review });
}));

router.post('/cases/:id/callback', asyncHandler(async (req, res) => {
  const callbackPhone = String(req.body.callbackPhone || '').trim();
  if (!callbackPhone) return res.status(400).json({ success: false, error: 'Callback phone is required.' });

  const [updated] = await db.update(counselorCases).set({
    status: 'callback_requested' as any,
    callbackPhone,
    callbackStatus: 'requested',
    preferredContactMethod: 'callback',
    updatedAt: new Date(),
  }).where(eq(counselorCases.id, req.params.id)).returning();

  if (!updated) return res.status(404).json({ success: false, error: 'Case not found.' });
  SocketService.emitCaseEvent(req.params.id, updated.userId, 'callback:requested', { case: updated });
  SocketService.emitCaseEvent(req.params.id, updated.userId, 'case:status_changed', { case: updated });
  res.json({ success: true, data: updated });
}));

router.post('/cases/:id/notes', asyncHandler(async (req, res) => {
  const caseRow = await isAssignedCounselor(req.params.id, req.user!.id);
  if (!caseRow) {
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
  const caseRow = await isAssignedCounselor(req.params.id, req.user!.id);
  if (!caseRow && !hasAnyRole(req.user, ['system-admin', 'super-admin'])) {
    return res.status(403).json({ success: false, error: 'Counselor access required.' });
  }

  const status = String(req.body.status || '');
  const allowed = ['requested', 'assigned', 'accepted', 'live', 'waiting_for_client', 'callback_requested', 'follow_up', 'resolved', 'escalated', 'closed'];
  if (!allowed.includes(status)) return res.status(400).json({ success: false, error: 'Invalid case status.' });

  const [updated] = await db.update(counselorCases).set({
    status: status as any,
    followUpAt: req.body.followUpAt ? new Date(req.body.followUpAt) : undefined,
    resolvedAt: status === 'resolved' || status === 'closed' ? new Date() : undefined,
    updatedAt: new Date(),
  }).where(eq(counselorCases.id, req.params.id)).returning();
  
  const event = status === 'escalated'
    ? 'case:escalated'
    : status === 'accepted'
      ? 'case:accepted'
      : 'case:status_changed';
  SocketService.emitCaseEvent(req.params.id, updated?.userId, event, { case: updated });

  res.json({ success: true, data: updated });
}));

export default router;
