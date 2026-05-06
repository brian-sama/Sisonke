-- Migration 000: Migration tracking table (run first!)
-- This table tracks which migrations have been executed

CREATE TABLE IF NOT EXISTS schema_migrations (
  id SERIAL PRIMARY KEY,
  version VARCHAR(255) NOT NULL UNIQUE,
  description VARCHAR(255),
  installed_on TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);