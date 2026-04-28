# Sisonke App - Implementation Guide

## Phase 1: Foundation & Infrastructure ✅ COMPLETE

This document outlines the complete structure of the Sisonke wellness app and next steps for development.

### What Has Been Built

#### 1. **Data Models** (`lib/shared/models/`)
- `resource.dart` - Resources (articles, guides, tools)
- `mood.dart` - Mood check-in entries with emotions and energy levels
- `journal.dart` - Private journal entries
- `safety_plan.dart` - User safety plans with coping strategies and trusted contacts
- `recovery_tracker.dart` - Sobriety/recovery tracking with events
- `question.dart` - Anonymous Q&A system
- `support_contact.dart` - Helplines, clinics, counselors directory
- `notification.dart` - App notifications system
- `index.dart` - Barrel export for all models

#### 2. **Reusable Widgets** (`lib/shared/widgets/`)
- `emergency_help_button.dart` - Floating button available on all screens
- `sisonke_app_bar.dart` - Custom app bar with consistent styling
- `sisonke_button.dart` - Unified button component (primary, secondary, text, danger)
- `sisonke_card.dart` - Custom card widget + ResourceCard + specialized cards
- `sisonke_text_field.dart` - Custom text field with icons and validation
- `sisonke_dialogs.dart` - Dialog helper functions (confirm, info, sheets, snackbars)
- `index.dart` - Barrel export

#### 3. **State Management Providers** (`lib/app/core/providers/`)
- `app_preferences_provider.dart` - Theme, language, text size, notifications, app lock
- `auth_provider.dart` - Authentication state, user data
- `resource_provider.dart` - Resources, filtering, search, bookmarks
- `mood_provider.dart` - Mood entries, trends analysis
- `journal_provider.dart` - Journal entries, search, lock status
- `qa_provider.dart` - Questions, answers, saved items
- `index.dart` - Barrel export

#### 4. **Navigation & Routing** (`lib/app/router/`)
- `router.dart` - Complete Go Router setup with:
  - Bottom navigation shell with 5 tabs
  - All 25+ screen routes
  - Nested routing for detail screens
  - Proper path structure
- `bottom_navigation_shell.dart` - Custom bottom nav widget

#### 5. **Screens** (`lib/features/`)
**Onboarding:**
- `onboarding/splash_screen.dart` - App splash loader
- `onboarding/onboarding_screen.dart` - Multi-page onboarding flow

**Home:**
- `home/home_screen.dart` - Main dashboard with quick actions and featured resources
- `home/all_screens.dart` - 21 placeholder screens for all features:
  - Resources Hub & Details - Browse and read articles
  - Daily Check-In - Quick mood/wellness capture
  - Mood Tracker - View mood history and trends
  - Journal - Private diary with lock support
  - Emergency Toolkit - SOS resources
  - Safety Plan - Crisis response planning
  - Breathing & Grounding Exercises - Wellness tools
  - Q&A - Anonymous question browsing & asking
  - Support Directory - Find local help
  - Bookmarks - Saved items
  - Notifications - App alerts
  - Settings & Privacy - Preferences
  - Topic Selection - Interest-based onboarding
  - Auth flow screens
  - Language selection
  - App lock screen
  - Quick exit screen

### Screens Overview (25 Total)

#### Navigation Tabs
```
📱 Home                  - Dashboard with quick actions
📚 Resources             - Educational content hub
😊 Check-In              - Mood & wellness tracking
🤝 Support               - Find help & Q&A
⚙️ Settings              - Preferences
```

#### Quick Access (Available Everywhere)
🆘 Emergency Help Button - Red floating button

### Architecture Overview

```
lib/
├── app/
│   ├── core/
│   │   └── providers/         # Riverpod state management
│   ├── router/
│   │   ├── router.dart        # Main routing logic
│   │   └── bottom_navigation_shell.dart
│   └── theme/
├── features/
│   ├── home/                  # Home & all placeholder screens
│   ├── onboarding/            # Splash & onboarding
│   ├── resources/             # (Future: resource detail logic)
│   ├── mood_tracker/          # (Future: mood tracking logic)
│   ├── journal/               # (Future: journal logic)
│   ├── emergency/             # (Future: emergency toolkit)
│   ├── qa/                    # (Future: Q&A logic)
│   ├── settings/              # (Future: settings logic)
│   ├── auth/                  # (Future: authentication)
│   └── sobriety_tracker/      # (Future: recovery tracking)
├── shared/
│   ├── models/                # Data models (8 types)
│   ├── widgets/               # Reusable UI components (6 types)
│   └── services/              # (Future: API/database services)
└── main.dart
```

### Dependencies Used

```yaml
flutter_riverpod: ^2.4.9      # State management
go_router: ^12.1.3            # Navigation
firebase_*: ^2.24+            # Authentication & backend
postgres: ^3.0.8              # Neon PostgreSQL
isar: ^3.1.0                  # Local storage
intl: ^0.19.0                 # Internationalization
connectivity_plus: ^5.0.2     # Network detection
url_launcher: ^6.2.5          # Links & phone calls
local_auth: ^2.1.7            # Biometric lock
flutter_secure_storage: ^9.0  # Secure storage
```

---

## Phase 2: Core Features Implementation

### 2.1 - Home Dashboard (In Progress)
**Current Status:** Basic layout complete, needs:
- [ ] Resource carousel/featured section
- [ ] Quick stats cards (mood average, journal count, etc.)
- [ ] Notifications integration
- [ ] Recent activity display

### 2.2 - Resources Feature
**Files needed:**
- `lib/features/resources/resources_screen.dart` - Grid/list of resources
- `lib/features/resources/resource_detail_screen.dart` - Full article view
- `lib/features/resources/search_and_filter.dart` - Search logic
- `lib/features/resources/providers.dart` - Resource state management

**Key Features:**
- [ ] Search by title/content
- [ ] Filter by category
- [ ] Save for later (bookmarks)
- [ ] Download for offline
- [ ] Share resources
- [ ] Related resources suggestions
- [ ] Read time estimation
- [ ] Text-to-speech

### 2.3 - Check-In & Mood Tracking
**Files needed:**
- `lib/features/mood_tracker/check_in_screen.dart` - Quick mood capture
- `lib/features/mood_tracker/mood_history_screen.dart` - Calendar/chart view
- `lib/features/mood_tracker/mood_trends_screen.dart` - Analytics
- `lib/features/mood_tracker/providers.dart` - Mood state

**Key Features:**
- [ ] 6-emotion picker (Great, Okay, Low, Anxious, Angry, Overwhelmed)
- [ ] Optional note
- [ ] Energy level slider
- [ ] Historical view (week/month/year)
- [ ] Trend analysis
- [ ] Suggestions based on mood patterns
- [ ] Export data

### 2.4 - Journal
**Files needed:**
- `lib/features/journal/journal_list_screen.dart` - All entries
- `lib/features/journal/journal_entry_screen.dart` - Write/edit
- `lib/features/journal/journal_detail_screen.dart` - Read entry
- `lib/features/journal/providers.dart` - Journal state

**Key Features:**
- [ ] Create/edit/delete entries
- [ ] Search entries
- [ ] Tag system
- [ ] PIN/biometric lock specific entry
- [ ] Full journal lock
- [ ] Export entry
- [ ] Linked mood at time of writing
- [ ] Word count

### 2.5 - Emergency Toolkit
**Files needed:**
- `lib/features/emergency/emergency_screen.dart` - Main toolkit
- `lib/features/emergency/breathing_exercise_screen.dart` - Breathing guide
- `lib/features/emergency/grounding_exercise_screen.dart` - 5-4-3-2-1 technique
- `lib/features/emergency/safety_plan_screen.dart` - Crisis plan editor
- `lib/features/emergency/providers.dart` - Emergency state

**Key Features:**
- [ ] Quick call buttons (emergency, helpline, trusted contact)
- [ ] Breathing exercise (4-7-8, box breathing, etc.)
- [ ] Grounding techniques (5 senses, etc.)
- [ ] Safety plan management
- [ ] Coping strategy quick reference
- [ ] Music/sounds for exercises
- [ ] Timer function

### 2.6 - Anonymous Q&A
**Files needed:**
- `lib/features/qa/qa_list_screen.dart` - Browse questions
- `lib/features/qa/ask_question_screen.dart` - Submit question
- `lib/features/qa/question_detail_screen.dart` - Read answer
- `lib/features/qa/providers.dart` - Q&A state

**Key Features:**
- [ ] View answered questions
- [ ] Browse by category
- [ ] Search questions
- [ ] Submit anonymous question
- [ ] Vote helpful/not helpful
- [ ] Save answer
- [ ] Report inappropriate content

### 2.7 - Support Directory
**Files needed:**
- `lib/features/settings/support_directory_screen.dart` - Find help
- `lib/features/settings/support_detail_screen.dart` - Contact info
- `lib/features/settings/providers.dart` - Directory state

**Key Features:**
- [ ] Search by service type
- [ ] Filter by location
- [ ] Show on map
- [ ] Call/message/visit website
- [ ] Save favorite contacts
- [ ] Operating hours display
- [ ] User ratings/reviews

### 2.8 - Settings & Privacy
**Files needed:**
- `lib/features/settings/settings_screen.dart` - Main settings
- `lib/features/settings/privacy_center_screen.dart` - Data management
- `lib/features/settings/notification_settings_screen.dart` - Alert preferences
- `lib/features/settings/providers.dart` - Settings state

**Key Features:**
- [ ] Dark mode toggle
- [ ] Language selection
- [ ] Text size adjustment
- [ ] Notification settings
- [ ] App lock with PIN/biometric
- [ ] Delete personal data
- [ ] Export all data
- [ ] Privacy policy link
- [ ] Version/about info

---

## Running the App

### Initial Setup
```bash
# Get dependencies
flutter pub get

# Run app development server
flutter run

# Run on specific device
flutter run -d chrome                    # Web
flutter run -d emulator-5554             # Android emulator
flutter run -d connected_ios_device      # iOS device
```

### Build & Deploy
```bash
# Build APK for Android
flutter build apk

# Build iOS
flutter build ios

# Clean build
flutter clean
flutter pub get
flutter run
```

### Code Quality
```bash
# Analyze code
flutter analyze

# Format code
dart format lib/

# Run tests
flutter test
```

---

## Next Steps for Phase 2

### Priority Order:
1. **Implement Home Dashboard** - Core landing page
2. **Build Resources Feature** - Main content delivery
3. **Add Mood Tracker** - Core wellness feature
4. **Implement Journal** - Personal data storage
5. **Emergency Toolkit** - Mental health support
6. **Q&A System** - Community education
7. **Support Directory** - Resource finding
8. **Settings & Auth** - User management

### Each Feature Needs:

```
1. Service Layer (API calls, data fetching)
2. Riverpod Provider (state management)
3. UI Screens (widgets)
4. Local Storage (Isar/SharedPreferences)
5. Tests (unit + widget tests)
6. Error Handling
7. Offline Support
8. Analytics Events
```

---

## Important Notes

### Data Security
- Personal data (journal, moods) should be encrypted
- Consider using `flutter_secure_storage` for sensitive info
- PIN/biometric for sensitive screens

### Offline Support
- Resources can be cached locally
- Journal entries stored locally
- Sync with backend when online
- Use Isar for local database

### Performance
- Lazy load screens
- Cache resources
- Paginate lists
- Optimize images

### Accessibility
- Use semantic labels
- Adequate contrast ratios
- Text scaling support (already implemented)
- Screen reader support

---

## File Structure Summary

Total files created in Phase 1:
- ✅ 8 Model files (resources, mood, journal, etc.)
- ✅ 6 Widget files (buttons, cards, dialogs, etc.)
- ✅ 6 Provider files (state management)
- ✅ 25+ Placeholder screens
- ✅ 3 Router files
- ✅ Updated main.dart

**Total: ~50+ new files in foundation**

---

## Questions or Issues?

Refer back to:
- Models: `lib/shared/models/` - Define your data types
- Widgets: `lib/shared/widgets/` - Reusable components
- Providers: `lib/app/core/providers/` - Global state
- Screens: `lib/features/*/` - Feature implementations
- Router: `lib/app/router/router.dart` - Navigation paths

