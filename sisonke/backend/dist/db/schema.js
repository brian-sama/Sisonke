"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.securityLogs = exports.notifications = exports.cmsContent = exports.communityPosts = exports.counselorNotes = exports.counselingMessages = exports.counselorCases = exports.chatbotMessages = exports.chatbotSessions = exports.journalEntries = exports.moodCheckins = exports.analyticsEvents = exports.emergencyContacts = exports.reports = exports.bookmarks = exports.answers = exports.questions = exports.resources = exports.userProfiles = exports.auditLogs = exports.users = exports.analyticsEventEnum = exports.contentStatusEnum = exports.reportStatusEnum = exports.questionCategoryEnum = exports.resourceCategoryEnum = exports.cmsContentTypeEnum = exports.communityPostStatusEnum = exports.counselorCaseStatusEnum = exports.riskLevelEnum = exports.chatbotPersonaEnum = exports.ageGroupEnum = exports.userRoleEnum = void 0;
const pg_core_1 = require("drizzle-orm/pg-core");
// Enums
exports.userRoleEnum = (0, pg_core_1.pgEnum)('user_role', ['guest', 'user', 'counselor', 'moderator', 'admin']);
exports.ageGroupEnum = (0, pg_core_1.pgEnum)('age_group', ['13-15', '16-17', '18-24', '25+']);
exports.chatbotPersonaEnum = (0, pg_core_1.pgEnum)('chatbot_persona', ['male', 'female']);
exports.riskLevelEnum = (0, pg_core_1.pgEnum)('risk_level', ['low', 'medium', 'high']);
exports.counselorCaseStatusEnum = (0, pg_core_1.pgEnum)('counselor_case_status', ['requested', 'assigned', 'live', 'follow-up', 'resolved', 'emergency']);
exports.communityPostStatusEnum = (0, pg_core_1.pgEnum)('community_post_status', ['pending', 'approved', 'removed']);
exports.cmsContentTypeEnum = (0, pg_core_1.pgEnum)('cms_content_type', ['article', 'srhr', 'event', 'helpline', 'faq', 'video', 'daily-prompt', 'announcement']);
exports.resourceCategoryEnum = (0, pg_core_1.pgEnum)('resource_category', [
    'mental-health',
    'srhr',
    'emergency',
    'substance-use',
    'wellness',
    'guide'
]);
exports.questionCategoryEnum = (0, pg_core_1.pgEnum)('question_category', [
    'mental-health',
    'srhr',
    'emergency',
    'relationships',
    'general'
]);
exports.reportStatusEnum = (0, pg_core_1.pgEnum)('report_status', ['pending', 'reviewed', 'resolved', 'dismissed']);
exports.contentStatusEnum = (0, pg_core_1.pgEnum)('content_status', ['draft', 'review', 'published', 'archived']);
exports.analyticsEventEnum = (0, pg_core_1.pgEnum)('analytics_event', [
    'app_opened',
    'resource_viewed',
    'resource_saved',
    'emergency_opened',
    'category_opened',
    'chatbot_session_started',
    'counselor_escalated',
    'community_post_submitted',
    'mood_logged',
    'sync_completed',
    'sync_failed'
]);
// Users (optional accounts)
exports.users = (0, pg_core_1.pgTable)('users', {
    id: (0, pg_core_1.uuid)('id').primaryKey().defaultRandom(),
    email: (0, pg_core_1.varchar)('email', { length: 255 }).unique(),
    passwordHash: (0, pg_core_1.varchar)('password_hash', { length: 255 }),
    role: (0, exports.userRoleEnum)('role').default('guest'),
    roles: (0, pg_core_1.varchar)('roles', { length: 40 }).array().default(['guest']),
    deviceId: (0, pg_core_1.varchar)('device_id', { length: 255 }).unique(),
    isGuest: (0, pg_core_1.boolean)('is_guest').default(true),
    isSuspended: (0, pg_core_1.boolean)('is_suspended').default(false),
    suspensionReason: (0, pg_core_1.text)('suspension_reason'),
    suspendedAt: (0, pg_core_1.timestamp)('suspended_at'),
    mustChangePassword: (0, pg_core_1.boolean)('must_change_password').default(false),
    createdAt: (0, pg_core_1.timestamp)('created_at').defaultNow(),
    updatedAt: (0, pg_core_1.timestamp)('updated_at'),
    deletedAt: (0, pg_core_1.timestamp)('deleted_at'),
    lastActiveAt: (0, pg_core_1.timestamp)('last_active_at').defaultNow(),
});
exports.auditLogs = (0, pg_core_1.pgTable)('audit_logs', {
    id: (0, pg_core_1.uuid)('id').primaryKey().defaultRandom(),
    actorId: (0, pg_core_1.uuid)('actor_id').references(() => exports.users.id, { onDelete: 'set null' }),
    action: (0, pg_core_1.varchar)('action', { length: 120 }).notNull(),
    entityType: (0, pg_core_1.varchar)('entity_type', { length: 50 }), // 'user', 'resource', 'post', etc.
    entityId: (0, pg_core_1.uuid)('entity_id'),
    metadata: (0, pg_core_1.jsonb)('metadata'),
    createdAt: (0, pg_core_1.timestamp)('created_at').defaultNow(),
});
exports.userProfiles = (0, pg_core_1.pgTable)('user_profiles', {
    id: (0, pg_core_1.uuid)('id').primaryKey().defaultRandom(),
    userId: (0, pg_core_1.uuid)('user_id').references(() => exports.users.id, { onDelete: 'cascade' }).notNull(),
    nickname: (0, pg_core_1.varchar)('nickname', { length: 120 }).notNull(),
    dateOfBirth: (0, pg_core_1.timestamp)('date_of_birth'),
    ageGroup: (0, exports.ageGroupEnum)('age_group').notNull(),
    gender: (0, pg_core_1.varchar)('gender', { length: 80 }),
    location: (0, pg_core_1.varchar)('location', { length: 120 }),
    consentAcceptedAt: (0, pg_core_1.timestamp)('consent_accepted_at'),
    chatbotPersona: (0, exports.chatbotPersonaEnum)('chatbot_persona').default('female'),
    screeningAnswers: (0, pg_core_1.jsonb)('screening_answers'),
    pinEnabled: (0, pg_core_1.boolean)('pin_enabled').default(false),
    biometricEnabled: (0, pg_core_1.boolean)('biometric_enabled').default(false),
    autoLockMinutes: (0, pg_core_1.integer)('auto_lock_minutes').default(5),
    hideJournalPreview: (0, pg_core_1.boolean)('hide_journal_preview').default(true),
    createdAt: (0, pg_core_1.timestamp)('created_at').defaultNow(),
    updatedAt: (0, pg_core_1.timestamp)('updated_at'),
});
// Resources (articles, guides, etc.)
exports.resources = (0, pg_core_1.pgTable)('resources', {
    id: (0, pg_core_1.uuid)('id').primaryKey().defaultRandom(),
    title: (0, pg_core_1.varchar)('title', { length: 255 }).notNull(),
    description: (0, pg_core_1.text)('description').notNull(),
    content: (0, pg_core_1.text)('content'),
    category: (0, exports.resourceCategoryEnum)('category').notNull(),
    tags: (0, pg_core_1.varchar)('tags', { length: 255 }).array(),
    authorId: (0, pg_core_1.uuid)('author_id').references(() => exports.users.id),
    imageUrl: (0, pg_core_1.varchar)('image_url', { length: 255 }),
    readingTimeMinutes: (0, pg_core_1.integer)('reading_time_minutes'),
    language: (0, pg_core_1.varchar)('language', { length: 10 }).default('en'),
    status: (0, exports.contentStatusEnum)('status').default('draft').notNull(),
    isPublished: (0, pg_core_1.boolean)('is_published').default(true),
    isOfflineAvailable: (0, pg_core_1.boolean)('is_offline_available').default(false),
    viewCount: (0, pg_core_1.integer)('view_count').default(0),
    downloadCount: (0, pg_core_1.integer)('download_count').default(0),
    createdAt: (0, pg_core_1.timestamp)('created_at').defaultNow(),
    updatedAt: (0, pg_core_1.timestamp)('updated_at'),
    publishedAt: (0, pg_core_1.timestamp)('published_at'),
    deletedAt: (0, pg_core_1.timestamp)('deleted_at'),
});
// Questions (anonymous Q&A)
exports.questions = (0, pg_core_1.pgTable)('questions', {
    id: (0, pg_core_1.uuid)('id').primaryKey().defaultRandom(),
    title: (0, pg_core_1.varchar)('title', { length: 300 }).notNull(),
    description: (0, pg_core_1.text)('description').notNull(),
    category: (0, exports.questionCategoryEnum)('category').notNull(),
    submittedAt: (0, pg_core_1.timestamp)('submitted_at').defaultNow(),
    status: (0, exports.contentStatusEnum)('status').default('draft').notNull(),
    isAnswered: (0, pg_core_1.boolean)('is_answered').default(false),
    isPublished: (0, pg_core_1.boolean)('is_published').default(false),
    flaggedForUrgent: (0, pg_core_1.boolean)('flagged_for_urgent').default(false),
    viewCount: (0, pg_core_1.integer)('view_count').default(0),
    helpfulCount: (0, pg_core_1.integer)('helpful_count').default(0),
    deviceId: (0, pg_core_1.varchar)('device_id', { length: 255 }), // For anonymous tracking
    createdAt: (0, pg_core_1.timestamp)('created_at').defaultNow(),
    updatedAt: (0, pg_core_1.timestamp)('updated_at'),
    publishedAt: (0, pg_core_1.timestamp)('published_at'),
    deletedAt: (0, pg_core_1.timestamp)('deleted_at'),
});
// Answers to questions
exports.answers = (0, pg_core_1.pgTable)('answers', {
    id: (0, pg_core_1.uuid)('id').primaryKey().defaultRandom(),
    questionId: (0, pg_core_1.uuid)('question_id').references(() => exports.questions.id, { onDelete: 'cascade' }).notNull(),
    content: (0, pg_core_1.text)('content').notNull(),
    expertName: (0, pg_core_1.varchar)('expert_name', { length: 255 }),
    expertRole: (0, pg_core_1.varchar)('expert_role', { length: 255 }),
    answeredAt: (0, pg_core_1.timestamp)('answered_at').defaultNow(),
    helpfulCount: (0, pg_core_1.integer)('helpful_count').default(0),
    isPublished: (0, pg_core_1.boolean)('is_published').default(false),
    createdAt: (0, pg_core_1.timestamp)('created_at').defaultNow(),
});
// User Bookmarks
exports.bookmarks = (0, pg_core_1.pgTable)('bookmarks', {
    id: (0, pg_core_1.uuid)('id').primaryKey().defaultRandom(),
    userId: (0, pg_core_1.uuid)('user_id').references(() => exports.users.id, { onDelete: 'cascade' }).notNull(),
    resourceId: (0, pg_core_1.uuid)('resource_id').references(() => exports.resources.id, { onDelete: 'cascade' }).notNull(),
    createdAt: (0, pg_core_1.timestamp)('created_at').defaultNow(),
});
// Reports (for content moderation)
exports.reports = (0, pg_core_1.pgTable)('reports', {
    id: (0, pg_core_1.uuid)('id').primaryKey().defaultRandom(),
    type: (0, pg_core_1.varchar)('type', { length: 50 }).notNull(), // 'question', 'answer', 'resource'
    resourceId: (0, pg_core_1.uuid)('resource_id'),
    reason: (0, pg_core_1.varchar)('reason', { length: 255 }).notNull(),
    description: (0, pg_core_1.text)('description'),
    reporterDeviceId: (0, pg_core_1.varchar)('reporter_device_id', { length: 255 }),
    status: (0, exports.reportStatusEnum)('status').default('pending'),
    createdAt: (0, pg_core_1.timestamp)('created_at').defaultNow(),
    reviewedAt: (0, pg_core_1.timestamp)('reviewed_at'),
    reviewedBy: (0, pg_core_1.uuid)('reviewed_by').references(() => exports.users.id),
});
// Emergency Contacts
exports.emergencyContacts = (0, pg_core_1.pgTable)('emergency_contacts', {
    id: (0, pg_core_1.uuid)('id').primaryKey().defaultRandom(),
    name: (0, pg_core_1.varchar)('name', { length: 255 }).notNull(),
    phoneNumber: (0, pg_core_1.varchar)('phone_number', { length: 50 }).notNull(),
    category: (0, pg_core_1.varchar)('category', { length: 50 }).notNull(), // 'crisis', 'srhr', 'mental-health', 'general'
    description: (0, pg_core_1.text)('description'),
    status: (0, exports.contentStatusEnum)('status').default('published').notNull(),
    isActive: (0, pg_core_1.boolean)('is_active').default(true),
    country: (0, pg_core_1.varchar)('country', { length: 10 }).default('ZW'),
    createdAt: (0, pg_core_1.timestamp)('created_at').defaultNow(),
    updatedAt: (0, pg_core_1.timestamp)('updated_at'),
    publishedAt: (0, pg_core_1.timestamp)('published_at').defaultNow(),
    deletedAt: (0, pg_core_1.timestamp)('deleted_at'),
});
// Anonymous aggregate analytics events. Do not store private notes, journal text, or PII here.
exports.analyticsEvents = (0, pg_core_1.pgTable)('analytics_events', {
    id: (0, pg_core_1.uuid)('id').primaryKey().defaultRandom(),
    event: (0, exports.analyticsEventEnum)('event').notNull(),
    resourceId: (0, pg_core_1.uuid)('resource_id'),
    category: (0, pg_core_1.varchar)('category', { length: 80 }),
    platform: (0, pg_core_1.varchar)('platform', { length: 40 }),
    appVersion: (0, pg_core_1.varchar)('app_version', { length: 40 }),
    locale: (0, pg_core_1.varchar)('locale', { length: 10 }),
    metadata: (0, pg_core_1.jsonb)('metadata'),
    occurredAt: (0, pg_core_1.timestamp)('occurred_at').defaultNow(),
});
// Mood Check-ins (stored locally, optional sync)
exports.moodCheckins = (0, pg_core_1.pgTable)('mood_checkins', {
    id: (0, pg_core_1.uuid)('id').primaryKey().defaultRandom(),
    userId: (0, pg_core_1.uuid)('user_id').references(() => exports.users.id, { onDelete: 'cascade' }),
    deviceId: (0, pg_core_1.varchar)('device_id', { length: 255 }),
    mood: (0, pg_core_1.varchar)('mood', { length: 50 }).notNull(), // 'great', 'okay', 'low', 'anxious', 'angry', 'overwhelmed'
    energyLevel: (0, pg_core_1.integer)('energy_level').notNull(), // 1-10
    note: (0, pg_core_1.text)('note'),
    tags: (0, pg_core_1.varchar)('tags', { length: 255 }).array(),
    checkinDate: (0, pg_core_1.timestamp)('checkin_date').defaultNow(),
    createdAt: (0, pg_core_1.timestamp)('created_at').defaultNow(),
});
// Journal Entries (encrypted locally, optional backup)
exports.journalEntries = (0, pg_core_1.pgTable)('journal_entries', {
    id: (0, pg_core_1.uuid)('id').primaryKey().defaultRandom(),
    userId: (0, pg_core_1.uuid)('user_id').references(() => exports.users.id, { onDelete: 'cascade' }),
    deviceId: (0, pg_core_1.varchar)('device_id', { length: 255 }),
    title: (0, pg_core_1.varchar)('title', { length: 255 }),
    content: (0, pg_core_1.text)('content').notNull(), // Encrypted content
    tags: (0, pg_core_1.varchar)('tags', { length: 255 }).array(),
    isPrivate: (0, pg_core_1.boolean)('is_private').default(true),
    entryDate: (0, pg_core_1.timestamp)('entry_date').defaultNow(),
    createdAt: (0, pg_core_1.timestamp)('created_at').defaultNow(),
    updatedAt: (0, pg_core_1.timestamp)('updated_at'),
});
exports.chatbotSessions = (0, pg_core_1.pgTable)('chatbot_sessions', {
    id: (0, pg_core_1.uuid)('id').primaryKey().defaultRandom(),
    userId: (0, pg_core_1.uuid)('user_id').references(() => exports.users.id, { onDelete: 'cascade' }),
    deviceId: (0, pg_core_1.varchar)('device_id', { length: 255 }),
    persona: (0, exports.chatbotPersonaEnum)('persona').notNull(),
    riskLevel: (0, exports.riskLevelEnum)('risk_level').default('low'),
    escalatedCaseId: (0, pg_core_1.uuid)('escalated_case_id'),
    summary: (0, pg_core_1.text)('summary'),
    createdAt: (0, pg_core_1.timestamp)('created_at').defaultNow(),
    updatedAt: (0, pg_core_1.timestamp)('updated_at'),
});
exports.chatbotMessages = (0, pg_core_1.pgTable)('chatbot_messages', {
    id: (0, pg_core_1.uuid)('id').primaryKey().defaultRandom(),
    sessionId: (0, pg_core_1.uuid)('session_id').references(() => exports.chatbotSessions.id, { onDelete: 'cascade' }).notNull(),
    sender: (0, pg_core_1.varchar)('sender', { length: 20 }).notNull(),
    content: (0, pg_core_1.text)('content').notNull(),
    riskLevel: (0, exports.riskLevelEnum)('risk_level').default('low'),
    createdAt: (0, pg_core_1.timestamp)('created_at').defaultNow(),
});
exports.counselorCases = (0, pg_core_1.pgTable)('counselor_cases', {
    id: (0, pg_core_1.uuid)('id').primaryKey().defaultRandom(),
    userId: (0, pg_core_1.uuid)('user_id').references(() => exports.users.id, { onDelete: 'cascade' }),
    counselorId: (0, pg_core_1.uuid)('counselor_id').references(() => exports.users.id),
    issueCategory: (0, pg_core_1.varchar)('issue_category', { length: 120 }).notNull(),
    status: (0, exports.counselorCaseStatusEnum)('status').default('requested').notNull(),
    riskLevel: (0, exports.riskLevelEnum)('risk_level').default('medium').notNull(),
    source: (0, pg_core_1.varchar)('source', { length: 40 }).default('mobile'),
    summary: (0, pg_core_1.text)('summary'),
    followUpAt: (0, pg_core_1.timestamp)('follow_up_at'),
    createdAt: (0, pg_core_1.timestamp)('created_at').defaultNow(),
    updatedAt: (0, pg_core_1.timestamp)('updated_at'),
    resolvedAt: (0, pg_core_1.timestamp)('resolved_at'),
});
exports.counselingMessages = (0, pg_core_1.pgTable)('counseling_messages', {
    id: (0, pg_core_1.uuid)('id').primaryKey().defaultRandom(),
    caseId: (0, pg_core_1.uuid)('case_id').references(() => exports.counselorCases.id, { onDelete: 'cascade' }).notNull(),
    senderUserId: (0, pg_core_1.uuid)('sender_user_id').references(() => exports.users.id),
    senderRole: (0, pg_core_1.varchar)('sender_role', { length: 30 }).notNull(),
    content: (0, pg_core_1.text)('content').notNull(),
    createdAt: (0, pg_core_1.timestamp)('created_at').defaultNow(),
});
exports.counselorNotes = (0, pg_core_1.pgTable)('counselor_notes', {
    id: (0, pg_core_1.uuid)('id').primaryKey().defaultRandom(),
    caseId: (0, pg_core_1.uuid)('case_id').references(() => exports.counselorCases.id, { onDelete: 'cascade' }).notNull(),
    counselorId: (0, pg_core_1.uuid)('counselor_id').references(() => exports.users.id).notNull(),
    note: (0, pg_core_1.text)('note').notNull(),
    createdAt: (0, pg_core_1.timestamp)('created_at').defaultNow(),
});
exports.communityPosts = (0, pg_core_1.pgTable)('community_posts', {
    id: (0, pg_core_1.uuid)('id').primaryKey().defaultRandom(),
    userId: (0, pg_core_1.uuid)('user_id').references(() => exports.users.id, { onDelete: 'set null' }),
    ageGroup: (0, exports.ageGroupEnum)('age_group').notNull(),
    content: (0, pg_core_1.text)('content').notNull(),
    status: (0, exports.communityPostStatusEnum)('status').default('pending').notNull(),
    moderationReason: (0, pg_core_1.text)('moderation_reason'),
    reportCount: (0, pg_core_1.integer)('report_count').default(0),
    createdAt: (0, pg_core_1.timestamp)('created_at').defaultNow(),
    reviewedAt: (0, pg_core_1.timestamp)('reviewed_at'),
    reviewedBy: (0, pg_core_1.uuid)('reviewed_by').references(() => exports.users.id),
    removedAt: (0, pg_core_1.timestamp)('removed_at'),
});
exports.cmsContent = (0, pg_core_1.pgTable)('cms_content', {
    id: (0, pg_core_1.uuid)('id').primaryKey().defaultRandom(),
    title: (0, pg_core_1.varchar)('title', { length: 255 }).notNull(),
    body: (0, pg_core_1.text)('body').notNull(),
    contentType: (0, exports.cmsContentTypeEnum)('content_type').notNull(),
    category: (0, pg_core_1.varchar)('category', { length: 80 }).notNull(),
    mediaUrl: (0, pg_core_1.varchar)('media_url', { length: 255 }),
    status: (0, exports.contentStatusEnum)('status').default('draft').notNull(),
    createdBy: (0, pg_core_1.uuid)('created_by').references(() => exports.users.id),
    createdAt: (0, pg_core_1.timestamp)('created_at').defaultNow(),
    updatedAt: (0, pg_core_1.timestamp)('updated_at'),
    publishedAt: (0, pg_core_1.timestamp)('published_at'),
});
exports.notifications = (0, pg_core_1.pgTable)('notifications', {
    id: (0, pg_core_1.uuid)('id').primaryKey().defaultRandom(),
    userId: (0, pg_core_1.uuid)('user_id').references(() => exports.users.id, { onDelete: 'cascade' }),
    channel: (0, pg_core_1.varchar)('channel', { length: 40 }).notNull(),
    title: (0, pg_core_1.varchar)('title', { length: 180 }).notNull(),
    body: (0, pg_core_1.text)('body').notNull(),
    metadata: (0, pg_core_1.jsonb)('metadata'),
    readAt: (0, pg_core_1.timestamp)('read_at'),
    createdAt: (0, pg_core_1.timestamp)('created_at').defaultNow(),
});
exports.securityLogs = (0, pg_core_1.pgTable)('security_logs', {
    id: (0, pg_core_1.uuid)('id').primaryKey().defaultRandom(),
    userId: (0, pg_core_1.uuid)('user_id').references(() => exports.users.id, { onDelete: 'set null' }),
    event: (0, pg_core_1.varchar)('event', { length: 120 }).notNull(),
    ipAddress: (0, pg_core_1.varchar)('ip_address', { length: 80 }),
    userAgent: (0, pg_core_1.text)('user_agent'),
    metadata: (0, pg_core_1.jsonb)('metadata'),
    createdAt: (0, pg_core_1.timestamp)('created_at').defaultNow(),
});
//# sourceMappingURL=schema.js.map