DO $$ BEGIN
 CREATE TYPE "age_group" AS ENUM('13-15', '16-17', '18-24', '25+');
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 CREATE TYPE "chatbot_persona" AS ENUM('male', 'female');
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 CREATE TYPE "cms_content_type" AS ENUM('article', 'srhr', 'event', 'helpline', 'faq', 'video', 'daily-prompt', 'announcement');
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 CREATE TYPE "community_post_status" AS ENUM('pending', 'approved', 'removed');
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 CREATE TYPE "counselor_case_status" AS ENUM('requested', 'assigned', 'live', 'follow-up', 'resolved', 'emergency');
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 CREATE TYPE "risk_level" AS ENUM('low', 'medium', 'high');
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
ALTER TYPE "analytics_event" ADD VALUE IF NOT EXISTS 'chatbot_session_started';--> statement-breakpoint
ALTER TYPE "analytics_event" ADD VALUE IF NOT EXISTS 'counselor_escalated';--> statement-breakpoint
ALTER TYPE "analytics_event" ADD VALUE IF NOT EXISTS 'community_post_submitted';--> statement-breakpoint
ALTER TYPE "analytics_event" ADD VALUE IF NOT EXISTS 'mood_logged';--> statement-breakpoint
ALTER TYPE "user_role" ADD VALUE IF NOT EXISTS 'counselor';--> statement-breakpoint
ALTER TYPE "user_role" ADD VALUE IF NOT EXISTS 'moderator';--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "audit_logs" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"actor_id" uuid,
	"action" varchar(120) NOT NULL,
	"entity_type" varchar(50),
	"entity_id" uuid,
	"metadata" jsonb,
	"created_at" timestamp DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "chatbot_messages" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"session_id" uuid NOT NULL,
	"sender" varchar(20) NOT NULL,
	"content" text NOT NULL,
	"risk_level" "risk_level" DEFAULT 'low',
	"created_at" timestamp DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "chatbot_sessions" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"user_id" uuid,
	"device_id" varchar(255),
	"persona" "chatbot_persona" NOT NULL,
	"risk_level" "risk_level" DEFAULT 'low',
	"escalated_case_id" uuid,
	"summary" text,
	"created_at" timestamp DEFAULT now(),
	"updated_at" timestamp
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "cms_content" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"title" varchar(255) NOT NULL,
	"body" text NOT NULL,
	"content_type" "cms_content_type" NOT NULL,
	"category" varchar(80) NOT NULL,
	"media_url" varchar(255),
	"status" "content_status" DEFAULT 'draft' NOT NULL,
	"created_by" uuid,
	"created_at" timestamp DEFAULT now(),
	"updated_at" timestamp,
	"published_at" timestamp
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "community_posts" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"user_id" uuid,
	"age_group" "age_group" NOT NULL,
	"content" text NOT NULL,
	"status" "community_post_status" DEFAULT 'pending' NOT NULL,
	"moderation_reason" text,
	"report_count" integer DEFAULT 0,
	"created_at" timestamp DEFAULT now(),
	"reviewed_at" timestamp,
	"reviewed_by" uuid,
	"removed_at" timestamp
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "counseling_messages" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"case_id" uuid NOT NULL,
	"sender_user_id" uuid,
	"sender_role" varchar(30) NOT NULL,
	"content" text NOT NULL,
	"created_at" timestamp DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "counselor_cases" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"user_id" uuid,
	"counselor_id" uuid,
	"issue_category" varchar(120) NOT NULL,
	"status" "counselor_case_status" DEFAULT 'requested' NOT NULL,
	"risk_level" "risk_level" DEFAULT 'medium' NOT NULL,
	"source" varchar(40) DEFAULT 'mobile',
	"summary" text,
	"follow_up_at" timestamp,
	"created_at" timestamp DEFAULT now(),
	"updated_at" timestamp,
	"resolved_at" timestamp
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "counselor_notes" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"case_id" uuid NOT NULL,
	"counselor_id" uuid NOT NULL,
	"note" text NOT NULL,
	"created_at" timestamp DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "notifications" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"user_id" uuid,
	"channel" varchar(40) NOT NULL,
	"title" varchar(180) NOT NULL,
	"body" text NOT NULL,
	"metadata" jsonb,
	"read_at" timestamp,
	"created_at" timestamp DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "security_logs" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"user_id" uuid,
	"event" varchar(120) NOT NULL,
	"ip_address" varchar(80),
	"user_agent" text,
	"metadata" jsonb,
	"created_at" timestamp DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "user_profiles" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"user_id" uuid NOT NULL,
	"nickname" varchar(120) NOT NULL,
	"date_of_birth" timestamp,
	"age_group" "age_group" NOT NULL,
	"gender" varchar(80),
	"location" varchar(120),
	"consent_accepted_at" timestamp,
	"chatbot_persona" "chatbot_persona" DEFAULT 'female',
	"screening_answers" jsonb,
	"pin_enabled" boolean DEFAULT false,
	"biometric_enabled" boolean DEFAULT false,
	"auto_lock_minutes" integer DEFAULT 5,
	"hide_journal_preview" boolean DEFAULT true,
	"created_at" timestamp DEFAULT now(),
	"updated_at" timestamp
);
--> statement-breakpoint
ALTER TABLE "users" ADD COLUMN IF NOT EXISTS "roles" varchar(40)[] DEFAULT '{guest}';--> statement-breakpoint
ALTER TABLE "users" ADD COLUMN IF NOT EXISTS "is_suspended" boolean DEFAULT false;--> statement-breakpoint
ALTER TABLE "users" ADD COLUMN IF NOT EXISTS "suspension_reason" text;--> statement-breakpoint
ALTER TABLE "users" ADD COLUMN IF NOT EXISTS "suspended_at" timestamp;--> statement-breakpoint
ALTER TABLE "users" ADD COLUMN IF NOT EXISTS "must_change_password" boolean DEFAULT false;--> statement-breakpoint
ALTER TABLE "users" ADD COLUMN IF NOT EXISTS "deleted_at" timestamp;--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "audit_logs" ADD CONSTRAINT "audit_logs_actor_id_users_id_fk" FOREIGN KEY ("actor_id") REFERENCES "users"("id") ON DELETE set null ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "chatbot_messages" ADD CONSTRAINT "chatbot_messages_session_id_chatbot_sessions_id_fk" FOREIGN KEY ("session_id") REFERENCES "chatbot_sessions"("id") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "chatbot_sessions" ADD CONSTRAINT "chatbot_sessions_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "cms_content" ADD CONSTRAINT "cms_content_created_by_users_id_fk" FOREIGN KEY ("created_by") REFERENCES "users"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "community_posts" ADD CONSTRAINT "community_posts_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE set null ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "community_posts" ADD CONSTRAINT "community_posts_reviewed_by_users_id_fk" FOREIGN KEY ("reviewed_by") REFERENCES "users"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "counseling_messages" ADD CONSTRAINT "counseling_messages_case_id_counselor_cases_id_fk" FOREIGN KEY ("case_id") REFERENCES "counselor_cases"("id") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "counseling_messages" ADD CONSTRAINT "counseling_messages_sender_user_id_users_id_fk" FOREIGN KEY ("sender_user_id") REFERENCES "users"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "counselor_cases" ADD CONSTRAINT "counselor_cases_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "counselor_cases" ADD CONSTRAINT "counselor_cases_counselor_id_users_id_fk" FOREIGN KEY ("counselor_id") REFERENCES "users"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "counselor_notes" ADD CONSTRAINT "counselor_notes_case_id_counselor_cases_id_fk" FOREIGN KEY ("case_id") REFERENCES "counselor_cases"("id") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "counselor_notes" ADD CONSTRAINT "counselor_notes_counselor_id_users_id_fk" FOREIGN KEY ("counselor_id") REFERENCES "users"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "notifications" ADD CONSTRAINT "notifications_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "security_logs" ADD CONSTRAINT "security_logs_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE set null ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "user_profiles" ADD CONSTRAINT "user_profiles_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
