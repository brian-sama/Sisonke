# 🚀 Google Play Console Deployment Guide for Serevo

This guide details the complete end-to-end process for preparing, signing, building, and deploying the **Serevo** Flutter mobile app to the **Google Play Console**.

---

## 📱 1. App Identifiers & Configuration

| Parameter | Configuration | Notes |
| :--- | :--- | :--- |
| **App Title** | `Serevo` | Configured in `AndroidManifest.xml` and `main.dart` |
| **Application ID** | `zw.org.serevo.app` | Unique store bundle ID configured in `app/build.gradle.kts` |
| **Namespace** | `com.example.sisonke` | Internal AGP code namespace |
| **Version** | `1.0.0+1` | `1.0.0` (versionName), `1` (versionCode) in `pubspec.yaml` |
| **Compile SDK** | `36` | Android 16 / 15 compatible |
| **Min SDK** | `21` | Android 5.0+ |

> [!IMPORTANT]
> Every subsequent update uploaded to Google Play Console must increment the **build number** (`+2`, `+3`, etc.) in `pubspec.yaml` (e.g., `version: 1.0.1+2`).

---

## 🔑 2. Release Keystore Generation & Signing Setup

Google Play Console requires apps to be cryptographically signed with an upload key. Debug keys are automatically rejected.

### Step 2.1: Generate the Release Keystore
Run the following command in PowerShell / Terminal:

```powershell
keytool -genkey -v -keystore sisonke/android/upload-keystore.jks `
  -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 `
  -alias upload
```

You will be prompted for:
- Keystore password (save this securely in a password manager!)
- Developer name, organization, city, and country code
- Key password (can be the same as store password)

### Step 2.2: Configure `android/key.properties`
Copy `android/key.properties.example` to `android/key.properties`:

```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=upload-keystore.jks
```

> [!CAUTION]
> Both `android/key.properties` and `*.jks` are in `.gitignore`. **NEVER** commit your private keystore or passwords to Git. Store an encrypted backup in a secure vault. If you lose your upload key, you will need to request a key reset through Google Play Console support.

---

## 📦 3. Building the Release Android App Bundle (.aab)

Google Play Console requires **Android App Bundles (.aab)** instead of APKs.

### Step 3.1: Clean and Prepare
```bash
cd sisonke
flutter clean
flutter pub get
```

### Step 3.2: Build the App Bundle
```bash
flutter build appbundle --release
```

To include symbol maps for Sentry / Play Console crash deobfuscation:
```bash
flutter build appbundle --release --obfuscate --split-debug-info=build/app/outputs/symbols
```

The resulting bundle is located at:
```text
sisonke/build/app/outputs/bundle/release/app-release.aab
```

---

## 🛡️ 4. ProGuard / R8 Rules

ProGuard rules are configured in `android/app/proguard-rules.pro` to safeguard:
- Flutter platform channels & embedding
- Isar database JNI reflection & collections
- Sentry error tracking line number mappings
- Android HomeWidget providers

---

## 📋 5. Google Play Console Listing & Policy Requirements

### 5.1 Store Listing Assets

| Asset | Specifications |
| :--- | :--- |
| **App Icon** | 512 x 512 px PNG (32-bit color, max 1024 KB, no alpha transparency on background) |
| **Feature Graphic** | 1024 x 500 px JPG or 24-bit PNG (no alpha, 16:9 ratio) |
| **Phone Screenshots** | Minimum 2 screenshots, maximum 8 (16:9 or 9:16 aspect ratio, min 320px, max 3840px) |
| **Short Description** | Maximum 80 characters (e.g. *Safe, private mental health support and youth mutual aid community.*) |
| **Full Description** | Maximum 4,000 characters detailing features, privacy guarantees, offline mode, and crisis contacts. |

### 5.2 Mandatory Policy Declarations

1. **Privacy Policy (REQUIRED)**:
   - Provide a publicly accessible URL (e.g., hosted via GitHub Pages, Vercel, or official website).
   - Must explicitly explain how sensitive data (audio recordings, mental health logs) are handled.
2. **App Permissions Justifications**:
   - `android.permission.RECORD_AUDIO`: Voice notes / audio grounding exercises.
   - `android.permission.POST_NOTIFICATIONS`: Daily check-in reminders and emergency crisis notifications.
   - `android.permission.USE_BIOMETRIC`: Local device authentication for app privacy locking.
3. **Data Safety Form**:
   - **Data Collection**: State clearly what data is stored locally (encrypted with AES-256) vs transmitted to backend APIs.
   - **Data Encryption**: Declare all network communications use TLS/HTTPS and local storage is encrypted at rest.
   - **Account Deletion**: Provide in-app account deletion or a URL where users can request data deletion.
4. **Target Audience & Content**:
   - Target age rating questionnaire (typically 13+ or 16+ due to mental health / crisis content).
5. **Health & Medical App Declarations**:
   - Specify that the app is a peer-support and wellness toolkit, not a licensed medical diagnostic service.

---

## 🚀 6. Release Tracks & Deployment Flow

1. **Internal Testing**:
   - Upload `app-release.aab` to **Testing > Internal testing**.
   - Add your own email to the tester list for immediate installation without review delay.
2. **Closed Testing (20 Testers Requirement)**:
   - For personal Google Play developer accounts created after Nov 2023: Google requires **at least 20 opted-in testers for 14 continuous days** before applying for production access.
3. **Production Release**:
   - Promote the validated build to Production.
   - Google review typically takes 1 to 5 business days for new apps.
