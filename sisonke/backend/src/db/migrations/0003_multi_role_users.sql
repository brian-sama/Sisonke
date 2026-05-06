ALTER TABLE "users" ADD COLUMN IF NOT EXISTS "roles" varchar(40)[] DEFAULT ARRAY['guest']::varchar(40)[];
--> statement-breakpoint
UPDATE "users"
SET "roles" = ARRAY["role"::text]::varchar(40)[]
WHERE "roles" IS NULL OR array_length("roles", 1) IS NULL;
