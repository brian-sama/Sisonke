# 📋 Sisonke MVP - Quick Decision Template

**Copy this, fill it in, and reply to proceed with Phase 2**

---

## TIER 1: CRITICAL DECISIONS (Required)

### 1. Target Users & Geography
```
Target Users: [A: Young people only / B: Students / C: Community / D: Parents too / E: Everyone]
Geographic: [A: Zimbabwe only / B: Southern Africa / C: Sub-Saharan / D: Global / E: Undecided]
Rationale: [2-3 sentences why]
```

### 2. MVP Core Focus
```
Primary Focus: [A: Mental Health / B: SRHR / C: Substance Use / D: Emergency / E: Q&A / F: Balanced]

MUST Have in v1:
- [ ] Emergency contacts/helplines
- [ ] Resource library
- [ ] Daily check-in
- [ ] Anonymous Q&A
- [ ] Offline reading
- [ ] Other: [List]

OUT of scope v1:
- [ ] Telemedicine
- [ ] AI chatbot
- [ ] Social chat
- [ ] Other: [List]
```

### 3. Privacy Model
```
Personal Data (Mood/Journal): 
  [A: Local only / B: Local + optional backup / C: Always encrypted on cloud / D: Cloud default]

Anonymous Q&A:
  [A: Fully anonymous / B: IP logged / C: Linked to account / D: Full tracking]

Tracking/Analytics:
  [A: None / B: Anonymous only / C: User ID tracking / D: Full analytics]

Accounts:
  [A: Not required / B: Optional / C: Required / D: With profiles]
```

### 4. Emergency Handling
```
When user indicates self-harm:
  [A: Show helplines only / B: Prompt to call / C: Message contact / D: Auto-SMS / E: No special handling]

Quick Exit Button:
  [A: Yes - one tap / B: No - lock only / C: Power button twice]

Location Tracking:
  [A: Never / B: Optional for "find help" / C: Required / D: Auto-collect]

Trusted Contacts:
  [Can users add family/friend numbers? Yes/No]

Helplines to include:
  - Zimbabwe Lifeline: +263 292 62 662
  - ALAC: +263 242 307 048
  - Mental Welfare: [Provide]
  - SRHR Services: [Provide]
```

### 5. Backend Structure
```
Backend needed: [Yes / No]

If YES:
  Framework: [A: Express / B: Hono / C: NestJS / D: Next.js / E: Undecided]
  ORM: [A: Drizzle / B: Prisma / C: TypeORM / D: Raw queries]
  Deployment: [A: Vercel / B: Railway / C: Self-hosted / D: AWS]
  Auth Method: [Firebase / Custom JWT / Supabase]

If NO:
  [Explain why offline-only approach works]
```

---

## TIER 2: IMPORTANT DECISIONS

### 6. Content Strategy
```
Article Authors: [A: In-house / B: NGO partners / C: Volunteers / D: Repurposed / E: Mix]
Approval: [A: Health professionals / B: NGO board / C: Volunteers / D: Internal / E: None]
Languages v1: [A: English / B: English+Shona / C: English+Ndebele / D: All three / E: Plus others]
Offline: [A: All downloadable / B: Favorites pinned / C: Auto-cache popular / D: Read-once]
Initial seeding: [How many articles to launch with? Target: 20-30]
```

### 7. Moderation (for Q&A)
```
Who answers questions:
  [A: Professionals only / B: Peer educators / C: NGO staff / D: Volunteers / E: Just resources]

Who moderates:
  [A: Automated filtering / B: Manual staff review / C: Community flag + staff / D: No moderation]

Urgent handling (self-harm):
  [A: Auto-flag + resources / B: Manual review / C: No special handling / D: Auto-response]

Response SLA:
  Urgent (self-harm): [Hours/days]
  Normal (general): [Days/weeks]
```

### 8. Admin Dashboard
```
Needed in Phase 2: [Yes / No / Phase 3 instead]

If YES, Priority features:
  [ ] Manage resources
  [ ] Review Q&A submissions
  [ ] Answer questions
  [ ] View analytics
  [ ] Manage helplines
  [ ] View reports
  [ ] User management
  [ ] Moderation queue
```

### 9. Offline Functionality
```
MUST work without internet:
  [ ] Emergency numbers
  [ ] Saved articles
  [ ] Mood tracker
  [ ] Journal
  [ ] Breathing exercises
  [ ] Safety plan
  [ ] Q&A cache
  [ ] Other: [List]

Sync strategy:
  [A: On app open / B: Every X minutes / C: Manual button / D: Real-time / E: No sync]

Storage limit:
  [A: Unlimited / B: <100MB / C: <500MB / D: User configurable]
```

### 10. Notifications
```
Should app send notifications:
  [A: No / B: Optional (off by default) / C: On by default / D: Required]

If YES, types:
  [ ] Daily check-in reminder
  [ ] Streak reminder
  [ ] New answer notification
  [ ] Motivational message
  [ ] Safety nudge
  [ ] Support group invite
  [ ] App update

Frequency:
  [A: Max 1/day / B: Max 3/day / C: User configurable / D: Unlimited]
```

---

## TIER 3: DESIGN & SAFETY

### 11. Security Features
```
Lock options:
  [ ] PIN lock
  [ ] Biometric
  [ ] Both
  [ ] None

Other features:
  [ ] Quick exit button
  [ ] Decoy screen
  [ ] Screenshot blocking
  [ ] Data deletion option

Data export:
  [A: Not available / B: PDF only / C: CSV / D: Full JSON / E: GDPR "my data"]

Trusted contacts:
  [Can add family/friends: Yes/No]
```

### 12. Branding & Tone
```
Visual style:
  [A: Professional/clinical / B: Friendly / C: Discreet / D: Youth-focused / E: Zimbabwean]

Primary color:
  [Blue / Green / Purple / Red / Your choice: _____]

Tone of voice:
  [A: Clinical / B: Friendly / C: Motivational / D: Neutral / E: Mix]

Discreet design:
  [App should look like it's "hiding"? Yes/No]

Icon:
  [Should hide the name "Sisonke" or be obvious?]
```

### 13. Legal
```
Age minimum:
  [13+ / 16+ / 18+ / Other: ___]

Medical disclaimer:
  [Required? Yes/No - In app or separate page?]

Geographic/Legal scope:
  [Zimbabwe law / Southern Africa / Other: ___]

Liability model:
  [User assumes all risk / Co-liability / Protected by disclaimer]

Data retention:
  [How long keep user data after deletion: Immediately / 30 days / 90 days / Never delete]
```

### 14. Success Metrics
```
3-Month Adoption Target: [Number of users]
Monthly Growth Target: [Percentage]
Daily Active User Target: [Percentage of registered]
Average Check-ins/User/Month: [Number]
Emergency Toolkit Usage: [Track as success metric? Yes/No]
1-Month Retention Target: [Percentage]

SUCCESS = [One sentence definition]
```

---

## 🎯 QUICK VERSION (If time is short)

If you just want to confirm the recommended MVP, fill this:

```
QUICK DECISION FORM
═══════════════════════════════════════════════════

Q: Accept recommended MVP (Mental health + Emergency + Resources)?
A: [Yes / No / Partial]

Q: Accept 10-week timeline?
A: [Yes / Can do less / Need more time]

Q: Accept Express.js backend on Vercel?
A: [Yes / Prefer different / Backend later]

Q: NGO partnership for content?
A: [Have contacts / Need help / Will seed content myself]

Q: Team size?
A: [Solo / Small team / Have developers]

NAME/DATE: _____________________ / _________
```

---

## HOW TO SUBMIT

**Option A: Full Decision Document**
1. Copy the TIER 1, 2, 3 sections above
2. Fill in all answers
3. Reply with completed form

**Option B: Quick Version Only**
1. Copy the "QUICK VERSION" section
2. Fill in 5 questions
3. I'll fill the rest with recommendations

**Option C: Accept Defaults**
1. Reply: "Accept RECOMMENDED_MVP.md as-is"
2. I'll start building immediately

---

**What's your preference?**

[ ] A - Send full decision form
[ ] B - Send quick decision  
[ ] C - Accept recommended MVP
[ ] D - Need to discuss first

Reply with your choice! 🚀

