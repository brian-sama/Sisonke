import { z } from 'zod';

// Auth schemas
export const LoginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(6),
});

export const RegisterSchema = z.object({
  email: z.string().email(),
  password: z.string().min(6),
});

export const GuestSessionSchema = z.object({
  deviceId: z.string().min(10),
});

// Resource schemas
export const CreateResourceSchema = z.object({
  title: z.string().min(1).max(255),
  description: z.string().min(1),
  content: z.string().optional(),
  category: z.enum(['mental-health', 'srhr', 'emergency', 'substance-use', 'wellness', 'guide']),
  tags: z.array(z.string()).optional(),
  imageUrl: z.string().url().optional(),
  readingTimeMinutes: z.number().int().positive().optional(),
  language: z.string().length(2).default('en'),
  status: z.enum(['draft', 'review', 'published', 'archived']).default('draft'),
  isOfflineAvailable: z.boolean().default(false),
});

export const UpdateResourceSchema = CreateResourceSchema.partial();

// Q&A schemas
export const CreateQuestionSchema = z.object({
  title: z.string().min(1).max(300),
  description: z.string().min(1),
  category: z.enum(['mental-health', 'srhr', 'emergency', 'relationships', 'general']),
  deviceId: z.string().optional(),
});

export const CreateAnswerSchema = z.object({
  questionId: z.string().uuid(),
  content: z.string().min(1),
  expertName: z.string().optional(),
  expertRole: z.string().optional(),
});

// Report schemas
export const CreateReportSchema = z.object({
  type: z.enum(['question', 'answer', 'resource']),
  resourceId: z.string().uuid().optional(),
  reason: z.string().min(1).max(255),
  description: z.string().optional(),
  reporterDeviceId: z.string().optional(),
});

// Emergency contact schemas
export const CreateEmergencyContactSchema = z.object({
  name: z.string().min(1).max(255),
  phoneNumber: z.string().min(1).max(50),
  category: z.string().min(1).max(50),
  description: z.string().optional(),
  status: z.enum(['draft', 'review', 'published', 'archived']).default('draft'),
  isActive: z.boolean().default(true),
  country: z.string().length(2).default('ZW'),
});

export const UpdateEmergencyContactSchema = CreateEmergencyContactSchema.partial();

export const AnalyticsEventSchema = z.object({
  event: z.enum([
    'app_opened',
    'resource_viewed',
    'resource_saved',
    'emergency_opened',
    'category_opened',
    'sync_completed',
    'sync_failed',
  ]),
  resourceId: z.string().uuid().optional(),
  category: z.string().max(80).optional(),
  platform: z.string().max(40).optional(),
  appVersion: z.string().max(40).optional(),
  locale: z.string().max(10).optional(),
  metadata: z.record(z.union([z.string(), z.number(), z.boolean(), z.null()])).optional(),
});

// Mood check-in schemas
export const CreateMoodCheckinSchema = z.object({
  mood: z.enum(['great', 'okay', 'low', 'anxious', 'angry', 'overwhelmed']),
  energyLevel: z.number().int().min(1).max(10),
  note: z.string().max(1000).optional(),
  tags: z.array(z.string()).optional(),
  deviceId: z.string().optional(),
});

// Journal entry schemas
export const CreateJournalEntrySchema = z.object({
  title: z.string().max(255).optional(),
  content: z.string().min(1),
  tags: z.array(z.string()).optional(),
  isPrivate: z.boolean().default(true),
  deviceId: z.string().optional(),
});

// Query schemas
export const ResourceQuerySchema = z.object({
  category: z.enum(['mental-health', 'srhr', 'emergency', 'substance-use', 'wellness', 'guide']).optional(),
  search: z.string().optional(),
  language: z.string().length(2).optional(),
  limit: z.coerce.number().int().positive().max(100).default(20),
  offset: z.coerce.number().int().nonnegative().default(0),
});

export const QuestionQuerySchema = z.object({
  category: z.enum(['mental-health', 'srhr', 'emergency', 'relationships', 'general']).optional(),
  answered: z.coerce.boolean().optional(),
  limit: z.coerce.number().int().positive().max(100).default(20),
  offset: z.coerce.number().int().nonnegative().default(0),
});

// Export types
export type LoginInput = z.infer<typeof LoginSchema>;
export type RegisterInput = z.infer<typeof RegisterSchema>;
export type GuestSessionInput = z.infer<typeof GuestSessionSchema>;
export type CreateResourceInput = z.infer<typeof CreateResourceSchema>;
export type UpdateResourceInput = z.infer<typeof UpdateResourceSchema>;
export type CreateQuestionInput = z.infer<typeof CreateQuestionSchema>;
export type CreateAnswerInput = z.infer<typeof CreateAnswerSchema>;
export type CreateReportInput = z.infer<typeof CreateReportSchema>;
export type CreateEmergencyContactInput = z.infer<typeof CreateEmergencyContactSchema>;
export type UpdateEmergencyContactInput = z.infer<typeof UpdateEmergencyContactSchema>;
export type AnalyticsEventInput = z.infer<typeof AnalyticsEventSchema>;
export type CreateMoodCheckinInput = z.infer<typeof CreateMoodCheckinSchema>;
export type CreateJournalEntryInput = z.infer<typeof CreateJournalEntrySchema>;
export type ResourceQuery = z.infer<typeof ResourceQuerySchema>;
export type QuestionQuery = z.infer<typeof QuestionQuerySchema>;
