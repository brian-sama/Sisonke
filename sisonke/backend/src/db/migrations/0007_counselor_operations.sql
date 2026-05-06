ALTER TABLE users ADD COLUMN IF NOT EXISTS counselor_status varchar(40) DEFAULT 'offline';
ALTER TABLE users ADD COLUMN IF NOT EXISTS counselor_specializations varchar(80)[] DEFAULT '{}';
ALTER TABLE users ADD COLUMN IF NOT EXISTS is_on_call boolean DEFAULT false;
