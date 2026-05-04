import { Router } from 'express';
import bcrypt from 'bcryptjs';
import { desc, eq, gte, isNull } from 'drizzle-orm';
import { db } from '../db';
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
} from '../db/schema';
import { authMiddleware, adminOnly, hasRole, superAdminOnly } from '../middleware/auth';
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

const router = Router();

router.use(authMiddleware, adminOnly);

router.get('/me', asyncHandler(async (req, res) => {
  res.json({ success: true, data: { user: req.user } });
}));

router.get('/overview', asyncHandler(async (_req, res) => {
  const [allUsers, allResources, allContacts, allQuestions, events, allCases, allChatbotSessions, pendingCommunityPosts] = await Promise.all([
    db.select().from(users),
    db.select().from(resources).where(isNull(resources.deletedAt)),
    db.select().from(emergencyContacts).where(isNull(emergencyContacts.deletedAt)),
    db.select().from(questions).where(isNull(questions.deletedAt)),
    db.select().from(analyticsEvents).orderBy(desc(analyticsEvents.occurredAt)).limit(500),
    db.select().from(counselorCases),
    db.select().from(chatbotSessions),
    db.select().from(communityPosts).where(eq(communityPosts.status, 'pending')),
  ]);

  const countBy = <T extends { status: string }>(items: T[]) =>
    items.reduce<Record<string, number>>((acc, item) => {
      acc[item.status] = (acc[item.status] || 0) + 1;
      return acc;
    }, {});

  const eventCounts = events.reduce<Record<string, number>>((acc, event) => {
    acc[event.event] = (acc[event.event] || 0) + 1;
    return acc;
  }, {});

  res.json({
    success: true,
    data: {
      users: {
        total: allUsers.length,
        guests: allUsers.filter((user) => user.isGuest).length,
        admins: allUsers.filter((user) => user.roles?.includes('admin') || user.roles?.includes('super-admin') || user.role === 'admin').length,
      },
      resources: { total: allResources.length, byStatus: countBy(allResources) },
      emergencyContacts: { total: allContacts.length, byStatus: countBy(allContacts) },
      questions: { total: allQuestions.length, byStatus: countBy(allQuestions) },
      analytics: eventCounts,
      chatbotSessions: { total: allChatbotSessions.length, highRisk: allChatbotSessions.filter((item) => item.riskLevel === 'high').length },
      counselorCases: {
        total: allCases.length,
        waiting: allCases.filter((item) => ['requested', 'assigned', 'emergency'].includes(item.status)).length,
        highRisk: allCases.filter((item) => item.riskLevel === 'high' || item.status === 'emergency').length,
      },
      communityPosts: { pending: pendingCommunityPosts.length },
    },
  });
}));

router.get('/resources', asyncHandler(async (_req, res) => {
  const rows = await db
    .select()
    .from(resources)
    .where(isNull(resources.deletedAt))
    .orderBy(desc(resources.updatedAt), desc(resources.createdAt));

  res.json({ success: true, data: rows });
}));

router.post('/resources', asyncHandler(async (req, res) => {
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

router.put('/resources/:id', asyncHandler(async (req, res) => {
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

router.post('/resources/:id/publish', asyncHandler(async (req, res) => {
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

router.post('/resources/:id/archive', asyncHandler(async (req, res) => {
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

router.get('/emergency-contacts', asyncHandler(async (_req, res) => {
  const rows = await db
    .select()
    .from(emergencyContacts)
    .where(isNull(emergencyContacts.deletedAt))
    .orderBy(emergencyContacts.category, emergencyContacts.name);

  res.json({ success: true, data: rows });
}));

router.post('/emergency-contacts', asyncHandler(async (req, res) => {
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

router.put('/emergency-contacts/:id', asyncHandler(async (req, res) => {
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

router.get('/analytics', asyncHandler(async (req, res) => {
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
      if (timeSeries[d] && (c.riskLevel === 'high' || c.status === 'emergency')) {
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

router.get('/counselor-cases', asyncHandler(async (_req, res) => {
  const rows = await db
    .select()
    .from(counselorCases)
    .orderBy(desc(counselorCases.createdAt))
    .limit(100);

  res.json({ success: true, data: rows });
}));

router.post('/counselor-cases/:id/status', asyncHandler(async (req, res) => {
  const status = String(req.body.status || '');
  const allowed = ['requested', 'assigned', 'live', 'follow-up', 'resolved', 'emergency'];
  if (!allowed.includes(status)) return res.status(400).json({ success: false, error: 'Invalid status' });

  const [updated] = await db.update(counselorCases).set({
    status: status as any,
    followUpAt: req.body.followUpAt ? new Date(req.body.followUpAt) : undefined,
    resolvedAt: status === 'resolved' ? new Date() : undefined,
    updatedAt: new Date(),
  }).where(eq(counselorCases.id, req.params.id)).returning();

  res.json({ success: true, data: updated });
}));

router.post('/counselor-cases/:id/notes', asyncHandler(async (req, res) => {
  const note = String(req.body.note || '').trim();
  if (!note) return res.status(400).json({ success: false, error: 'Note is required' });

  await db.insert(securityLogs).values({
    userId: req.user!.id,
    event: 'counselor_note_added',
    ipAddress: req.ip,
    userAgent: req.get('user-agent'),
    metadata: { caseId: req.params.id },
  });

  res.status(201).json({ success: true });
}));

router.get('/community-posts', asyncHandler(async (_req, res) => {
  const rows = await db
    .select()
    .from(communityPosts)
    .orderBy(desc(communityPosts.createdAt))
    .limit(100);

  res.json({ success: true, data: rows });
}));

router.post('/community-posts/:id/moderate', asyncHandler(async (req, res) => {
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

  res.json({ success: true, data: updated });
}));

router.get('/reports', asyncHandler(async (_req, res) => {
  const rows = await db.select().from(reports).orderBy(desc(reports.createdAt)).limit(100);
  res.json({ success: true, data: rows });
}));

router.post('/reports/:id/status', asyncHandler(async (req, res) => {
  const status = String(req.body.status || '');
  if (!['pending', 'reviewed', 'resolved', 'dismissed'].includes(status)) {
    return res.status(400).json({ success: false, error: 'Invalid report status' });
  }

  const [updated] = await db.update(reports).set({
    status: status as any,
    reviewedAt: new Date(),
    reviewedBy: req.user!.id,
  }).where(eq(reports.id, req.params.id)).returning();

  res.json({ success: true, data: updated });
}));

router.get('/cms-content', asyncHandler(async (_req, res) => {
  const rows = await db.select().from(cmsContent).orderBy(desc(cmsContent.createdAt)).limit(100);
  res.json({ success: true, data: rows });
}));

router.get('/faqs', asyncHandler(async (_req, res) => {
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

router.get('/safety-rules', asyncHandler(async (_req, res) => {
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

router.post('/safety-rules/test', asyncHandler(async (req, res) => {
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

router.post('/cms-content', asyncHandler(async (req, res) => {
  const input = CmsContentSchema.parse(req.body);
  const [created] = await db.insert(cmsContent).values({
    ...input,
    createdBy: req.user!.id,
    publishedAt: input.status === 'published' ? new Date() : undefined,
    updatedAt: new Date(),
  }).returning();

  res.status(201).json({ success: true, data: created });
}));

router.put('/cms-content/:id', asyncHandler(async (req, res) => {
  const input = CmsContentSchema.partial().parse(req.body);
  const [updated] = await db.update(cmsContent).set({
    ...input,
    publishedAt: input.status === 'published' ? new Date() : undefined,
    updatedAt: new Date(),
  }).where(eq(cmsContent.id, req.params.id)).returning();

  if (!updated) return res.status(404).json({ success: false, error: 'CMS content not found' });
  res.json({ success: true, data: updated });
}));

router.get('/users', asyncHandler(async (_req, res) => {
  const rows = await db.select().from(users).orderBy(desc(users.createdAt)).limit(100);
  res.json({
    success: true,
    data: rows.map((user) => ({
      id: user.id,
      email: user.email,
      role: user.role,
      roles: user.roles?.length ? user.roles : [user.role || 'guest'],
      isGuest: user.isGuest,
      isSuspended: user.isSuspended,
      suspensionReason: user.suspensionReason,
      mustChangePassword: user.mustChangePassword,
      createdAt: user.createdAt,
      lastActiveAt: user.lastActiveAt,
    })),
  });
}));

const primaryRoleFor = (roles: string[]) => {
  if (roles.includes('admin') || roles.includes('super-admin')) return 'admin';
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
    role: primaryRole as any,
    roles: input.roles,
    isGuest: input.isGuest,
    mustChangePassword: input.mustChangePassword,
    updatedAt: new Date(),
  }).returning();

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
      role: created.role,
      roles: created.roles,
      isGuest: created.isGuest,
      mustChangePassword: created.mustChangePassword,
      createdAt: created.createdAt,
    },
  });
}));

router.put('/users/:id', superAdminOnly, asyncHandler(async (req, res) => {
  const input = UpdateAdminUserSchema.parse(req.body);

  if (req.params.id === req.user!.id && input.roles && !input.roles.includes('super-admin')) {
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
      role: updated.role,
      roles: updated.roles,
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

  if (req.params.id === req.user!.id && !input.roles.includes('super-admin')) {
    return res.status(400).json({ success: false, error: 'You cannot remove your own super-admin role.' });
  }

  const primaryRole = primaryRoleFor(input.roles);
  const [updated] = await db.update(users).set({
    role: primaryRole as any,
    roles: input.roles,
    isGuest: input.roles.includes('guest') && input.roles.length === 1,
    updatedAt: new Date(),
  }).where(eq(users.id, req.params.id)).returning();

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
  if (!hasRole(req.user, 'super-admin')) {
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

router.get('/security-logs', asyncHandler(async (_req, res) => {
  const rows = await db.select().from(securityLogs).orderBy(desc(securityLogs.createdAt)).limit(100);
  res.json({ success: true, data: rows });
}));

export default router;
