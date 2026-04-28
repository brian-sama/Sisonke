"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.journalEntries = exports.moodCheckins = exports.analyticsEvents = exports.emergencyContacts = exports.reports = exports.bookmarks = exports.answers = exports.questions = exports.resources = exports.users = exports.analyticsEventEnum = exports.contentStatusEnum = exports.reportStatusEnum = exports.questionCategoryEnum = exports.resourceCategoryEnum = exports.userRoleEnum = void 0;
const pg_core_1 = require("drizzle-orm/pg-core");
// Enums
exports.userRoleEnum = (0, pg_core_1.pgEnum)('user_role', ['guest', 'user', 'admin']);
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
    'sync_completed',
    'sync_failed'
]);
// Users (optional accounts)
exports.users = (0, pg_core_1.pgTable)('users', {
    id: (0, pg_core_1.uuid)('id').primaryKey().defaultRandom(),
    email: (0, pg_core_1.varchar)('email', { length: 255 }).unique(),
    passwordHash: (0, pg_core_1.varchar)('password_hash', { length: 255 }),
    role: (0, exports.userRoleEnum)('role').default('guest'),
    deviceId: (0, pg_core_1.varchar)('device_id', { length: 255 }).unique(),
    isGuest: (0, pg_core_1.boolean)('is_guest').default(true),
    createdAt: (0, pg_core_1.timestamp)('created_at').defaultNow(),
    updatedAt: (0, pg_core_1.timestamp)('updated_at'),
    lastActiveAt: (0, pg_core_1.timestamp)('last_active_at').defaultNow(),
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
//# sourceMappingURL=schema.js.map