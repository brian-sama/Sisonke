# 🎯 Sisonke App - Strategic Requirements & Decisions

## URGENT: Answer These 15 Questions Before Phase 2

This document will guide all Phase 2 implementation. **Your answers here determine architecture, features, and priorities.**

---

## TIER 1: CRITICAL DECISIONS (Decide First)

### ❌ 1. TARGET USERS

**Who is the first version for?**

- [ ] A. Young people only (13-24 years)
- [ ] B. Students (16+ in schools/universities)
- [ ] C. Community members (general adults 18+)
- [ ] D. Parents/Guardians too (18+ responsible adults)
- [ ] E. Everyone (13+ to unrestricted adults)

**Geographic scope?**

- [ ] A. Zimbabwe only
- [ ] B. Southern Africa (SADC region)
- [ ] C. Sub-Saharan Africa
- [ ] D. English-speaking globally
- [ ] E. Undecided - start with Zimbabwe

**Answer format:**
```
Target Users: [A/B/C/D/E]
Geographic: [A/B/C/D/E]
Rationale: [Brief explanation]
```

---

### ❌ 2. MVP CORE FOCUS

**What's the ONE thing this app does best in v1?**

- [ ] A. Mental Health Support (primary)
  - Daily mood tracking, coping strategies, exercises
- [ ] B. Sexual & Reproductive Health (primary)
  - Education, contraception info, clinic finder
- [ ] C. Substance Use Support (primary)
  - Recovery tracking, urge management, resources
- [ ] D. Emergency Toolkit (primary)
  - Breathing, grounding, helpline integration
- [ ] E. Anonymous Q&A (primary)
  - Community-driven answers, expert content
- [ ] F. Balanced MVP - All above, simplified

**What is DEFINITELY in v1?**

- [ ] Emergency contacts/helplines (essential)
- [ ] Resource library (articles/guides)
- [ ] Daily check-in (mood or wellness)
- [ ] Anonymous Q&A
- [ ] Offline reading

**What is DEFINITELY NOT in v1?**

- [ ] Telemedicine appointments
- [ ] AI chatbot
- [ ] Social features (forum, chat)
- [ ] Advanced analytics
- [ ] Video content

**Answer format:**
```
Primary Focus: [A/B/C/D/E/F]
Must Have: [List 3-5]
Out of Scope v1: [List 3-5]
```

---

### ❌ 3. PRIVACY MODEL

**Where does user data live?**

**Case 1: Personal Content (Journal, Moods, Safety Plan)**
- [ ] A. LOCAL ONLY - Never sent to server (most private)
- [ ] B. Local + Optional Backup to Neon (if user enables)
- [ ] C. Always Encrypted on Neon
- [ ] D. Neon unencrypted (least private)

**Case 2: Anonymous Content (Q&A Submissions)**
- [ ] A. No personal data collected (fully anonymous)
- [ ] B. IP + timestamp logged for moderation
- [ ] C. Linked to optional user account
- [ ] D. Full device fingerprinting

**Case 3: Behavior Tracking**
- [ ] A. No tracking (privacy-first)
- [ ] B. Anonymous analytics (no user ID)
- [ ] C. User ID tracking (Firebase Analytics)
- [ ] D. Full funnel tracking

**Case 4: Account Data**
- [ ] A. No accounts required
- [ ] B. Optional accounts (guest-first)
- [ ] C. Required accounts
- [ ] D. Accounts + linked profiles

**Answer format:**
```
Personal Data: [A/B/C/D]
Anonymous Posts: [A/B/C/D]
Tracking: [A/B/C/D]
Accounts: [A/B/C/D]
Justification: [Why this approach?]
```

---

### ❌ 4. EMERGENCY HANDLING

**If someone says they're in danger:**

- [ ] A. Show helpline numbers + links (passive)
- [ ] B. Prompt them to call helpline (active)
- [ ] C. Allow them to message trusted contact
- [ ] D. Allow auto-SMS to trusted contact
- [ ] E. No special handling - just resources

**Which helplines to include?**

```
Country: Zimbabwe
Crisis Hotlines:
- [ ] Lifeline: +263 292 62 662
- [ ] ALAC: +263 242 307 048
- [ ] Mental Welfare: [Provide numbers]
- [ ] SRHR Services: [Provide numbers]
```

**Quick exit feature?**

- [ ] A. Yes - Red "Exit" button → neutral screen
- [ ] B. No - Privacy through app lock only
- [ ] C. Yes - Press power button twice

**Location tracking?**

- [ ] A. Never collect location
- [ ] B. Optional for "find nearby help"
- [ ] C. Required for some features
- [ ] D. Automatic with user consent

**Answer format:**
```
When User Says "I'm Suicidal":
Response: [A/B/C/D/E]

Quick Exit: [A/B/C]
Location: [A/B/C/D]
Helplines: [List with numbers]
Trusted Contacts: [Yes/No - can user add family/friend numbers?]
```

---

### ❌ 5. BACKEND STRUCTURE

**Do you even need a backend?**

- [ ] A. NO - Fully local (offline-first, no sync)
- [ ] B. YES - Cloud sync optional
- [ ] C. YES - Cloud required for features

**If yes to backend:**

**Node.js Framework?**
- [ ] A. Express (lightweight)
- [ ] B. Hono (fast, edge-ready)
- [ ] C. NestJS (enterprise-grade)
- [ ] D. Next.js API Routes (simplest)
- [ ] E. Not decided yet

**Database ORM?**
- [ ] A. Drizzle (type-safe, lightweight)
- [ ] B. Prisma (popular, migrations easier)
- [ ] C. TypeORM (traditional ORM)
- [ ] D. Raw Neon queries

**Deployment?**
- [ ] A. Vercel (easy, free tier)
- [ ] B. Railway (affordable, reliable)
- [ ] C. Self-hosted (full control)
- [ ] D. AWS/Google Cloud (scalable)

**Answer format:**
```
Backend Needed: [Yes/No]
If Yes:
  Framework: [A/B/C/D/E]
  ORM: [A/B/C/D]
  Deployment: [A/B/C/D]
  Auth Method: [Firebase / Custom JWT / Supabase]
```

---

## TIER 2: IMPORTANT DECISIONS

### ❌ 6. CONTENT STRATEGY

**Who writes articles?**

- [ ] A. In-house team (hire writers)
- [ ] B. NGO partners (Mental Welfare, ALAC, etc.)
- [ ] C. Community volunteers (moderated)
- [ ] D. Repurposed from open-source health content
- [ ] E. Combination

**Who approves SRHR/Mental Health content?**

- [ ] A. Health professionals (doctors, counselors)
- [ ] B. NGO review board
- [ ] C. Community volunteers
- [ ] D. Internal team (no formal review)

**Language support v1:**

- [ ] A. English only
- [ ] B. English + Shona
- [ ] C. English + Ndebele
- [ ] D. All three (English, Shona, Ndebele)
- [ ] E. English + Shona + Ndebele + other languages

**Offline access:**

- [ ] A. ALL articles downloadable
- [ ] B. User can PIN favorite articles
- [ ] C. Auto-cache "popular" articles
- [ ] D. Read-once only (network required)

**Answer format:**
```
Content Authors: [A/B/C/D/E]
Approval Process: [A/B/C/D]
Languages v1: [A/B/C/D/E]
Offline: [A/B/C/D]
Initial Seeding: [How many articles to launch with?]
```

---

### ❌ 7. MODERATION SYSTEM (For Anonymous Q&A)

**Who answers questions?**

- [ ] A. Health professionals only
- [ ] B. Trained peer educators
- [ ] C. NGO staff
- [ ] D. Community volunteers (moderated)
- [ ] E. No answers - just resource recommendations

**Who moderates submissions?**

- [ ] A. Automated (keyword filtering)
- [ ] B. Manual review by staff
- [ ] C. Community flagging + staff review
- [ ] D. No moderation - all published

**What content is rejected?**

- [ ] Spam/ads → Always reject
- [ ] Hate speech → Always reject
- [ ] Self-harm indicators → Flag for urgent response
- [ ] Medical advice requests → [Your policy]
- [ ] Off-topic → [Your policy]

**Urgent questions (self-harm/suicide)?**

- [ ] A. Auto-flag to moderators + show crisis resources
- [ ] B. Manual review only
- [ ] C. No special handling
- [ ] D. Auto-response + human review

**Answer format:**
```
Responders: [A/B/C/D/E]
Moderation: [A/B/C/D]
Rejection Criteria: [List]
Urgent Handling: [A/B/C/D]
Response SLA: [How fast should answers be?]
```

---

### ❌ 8. ADMIN DASHBOARD

**Do you need an admin panel?**

- [ ] A. No - Everything managed in app
- [ ] B. Minimal - Just manage emergency contacts
- [ ] C. Basic - Manage content + flag submissions
- [ ] D. Full - Analytics, moderation, user management
- [ ] E. Yes, but build in Phase 3

**If yes, what features?**

- [ ] A. Manage resources (add/edit/delete articles)
- [ ] B. Review Q&A submissions
- [ ] C. Answer questions
- [ ] D. View analytics (how many users, check-ins, etc.)
- [ ] E. Manage helpline numbers
- [ ] F. View reports (abuse, bugs)
- [ ] G. User management (block, delete)
- [ ] H. View mod queue (flagged content)

**Answer format:**
```
Admin Panel Needed: [A/B/C/D/E]
Must-Have Features: [List from A-H]
Timeline: [Phase 2 or Phase 3+?]
Admins: [How many people will use this?]
```

---

### ❌ 9. OFFLINE FUNCTIONALITY

**What MUST work without internet?**

- [ ] Emergency numbers (helplines)
- [ ] Saved articles (cached)
- [ ] Mood tracker (local storage)
- [ ] Journal (local storage)
- [ ] Breathing exercises (not dynamic)
- [ ] Safety plan (local storage)
- [ ] Q&A reading (cached answers only)

**Sync strategy:**

- [ ] A. Sync on app open (if online)
- [ ] B. Sync every X minutes
- [ ] C. Manual "sync now" button
- [ ] D. Real-time sync (WebSocket)
- [ ] E. No sync needed (fully local)

**Storage limits:**

- [ ] A. Unlimited (whatever device allows)
- [ ] B. <100MB cached data
- [ ] C. <500MB cached data
- [ ] D. User configurable

**Answer format:**
```
Must Work Offline: [List 5-10]
Sync Strategy: [A/B/C/D/E]
Storage Limit: [A/B/C/D]
Fallbacks: [What if download fails?]
```

---

### ❌ 10. NOTIFICATIONS

**Should the app send notifications?**

- [ ] A. No - User-initiated only
- [ ] B. Optional - User can enable
- [ ] C. Enabled by default
- [ ] D. Required for some features

**What notifications?**

- [ ] Daily check-in reminder (e.g., 9 AM)
- [ ] "Streak reminder" (recovery/sobriety updates)
- [ ] New answer to your question
- [ ] "Motivational" message
- [ ] Emergency/safety nudge
- [ ] Join a support group
- [ ] App update

**Notification frequency:**

- [ ] A. Max 1 per day
- [ ] B. Max 3 per day
- [ ] C. User configurable
- [ ] D. Unlimited

**Answer format:**
```
Notifications: [A/B/C/D]
Types: [List which ones]
Frequency: [A/B/C/D]
Opt-Out: [Can users disable all?]
```

---

## TIER 3: DESIGN & SAFETY

### ❌ 11. SECURITY FEATURES

**Lock/Privacy features:**

- [ ] PIN lock (simple 4-6 digit code)
- [ ] Biometric lock (fingerprint/face)
- [ ] Quick exit button (hide app immediately)
- [ ] Decoy screen ("boring app" if lock fails)
- [ ] Screenshot blocking (on sensitive screens)
- [ ] Data deletion (clear app data in one tap)

**Data export:**

- [ ] A. Not available
- [ ] B. PDF export only
- [ ] C. CSV export
- [ ] D. Full JSON export
- [ ] E. User can request all their data (GDPR)

**Trusted contacts:**

- [ ] Can add family/friends
- [ ] Can message them from app
- [ ] Can auto-SMS emergency message
- [ ] Not available v1

**Answer format:**
```
Lock: [PIN / Biometric / Both / None]
Quick Exit: [Yes/No]
Decoy Screen: [Yes/No]
Screenshot Block: [Yes/No]
Data Export: [A/B/C/D/E]
Trusted Contacts: [Available?]
```

---

### ❌ 12. APP BRANDING & TONE

**Visual style:**

- [ ] A. Professional/clinical (looks like health app)
- [ ] B. Friendly/approachable (colorful, modern)
- [ ] C. Discreet/minimal (looks like any app)
- [ ] D. Youth-focused (trendy design)
- [ ] E. Culturally Zimbabwean (local aesthetics)

**Primary color:**

- [ ] A. Blue (trust, calm)
- [ ] B. Green (growth, health)
- [ ] C. Purple (supportive, spiritual)
- [ ] D. Your choice: [Color]

**Tone of voice:**

- [ ] A. Clinical/professional
- [ ] B. Friendly/peer-like
- [ ] C. Motivational/uplifting
- [ ] D. Neutral/non-judgmental
- [ ] E. Combination

**Discreet design?**

- [ ] Yes - Hide as "Notes" or "Weather" app
- [ ] No - Clear that it's a wellness app

**Answer format:**
```
Visual Style: [A/B/C/D/E]
Primary Color: [Color]
Tone: [A/B/C/D/E]
Discreet: [Yes/No]
Icon: [Should it hide "Sisonke" name?]
```

---

### ❌ 13. LEGAL & DISCLAIMERS

**Required before launch:**

- [ ] Privacy Policy
- [ ] Terms of Use
- [ ] Medical Disclaimer
- [ ] Crisis Resources Disclaimer
- [ ] Age Policy (13+, 18+, etc.)
- [ ] Consent Language

**Sample privacy statement:**

> "Sisonke does not diagnose or treat mental health conditions. We are not a substitute for professional help. In crisis, contact emergency services or helplines."

**Answer format:**
```
Countries/Laws: [Which apply?]
Age Minimum: [13+ / 18+ / Other]
Liability: [Waived completely? Co-liability?]
Data Retention: [How long keep user data?]
Medical Disclaimer: [In app or separate?]
```

---

### ❌ 14. SUCCESS METRICS

**How do you measure success?**

**Adoption:**
- [ ] Target X users in first 3 months
- [ ] Target X new users per month

**Engagement:**
- [ ] X% daily active users
- [ ] Average Y check-ins per user per month
- [ ] X articles read per user

**Impact:**
- [ ] X people used emergency toolkit
- [ ] X Q&A questions submitted
- [ ] X users completed recovery milestones

**Retention:**
- [ ] X% of users return after 1 month
- [ ] X% of users return after 3 months

**Answer format:**
```
Adoption Target (3 months): [Number]
Monthly Growth: [Target percentage]
Daily Active: [Target percentage]
Check-ins: [Target per user per month]
Emergency Toolkit Usage: [Track as important?]
Retention 1-month: [Target percentage]
Success = [Your definition]
```

---

## 📋 DECISION SUMMARY TABLE

Print this and fill it in:

```
DECISION                 | YOUR ANSWER           | RATIONALE
------------------------|-----------------------|-------------------
1. Target Users         | [Decision]            | 
2. Geographic           | [Decision]            |
3. MVP Focus            | [Decision]            |
4. Privacy Model        | [Decision]            |
5. Emergency Response   | [Decision]            |
6. Backend Framework    | [Decision]            |
7. Content Authors      | [Decision]            |
8. Moderation           | [Decision]            |
9. Admin Dashboard      | [Decision]            |
10. Offline            | [Decision]            |
11. Notifications      | [Decision]            |
12. Security Features  | [Decision]            |
13. Visual Branding    | [Decision]            |
14. Legal Age          | [Decision]            |
15. Success Metrics    | [Decision]            |
```

---

## 🚀 NEXT STEPS

### Option A: You Fill Out & Reply
1. Copy the section above
2. Fill in your answers
3. Reply with the completed table
4. I'll create:
   - Database schema
   - API spec
   - Detailed Phase 2 roadmap
   - Backend starter code
   - Priority ordering

### Option B: Use My Recommendations
I can make educated guesses based on your project vision:

```
🎯 RECOMMENDED MVP (My Suggestion)
├─ Target: Young people 13-24 in Zimbabwe
├─ Focus: Mental Health + Emergency Support
├─ Privacy: Local-first + optional backup
├─ Admin: Minimal (Phase 3+)
├─ Backend: Yes - Express + Drizzle + Vercel
├─ Moderation: Manual review + auto-flag
├─ Notifications: Optional, user-controlled
├─ Emergency: Show helplines + quick exit
└─ Timeline: 8-10 weeks to launch v1
```

If this aligns with your vision, I can proceed immediately.

---

## ⏰ DECISION DEADLINE

**To proceed with Phase 2, please provide:**

1. ✅ Completed decision table above
2. ✅ Or confirmation to use recommendations
3. ✅ Or clarifications on any points

**Then I will immediately:**

- Create database schema
- Design API endpoints
- Build backend starter
- Prioritize Phase 2 features
- Create implementation roadmap

---

**What's your preference?**

- [ ] A. I'll fill out all 15 decisions (in next message)
- [ ] B. Use your recommended MVP
- [ ] C. Partial decisions + recommendations on rest
- [ ] D. Schedule a quick chat to discuss

Let me know! 🚀

