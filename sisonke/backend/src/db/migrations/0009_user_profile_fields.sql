ALTER TABLE "users" ADD COLUMN IF NOT EXISTS "name" varchar(120);
ALTER TABLE "users" ADD COLUMN IF NOT EXISTS "avatar_url" varchar(500);
