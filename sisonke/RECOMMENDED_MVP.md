# 🚀 Sisonke Phase 2 - Recommended Implementation Plan

## RECOMMENDED MVP CONFIGURATION

Based on best practices for a mental health + SRHR app in Zimbabwe, here's my suggested approach:

```
✅ TARGET USERS
   → Young people 13-24 in Zimbabwe
   → Culturally sensitive, youth-first
   → Starting with schools & NGO partnerships

✅ PRIMARY FOCUS (MVP)
   → Mental Health & Wellness (Core)
   → Emergency Support (Critical)
   → Resource Library (Essential)
   → Anonymous Q&A (Engagement)
   → Mood Tracking (Retention)
   
   OUT OF SCOPE v1:
   → Telemedicine, Social chat, AI
   → Advanced analytics, Video content

✅ PRIVACY MODEL (Privacy-First)
   → Personal Data: Local Only
   → Mood/Journal: Never leave device unless user enables backup
   → Anonymous Posts: No personal data collected
   → Tracking: None (no Firebase Analytics yet)
   → Accounts: Optional (guest-first)

✅ BACKEND
   → YES - But lightweight
   → Framework: Express.js (simple, fast)
   → ORM: Drizzle (type-safe, minimal)
   → Database: Neon PostgreSQL (already configured)
   → Deployment: Vercel (free, easy, reliable)
   → Auth: Custom JWT (Firebase optional later)

✅ EMERGENCY HANDLING
   → Show trusted helpline numbers prominently
   → Quick Exit button (one tap to hide)
   → Message trusted contact feature
   → Breathing exercises (offline)
   → NO auto-SMS (privacy first)
   → NO location tracking initially

✅ CONTENT STRATEGY
   → Partner with local NGOs (Mental Welfare, ALAC)
   → Initial 20-30 articles seeded by partners
   → Community-contributed resources (moderated)
   → Languages: English + Shona + Ndebele
   → All articles downloadable offline

✅ MODERATION (Lean but Safe)
   → Community volunteers answer questions
   → Staff review before publishing
   → Auto-flag: Suicide/self-harm keywords
   → Reject: Spam, hate speech, medical advice
   → Response SLA: 48 hours for urgent, 1 week normal

✅ ADMIN PANEL
   → NOT in Phase 2 (can be web later)
   → Use backend directly for initial content
   → Manual database updates for migrations

✅ OFFLINE
   → Everything works offline locally
   → Auto-sync when online (no user action)
   → Storage: <100MB limit
   → Cache strategy: Auto-expire old data

✅ NOTIFICATIONS
   → Optional (off by default)
   → Max 1 per day
   → Types: Check-in reminder, new answers, motivational
   → Can disable all notifications

✅ SECURITY
   → PIN lock option (4-digit code)
   → Biometric support (fingerprint)
   → Quick exit (minimizes app)
   → Screenshot blocking on journal
   → Data export as JSON

✅ BRANDING
   → Friendly + professional tone
   → Primary color: Green (#2E7D32 - growth, hope)
   → Modern design, culturally respectful
   → Icon: Stylized hand (support) or heart (care)
   → NOT discreet - clear this is wellness app

✅ LEGAL
   → Privacy Policy (required)
   → Terms of Use (required)
   → Medical Disclaimer (required)
   → Age: 13+ (parental discretion)
   → Data retention: 30 days inactive deletion option

✅ LAUNCH TARGET
   → Week 1-2: Backend + admin endpoints
   → Week 3-4: Resources feature fully built
   → Week 5-6: Mood tracker + journal
   → Week 7-8: Q&A system + emergency toolkit
   → Week 9-10: Polish, testing, launch
   → Target: MVP in 10 weeks from now
```

---

## PHASE 2 IMPLEMENTATION ROADMAP

### Sprint 1 (Week 1-2): Backend Foundation

**What to build:**
1. Express.js API server
2. Neon database schema
3. JWT authentication
4. Resource endpoints (CRUD)
5. Question/Answer endpoints

**Files to create:**
```
backend/
├── src/
│   ├── db/
│   │   ├── schema.ts        # Drizzle schema
│   │   └── migrations/      # Database migrations
│   ├── routes/
│   │   ├── resources.ts     # GET/POST/PUT/DELETE resources
│   │   ├── questions.ts     # Q&A endpoints
│   │   ├── auth.ts          # JWT auth
│   │   └── health.ts        # Health check
│   ├── middleware/
│   │   ├── auth.ts          # Auth middleware
│   │   └── errorHandler.ts  # Error handling
│   ├── services/
│   │   ├── resourceService.ts
│   │   └── qaService.ts
│   ├── types/
│   │   └── index.ts         # TypeScript types
│   └── index.ts             # App entry point
├── package.json
├── drizzle.config.ts
└── .env.example
```

**Deploy to:** Vercel (free tier)

---

### Sprint 2 (Week 3-4): Resources Feature

**Frontend:**
```dart
// lib/features/resources/
├── services/
│   └── resource_service.dart      # API calls
├── providers/
│   └── resource_provider_extended.dart  # Data fetching
├── screens/
│   ├── resources_screen.dart      # List view
│   ├── resource_detail_screen.dart
│   ├── search_screen.dart
│   └── resource_filter_screen.dart
└── widgets/
    ├── resource_card.dart
    ├── category_filter.dart
    └── search_bar.dart
```

**Backend:**
```
POST   /api/resources              # Create
GET    /api/resources              # List + filter + search
GET    /api/resources/:id          # Get one
PUT    /api/resources/:id          # Update (admin only)
DELETE /api/resources/:id          # Delete (admin only)
GET    /api/resources/:id/download # Get offline version
```

**Features:**
- Browse all resources by category
- Search by keyword
- Filter by type (article, guide, video)
- Save to bookmarks (local)
- Download for offline (local storage)
- Read time estimate
- Text size adjustment

---

### Sprint 3 (Week 5-6): Mood Tracker & Journal

**Frontend:**
```dart
// lib/features/mood_tracker/
├── screens/
│   ├── checkin_screen.dart        # Quick mood capture
│   ├── mood_history_screen.dart   # Calendar view
│   ├── mood_trends_screen.dart    # Analysis
│   └── mood_detail_screen.dart
├── providers/
│   └── mood_tracking_provider.dart
└── widgets/
    ├── mood_picker.dart
    ├── mood_chart.dart
    └── energy_slider.dart

// lib/features/journal/
├── screens/
│   ├── journal_list_screen.dart
│   ├── journal_entry_screen.dart  # Write/edit
│   ├── journal_detail_screen.dart # Read
│   └── journal_search_screen.dart
├── providers/
│   └── journal_provider_extended.dart
├── services/
│   └── journal_encryption_service.dart  # Encrypt locally
└── widgets/
    ├── journal_entry_card.dart
    └── tag_picker.dart
```

**Features:**
- 6-emotion picker (Great, Okay, Low, Anxious, Angry, Overwhelmed)
- Energy level slider (1-10)
- Optional note with max 1000 chars
- Calendar heatmap of moods
- Trend analysis (most common, average energy)
- Journal with PIN lock
- Search by tags
- Export as PDF/JSON

**All local storage** (encrypted at rest if possible)

---

### Sprint 4 (Week 7-8): Q&A & Emergency Toolkit

**Frontend - Q&A:**
```dart
// lib/features/qa/
├── screens/
│   ├── qa_browse_screen.dart      # All questions
│   ├── ask_question_screen.dart   # Submit anonymous
│   ├── question_detail_screen.dart
│   └── qa_filter_screen.dart      # By category
├── providers/
│   └── qa_provider_extended.dart
└── widgets/
    ├── question_card.dart
    └── answer_card.dart
```

**Backend - Q&A:**
```
GET    /api/questions              # List + category filter
GET    /api/questions/:id          # Get with answers
POST   /api/questions              # Anonymous submit
GET    /api/answers/:id            # Get answer
POST   /api/answers/:id/helpful    # Mark helpful
POST   /api/questions/:id/report   # Report issue
```

**Frontend - Emergency:**
```dart
// lib/features/emergency/
├── screens/
│   ├── emergency_toolkit_screen.dart
│   ├── breathing_exercise_screen.dart
│   ├── grounding_exercise_screen.dart
│   └── safety_plan_editor_screen.dart
├── widgets/
│   ├── helpline_quick_call.dart
│   ├── breathing_animator.dart
│   ├── grounding_steps.dart
│   └── trusted_contact_item.dart
└── services/
    └── emergency_service.dart
```

**Features:**
- Quick call buttons to helplines
- Breathing exercise (4-7-8, box breathing)
- Grounding technique (5 senses)
- Safety plan editor (warnings, strategies, contacts)
- Message trusted contact
- Resources for crisis

---

### Sprint 5 (Week 9-10): Polish & Launch

**What to do:**
1. Security audit
2. Performance optimization
3. Testing (unit + widget tests)
4. User testing with sample users
5. Accessibility review
6. Beta release (TestFlight + internal testing)
7. Bug fixes
8. Launch to stores

**To complete:**
```
□ All screens responsive (mobile, tablet)
□ Error messages user-friendly
□ Empty states designed
□ Loading states shown
□ Offline mode tested
□ Privacy policy finalized
□ Terms of use finalized
□ Medical disclaimer added
□ Crash reporting (Sentry)
□ Analytics (basic)
□ App signing (Android + iOS)
□ App store listings
```

---

## BACKEND STRUCTURE (Detailed)

### Database Schema

```sql
-- Resources
CREATE TABLE resources (
  id UUID PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  content TEXT,
  category VARCHAR(50) NOT NULL,
  tags VARCHAR(255)[],
  author_id UUID,
  image_url VARCHAR(255),
  reading_time_minutes INT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP,
  is_published BOOLEAN DEFAULT TRUE,
  is_offline_available BOOLEAN DEFAULT FALSE
);

-- Questions
CREATE TABLE questions (
  id UUID PRIMARY KEY,
  title VARCHAR(300) NOT NULL,
  description TEXT NOT NULL,
  category VARCHAR(50) NOT NULL,
  submitted_at TIMESTAMP DEFAULT NOW(),
  is_answered BOOLEAN DEFAULT FALSE,
  is_published BOOLEAN DEFAULT FALSE,
  flagged_for_urgent BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP
);

-- Answers
CREATE TABLE answers (
  id UUID PRIMARY KEY,
  question_id UUID NOT NULL REFERENCES questions(id),
  content TEXT NOT NULL,
  expert_name VARCHAR(255),
  expert_role VARCHAR(255),
  answered_at TIMESTAMP DEFAULT NOW(),
  helpful_count INT DEFAULT 0,
  is_published BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP
);

-- Users (optional)
CREATE TABLE users (
  id UUID PRIMARY KEY,
  email VARCHAR(255),
  password_hash VARCHAR(255),
  created_at TIMESTAMP DEFAULT NOW(),
  device_id VARCHAR(255) UNIQUE,
  is_guest BOOLEAN DEFAULT TRUE
);

-- User Bookmarks
CREATE TABLE bookmarks (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL,
  resource_id UUID NOT NULL REFERENCES resources(id),
  created_at TIMESTAMP DEFAULT NOW()
);

-- Reports
CREATE TABLE reports (
  id UUID PRIMARY KEY,
  type VARCHAR(50),  -- 'question', 'answer', 'resource'
  resource_id UUID,
  reason VARCHAR(255),
  description TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  status VARCHAR(50) DEFAULT 'pending'
);
```

### API Endpoints

```
AUTH
POST   /api/auth/register         # Create account
POST   /api/auth/login            # Get JWT
POST   /api/auth/guest            # Guest session
POST   /api/auth/refresh          # Refresh token

RESOURCES
GET    /api/resources             # List all
GET    /api/resources?category=mental-health
GET    /api/resources?search=stress
GET    /api/resources/:id         # Get one
POST   /api/resources             # Create (admin)
PUT    /api/resources/:id         # Update (admin)
DELETE /api/resources/:id         # Delete (admin)

QUESTIONS
GET    /api/questions             # List all
GET    /api/questions?category=srhr
POST   /api/questions             # Submit anonymous
GET    /api/questions/:id         # Get with answers
POST   /api/questions/:id/report  # Report question

ANSWERS
GET    /api/answers/:id           # Get answer
POST   /api/answers/:id/helpful   # Mark helpful
POST   /api/answers/:id/report    # Report answer

BOOKMARKS
GET    /api/bookmarks             # Get user's bookmarks
POST   /api/bookmarks             # Add bookmark
DELETE /api/bookmarks/:id         # Remove bookmark

SYNC
POST   /api/sync/moods            # Upload mood data (optional)
POST   /api/sync/journal          # Backup journal (optional)
GET    /api/sync/resources        # Get latest resource list
```

---

## ESTIMATED TIMELINE

```
Week 1-2:  Backend foundation         ✅ (Core endpoints)
Week 3-4:  Resources feature          ✅ (Search, filter, offline)
Week 5-6:  Mood + Journal             ✅ (Local storage)
Week 7-8:  Q&A + Emergency            ✅ (Community features)
Week 9-10: Testing + Launch           ✅ (Beta → Store release)

Total: 10 weeks = ~2.5 months
Ideal launch: Mid-July 2026
```

---

## EFFORT ESTIMATES

```
Phase 2 Frontend:  80 hours  (~4 weeks, 1 dev)
Phase 2 Backend:   40 hours  (~2 weeks, 1 dev)
Testing:           20 hours  (~1 week)
Deployment:        10 hours  (~0.5 week)
---
TOTAL:            150 hours  (~7.5 weeks)
```

---

## TECH STACK (Recommended)

**Frontend:**
- Flutter 3.19+
- Riverpod (state management) ✅ Already in place
- Go Router (navigation) ✅ Already in place
- Isar (local database) ✅ Already configured
- HTTP + Dio (API calls)
- Encrypted_preferences (secure storage)

**Backend:**
- Node.js 18+ LTS
- Express.js (framework)
- Drizzle ORM (database access)
- Neon PostgreSQL (database) ✅ Already configured
- Vercel (deployment)
- JWT (authentication)

**Infrastructure:**
- Neon PostgreSQL (database)
- Vercel (backend hosting - free tier)
- Firebase Storage (optional - media storage)
- Sentry (error tracking)

---

## DEPENDENCIES TO ADD

**Frontend (`pubspec.yaml`):**
```yaml
dependencies:
  dio: ^5.3.0                    # HTTP client
  http: ^1.1.0                  # Alternative to Dio
  encrypted_preferences: ^2.0.0 # Secure local storage
  charts_flutter: ^0.12.0       # Mood charts (optional)
  intl: ^0.19.0                 # Already added
  table_calendar: ^3.0.8        # Calendar for mood tracker
```

**Backend (`package.json`):**
```json
{
  "dependencies": {
    "express": "^4.18.2",
    "drizzle-orm": "^0.29.1",
    "drizzle-kit": "^0.20.0",
    "pg": "^8.11.0",
    "jsonwebtoken": "^9.1.0",
    "bcryptjs": "^2.4.3",
    "cors": "^2.8.5",
    "dotenv": "^16.3.1"
  }
}
```

---

## NEXT STEPS

### If you accept these recommendations:

1. **Reply with:** "Accept recommended MVP"
2. I will immediately:
   - Generate backend starter code (Express + Drizzle)
   - Create database schema
   - Build API starter templates
   - Create feature implementation roadmap
   - Provide week-by-week breakdown

### If you want modifications:

1. **Fill in the STRATEGIC_REQUIREMENTS.md**
2. Reply with your decisions
3. I'll adjust this roadmap accordingly

### If you want to start right now:

Reply with any 5 key decisions:
```
Target Users: [Your answer]
MVP Focus: [Your answer]
Privacy Model: [Your answer]
Backend Framework: [Your answer]
Emergency Handling: [Your answer]
```

And I'll begin Phase 2 implementation immediately.

---

## QUESTIONS FOR YOU

Before I proceed, please clarify:

1. **Do you accept the Recommended MVP above?** (Yes/No/Partial)
2. **Timeline: Can you commit 2.5 months for launch?** (Yes/Flexible/Need shorter)
3. **Team: Who's building this?** (You + dev? NGO partnership? Outsourced?)
4. **Budget: Backend hosting - free (Vercel), cheap (<$50/mo), or doesn't matter?**
5. **Content: Do you have NGO partners ready to provide initial articles?**

Your answers will help me prioritize and adjust timelines.

---

**What would you like to do next?**

A) ✅ Accept recommended MVP → Start building backend
B) ✅ Fill out strategic requirements → Customize approach  
C) ✅ Provide 5 key decisions → I'll fill in the rest
D) ✅ Schedule quick discussion → Clarify priorities together

Let me know! 🚀

