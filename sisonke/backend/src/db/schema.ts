import { pgTable, uuid, varchar, text, boolean, timestamp, integer, jsonb, pgEnum } from 'drizzle-orm/pg-core';

// Enums
export const userRoleEnum = pgEnum('user_role', ['guest', 'user', 'admin']);
export const resourceCategoryEnum = pgEnum('resource_category', [
  'mental-health',
  'srhr', 
  'emergency',
  'substance-use',
  'wellness',
  'guide'
]);
export const questionCategoryEnum = pgEnum('question_category', [
  'mental-health',
  'srhr',
  'emergency',
  'relationships',
  'general'
]);
export const reportStatusEnum = pgEnum('report_status', ['pending', 'reviewed', 'resolved', 'dismissed']);
export const contentStatusEnum = pgEnum('content_status', ['draft', 'review', 'published', 'archived']);
export const analyticsEventEnum = pgEnum('analytics_event', [
  'app_opened',
  'resource_viewed',
  'resource_saved',
  'emergency_opened',
  'category_opened',
  'sync_completed',
  'sync_failed'
]);

// Users (optional accounts)
export const users = pgTable('users', {
  id: uuid('id').primaryKey().defaultRandom(),
  email: varchar('email', { length: 255 }).unique(),
  passwordHash: varchar('password_hash', { length: 255 }),
  role: userRoleEnum('role').default('guest'),
  deviceId: varchar('device_id', { length: 255 }).unique(),
  isGuest: boolean('is_guest').default(true),
  createdAt: timestamp('created_at').defaultNow(),
  updatedAt: timestamp('updated_at'),
  lastActiveAt: timestamp('last_active_at').defaultNow(),
});

// Resources (articles, guides, etc.)
export const resources = pgTable('resources', {
  id: uuid('id').primaryKey().defaultRandom(),
  title: varchar('title', { length: 255 }).notNull(),
  description: text('description').notNull(),
  content: text('content'),
  category: resourceCategoryEnum('category').notNull(),
  tags: varchar('tags', { length: 255 }).array(),
  authorId: uuid('author_id').references(() => users.id),
  imageUrl: varchar('image_url', { length: 255 }),
  readingTimeMinutes: integer('reading_time_minutes'),
  language: varchar('language', { length: 10 }).default('en'),
  status: contentStatusEnum('status').default('draft').notNull(),
  isPublished: boolean('is_published').default(true),
  isOfflineAvailable: boolean('is_offline_available').default(false),
  viewCount: integer('view_count').default(0),
  downloadCount: integer('download_count').default(0),
  createdAt: timestamp('created_at').defaultNow(),
  updatedAt: timestamp('updated_at'),
  publishedAt: timestamp('published_at'),
  deletedAt: timestamp('deleted_at'),
});

// Questions (anonymous Q&A)
export const questions = pgTable('questions', {
  id: uuid('id').primaryKey().defaultRandom(),
  title: varchar('title', { length: 300 }).notNull(),
  description: text('description').notNull(),
  category: questionCategoryEnum('category').notNull(),
  submittedAt: timestamp('submitted_at').defaultNow(),
  status: contentStatusEnum('status').default('draft').notNull(),
  isAnswered: boolean('is_answered').default(false),
  isPublished: boolean('is_published').default(false),
  flaggedForUrgent: boolean('flagged_for_urgent').default(false),
  viewCount: integer('view_count').default(0),
  helpfulCount: integer('helpful_count').default(0),
  deviceId: varchar('device_id', { length: 255 }), // For anonymous tracking
  createdAt: timestamp('created_at').defaultNow(),
  updatedAt: timestamp('updated_at'),
  publishedAt: timestamp('published_at'),
  deletedAt: timestamp('deleted_at'),
});

// Answers to questions
export const answers = pgTable('answers', {
  id: uuid('id').primaryKey().defaultRandom(),
  questionId: uuid('question_id').references(() => questions.id, { onDelete: 'cascade' }).notNull(),
  content: text('content').notNull(),
  expertName: varchar('expert_name', { length: 255 }),
  expertRole: varchar('expert_role', { length: 255 }),
  answeredAt: timestamp('answered_at').defaultNow(),
  helpfulCount: integer('helpful_count').default(0),
  isPublished: boolean('is_published').default(false),
  createdAt: timestamp('created_at').defaultNow(),
});

// User Bookmarks
export const bookmarks = pgTable('bookmarks', {
  id: uuid('id').primaryKey().defaultRandom(),
  userId: uuid('user_id').references(() => users.id, { onDelete: 'cascade' }).notNull(),
  resourceId: uuid('resource_id').references(() => resources.id, { onDelete: 'cascade' }).notNull(),
  createdAt: timestamp('created_at').defaultNow(),
});

// Reports (for content moderation)
export const reports = pgTable('reports', {
  id: uuid('id').primaryKey().defaultRandom(),
  type: varchar('type', { length: 50 }).notNull(), // 'question', 'answer', 'resource'
  resourceId: uuid('resource_id'),
  reason: varchar('reason', { length: 255 }).notNull(),
  description: text('description'),
  reporterDeviceId: varchar('reporter_device_id', { length: 255 }),
  status: reportStatusEnum('status').default('pending'),
  createdAt: timestamp('created_at').defaultNow(),
  reviewedAt: timestamp('reviewed_at'),
  reviewedBy: uuid('reviewed_by').references(() => users.id),
});

// Emergency Contacts
export const emergencyContacts = pgTable('emergency_contacts', {
  id: uuid('id').primaryKey().defaultRandom(),
  name: varchar('name', { length: 255 }).notNull(),
  phoneNumber: varchar('phone_number', { length: 50 }).notNull(),
  category: varchar('category', { length: 50 }).notNull(), // 'crisis', 'srhr', 'mental-health', 'general'
  description: text('description'),
  status: contentStatusEnum('status').default('published').notNull(),
  isActive: boolean('is_active').default(true),
  country: varchar('country', { length: 10 }).default('ZW'),
  createdAt: timestamp('created_at').defaultNow(),
  updatedAt: timestamp('updated_at'),
  publishedAt: timestamp('published_at').defaultNow(),
  deletedAt: timestamp('deleted_at'),
});

// Anonymous aggregate analytics events. Do not store private notes, journal text, or PII here.
export const analyticsEvents = pgTable('analytics_events', {
  id: uuid('id').primaryKey().defaultRandom(),
  event: analyticsEventEnum('event').notNull(),
  resourceId: uuid('resource_id'),
  category: varchar('category', { length: 80 }),
  platform: varchar('platform', { length: 40 }),
  appVersion: varchar('app_version', { length: 40 }),
  locale: varchar('locale', { length: 10 }),
  metadata: jsonb('metadata'),
  occurredAt: timestamp('occurred_at').defaultNow(),
});

// Mood Check-ins (stored locally, optional sync)
export const moodCheckins = pgTable('mood_checkins', {
  id: uuid('id').primaryKey().defaultRandom(),
  userId: uuid('user_id').references(() => users.id, { onDelete: 'cascade' }),
  deviceId: varchar('device_id', { length: 255 }),
  mood: varchar('mood', { length: 50 }).notNull(), // 'great', 'okay', 'low', 'anxious', 'angry', 'overwhelmed'
  energyLevel: integer('energy_level').notNull(), // 1-10
  note: text('note'),
  tags: varchar('tags', { length: 255 }).array(),
  checkinDate: timestamp('checkin_date').defaultNow(),
  createdAt: timestamp('created_at').defaultNow(),
});

// Journal Entries (encrypted locally, optional backup)
export const journalEntries = pgTable('journal_entries', {
  id: uuid('id').primaryKey().defaultRandom(),
  userId: uuid('user_id').references(() => users.id, { onDelete: 'cascade' }),
  deviceId: varchar('device_id', { length: 255 }),
  title: varchar('title', { length: 255 }),
  content: text('content').notNull(), // Encrypted content
  tags: varchar('tags', { length: 255 }).array(),
  isPrivate: boolean('is_private').default(true),
  entryDate: timestamp('entry_date').defaultNow(),
  createdAt: timestamp('created_at').defaultNow(),
  updatedAt: timestamp('updated_at'),
});

// Export types
export type User = typeof users.$inferSelect;
export type NewUser = typeof users.$inferInsert;
export type Resource = typeof resources.$inferSelect;
export type NewResource = typeof resources.$inferInsert;
export type Question = typeof questions.$inferSelect;
export type NewQuestion = typeof questions.$inferInsert;
export type Answer = typeof answers.$inferSelect;
export type NewAnswer = typeof answers.$inferInsert;
export type Bookmark = typeof bookmarks.$inferSelect;
export type NewBookmark = typeof bookmarks.$inferInsert;
export type Report = typeof reports.$inferSelect;
export type NewReport = typeof reports.$inferInsert;
export type EmergencyContact = typeof emergencyContacts.$inferSelect;
export type NewEmergencyContact = typeof emergencyContacts.$inferInsert;
export type AnalyticsEvent = typeof analyticsEvents.$inferSelect;
export type NewAnalyticsEvent = typeof analyticsEvents.$inferInsert;
export type MoodCheckin = typeof moodCheckins.$inferSelect;
export type NewMoodCheckin = typeof moodCheckins.$inferInsert;
export type JournalEntry = typeof journalEntries.$inferSelect;
export type NewJournalEntry = typeof journalEntries.$inferInsert;
