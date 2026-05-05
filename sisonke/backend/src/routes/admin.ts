import { Router } from 'express';
import bcrypt from 'bcryptjs';
import { count, desc, eq, gte, isNull, sql, and } from 'drizzle-orm';
import { db } from '../db';
import { AuthService } from '../services/authService';
import {
  analyticsEvents,
  chatbotSessions,
  cmsContent,
  communityPosts,
  counselorCases,
  emergencyContacts,
  moodCheckins,
  questions,
  reports,
  resources,
  securityLogs,
  userProfiles,
  users,
  auditLogs,
} from '../db/schema';
import { authMiddleware, adminOnly, dashboardAccess, hasRole, superAdminOnly } from '../middleware/auth';
import { asyncHandler } from '../middleware/errorHandler';
import {
  CreateEmergencyContactSchema,
  CreateAdminUserSchema,
  CmsContentSchema,
  AdminSetPasswordSchema,
  CreateResourceSchema,
  UpdateAdminUserSchema,
  UpdateUserRolesSchema,
  UpdateEmergencyContactSchema,
  UpdateResourceSchema,
} from '../types';
import { detectRisk } from '../services/riskService';
import { goldFaqCards, safetyRules } from '../data/zimbabweRagKnowledge';
import { SocketService } from '../services/socketService';

const router = Router();

router.use(authMiddleware);

const roleList = (user: any) =>
  (user?.roles?.length ? user.roles : ['guest']).map((role: string) =>
    String(role).toLowerCase().replace(/_/g, '-'),
  );

const hasAny = (user: any, roles: string[]) => {
  const current = roleList(user);
  return roles.some((role) => current.includes(role));
};

const canSeePrivateCase = (user: any, item: any) => {
  return hasAny(user, ['counselor']) && item.counselorId === user.id;
};

const sanitizeCaseForUser = (user: any, item: any) => {
  if (canSeePrivateCase(user, item)) return item;
  return {
    id: item.id,
    issueCategory: item.issueCategory,
    status: item.status,
    riskLevel: item.riskLevel,
    source: item.source,
    preferredContactMethod: item.preferredContactMethod,
    callbackStatus: item.callbackStatus,
    counselorId: item.counselorId,
    createdAt: item.createdAt,
    updatedAt: item.updatedAt,
    followUpAt: item.followUpAt,
    resolvedAt: item.resolvedAt,
  };
};

router.get('/me', asyncHandler(async (req, res) => {
  res.json({ success: true, data: { user: req.user } });
}));

router.get('/analytics/health', dashboardAccess, asyncHandler(async (_req, res) => {
  const sevenDaysAgo = new Date();
  sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);

  const stats = await db.select({
    date: sql<string>`DATE(${analyticsEvents.occurredAt})`,
    count: count()
  })
  .from(analyticsEvents)
  .where(gte(analyticsEvents.occurredAt, sevenDaysAgo))
  .groupBy(sql`DATE(${analyticsEvents.occurredAt})`)
  .orderBy(sql`DATE(${analyticsEvents.occurredAt})`);

  res.json({ success: true, data: stats });
}));

router.get('/overview', dashboardAccess, asyncHandler(async (_req, res) => {
  const results = await Promise.all([
    db.select({ value: count() }).from(users),
    db.select({ value: count() }).from(resources).where(isNull(resources.deletedAt)),
    db.select({ value: count() }).from(emergencyContacts).where(isNull(emergencyContacts.deletedAt)),
    db.select({ value: count() }).from(questions).where(isNull(questions.deletedAt)),
    db.select({ value: count() }).from(counselorCases),
    db.select({ value: count() }).from(chatbotSessions),
    db.select({ value: count() }).from(communityPosts).where(eq(communityPosts.status, 'pending')),
    db.select({ value: count() }).from(counselorCases).where(eq(counselorCases.riskLevel, 'high')),
    db.select().from(analyticsEvents).orderBy(desc(analyticsEvents.occurredAt)).limit(10),
  ]);

  const userCount = Number(results[0][0]?.value ?? 0);
  const resourceCount = Number(results[1][0]?.value ?? 0);
  const contactCount = Number(results[2][0]?.value ?? 0);
  const questionCount = Number(results[3][0]?.value ?? 0);
  const caseCount = Number(results[4][0]?.value ?? 0);
  const sessionCount = Number(results[5][0]?.value ?? 0);
  const pendingPostsCount = Number(results[6][0]?.value ?? 0);
  const highRiskCasesCount = Number(results[7][0]?.value ?? 0);
  const latestEvents = results[8];

  res.json({
    success: true,
    data: {
      users: { total: userCount },
      resources: { total: resourceCount },
      emergencyContacts: { total: contactCount },
      questions: { total: questionCount },
      counselorCases: { 
        total: caseCount, 
        highRisk: highRiskCasesCount 
      },
      chatbotSessions: { total: sessionCount },
      communityPosts: { pending: pendingPostsCount },
      latestEvents
    },
  });
}));

router.get('/community-posts', dashboardAccess, asyncHandler(async (_req, res) => {
  const rows = await db
    .select()
    .from(communityPosts)
    .orderBy(desc(communityPosts.createdAt))
    .limit(100);
  res.json({ success: true, data: rows });
}));

router.post('/community-posts/:id/moderate', dashboardAccess, asyncHandler(async (req, res) => {
  const status = String(req.body.status || '');
  if (!['approved', 'removed'].includes(status)) {
    return res.status(400).json({ success: false, error: 'Status must be approved or removed.' });
  }

  const [updated] = await db.update(communityPosts).set({
    status: status as any,
    moderationReason: req.body.reason,
    reviewedAt: new Date(),
    reviewedBy: req.user!.id,
    removedAt: status === 'removed' ? new Date() : undefined,
  }).where(eq(communityPosts.id, req.params.id)).returning();

  if (!updated) return res.status(404).json({ success: false, error: 'Post not found' });
  
  SocketService.broadcastDashboardUpdate({ type: 'community_post', action: 'moderated' });
  res.json({ success: true, data: updated });
}));

router.get('/reports', dashboardAccess, asyncHandler(async (_req, res) => {
  const rows = await db
    .select()
    .from(reports)
    .orderBy(desc(reports.createdAt))
    .limit(100);
  res.json({ success: true, data: rows });
}));

router.post('/reports/:id/status', dashboardAccess, asyncHandler(async (req, res) => {
  const status = String(req.body.status || '');
  if (!['pending', 'reviewed', 'resolved', 'dismissed'].includes(status)) {
    return res.status(400).json({ success: false, error: 'Invalid report status' });
  }

  const [updated] = await db.update(reports).set({
    status: status as any,
    reviewedAt: new Date(),
    reviewedBy: req.user!.id,
  }).where(eq(reports.id, req.params.id)).returning();

  if (!updated) return res.status(404).json({ success: false, error: 'Report not found' });
  
  SocketService.broadcastDashboardUpdate({ type: 'report', action: 'resolved' });
  res.json({ success: true, data: updated });
}));

router.get('/resources', dashboardAccess, asyncHandler(async (_req, res) => {
  const rows = await db
    .select()
    .from(resources)
    .where(isNull(resources.deletedAt))
    .orderBy(desc(resources.updatedAt), desc(resources.createdAt));

  res.json({ success: true, data: rows });
}));

router.post('/resources', dashboardAccess, asyncHandler(async (req, res) => {
  const input = CreateResourceSchema.parse(req.body);
  const isPublished = input.status === 'published';
  const [created] = await db.insert(resources).values({
    ...input,
    authorId: req.user!.id,
    isPublished,
    publishedAt: isPublished ? new Date() : null,
    updatedAt: new Date(),
  }).returning();

  res.status(201).json({ success: true, data: created });
}));

router.put('/resources/:id', dashboardAccess, asyncHandler(async (req, res) => {
  const input = UpdateResourceSchema.parse(req.body);
  const isPublishing = input.status === 'published';
  const [updated] = await db
    .update(resources)
    .set({
      ...input,
      isPublished: input.status ? input.status === 'published' : undefined,
      publishedAt: isPublishing ? new Date() : undefined,
      updatedAt: new Date(),
    })
    .where(eq(resources.id, req.params.id))
    .returning();

  if (!updated) {
    return res.status(404).json({ success: false, error: 'Resource not found' });
  }
  res.json({ success: true, data: updated });
}));

router.post('/resources/:id/publish', dashboardAccess, asyncHandler(async (req, res) => {
  const [updated] = await db
    .update(resources)
    .set({ status: 'published', isPublished: true, publishedAt: new Date(), updatedAt: new Date() })
    .where(eq(resources.id, req.params.id))
    .returning();

  if (!updated) {
    return res.status(404).json({ success: false, error: 'Resource not found' });
  }
  res.json({ success: true, data: updated });
}));

router.post('/resources/:id/archive', dashboardAccess, asyncHandler(async (req, res) => {
  const [updated] = await db
    .update(resources)
    .set({ status: 'archived', isPublished: false, deletedAt: new Date(), updatedAt: new Date() })
    .where(eq(resources.id, req.params.id))
    .returning();

  if (!updated) {
    return res.status(404).json({ success: false, error: 'Resource not found' });
  }
  res.json({ success: true, data: updated });
}));

router.get('/emergency-contacts', dashboardAccess, asyncHandler(async (_req, res) => {
  const rows = await db
    .select()
    .from(emergencyContacts)
    .where(isNull(emergencyContacts.deletedAt))
    .orderBy(emergencyContacts.category, emergencyContacts.name);

  res.json({ success: true, data: rows });
}));

router.post('/emergency-contacts', dashboardAccess, asyncHandler(async (req, res) => {
  const input = CreateEmergencyContactSchema.parse(req.body);
  const isPublished = input.status === 'published';
  const [created] = await db.insert(emergencyContacts).values({
    ...input,
    isActive: input.isActive,
    publishedAt: isPublished ? new Date() : null,
    updatedAt: new Date(),
  }).returning();

  res.status(201).json({ success: true, data: created });
}));

router.put('/emergency-contacts/:id', dashboardAccess, asyncHandler(async (req, res) => {
  const input = UpdateEmergencyContactSchema.parse(req.body);
  const [updated] = await db
    .update(emergencyContacts)
    .set({
      ...input,
      publishedAt: input.status === 'published' ? new Date() : undefined,
      updatedAt: new Date(),
    })
    .where(eq(emergencyContacts.id, req.params.id))
    .returning();

  if (!updated) {
    return res.status(404).json({ success: false, error: 'Emergency contact not found' });
  }
  res.json({ success: true, data: updated });
}));

router.get('/analytics', dashboardAccess, asyncHandler(async (req, res) => {
  const days = Number(req.query.days || 30);
  const since = new Date(Date.now() - Math.max(1, Math.min(days, 365)) * 24 * 60 * 60 * 1000);
  const [rows, profiles, moodRows, chatRows, cases] = await Promise.all([
    db.select().from(analyticsEvents).where(gte(analyticsEvents.occurredAt, since)),
    db.select().from(userProfiles),
    db.select().from(moodCheckins).where(gte(moodCheckins.createdAt, since)),
    db.select().from(chatbotSessions).where(gte(chatbotSessions.createdAt, since)),
    db.select().from(counselorCases).where(gte(counselorCases.createdAt, since)),
  ]);

  const byEvent = rows.reduce<Record<string, number>>((acc, event) => {
    acc[event.event] = (acc[event.event] || 0) + 1;
    return acc;
  }, {});

  // Time Series Aggregation
  const timeSeries: Record<string, { appUse: number; urgent: number }> = {};
  for (let i = 0; i < days; i++) {
    const d = new Date(Date.now() - i * 24 * 60 * 60 * 1000).toISOString().split('T')[0];
    timeSeries[d] = { appUse: 0, urgent: 0 };
  }

  rows.forEach((event) => {
    if (event.occurredAt) {
      const d = event.occurredAt.toISOString().split('T')[0];
      if (timeSeries[d]) timeSeries[d].appUse++;
    }
  });

  cases.forEach((c) => {
    if (c.createdAt) {
      const d = c.createdAt.toISOString().split('T')[0];
      if (timeSeries[d] && (c.riskLevel === 'high' || c.status === 'escalated')) {
        timeSeries[d].urgent++;
      }
    }
  });

  const timeSeriesList = Object.entries(timeSeries)
    .map(([date, counts]) => ({ date, ...counts }))
    .sort((a, b) => a.date.localeCompare(b.date));

  const countByKey = <T>(items: T[], picker: (item: T) => string | null | undefined) =>
    items.reduce<Record<string, number>>((acc, item) => {
      const key = picker(item);
      if (key) acc[key] = (acc[key] || 0) + 1;
      return acc;
    }, {});

  res.json({
    success: true,
    data: {
      total: rows.length,
      byEvent,
      timeSeries: timeSeriesList,
      ageRangeDistribution: countByKey(profiles, (profile) => profile.ageGroup),
      genderDistribution: countByKey(profiles, (profile) => profile.gender || 'unspecified'),
      moodTrendsByMood: countByKey(moodRows, (mood) => mood.mood),
      chatbotSessions: chatRows.length,
      counselorEscalations: cases.filter((item) => item.source === 'chatbot' || item.riskLevel === 'high').length,
      issueCategories: countByKey(cases, (item) => item.issueCategory),
    },
  });
}));

router.get('/counselor-cases', dashboardAccess, asyncHandler(async (req, res) => {
  const rows = await db
    .select()
    .from(counselorCases)
    .orderBy(desc(counselorCases.createdAt))
    .limit(100);

  const visibleRows = hasAny(req.user, ['admin', 'system-admin', 'super-admin'])
    ? rows.map((item) => sanitizeCaseForUser(req.user, item))
    : rows
        .filter((item) => item.counselorId === req.user!.id)
        .map((item) => sanitizeCaseForUser(req.user, item));

  res.json({ success: true, data: visibleRows });
}));

router.get('/counselor-operations', dashboardAccess, asyncHandler(async (req, res) => {
  const [cases, counselors, auditRows] = await Promise.all([
    db.select().from(counselorCases).orderBy(desc(counselorCases.createdAt)).limit(100),
    db.select().from(users),
    db
      .select()
      .from(auditLogs)
      .where(eq(auditLogs.entityType, 'counselor_case'))
      .orderBy(desc(auditLogs.createdAt))
      .limit(50),
  ]);

  const visibleCases = hasAny(req.user, ['admin', 'system-admin', 'super-admin'])
    ? cases.map((item) => sanitizeCaseForUser(req.user, item))
    : cases
        .filter((item) => item.counselorId === req.user!.id)
        .map((item) => sanitizeCaseForUser(req.user, item));

  const activeStatuses = ['assigned', 'accepted', 'live', 'waiting_for_client', 'callback_requested', 'follow_up'];
  const staffRoles = ['counselor', 'admin', 'super-admin', 'system-admin'];
  // Filter users who have counselor or admin roles using new role system
  const staffUsers: typeof counselors = [];
  for (const user of counselors) {
    const userRoles = await AuthService.getUserRoles(user.id);
    const roleNames = userRoles.map(r => r.name.toLowerCase().replace(/_/g, '-'));
    if (roleNames.some((role: string) => staffRoles.includes(role))) {
      staffUsers.push(user);
    }
  }
  const workloadFor = (id: string) => cases.filter((item) => item.counselorId === id && activeStatuses.includes(item.status)).length;
  const operationsCounselors = staffUsers.map((counselor) => ({
    id: counselor.id,
    email: counselor.email,
    status: counselor.counselorStatus || 'offline',
    isOnCall: counselor.isOnCall,
    specializations: counselor.counselorSpecializations || [],
    workload: workloadFor(counselor.id),
    lastActiveAt: counselor.lastActiveAt,
  }));

  const metrics = {
    activeCases: visibleCases.filter((item) => activeStatuses.includes(item.status)).length,
    highRiskAlerts: visibleCases.filter((item) => item.riskLevel === 'high' || item.status === 'escalated').length,
    counselorsOnline: operationsCounselors.filter((item) => item.status === 'online').length,
    pendingRequests: visibleCases.filter((item) => item.status === 'requested').length,
  };

  res.json({
    success: true,
    data: {
      metrics,
      cases: visibleCases,
      counselors: operationsCounselors,
      auditLogs: auditRows,
      assignmentPolicy: {
        low: 'queue_claiming',
        medium: 'queue_claiming',
        high: 'auto_assign_lowest_workload_available_or_on_call',
      },
    },
  });
}));

router.post('/counselor-cases/:id/assign', dashboardAccess, asyncHandler(async (req, res) => {
  const counselorId = String(req.body.counselorId || '').trim();
  if (!counselorId) return res.status(400).json({ success: false, error: 'Counselor is required' });

  const [existing] = await db.select().from(counselorCases).where(eq(counselorCases.id, req.params.id)).limit(1);
  if (!existing) return res.status(404).json({ success: false, error: 'Case not found' });
  const canReassign = hasAny(req.user, ['admin', 'system-admin', 'super-admin'])
    || (hasAny(req.user, ['counselor']) && existing.counselorId === req.user!.id);
  if (!canReassign) {
    return res.status(403).json({ success: false, error: 'You cannot reassign this case' });
  }

  const [updated] = await db.update(counselorCases).set({
    counselorId,
    status: 'assigned' as any,
    updatedAt: new Date(),
  }).where(eq(counselorCases.id, req.params.id)).returning();

  if (!updated) return res.status(404).json({ success: false, error: 'Case not found' });

  await db.insert(auditLogs).values({
    actorId: req.user!.id,
    action: 'case_assigned',
    entityType: 'counselor_case',
    entityId: updated.id,
    metadata: { counselorId, previousStatus: req.body.previousStatus },
  });

  SocketService.emitCaseEvent(req.params.id, updated.userId, 'case:assigned', { case: updated });
  res.json({ success: true, data: updated });
}));

router.post('/counselors/:id/availability', dashboardAccess, asyncHandler(async (req, res) => {
  const status = String(req.body.status || 'offline');
  if (!['online', 'busy', 'offline'].includes(status)) {
    return res.status(400).json({ success: false, error: 'Invalid counselor status' });
  }

  const [updated] = await db.update(users).set({
    counselorStatus: status,
    isOnCall: typeof req.body.isOnCall === 'boolean' ? req.body.isOnCall : undefined,
    counselorSpecializations: Array.isArray(req.body.specializations) ? req.body.specializations : undefined,
    lastActiveAt: new Date(),
    updatedAt: new Date(),
  }).where(eq(users.id, req.params.id)).returning();

  if (!updated) return res.status(404).json({ success: false, error: 'Counselor not found' });

  await db.insert(auditLogs).values({
    actorId: req.user!.id,
    action: 'counselor_availability_changed',
    entityType: 'user',
    entityId: updated.id,
    metadata: { status, isOnCall: updated.isOnCall, specializations: updated.counselorSpecializations },
  });

  SocketService.notifyStaff(status === 'online' ? 'counselor:online' : 'counselor:offline', {
    counselorId: updated.id,
    status,
    isOnCall: updated.isOnCall,
  });
  SocketService.broadcastDashboardUpdate({ type: 'counselor', action: 'availability_changed', counselorId: updated.id });

  res.json({ success: true, data: updated });
}));

router.post('/counselor-cases/:id/status', dashboardAccess, asyncHandler(async (req, res) => {
  const status = String(req.body.status || '');
  const allowed = [
    'requested',
    'assigned',
    'accepted',
    'live',
    'waiting_for_client',
    'callback_requested',
    'follow_up',
    'resolved',
    'escalated',
    'closed',
  ];
  if (!allowed.includes(status)) return res.status(400).json({ success: false, error: 'Invalid status' });

  const [existing] = await db.select().from(counselorCases).where(eq(counselorCases.id, req.params.id)).limit(1);
  if (!existing) return res.status(404).json({ success: false, error: 'Case not found' });
  const canManageCase = hasAny(req.user, ['system-admin', 'super-admin'])
    || (hasAny(req.user, ['counselor']) && existing.counselorId === req.user!.id);
  if (!canManageCase) {
    return res.status(403).json({ success: false, error: 'Only the assigned counselor can manage private case status' });
  }

  const [updated] = await db.update(counselorCases).set({
    status: status as any,
    followUpAt: req.body.followUpAt ? new Date(req.body.followUpAt) : undefined,
    resolvedAt: status === 'resolved' || status === 'closed' ? new Date() : undefined,
    updatedAt: new Date(),
  }).where(eq(counselorCases.id, req.params.id)).returning();

  if (!updated) return res.status(404).json({ success: false, error: 'Case not found' });

  await db.insert(auditLogs).values({
    actorId: req.user!.id,
    action: status === 'escalated' ? 'case_escalated' : status === 'resolved' || status === 'closed' ? 'case_closed' : 'case_status_changed',
    entityType: 'counselor_case',
    entityId: updated.id,
    metadata: { status, followUpAt: req.body.followUpAt },
  });

  const event = status === 'escalated'
    ? 'case:escalated'
    : status === 'accepted'
      ? 'case:accepted'
      : 'case:status_changed';
  SocketService.emitCaseEvent(req.params.id, updated?.userId, event, { case: updated });

  res.json({ success: true, data: updated });
}));

router.post('/counselor-cases/:id/notes', dashboardAccess, asyncHandler(async (req, res) => {
  const note = String(req.body.note || '').trim();
  if (!note) return res.status(400).json({ success: false, error: 'Note is required' });

  const [existing] = await db.select().from(counselorCases).where(eq(counselorCases.id, req.params.id)).limit(1);
  if (!existing) return res.status(404).json({ success: false, error: 'Case not found' });
  if (!hasAny(req.user, ['counselor']) || existing.counselorId !== req.user!.id) {
    return res.status(403).json({ success: false, error: 'Only the assigned counselor can add private notes' });
  }

  await db.insert(securityLogs).values({
    userId: req.user!.id,
    event: 'counselor_note_added',
    ipAddress: req.ip,
    userAgent: req.get('user-agent'),
    metadata: { caseId: req.params.id },
  });

  await db.insert(auditLogs).values({
    actorId: req.user!.id,
    action: 'case_note_added',
    entityType: 'counselor_case',
    entityId: req.params.id,
    metadata: { noteLength: note.length },
  });

  res.status(201).json({ success: true });
}));

router.get('/cms-content', dashboardAccess, asyncHandler(async (_req, res) => {
  const rows = await db.select().from(cmsContent).orderBy(desc(cmsContent.createdAt)).limit(100);
  res.json({ success: true, data: rows });
}));

router.get('/faqs', dashboardAccess, asyncHandler(async (_req, res) => {
  res.json({
    success: true,
    data: goldFaqCards.map((card) => ({
      id: card.id,
      question: card.title,
      goldAnswer: card.content,
      topic: card.category,
      riskLevel: card.riskLevel,
      language: 'en',
      tags: card.tags,
      status: 'published',
    })),
  });
}));

router.get('/safety-rules', dashboardAccess, asyncHandler(async (_req, res) => {
  res.json({
    success: true,
    data: safetyRules.map((rule, index) => ({
      id: `${rule.route}-${index}`,
      route: rule.route,
      risk: rule.risk,
      terms: rule.terms,
      responseTemplate: rule.risk === 'red'
        ? 'Stop normal AI response. Show local emergency contacts and route to a human supporter immediately.'
        : 'Offer grounding, check safety, and suggest human support if distress continues.',
      active: true,
    })),
  });
}));

router.post('/safety-rules/test', dashboardAccess, asyncHandler(async (req, res) => {
  const message = String(req.body.message || '');
  const detection = detectRisk(message);
  res.json({
    success: true,
    data: {
      detected: detection.level === 'high',
      riskLevel: detection.level,
      route: detection.route,
      rule: detection.route ? { route: detection.route } : null,
    },
  });
}));

router.post('/cms-content', dashboardAccess, asyncHandler(async (req, res) => {
  const input = CmsContentSchema.parse(req.body);
  const [created] = await db.insert(cmsContent).values({
    ...input,
    createdBy: req.user!.id,
    publishedAt: input.status === 'published' ? new Date() : undefined,
    updatedAt: new Date(),
  }).returning();

  res.status(201).json({ success: true, data: created });
}));

router.put('/cms-content/:id', dashboardAccess, asyncHandler(async (req, res) => {
  const input = CmsContentSchema.partial().parse(req.body);
  const [updated] = await db.update(cmsContent).set({
    ...input,
    publishedAt: input.status === 'published' ? new Date() : undefined,
    updatedAt: new Date(),
  }).where(eq(cmsContent.id, req.params.id)).returning();

  if (!updated) return res.status(404).json({ success: false, error: 'CMS content not found' });
  res.json({ success: true, data: updated });
}));

router.get('/users', adminOnly, asyncHandler(async (_req, res) => {
  const rows = await db.select().from(users).orderBy(desc(users.createdAt)).limit(100);
  const usersWithRoles = await Promise.all(rows.map(async (user) => {
      const userRoles = await AuthService.getUserRoles(user.id);
      const roleNames = userRoles.map(r => r.name);
      return {
        id: user.id,
        email: user.email,
        roles: roleNames,
        isGuest: user.isGuest,
        isSuspended: user.isSuspended,
        suspensionReason: user.suspensionReason,
        mustChangePassword: user.mustChangePassword,
        createdAt: user.createdAt,
        lastActiveAt: user.lastActiveAt,
      };
    }));
  res.json({
    success: true,
    data: usersWithRoles,
  });
}));

const primaryRoleFor = (roles: string[]) => {
  if (roles.includes('admin') || roles.includes('super-admin') || roles.includes('system-admin')) return 'admin';
  if (roles.includes('counselor')) return 'counselor';
  if (roles.includes('moderator')) return 'moderator';
  if (roles.includes('user')) return 'user';
  return 'guest';
};

router.post('/users', superAdminOnly, asyncHandler(async (req, res) => {
  const input = CreateAdminUserSchema.parse(req.body);
  const email = input.email.trim().toLowerCase();
  const existing = await db.select().from(users).where(eq(users.email, email)).limit(1);

  if (existing.length) {
    return res.status(409).json({ success: false, error: 'A user with this email already exists.' });
  }

  const passwordHash = await bcrypt.hash(input.password, 12);
  const primaryRole = primaryRoleFor(input.roles);
  const [created] = await db.insert(users).values({
    email,
    passwordHash,
    isGuest: input.isGuest,
    mustChangePassword: input.mustChangePassword,
    updatedAt: new Date(),
  }).returning();

  // Assign roles to the new user
  if (input.roles && input.roles.length > 0) {
    for (const roleName of input.roles) {
      await AuthService.assignRole(created.id, roleName, req.user!.id);
    }
  }

  await db.insert(securityLogs).values({
    userId: req.user!.id,
    event: 'admin_user_created',
    ipAddress: req.ip,
    userAgent: req.get('user-agent'),
    metadata: { targetUserId: created.id, roles: input.roles },
  });

  res.status(201).json({
    success: true,
    data: {
      id: created.id,
      email: created.email,
      roles: input.roles,
      isGuest: created.isGuest,
      mustChangePassword: created.mustChangePassword,
      createdAt: created.createdAt,
    },
  }));

router.put('/users/:id', superAdminOnly, asyncHandler(async (req, res) => {
  const input = UpdateAdminUserSchema.parse(req.body);

  if (req.params.id === req.user!.id && input.roles && !input.roles.some((role) => ['super-admin', 'system-admin'].includes(role))) {
    return res.status(400).json({ success: false, error: 'You cannot remove your own top-level access.' });
  }

  const roleUpdate = input.roles ? {
    role: primaryRoleFor(input.roles) as any,
    roles: input.roles,
    isGuest: input.roles.includes('guest') && input.roles.length === 1,
  } : {};

  const [updated] = await db.update(users).set({
    ...roleUpdate,
    email: input.email ? input.email.trim().toLowerCase() : undefined,
    isSuspended: input.isSuspended,
    suspensionReason: input.isSuspended ? input.suspensionReason || 'Paused by an admin' : input.isSuspended === false ? null : undefined,
    suspendedAt: input.isSuspended === true ? new Date() : input.isSuspended === false ? null : undefined,
    mustChangePassword: input.mustChangePassword,
    updatedAt: new Date(),
  }).where(eq(users.id, req.params.id)).returning();

  if (!updated) {
    return res.status(404).json({ success: false, error: 'User not found.' });
  }

  await db.insert(securityLogs).values({
    userId: req.user!.id,
    event: 'user_updated',
    ipAddress: req.ip,
    userAgent: req.get('user-agent'),
    metadata: { targetUserId: req.params.id },
  });

  res.json({
    success: true,
    data: {
      id: updated.id,
      email: updated.email,
      isGuest: updated.isGuest,
      isSuspended: updated.isSuspended,
      suspensionReason: updated.suspensionReason,
      mustChangePassword: updated.mustChangePassword,
      updatedAt: updated.updatedAt,
    },
  });
}));

router.put('/users/:id/password', superAdminOnly, asyncHandler(async (req, res) => {
  const input = AdminSetPasswordSchema.parse(req.body);
  const passwordHash = await bcrypt.hash(input.password, 12);

  const [updated] = await db.update(users).set({
    passwordHash,
    mustChangePassword: input.mustChangePassword,
    updatedAt: new Date(),
  }).where(eq(users.id, req.params.id)).returning();

  if (!updated) {
    return res.status(404).json({ success: false, error: 'User not found.' });
  }

  await db.insert(securityLogs).values({
    userId: req.user!.id,
    event: 'user_password_set',
    ipAddress: req.ip,
    userAgent: req.get('user-agent'),
    metadata: { targetUserId: req.params.id, mustChangePassword: input.mustChangePassword },
  });

  res.json({ success: true, data: { id: updated.id, mustChangePassword: updated.mustChangePassword } });
}));

router.put('/users/:id/roles', superAdminOnly, asyncHandler(async (req, res) => {
  const input = UpdateUserRolesSchema.parse(req.body);

  if (req.params.id === req.user!.id && !input.roles.some((role) => ['super-admin', 'system-admin'].includes(role))) {
    return res.status(400).json({ success: false, error: 'You cannot remove your own top-level role.' });
  }

  const primaryRole = primaryRoleFor(input.roles);
  // Update user properties (excluding roles which are now managed separately)
  const [updated] = await db.update(users).set({
    isGuest: input.roles.includes('guest') && input.roles.length === 1,
    updatedAt: new Date(),
  }).where(eq(users.id, req.params.id)).returning();

  // Update roles using new role system
  if (input.roles && input.roles.length > 0) {
    // First, remove all existing roles
    await db.delete(userRoles).where(eq(userRoles.userId, req.params.id));
    
    // Then assign new roles
    for (const roleName of input.roles) {
      await AuthService.assignRole(req.params.id, roleName, req.user!.id);
    }
  }

  if (!updated) {
    return res.status(404).json({ success: false, error: 'User not found.' });
  }

  await db.insert(securityLogs).values({
    userId: req.user!.id,
    event: 'user_roles_updated',
    ipAddress: req.ip,
    userAgent: req.get('user-agent'),
    metadata: { targetUserId: req.params.id, roles: input.roles },
  });

  res.json({
    success: true,
    data: {
      id: updated.id,
      email: updated.email,
      role: updated.role,
    roles: updated.roles,
    isGuest: updated.isGuest,
    mustChangePassword: updated.mustChangePassword,
    updatedAt: updated.updatedAt,
  },
  });
}));

router.post('/users/:id/suspension', asyncHandler(async (req, res) => {
  if (!hasRole(req.user, 'super-admin') && !hasRole(req.user, 'system-admin')) {
    return res.status(403).json({ success: false, error: 'Super admin access required.' });
  }

  const suspended = Boolean(req.body.suspended);
  const [updated] = await db.update(users).set({
    isSuspended: suspended,
    suspensionReason: suspended ? String(req.body.reason || 'Suspended by admin') : null,
    suspendedAt: suspended ? new Date() : null,
    updatedAt: new Date(),
  }).where(eq(users.id, req.params.id)).returning();

  await db.insert(securityLogs).values({
    userId: req.user!.id,
    event: suspended ? 'user_suspended' : 'user_unsuspended',
    ipAddress: req.ip,
    userAgent: req.get('user-agent'),
    metadata: { targetUserId: req.params.id },
  });

  res.json({ success: true, data: updated });
}));

router.get('/security-logs', adminOnly, asyncHandler(async (_req, res) => {
  const rows = await db.select().from(securityLogs).orderBy(desc(securityLogs.createdAt)).limit(100);
  res.json({ success: true, data: rows });
}));

router.get('/audit-logs', adminOnly, asyncHandler(async (_req, res) => {
  const rows = await db.select().from(auditLogs).orderBy(desc(auditLogs.createdAt)).limit(100);
  res.json({ success: true, data: rows });
}));

export default router;
