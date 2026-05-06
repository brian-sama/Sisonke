-- Migration 002: Authentication schema
-- Users table with password hashing and sessions

CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT UNIQUE,
  password_hash TEXT,
  is_guest BOOLEAN DEFAULT true,
  display_name TEXT,
  country TEXT,
  language TEXT DEFAULT 'en',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  last_login TIMESTAMP WITH TIME ZONE,
  is_active BOOLEAN DEFAULT true
);

CREATE TABLE IF NOT EXISTS sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token TEXT UNIQUE NOT NULL,
  expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  last_used TIMESTAMP WITH TIME ZONE
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_is_guest ON users(is_guest);
CREATE INDEX IF NOT EXISTS idx_sessions_user_id ON sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_sessions_token ON sessions(token);
CREATE INDEX IF NOT EXISTS idx_sessions_expires_at ON sessions(expires_at);

-- Enable RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE sessions ENABLE ROW LEVEL SECURITY;

-- RLS Policies for users (allow users to see own data, guests can sign up)
CREATE POLICY "Users can view own profile" ON users FOR SELECT 
  USING (auth.uid() = id::text OR is_guest = true);

CREATE POLICY "Users can update own profile" ON users FOR UPDATE 
  USING (auth.uid() = id::text);

CREATE POLICY "Anyone can insert guest user" ON users FOR INSERT 
  WITH CHECK (is_guest = true OR auth.uid() = id::text);

-- RLS Policies for sessions
CREATE POLICY "Users can view own sessions" ON sessions FOR SELECT 
  USING (auth.uid() = user_id::text);

CREATE POLICY "Users can insert own sessions" ON sessions FOR INSERT 
  WITH CHECK (auth.uid() = user_id::text);

-- Function to clean up expired sessions (can be called periodically)
CREATE OR REPLACE FUNCTION cleanup_expired_sessions()
RETURNS void AS $$
BEGIN
  DELETE FROM sessions WHERE expires_at < NOW();
END;
$$ LANGUAGE plpgsql;