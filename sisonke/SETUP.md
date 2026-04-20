# Sisonke - Developer Setup Guide

## Prerequisites
- Flutter 3.11+
- Dart 3.11+
- Git

## Initial Setup

### 1. Clone the Repository
```bash
git clone <repo-url>
cd sisonke
flutter pub get
```

### 2. Configure Secrets & Credentials

**Never commit `config.dart`, `.env`, or Firebase config files to version control.**

#### a) Neon Postgres Connection
1. Go to [neon.tech](https://neon.tech) and create a project
2. Get your connection string from the dashboard
3. Copy `lib/app/core/constants/config.dart.example` to `lib/app/core/constants/config.dart`
4. Replace `YOUR_NEON_CONNECTION_STRING_HERE` with your actual connection string

#### b) Firebase Setup
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a project named "Sisonke"
3. Enable Authentication (Anonymous + Email/Password)
4. Enable Cloud Storage
5. Add Flutter app and download config files:
   - **Android**: `google-services.json` → `android/app/`
   - **iOS**: `GoogleService-Info.plist` → `ios/Runner/`
6. Run: `dart pub global activate flutterfire_cli`
7. Run: `flutterfire configure`

#### c) Database Schema (Neon)
1. In your Neon dashboard, open the SQL Editor
2. Replace `YOUR_DATABASE_NAME` in `setup_neon.sql` with your database name
3. Copy and paste the entire SQL script into the editor
4. Execute to create tables and enable RLS

#### d) (Optional) Cloudinary for Image Storage
1. Go to [cloudinary.com](https://cloudinary.com) and sign up
2. Copy your cloud name and API key
3. Update `config.dart` with these values

### 3. Run the App
```bash
flutter run
```

## Environment Variables (Alternative to config.dart)

If you prefer using `.env` files:
1. Copy `.env.example` to `.env`
2. Fill in your actual credentials
3. Install `flutter_dotenv`: `flutter pub add flutter_dotenv`
4. Load in `main.dart` before running

## Important Files to Never Commit
- `lib/app/core/constants/config.dart` (has secrets)
- `.env` (has secrets)
- `android/app/google-services.json` (Firebase config)
- `ios/Runner/GoogleService-Info.plist` (Firebase config)
- `setup_neon.sql` (if modified with real data)

These are listed in `.gitignore` for your protection.

## Architecture Overview
```
lib/
  app/              # App shell, routing, theme
  features/         # Feature-specific code (auth, resources, etc.)
  shared/           # Shared models and widgets
  data/             # Data sources (Neon, Isar, etc.)
```

## Testing
```bash
flutter test
```

## Building for Release
```bash
flutter build apk          # Android
flutter build ios          # iOS
flutter build windows      # Windows
```

## Support
For issues, check the [Flutter docs](https://flutter.dev) and the respective service docs:
- Neon: https://neon.tech/docs
- Firebase: https://firebase.flutter.dev
- Cloudinary: https://cloudinary.com/documentation