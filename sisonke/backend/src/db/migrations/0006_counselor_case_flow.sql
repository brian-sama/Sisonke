ALTER TYPE counselor_case_status ADD VALUE IF NOT EXISTS 'accepted';
ALTER TYPE counselor_case_status ADD VALUE IF NOT EXISTS 'waiting_for_client';
ALTER TYPE counselor_case_status ADD VALUE IF NOT EXISTS 'callback_requested';
ALTER TYPE counselor_case_status ADD VALUE IF NOT EXISTS 'follow_up';
ALTER TYPE counselor_case_status ADD VALUE IF NOT EXISTS 'closed';

ALTER TABLE counselor_cases
  ADD COLUMN IF NOT EXISTS callback_phone varchar(80),
  ADD COLUMN IF NOT EXISTS preferred_contact_method varchar(40) DEFAULT 'live_chat',
  ADD COLUMN IF NOT EXISTS callback_status varchar(40);

ALTER TABLE counseling_messages
  ADD COLUMN IF NOT EXISTS message_type varchar(30) NOT NULL DEFAULT 'text',
  ADD COLUMN IF NOT EXISTS media_url text;
