# 🚀 Sisonke - Privacy-First Health Support App

A Flutter app for SRHR, mental health, and substance use support with **Neon Postgres for everything**.

## Architecture

### Tech Stack
- **Frontend**: Flutter 3.41+ with Riverpod state management
- **Database**: Neon Postgres (serverless, free tier)
- **Authentication**: Custom JWT-based auth in Neon (no Firebase Auth)
- **Local Storage**: Isar for offline-first caching
- **Navigation**: go_router
- **Styling**: Material Design 3

### Why Neon for Everything?
✅ **Zero cost** (generous free tier)  
✅ **Privacy-first** (full control of data)  
✅ **Single source of truth** (no vendor lock-in)  
✅ **Offline-first ready** (Isar + Neon sync)  
✅ **RLS support** (Row-Level Security for user data isolation)  
✅ **Scales easily** (Neon handles growth)  

---

## Getting Started

### 1. Prerequisites
```bash
# Ensure you have:
- Flutter 3.11+ installed
- Dart 3.11+ 
- Neon account (https://neon.tech)
- Windows Developer Mode enabled
```

### 2. Clone & Setup
```bash
git clone https://github.com/brian-sama/Sisonke.git
cd Sisonke/sisonke
flutter pub get
```

### 3. Configure Neon Connection
The app includes your Neon connection string in `lib/app/core/constants/config.dart`:
```dart
postgresql://neondb_owner:npg_biOvRP0AM8Bo@ep-raspy-leaf-amjp2hzf-pooler.c-5.us-east-1.aws.neon.tech/neondb?sslmode=require
```

### 4. Run the App
```bash
flutter run
```

**On first run**, the app automatically:
- Connects to Neon
- Checks which migrations have been applied
- Runs any pending migrations (000, 001, 002, 003)
- Creates all tables and policies
- Returns to home screen

### 5. Test Auth
**Home Screen Options:**
- **Continue as Guest** → Creates anonymous user in Neon
- **Sign In / Sign Up** → Email-based registration/login

---

## Database Schema

### Core Tables
```
users
├── id (UUID)
├── email (unique)
├── password_hash (SHA-256)
├── is_guest
├── display_name
└── created_at

sessions
├── id (UUID)
├── user_id (FK → users)
├── token (JWT)
├── expires_at
└── created_at

mood_entries → user_id
sobriety_entries → user_id
journal_entries → user_id
resources (articles, content)
emergency_contacts (help numbers)
anonymous_questions (Q&A)
answers (moderated responses)
```

### Security
- **RLS Policies** enforce data isolation (users only see own data)
- **Passwords** hashed with SHA-256 (upgrade to bcrypt in production)
- **JWT Tokens** valid for 7 days
- **Sessions** expire automatically

---

## Migrations

### Automatic Migration on App Startup
The `MigrationRunnerEmbedded` in `lib/data/migrations/migration_runner_embedded.dart`:
1. Ensures `schema_migrations` table exists
2. Checks applied migrations
3. Runs pending migrations in order
4. Records successful migrations

### Migration Files (Embedded)
- **000** — Schema migrations table
- **001** — Resources, emergency contacts, Q&A tables
- **002** — Users, sessions, and auth tables
- **003** — User data tables (mood, sobriety, journal)

---

## Authentication Flow

### Sign Up
```dart
await ref.read(authStateProvider.notifier).signUp(
  'user@example.com',
  'password123',
  displayName: 'John Doe',
);
```

### Sign In
```dart
await ref.read(authStateProvider.notifier).signIn(
  'user@example.com',
  'password123',
);
```

### Sign Up as Guest
```dart
await ref.read(authStateProvider.notifier).signUpGuest();
```

---

## File Structure
```
lib/
├── app/
│   ├── router/              # go_router navigation
│   ├── theme/               # Material Design theming
│   ├── core/
│   │   ├── constants/       # config, app constants
│   │   ├── services/        # Neon, auth providers
│   │   └── utils/           # utilities
│
├── features/
│   ├── auth/                # Auth service (Neon-based)
│   ├── home/                # Home screen
│   ├── resources/           # Articles/content
│   ├── emergency/           # Emergency toolkit
│   ├── mood_tracker/        # Mood tracking
│   ├── sobriety_tracker/    # Recovery tracking
│   ├── journal/             # Private journal
│   ├── qa/                  # Anonymous Q&A
│   └── settings/            # Settings
│
├── data/
│   ├── migrations/          # SQL migrations
│   └── sources/             # Data sources
│
├── shared/
│   ├── models/              # Data models
│   └── widgets/             # Reusable widgets
│
└── main.dart                # App entry + migrations
```

---

## Quick Start Examples

### Sign Up New User
```dart
try {
  await ref.read(authStateProvider.notifier).signUp(
    'user@email.com',
    'password123',
    displayName: 'User Name',
  );
  // User now logged in
} catch (e) {
  print('Sign up failed: $e');
}
```

### Sign In Existing User
```dart
try {
  await ref.read(authStateProvider.notifier).signIn(
    'user@email.com',
    'password123',
  );
  // User now logged in
} catch (e) {
  print('Sign in failed: $e');
}
```

### Guest Access
```dart
await ref.read(authStateProvider.notifier).signUpGuest();
// Now user can access resources anonymously
```

---

## Key Features

### Privacy-First
- Guest-first experience (no signup required)
- Full data control
- Row-Level Security in Neon
- No external tracking

### Offline-First
- Isar caches articles, contacts, entries
- Works without internet
- Auto-syncs when online

### Crisis Support
- 24/7 helpline directory
- Emergency shortcuts
- Calming tools
- Safety plans

---

## Development

### Run Tests
```bash
flutter test
```

### Check Code Quality
```bash
flutter analyze
```

### Build APK
```bash
flutter build apk
```

---

## Security Roadmap

- [x] Custom auth with JWT
- [x] Password hashing
- [x] User data isolation (RLS)
- [ ] Email verification
- [ ] Password reset
- [ ] bcrypt hashing
- [ ] Rate limiting
- [ ] 2FA support

---

## Documentation

- [SETUP.md](SETUP.md) - Development environment setup
- [NEON_SETUP.md](NEON_SETUP.md) - Database configuration
- [Flutter Docs](https://flutter.dev)
- [Neon Docs](https://neon.tech/docs)

---

## Support

For issues:
1. Check [NEON_SETUP.md](NEON_SETUP.md) and [SETUP.md](SETUP.md)
2. Review console output for error messages
3. Check Neon dashboard for database status
4. Create an issue on GitHub

---

**Made with ❤️ for privacy and health**

*Sisonke means "together" in Nguni languages*
