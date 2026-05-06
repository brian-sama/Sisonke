-- Migration 001: Initialize database schema
-- Tables for resources, emergency contacts, and anonymous Q&A

CREATE TABLE IF NOT EXISTS resources (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  summary TEXT,
  content TEXT,
  category TEXT,
  topic_tags TEXT[],
  language TEXT DEFAULT 'en',
  is_published BOOLEAN DEFAULT false,
  is_offline_featured BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS emergency_contacts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  phone_number TEXT NOT NULL,
  region TEXT,
  category TEXT,
  is_24_7 BOOLEAN DEFAULT false,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS anonymous_questions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  question_text TEXT NOT NULL,
  topic TEXT,
  status TEXT DEFAULT 'pending', -- 'pending', 'approved', 'rejected'
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  moderation_flag BOOLEAN DEFAULT false
);

CREATE TABLE IF NOT EXISTS answers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  question_id UUID REFERENCES anonymous_questions(id) ON DELETE CASCADE,
  answer_text TEXT NOT NULL,
  reviewed_by TEXT,
  published_at TIMESTAMP WITH TIME ZONE
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_resources_slug ON resources(slug);
CREATE INDEX IF NOT EXISTS idx_resources_category ON resources(category);
CREATE INDEX IF NOT EXISTS idx_resources_is_published ON resources(is_published);
CREATE INDEX IF NOT EXISTS idx_emergency_contacts_region ON emergency_contacts(region);
CREATE INDEX IF NOT EXISTS idx_anonymous_questions_status ON anonymous_questions(status);
CREATE INDEX IF NOT EXISTS idx_answers_question_id ON answers(question_id);

-- Add RLS (will be managed per table in migrations)
ALTER TABLE resources ENABLE ROW LEVEL SECURITY;
ALTER TABLE emergency_contacts ENABLE ROW LEVEL SECURITY;
ALTER TABLE anonymous_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE answers ENABLE ROW LEVEL SECURITY;