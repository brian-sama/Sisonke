"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.QuestionQuerySchema = exports.ResourceQuerySchema = exports.CreateJournalEntrySchema = exports.CreateMoodCheckinSchema = exports.CmsContentSchema = exports.CommunityPostSchema = exports.CounselorRequestSchema = exports.ChatbotMessageSchema = exports.OnboardingProfileSchema = exports.AnalyticsEventSchema = exports.UpdateEmergencyContactSchema = exports.CreateEmergencyContactSchema = exports.CreateReportSchema = exports.CreateAnswerSchema = exports.CreateQuestionSchema = exports.UpdateResourceSchema = exports.CreateResourceSchema = exports.ChangePasswordSchema = exports.AdminSetPasswordSchema = exports.UpdateAdminUserSchema = exports.UpdateUserRolesSchema = exports.CreateAdminUserSchema = exports.AdminRoleSchema = exports.GuestSessionSchema = exports.RegisterSchema = exports.LoginSchema = void 0;
const zod_1 = require("zod");
// Auth schemas
exports.LoginSchema = zod_1.z.object({
    email: zod_1.z.string().email(),
    password: zod_1.z.string().min(6),
});
exports.RegisterSchema = zod_1.z.object({
    email: zod_1.z.string().email(),
    password: zod_1.z.string().min(6),
});
exports.GuestSessionSchema = zod_1.z.object({
    deviceId: zod_1.z.string().min(10),
});
const AdminRoleValueSchema = zod_1.z.enum([
    'guest',
    'user',
    'counselor',
    'moderator',
    'content-admin',
    'admin',
    'super-admin',
    'system-admin',
    'content-manager',
    'safety-reviewer',
    'analyst',
]);
exports.AdminRoleSchema = zod_1.z.preprocess((value) => typeof value === 'string' ? value.trim().toLowerCase().replace(/_/g, '-') : value, AdminRoleValueSchema);
exports.CreateAdminUserSchema = zod_1.z.object({
    email: zod_1.z.string().email(),
    password: zod_1.z.string().min(1),
    name: zod_1.z.string().max(120).optional(),
    avatarUrl: zod_1.z.string().max(500).optional(),
    roles: zod_1.z.array(exports.AdminRoleSchema).min(1).default(['user']),
    isGuest: zod_1.z.boolean().default(false),
    mustChangePassword: zod_1.z.boolean().default(false),
});
exports.UpdateUserRolesSchema = zod_1.z.object({
    roles: zod_1.z.array(exports.AdminRoleSchema).min(1),
});
exports.UpdateAdminUserSchema = zod_1.z.object({
    email: zod_1.z.string().email().optional(),
    name: zod_1.z.string().max(120).optional().nullable(),
    avatarUrl: zod_1.z.string().max(500).optional().nullable(),
    roles: zod_1.z.array(exports.AdminRoleSchema).min(1).optional(),
    isSuspended: zod_1.z.boolean().optional(),
    suspensionReason: zod_1.z.string().optional(),
    mustChangePassword: zod_1.z.boolean().optional(),
});
exports.AdminSetPasswordSchema = zod_1.z.object({
    password: zod_1.z.string().min(1),
    mustChangePassword: zod_1.z.boolean().default(false),
});
exports.ChangePasswordSchema = zod_1.z.object({
    currentPassword: zod_1.z.string().optional(),
    newPassword: zod_1.z.string().min(1),
});
// Resource schemas
exports.CreateResourceSchema = zod_1.z.object({
    title: zod_1.z.string().min(1).max(255),
    description: zod_1.z.string().min(1),
    content: zod_1.z.string().optional(),
    category: zod_1.z.enum(['mental-health', 'srhr', 'emergency', 'substance-use', 'wellness', 'guide']),
    tags: zod_1.z.array(zod_1.z.string()).optional(),
    imageUrl: zod_1.z.string().url().optional(),
    readingTimeMinutes: zod_1.z.number().int().positive().optional(),
    language: zod_1.z.string().length(2).default('en'),
    status: zod_1.z.enum(['draft', 'review', 'published', 'archived']).default('draft'),
    isOfflineAvailable: zod_1.z.boolean().default(false),
});
exports.UpdateResourceSchema = exports.CreateResourceSchema.partial();
// Q&A schemas
exports.CreateQuestionSchema = zod_1.z.object({
    title: zod_1.z.string().min(1).max(300),
    description: zod_1.z.string().min(1),
    category: zod_1.z.enum(['mental-health', 'srhr', 'emergency', 'relationships', 'general']),
    deviceId: zod_1.z.string().optional(),
});
exports.CreateAnswerSchema = zod_1.z.object({
    questionId: zod_1.z.string().uuid(),
    content: zod_1.z.string().min(1),
    expertName: zod_1.z.string().optional(),
    expertRole: zod_1.z.string().optional(),
});
// Report schemas
exports.CreateReportSchema = zod_1.z.object({
    type: zod_1.z.enum(['question', 'answer', 'resource']),
    resourceId: zod_1.z.string().uuid().optional(),
    reason: zod_1.z.string().min(1).max(255),
    description: zod_1.z.string().optional(),
    reporterDeviceId: zod_1.z.string().optional(),
});
// Emergency contact schemas
exports.CreateEmergencyContactSchema = zod_1.z.object({
    name: zod_1.z.string().min(1).max(255),
    phoneNumber: zod_1.z.string().min(1).max(50),
    category: zod_1.z.string().min(1).max(50),
    description: zod_1.z.string().optional(),
    status: zod_1.z.enum(['draft', 'review', 'published', 'archived']).default('draft'),
    isActive: zod_1.z.boolean().default(true),
    country: zod_1.z.string().length(2).default('ZW'),
});
exports.UpdateEmergencyContactSchema = exports.CreateEmergencyContactSchema.partial();
exports.AnalyticsEventSchema = zod_1.z.object({
    event: zod_1.z.enum([
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
        'sync_failed',
    ]),
    resourceId: zod_1.z.string().uuid().optional(),
    category: zod_1.z.string().max(80).optional(),
    platform: zod_1.z.string().max(40).optional(),
    appVersion: zod_1.z.string().max(40).optional(),
    locale: zod_1.z.string().max(10).optional(),
    metadata: zod_1.z.record(zod_1.z.union([zod_1.z.string(), zod_1.z.number(), zod_1.z.boolean(), zod_1.z.null()])).optional(),
});
exports.OnboardingProfileSchema = zod_1.z.object({
    nickname: zod_1.z.string().min(1).max(120),
    dateOfBirth: zod_1.z.coerce.date().optional(),
    age: zod_1.z.number().int().min(13).max(120).optional(),
    gender: zod_1.z.string().max(80).optional(),
    location: zod_1.z.string().max(120).optional(),
    consentAccepted: zod_1.z.boolean(),
    pinEnabled: zod_1.z.boolean().default(true),
    biometricEnabled: zod_1.z.boolean().default(false),
    autoLockMinutes: zod_1.z.number().int().min(1).max(60).default(5),
    hideJournalPreview: zod_1.z.boolean().default(true),
    chatbotPersona: zod_1.z.enum(['male', 'female']).default('female'),
    screeningAnswers: zod_1.z.record(zod_1.z.boolean()).default({}),
});
exports.ChatbotMessageSchema = zod_1.z.object({
    sessionId: zod_1.z.string().uuid().optional(),
    persona: zod_1.z.enum(['male', 'female']).default('female'),
    message: zod_1.z.string().min(1).max(2000),
    deviceId: zod_1.z.string().optional(),
});
exports.CounselorRequestSchema = zod_1.z.object({
    issueCategory: zod_1.z.string().min(1).max(120),
    summary: zod_1.z.string().max(2000).optional(),
    riskLevel: zod_1.z.enum(['low', 'medium', 'high']).default('medium'),
    preferredContactMethod: zod_1.z.enum(['live_chat', 'leave_message', 'voice_note', 'callback']).default('live_chat'),
    callbackPhone: zod_1.z.string().max(80).optional(),
});
exports.CommunityPostSchema = zod_1.z.object({
    ageGroup: zod_1.z.enum(['13-15', '16-17', '18-24', '25+']),
    content: zod_1.z.string().min(1).max(1200),
});
exports.CmsContentSchema = zod_1.z.object({
    title: zod_1.z.string().min(1).max(255),
    body: zod_1.z.string().min(1),
    contentType: zod_1.z.enum(['article', 'srhr', 'event', 'helpline', 'faq', 'video', 'daily-prompt', 'announcement']),
    category: zod_1.z.enum([
        'Mental Health',
        'SRHR',
        'Substance Abuse',
        'Relationships',
        'Self-Care',
        'Youth Opportunities',
        'Emergency Support',
    ]),
    mediaUrl: zod_1.z.string().url().optional(),
    status: zod_1.z.enum(['draft', 'review', 'published', 'archived']).default('draft'),
});
// Mood check-in schemas
exports.CreateMoodCheckinSchema = zod_1.z.object({
    mood: zod_1.z.enum(['great', 'okay', 'low', 'anxious', 'angry', 'overwhelmed']),
    energyLevel: zod_1.z.number().int().min(1).max(10),
    note: zod_1.z.string().max(1000).optional(),
    tags: zod_1.z.array(zod_1.z.string()).optional(),
    deviceId: zod_1.z.string().optional(),
});
// Journal entry schemas
exports.CreateJournalEntrySchema = zod_1.z.object({
    title: zod_1.z.string().max(255).optional(),
    content: zod_1.z.string().min(1),
    tags: zod_1.z.array(zod_1.z.string()).optional(),
    isPrivate: zod_1.z.boolean().default(true),
    deviceId: zod_1.z.string().optional(),
});
// Query schemas
exports.ResourceQuerySchema = zod_1.z.object({
    category: zod_1.z.enum(['mental-health', 'srhr', 'emergency', 'substance-use', 'wellness', 'guide']).optional(),
    search: zod_1.z.string().optional(),
    language: zod_1.z.string().length(2).optional(),
    limit: zod_1.z.coerce.number().int().positive().max(100).default(20),
    offset: zod_1.z.coerce.number().int().nonnegative().default(0),
});
exports.QuestionQuerySchema = zod_1.z.object({
    category: zod_1.z.enum(['mental-health', 'srhr', 'emergency', 'relationships', 'general']).optional(),
    answered: zod_1.z.coerce.boolean().optional(),
    limit: zod_1.z.coerce.number().int().positive().max(100).default(20),
    offset: zod_1.z.coerce.number().int().nonnegative().default(0),
});
//# sourceMappingURL=index.js.map