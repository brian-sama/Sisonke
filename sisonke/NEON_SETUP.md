# Sisonke - Neon Database Setup & Migration Guide

## Overview
Sisonke now uses **Neon Postgres for everything** including authentication, user data, and content. Database migrations are automatically run on app startup via the `MigrationRunner`.

## Prerequisites
- ✅ Neon account and connection string (you have this)
- ✅ Flutter environment configured
- ✅ Developer Mode enabled on Windows (for symlinks)

## Automatic Migration Setup

### What Happens on App Startup
1. `main.dart` initializes the Neon connection
2. `MigrationRunner` scans `lib/data/migrations/` for SQL files
3. Compares against `schema_migrations` table (which tracks applied migrations)
4. Runs any pending migrations (000, 001, 002, 003)
5. Records migration in `schema_migrations` table

### Migration Files
Located in `lib/data/migrations/`:
- **000_schema_migrations.sql** — Creates migration tracking table
- **001_init.sql** — Creates resources, emergency contacts, Q&A tables
- **002_auth.sql** — Creates users and sessions tables with auth logic
- **003_user_data.sql** — Creates mood entries, sobriety tracker, journal

## Manual Migration (If Needed)

### Option A: Run via Neon Dashboard
1. Go to [https://console.neon.tech](https://console.neon.tech)
2. Open SQL Editor for your neondb database
3. Copy and paste each migration file in order:
   - `000_schema_migrations.sql`
   - `001_init.sql`
   - `002_auth.sql`
   - `003_user_data.sql`
4. Execute each

### Option B: Run via Flutter App
The app will auto-run migrations on startup. Check console output:
```
🔄 Running database migrations...
✅ Migration applied: 000
✅ Migration applied: 001
✅ Migration applied: 002
✅ Migration applied: 003
✅ All migrations completed! (4 new migrations applied)
```

## Database Schema

### Users Table
```sql
users (
  id UUID PRIMARY KEY,
  email TEXT UNIQUE,
  password_hash TEXT,
  is_guest BOOLEAN,
  display_name TEXT,
  created_at TIMESTAMP,
  last_login TIMESTAMP,
  is_active BOOLEAN
)
```

### Sessions Table
```sql
sessions (
  id UUID PRIMARY KEY,
  user_id UUID (FK -> users),
  token TEXT UNIQUE,
  expires_at TIMESTAMP,
  created_at TIMESTAMP
)
```

### User Data Tables
- `mood_entries` — Daily mood tracking
- `sobriety_entries` — Recovery/sobriety milestones
- `journal_entries` — Private journal entries
- `resources` — Articles and content
- `emergency_contacts` — Help resources
- `anonymous_questions` — Q&A submissions
- `answers` — Moderated answers

## Authentication Flow (Neon-Based)

### Sign Up (New Email User)
```dart
await authService.signUp(
  'user@example.com',
  'password123',
  displayName: 'John Doe',
);
```
→ Creates user with bcrypt-like hashed password (SHA-256 for MVP)
→ Generates JWT token
→ Creates session record
→ Returns User object

### Sign In (Existing Email User)
```dart
await authService.signIn('user@example.com', 'password123');
```
→ Verifies password hash
→ Generates new JWT token
→ Creates session record
→ Updates last_login timestamp

### Sign Up as Guest (Anonymous)
```dart
await authService.signUpGuest();
```
→ Creates user with is_guest = true
→ No password required
→ Generates JWT token
→ Creates session record

### Restore Session (On App Restart)
```dart
final token = await secureStorage.read(key: 'auth_token');
final success = await authService.restoreSession(token);
```
→ Validates token hasn't expired
→ Returns User object if valid

## Security Considerations

### Current (MVP)
- Passwords hashed with SHA-256
- JWT tokens valid for 7 days
- RLS policies enforce user data isolation
- Sessions stored in Neon with expiration

### Production Upgrades Needed
- [ ] Replace SHA-256 with bcrypt (use `pointycastle` package)
- [ ] Use proper JWT library (support key rotation)
- [ ] Add email verification
- [ ] Add password reset flow
- [ ] Implement rate limiting
- [ ] Add HTTPS enforcement
- [ ] Audit logging for auth events

## Testing Auth Flow

### Test Guest Login
1. Run app: `flutter run`
2. Tap "Continue as Guest"
3. Should see "Guest User: true" on home screen
4. Guest user data syncs to Neon

### Test Email Signup
1. Tap "Sign In / Sign Up"
2. Toggle to "Sign Up" mode
3. Enter email, password, optional name
4. Should see user data on home screen
5. Can check `users` table in Neon dashboard

### Test Email Login
1. Sign out
2. Tap "Sign In / Sign Up"
3. Use same credentials from signup
4. Should log in successfully

## Troubleshooting

### Migrations Not Running
**Symptom**: "No migration files found" or migrations skipped

**Solution**:
1. Ensure `lib/data/migrations/*.sql` files exist
2. Check migration file naming: `000_name.sql`, `001_name.sql`, etc.
3. Check Neon connection string in `lib/app/core/constants/config.dart`
4. Check console for specific errors

### Auth Service Errors
**Symptom**: "Auth service not initialized" or connection errors

**Solution**:
1. Verify Neon connection string is correct
2. Check that migrations ran successfully
3. Ensure `users` table exists in Neon
4. Check network connectivity

### Password Hash Mismatch
**Symptom**: "Invalid email or password" even with correct credentials

**Solution**:
1. Currently using SHA-256 hashing (MVP)
2. Ensure password isn't being double-hashed
3. Check for whitespace in email/password fields
4. Verify user exists in `users` table

## Next Steps

1. **Enable email verification** for sign up
2. **Add password reset** flow
3. **Implement OAuth** (Google, Apple) for optional accounts
4. **Add 2FA** for registered users
5. **Upgrade to bcrypt** for password hashing
6. **Add audit logging** for security events
7. **Set up automated backups** in Neon

## Useful Neon Commands

### View Applied Migrations
```sql
SELECT * FROM schema_migrations ORDER BY installed_on;
```

### View All Users
```sql
SELECT id, email, is_guest, created_at, last_login FROM users;
```

### View Active Sessions
```sql
SELECT s.id, u.email, s.expires_at, s.last_used 
FROM sessions s 
JOIN users u ON s.user_id = u.id 
WHERE s.expires_at > NOW();
```

### Clean Up Expired Sessions
```sql
DELETE FROM sessions WHERE expires_at < NOW();
```

## Support
For issues, check:
- Console output during app startup for migration errors
- Neon dashboard SQL Editor for direct query execution
- [Neon Docs](https://neon.tech/docs)
- [PostgreSQL Docs](https://www.postgresql.org/docs/)