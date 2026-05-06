-- Migration 003: User tracking and personal data
-- Mood entries, sobriety tracker, journal entries

CREATE TABLE IF NOT EXISTS mood_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  mood_score INTEGER NOT NULL CHECK (mood_score >= 1 AND mood_score <= 10),
  mood_label TEXT,
  note TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  synced BOOLEAN DEFAULT false
);

CREATE TABLE IF NOT EXISTS sobriety_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  entry_type TEXT NOT NULL, -- 'start', 'milestone', 'relapse'
  date DATE NOT NULL,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  synced BOOLEAN DEFAULT false
);

CREATE TABLE IF NOT EXISTS journal_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title TEXT,
  body TEXT, -- Can be encrypted on client side before sending
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  synced BOOLEAN DEFAULT false
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_mood_entries_user_id ON mood_entries(user_id);
CREATE INDEX IF NOT EXISTS idx_mood_entries_created_at ON mood_entries(created_at);
CREATE INDEX IF NOT EXISTS idx_sobriety_entries_user_id ON sobriety_entries(user_id);
CREATE INDEX IF NOT EXISTS idx_sobriety_entries_date ON sobriety_entries(date);
CREATE INDEX IF NOT EXISTS idx_journal_entries_user_id ON journal_entries(user_id);
CREATE INDEX IF NOT EXISTS idx_journal_entries_created_at ON journal_entries(created_at);

-- Enable RLS
ALTER TABLE mood_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE sobriety_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE journal_entries ENABLE ROW LEVEL SECURITY;

-- RLS Policies (users can only access their own data)
CREATE POLICY "Users can view own mood entries" ON mood_entries FOR SELECT 
  USING (auth.uid() = user_id::text);

CREATE POLICY "Users can insert own mood entries" ON mood_entries FOR INSERT 
  WITH CHECK (auth.uid() = user_id::text);

CREATE POLICY "Users can update own mood entries" ON mood_entries FOR UPDATE 
  USING (auth.uid() = user_id::text);

CREATE POLICY "Users can view own sobriety entries" ON sobriety_entries FOR SELECT 
  USING (auth.uid() = user_id::text);

CREATE POLICY "Users can insert own sobriety entries" ON sobriety_entries FOR INSERT 
  WITH CHECK (auth.uid() = user_id::text);

CREATE POLICY "Users can view own journal entries" ON journal_entries FOR SELECT 
  USING (auth.uid() = user_id::text);

CREATE POLICY "Users can insert own journal entries" ON journal_entries FOR INSERT 
  WITH CHECK (auth.uid() = user_id::text);

CREATE POLICY "Users can update own journal entries" ON journal_entries FOR UPDATE 
  USING (auth.uid() = user_id::text);