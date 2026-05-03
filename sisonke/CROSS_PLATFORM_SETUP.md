# Cross-platform setup

Sisonke's Flutter clients should run as API clients on Android, iOS, macOS, Linux, Windows, and web. Private logic, AI routing, moderation, counselor workflows, analytics, and database access live in the backend.

## API URLs

Pass the backend URL at build or run time:

```bash
flutter run --dart-define=API_BASE_URL=http://localhost:3001/api
flutter build apk --dart-define=API_BASE_URL=https://your-domain.example/api
flutter build ios --dart-define=API_BASE_URL=https://your-domain.example/api
flutter build macos --dart-define=API_BASE_URL=https://your-domain.example/api
flutter build linux --dart-define=API_BASE_URL=https://your-domain.example/api
```

Debug defaults:

```text
Android emulator: http://10.0.2.2:3001/api
iOS simulator, macOS, Linux, Windows, web: http://localhost:3001/api
Release: https://sisonke.mmpzmne.co.zw/api
```

## Platform notes

```text
Android: biometric prompts use FlutterFragmentActivity and require USE_BIOMETRIC.
iOS/macOS: Face ID/device auth usage text is configured in Info.plist.
Linux: PIN lock is supported; biometrics are hidden because local_auth has no Linux implementation here.
macOS/Linux/Windows/web: secure storage and shared preferences are provided by platform plugins.
```

## Client data rule

Do not ship database credentials in Flutter builds. The app should call the backend API; only backend services should connect to PostgreSQL, AI services, CMS, counselor routing, moderation, notifications, and security logs.
