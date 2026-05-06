DO $$ BEGIN
 CREATE TYPE "role_name" AS ENUM('USER', 'COUNSELOR', 'MODERATOR', 'CONTENT_ADMIN', 'ADMIN', 'SYSTEM_ADMIN', 'SUPER_ADMIN');
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "roles" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"name" "role_name" NOT NULL,
	"description" text,
	"permissions" jsonb DEFAULT '{}'::jsonb NOT NULL,
	"created_at" timestamp DEFAULT now(),
	"updated_at" timestamp,
	CONSTRAINT "roles_name_unique" UNIQUE("name")
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "user_roles" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"user_id" uuid NOT NULL,
	"role_id" uuid NOT NULL,
	"assigned_by" uuid,
	"assigned_at" timestamp DEFAULT now()
);
--> statement-breakpoint
INSERT INTO "roles" ("name", "description", "permissions")
VALUES
	('USER', 'Regular app user with access to wellness features', '{}'::jsonb),
	('COUNSELOR', 'Mental health counselor providing support to users', '{}'::jsonb),
	('MODERATOR', 'Community moderator managing posts and reports', '{}'::jsonb),
	('CONTENT_ADMIN', 'Content manager for resources and articles', '{}'::jsonb),
	('ADMIN', 'System administrator with broad access', '{}'::jsonb),
	('SYSTEM_ADMIN', 'System administrator with user management capabilities', '{}'::jsonb),
	('SUPER_ADMIN', 'Super administrator with full system access', '{}'::jsonb)
ON CONFLICT ("name") DO NOTHING;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "user_roles" ADD CONSTRAINT "user_roles_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "user_roles" ADD CONSTRAINT "user_roles_role_id_roles_id_fk" FOREIGN KEY ("role_id") REFERENCES "roles"("id") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "user_roles" ADD CONSTRAINT "user_roles_assigned_by_users_id_fk" FOREIGN KEY ("assigned_by") REFERENCES "users"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
