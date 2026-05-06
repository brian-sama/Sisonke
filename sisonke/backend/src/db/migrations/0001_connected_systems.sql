ALTER TYPE "user_role" ADD VALUE IF NOT EXISTS 'counselor';
--> statement-breakpoint
ALTER TYPE "user_role" ADD VALUE IF NOT EXISTS 'moderator';
--> statement-breakpoint
ALTER TYPE "analytics_event" ADD VALUE IF NOT EXISTS 'chatbot_session_started';
--> statement-breakpoint
ALTER TYPE "analytics_event" ADD VALUE IF NOT EXISTS 'counselor_escalated';
--> statement-breakpoint
ALTER TYPE "analytics_event" ADD VALUE IF NOT EXISTS 'community_post_submitted';
--> statement-breakpoint
ALTER TYPE "analytics_event" ADD VALUE IF NOT EXISTS 'mood_logged';
--> statement-breakpoint
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
 CREATE TYPE "risk_level" AS ENUM('low', 'medium', 'high');
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
 CREATE TYPE "community_post_status" AS ENUM('pending', 'approved', 'removed');
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
CREATE TABLE IF NOT EXISTS "user_profiles" (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
  "user_id" uuid NOT NULL REFERENCES "users"("id") ON DELETE cascade,
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
CREATE TABLE IF NOT EXISTS "chatbot_sessions" (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
  "user_id" uuid REFERENCES "users"("id") ON DELETE cascade,
  "device_id" varchar(255),
  "persona" "chatbot_persona" NOT NULL,
  "risk_level" "risk_level" DEFAULT 'low',
  "escalated_case_id" uuid,
  "summary" text,
  "created_at" timestamp DEFAULT now(),
  "updated_at" timestamp
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "chatbot_messages" (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
  "session_id" uuid NOT NULL REFERENCES "chatbot_sessions"("id") ON DELETE cascade,
  "sender" varchar(20) NOT NULL,
  "content" text NOT NULL,
  "risk_level" "risk_level" DEFAULT 'low',
  "created_at" timestamp DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "counselor_cases" (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
  "user_id" uuid REFERENCES "users"("id") ON DELETE cascade,
  "counselor_id" uuid REFERENCES "users"("id"),
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
CREATE TABLE IF NOT EXISTS "counseling_messages" (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
  "case_id" uuid NOT NULL REFERENCES "counselor_cases"("id") ON DELETE cascade,
  "sender_user_id" uuid REFERENCES "users"("id"),
  "sender_role" varchar(30) NOT NULL,
  "content" text NOT NULL,
  "created_at" timestamp DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "counselor_notes" (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
  "case_id" uuid NOT NULL REFERENCES "counselor_cases"("id") ON DELETE cascade,
  "counselor_id" uuid NOT NULL REFERENCES "users"("id"),
  "note" text NOT NULL,
  "created_at" timestamp DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "community_posts" (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
  "user_id" uuid REFERENCES "users"("id") ON DELETE set null,
  "age_group" "age_group" NOT NULL,
  "content" text NOT NULL,
  "status" "community_post_status" DEFAULT 'pending' NOT NULL,
  "moderation_reason" text,
  "report_count" integer DEFAULT 0,
  "created_at" timestamp DEFAULT now(),
  "reviewed_at" timestamp,
  "reviewed_by" uuid REFERENCES "users"("id"),
  "removed_at" timestamp
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
  "created_by" uuid REFERENCES "users"("id"),
  "created_at" timestamp DEFAULT now(),
  "updated_at" timestamp,
  "published_at" timestamp
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "notifications" (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
  "user_id" uuid REFERENCES "users"("id") ON DELETE cascade,
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
  "user_id" uuid REFERENCES "users"("id") ON DELETE set null,
  "event" varchar(120) NOT NULL,
  "ip_address" varchar(80),
  "user_agent" text,
  "metadata" jsonb,
  "created_at" timestamp DEFAULT now()
);
