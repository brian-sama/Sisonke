# 🚀 Sisonke Release Checklist

## 🔐 Security & Privacy
- [x] AES-256 Encryption for Local Journaling.
- [x] Screenshot protection enabled on sensitive screens.
- [x] Biometric / PIN Authentication implemented.
- [x] DB Migrations restricted to `kDebugMode` (no DB creds in production binary).
- [ ] Update Sentry DSN in `lib/main.dart`.
- [ ] Review Backend CORS settings for production URL.

## 📊 Performance
- [x] Image caching using `CachedNetworkImage`.
- [x] Optimized Isar database queries.
- [x] ProGuard enabled for Android (default in Flutter).

## 🌍 Internationalization (l10n)
- [x] English support.
- [x] Shona (sn) support (placeholders added).
- [x] Ndebele (nd) support (placeholders added).

## 📱 App Store Prep (Android)
- [x] Application ID set to `zw.org.sisonke.app`.
- [ ] Create signing key (Keystore).
- [ ] Update `android/app/build.gradle.kts` with signing config.
- [ ] Prepare Store listing:
    - [ ] App Name: Sisonke Wellness
    - [ ] Short Description: Mental Health & SRHR support for Zimbabwean youth.
    - [ ] Privacy Policy URL.

## 🌐 Backend Deployment
- [x] `vercel.json` configured for Express.js deployment.
- [ ] Set environment variables in Vercel:
    - `DATABASE_URL`
    - `JWT_SECRET`
    - `NODE_ENV=production`

## ✅ Final Testing
- [ ] Test on real Android device.
- [ ] Verify offline mode works.
- [ ] Verify emergency toolkit loads fallback data if offline.
