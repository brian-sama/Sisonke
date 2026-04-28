import { z } from 'zod';
export declare const LoginSchema: z.ZodObject<{
    email: z.ZodString;
    password: z.ZodString;
}, "strip", z.ZodTypeAny, {
    email: string;
    password: string;
}, {
    email: string;
    password: string;
}>;
export declare const RegisterSchema: z.ZodObject<{
    email: z.ZodString;
    password: z.ZodString;
}, "strip", z.ZodTypeAny, {
    email: string;
    password: string;
}, {
    email: string;
    password: string;
}>;
export declare const GuestSessionSchema: z.ZodObject<{
    deviceId: z.ZodString;
}, "strip", z.ZodTypeAny, {
    deviceId: string;
}, {
    deviceId: string;
}>;
export declare const CreateResourceSchema: z.ZodObject<{
    title: z.ZodString;
    description: z.ZodString;
    content: z.ZodOptional<z.ZodString>;
    category: z.ZodEnum<["mental-health", "srhr", "emergency", "substance-use", "wellness", "guide"]>;
    tags: z.ZodOptional<z.ZodArray<z.ZodString, "many">>;
    imageUrl: z.ZodOptional<z.ZodString>;
    readingTimeMinutes: z.ZodOptional<z.ZodNumber>;
    language: z.ZodDefault<z.ZodString>;
    status: z.ZodDefault<z.ZodEnum<["draft", "review", "published", "archived"]>>;
    isOfflineAvailable: z.ZodDefault<z.ZodBoolean>;
}, "strip", z.ZodTypeAny, {
    title: string;
    description: string;
    category: "mental-health" | "srhr" | "emergency" | "substance-use" | "wellness" | "guide";
    language: string;
    status: "draft" | "review" | "published" | "archived";
    isOfflineAvailable: boolean;
    content?: string | undefined;
    tags?: string[] | undefined;
    imageUrl?: string | undefined;
    readingTimeMinutes?: number | undefined;
}, {
    title: string;
    description: string;
    category: "mental-health" | "srhr" | "emergency" | "substance-use" | "wellness" | "guide";
    content?: string | undefined;
    tags?: string[] | undefined;
    imageUrl?: string | undefined;
    readingTimeMinutes?: number | undefined;
    language?: string | undefined;
    status?: "draft" | "review" | "published" | "archived" | undefined;
    isOfflineAvailable?: boolean | undefined;
}>;
export declare const UpdateResourceSchema: z.ZodObject<{
    title: z.ZodOptional<z.ZodString>;
    description: z.ZodOptional<z.ZodString>;
    content: z.ZodOptional<z.ZodOptional<z.ZodString>>;
    category: z.ZodOptional<z.ZodEnum<["mental-health", "srhr", "emergency", "substance-use", "wellness", "guide"]>>;
    tags: z.ZodOptional<z.ZodOptional<z.ZodArray<z.ZodString, "many">>>;
    imageUrl: z.ZodOptional<z.ZodOptional<z.ZodString>>;
    readingTimeMinutes: z.ZodOptional<z.ZodOptional<z.ZodNumber>>;
    language: z.ZodOptional<z.ZodDefault<z.ZodString>>;
    status: z.ZodOptional<z.ZodDefault<z.ZodEnum<["draft", "review", "published", "archived"]>>>;
    isOfflineAvailable: z.ZodOptional<z.ZodDefault<z.ZodBoolean>>;
}, "strip", z.ZodTypeAny, {
    title?: string | undefined;
    description?: string | undefined;
    content?: string | undefined;
    category?: "mental-health" | "srhr" | "emergency" | "substance-use" | "wellness" | "guide" | undefined;
    tags?: string[] | undefined;
    imageUrl?: string | undefined;
    readingTimeMinutes?: number | undefined;
    language?: string | undefined;
    status?: "draft" | "review" | "published" | "archived" | undefined;
    isOfflineAvailable?: boolean | undefined;
}, {
    title?: string | undefined;
    description?: string | undefined;
    content?: string | undefined;
    category?: "mental-health" | "srhr" | "emergency" | "substance-use" | "wellness" | "guide" | undefined;
    tags?: string[] | undefined;
    imageUrl?: string | undefined;
    readingTimeMinutes?: number | undefined;
    language?: string | undefined;
    status?: "draft" | "review" | "published" | "archived" | undefined;
    isOfflineAvailable?: boolean | undefined;
}>;
export declare const CreateQuestionSchema: z.ZodObject<{
    title: z.ZodString;
    description: z.ZodString;
    category: z.ZodEnum<["mental-health", "srhr", "emergency", "relationships", "general"]>;
    deviceId: z.ZodOptional<z.ZodString>;
}, "strip", z.ZodTypeAny, {
    title: string;
    description: string;
    category: "mental-health" | "srhr" | "emergency" | "relationships" | "general";
    deviceId?: string | undefined;
}, {
    title: string;
    description: string;
    category: "mental-health" | "srhr" | "emergency" | "relationships" | "general";
    deviceId?: string | undefined;
}>;
export declare const CreateAnswerSchema: z.ZodObject<{
    questionId: z.ZodString;
    content: z.ZodString;
    expertName: z.ZodOptional<z.ZodString>;
    expertRole: z.ZodOptional<z.ZodString>;
}, "strip", z.ZodTypeAny, {
    content: string;
    questionId: string;
    expertName?: string | undefined;
    expertRole?: string | undefined;
}, {
    content: string;
    questionId: string;
    expertName?: string | undefined;
    expertRole?: string | undefined;
}>;
export declare const CreateReportSchema: z.ZodObject<{
    type: z.ZodEnum<["question", "answer", "resource"]>;
    resourceId: z.ZodOptional<z.ZodString>;
    reason: z.ZodString;
    description: z.ZodOptional<z.ZodString>;
    reporterDeviceId: z.ZodOptional<z.ZodString>;
}, "strip", z.ZodTypeAny, {
    type: "question" | "answer" | "resource";
    reason: string;
    description?: string | undefined;
    resourceId?: string | undefined;
    reporterDeviceId?: string | undefined;
}, {
    type: "question" | "answer" | "resource";
    reason: string;
    description?: string | undefined;
    resourceId?: string | undefined;
    reporterDeviceId?: string | undefined;
}>;
export declare const CreateEmergencyContactSchema: z.ZodObject<{
    name: z.ZodString;
    phoneNumber: z.ZodString;
    category: z.ZodString;
    description: z.ZodOptional<z.ZodString>;
    status: z.ZodDefault<z.ZodEnum<["draft", "review", "published", "archived"]>>;
    isActive: z.ZodDefault<z.ZodBoolean>;
    country: z.ZodDefault<z.ZodString>;
}, "strip", z.ZodTypeAny, {
    name: string;
    category: string;
    status: "draft" | "review" | "published" | "archived";
    phoneNumber: string;
    isActive: boolean;
    country: string;
    description?: string | undefined;
}, {
    name: string;
    category: string;
    phoneNumber: string;
    description?: string | undefined;
    status?: "draft" | "review" | "published" | "archived" | undefined;
    isActive?: boolean | undefined;
    country?: string | undefined;
}>;
export declare const UpdateEmergencyContactSchema: z.ZodObject<{
    name: z.ZodOptional<z.ZodString>;
    phoneNumber: z.ZodOptional<z.ZodString>;
    category: z.ZodOptional<z.ZodString>;
    description: z.ZodOptional<z.ZodOptional<z.ZodString>>;
    status: z.ZodOptional<z.ZodDefault<z.ZodEnum<["draft", "review", "published", "archived"]>>>;
    isActive: z.ZodOptional<z.ZodDefault<z.ZodBoolean>>;
    country: z.ZodOptional<z.ZodDefault<z.ZodString>>;
}, "strip", z.ZodTypeAny, {
    name?: string | undefined;
    description?: string | undefined;
    category?: string | undefined;
    status?: "draft" | "review" | "published" | "archived" | undefined;
    phoneNumber?: string | undefined;
    isActive?: boolean | undefined;
    country?: string | undefined;
}, {
    name?: string | undefined;
    description?: string | undefined;
    category?: string | undefined;
    status?: "draft" | "review" | "published" | "archived" | undefined;
    phoneNumber?: string | undefined;
    isActive?: boolean | undefined;
    country?: string | undefined;
}>;
export declare const AnalyticsEventSchema: z.ZodObject<{
    event: z.ZodEnum<["app_opened", "resource_viewed", "resource_saved", "emergency_opened", "category_opened", "sync_completed", "sync_failed"]>;
    resourceId: z.ZodOptional<z.ZodString>;
    category: z.ZodOptional<z.ZodString>;
    platform: z.ZodOptional<z.ZodString>;
    appVersion: z.ZodOptional<z.ZodString>;
    locale: z.ZodOptional<z.ZodString>;
    metadata: z.ZodOptional<z.ZodRecord<z.ZodString, z.ZodUnion<[z.ZodString, z.ZodNumber, z.ZodBoolean, z.ZodNull]>>>;
}, "strip", z.ZodTypeAny, {
    event: "app_opened" | "resource_viewed" | "resource_saved" | "emergency_opened" | "category_opened" | "sync_completed" | "sync_failed";
    category?: string | undefined;
    resourceId?: string | undefined;
    platform?: string | undefined;
    appVersion?: string | undefined;
    locale?: string | undefined;
    metadata?: Record<string, string | number | boolean | null> | undefined;
}, {
    event: "app_opened" | "resource_viewed" | "resource_saved" | "emergency_opened" | "category_opened" | "sync_completed" | "sync_failed";
    category?: string | undefined;
    resourceId?: string | undefined;
    platform?: string | undefined;
    appVersion?: string | undefined;
    locale?: string | undefined;
    metadata?: Record<string, string | number | boolean | null> | undefined;
}>;
export declare const CreateMoodCheckinSchema: z.ZodObject<{
    mood: z.ZodEnum<["great", "okay", "low", "anxious", "angry", "overwhelmed"]>;
    energyLevel: z.ZodNumber;
    note: z.ZodOptional<z.ZodString>;
    tags: z.ZodOptional<z.ZodArray<z.ZodString, "many">>;
    deviceId: z.ZodOptional<z.ZodString>;
}, "strip", z.ZodTypeAny, {
    mood: "great" | "okay" | "low" | "anxious" | "angry" | "overwhelmed";
    energyLevel: number;
    deviceId?: string | undefined;
    tags?: string[] | undefined;
    note?: string | undefined;
}, {
    mood: "great" | "okay" | "low" | "anxious" | "angry" | "overwhelmed";
    energyLevel: number;
    deviceId?: string | undefined;
    tags?: string[] | undefined;
    note?: string | undefined;
}>;
export declare const CreateJournalEntrySchema: z.ZodObject<{
    title: z.ZodOptional<z.ZodString>;
    content: z.ZodString;
    tags: z.ZodOptional<z.ZodArray<z.ZodString, "many">>;
    isPrivate: z.ZodDefault<z.ZodBoolean>;
    deviceId: z.ZodOptional<z.ZodString>;
}, "strip", z.ZodTypeAny, {
    content: string;
    isPrivate: boolean;
    deviceId?: string | undefined;
    title?: string | undefined;
    tags?: string[] | undefined;
}, {
    content: string;
    deviceId?: string | undefined;
    title?: string | undefined;
    tags?: string[] | undefined;
    isPrivate?: boolean | undefined;
}>;
export declare const ResourceQuerySchema: z.ZodObject<{
    category: z.ZodOptional<z.ZodEnum<["mental-health", "srhr", "emergency", "substance-use", "wellness", "guide"]>>;
    search: z.ZodOptional<z.ZodString>;
    language: z.ZodOptional<z.ZodString>;
    limit: z.ZodDefault<z.ZodNumber>;
    offset: z.ZodDefault<z.ZodNumber>;
}, "strip", z.ZodTypeAny, {
    limit: number;
    offset: number;
    category?: "mental-health" | "srhr" | "emergency" | "substance-use" | "wellness" | "guide" | undefined;
    language?: string | undefined;
    search?: string | undefined;
}, {
    category?: "mental-health" | "srhr" | "emergency" | "substance-use" | "wellness" | "guide" | undefined;
    language?: string | undefined;
    search?: string | undefined;
    limit?: number | undefined;
    offset?: number | undefined;
}>;
export declare const QuestionQuerySchema: z.ZodObject<{
    category: z.ZodOptional<z.ZodEnum<["mental-health", "srhr", "emergency", "relationships", "general"]>>;
    answered: z.ZodOptional<z.ZodBoolean>;
    limit: z.ZodDefault<z.ZodNumber>;
    offset: z.ZodDefault<z.ZodNumber>;
}, "strip", z.ZodTypeAny, {
    limit: number;
    offset: number;
    category?: "mental-health" | "srhr" | "emergency" | "relationships" | "general" | undefined;
    answered?: boolean | undefined;
}, {
    category?: "mental-health" | "srhr" | "emergency" | "relationships" | "general" | undefined;
    limit?: number | undefined;
    offset?: number | undefined;
    answered?: boolean | undefined;
}>;
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
//# sourceMappingURL=index.d.ts.map