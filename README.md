# Hatch

A Flutter mobile app that connects ALU students with startup roles posted by verified founders in the African Leadership University ecosystem.

---

## Features

### For Students
- **Discover roles** — real-time feed of open opportunities with match-score badges computed from your skill profile
- **Skill-gap analysis** — missing skills highlighted inline on every role detail screen
- **Bookmark roles** — save opportunities for later with instant O(1) Set-backed state
- **Apply** — structured application form with cover letter, availability, portfolio URL, and CV link
- **Track applications** — grouped by status (Reviewing · Pending · Decided) with colour-coded cards
- **Withdraw** — cancel a pending or reviewing application at any time
- **Post-acceptance reveal** — founder contact email and website unlocked on acceptance
- **Meeting cards** — view and join meetings scheduled by the founder, in real time

### For Founders
- **Post roles** — create opportunities with required skills, category, location, and deadline
- **Edit & delete roles** — update or remove a posting at any time via the overflow menu
- **Applicant count badge** — see interest at a glance on every role card
- **Review applicants** — cover letter, availability, portfolio, and CV link in one screen
- **Auto-reviewing trigger** — opening an applicant auto-advances status from `submitted` → `reviewing`
- **Accept / Reject** — one-tap decision with confirmation
- **Schedule meetings** — date, time, link, and optional note; appended atomically with `arrayUnion`
- **Contact reveal** — accepted applicant's email surfaces on acceptance

---

## Tech Stack

| Layer | Technology |
|---|---|
| UI | Flutter 3.x · Dart 3.x (null-safe) |
| State management | Riverpod 3 (`StreamProvider`, `NotifierProvider`, `Provider.family`) |
| Navigation | GoRouter 14.x · `StatefulShellRoute.indexedStack` |
| Backend | Firebase Auth · Cloud Firestore |
| Deep links / URL launch | `url_launcher` |
| Architecture | Repository pattern · clean separation of UI / state / data |

---

## Project Structure

```
lib/
├── main.dart
├── firebase_options.dart
│
├── data/                          # Repositories — all Firestore access lives here
│   ├── application_repository.dart
│   ├── auth_repository.dart
│   ├── opportunity_repository.dart
│   ├── startup_repository.dart
│   └── user_repository.dart
│
├── models/                        # Immutable data models with toMap / fromMap
│   ├── app_user.dart
│   ├── application.dart
│   ├── meeting.dart
│   ├── opportunity.dart
│   ├── profile_entry.dart
│   └── startup.dart
│
├── providers/                     # Riverpod providers (StreamProvider / NotifierProvider)
│   ├── application_providers.dart
│   ├── auth_providers.dart
│   ├── opportunity_providers.dart
│   ├── startup_providers.dart
│   └── user_providers.dart
│
├── router/
│   └── app_router.dart            # GoRouter config, route constants, role-based redirects
│
├── screens/
│   │
│   ├── # Auth 
│   ├── welcome_screen.dart        # Landing / splash
│   ├── login_screen.dart
│   ├── signup_screen.dart
│   ├── role_selection_screen.dart # Student vs Founder picker on first sign-up
│   │
│   ├── # Student shell
│   ├── student_shell.dart         # StatefulShellRoute — bottom nav for students
│   ├── student_home_screen.dart   # Tab: Discover feed with match scores & filters
│   ├── home_screen.dart           # Opportunity feed / hero screen
│   ├── discover_screen.dart       # Filtered browse view
│   ├── opportunity_detail_screen.dart  # Role detail + skill-gap + apply CTA
│   ├── apply_screen.dart          # Application form
│   ├── applications_screen.dart   # My applications (grouped by status)
│   ├── student_application_detail_screen.dart  # Detail + withdraw + meetings
│   │
│   ├── # Founder shell 
│   ├── founder_shell.dart         # StatefulShellRoute — bottom nav for founders
│   ├── founder_home_screen.dart   # Founder dashboard / overview
│   ├── founder_roles_screen.dart  # Posted roles list with applicant count badges
│   ├── post_opportunity_screen.dart  # Create & edit role (dual-purpose)
│   ├── founder_applicants_screen.dart  # Applicant list for a role
│   ├── applicant_detail_screen.dart    # Review, accept/reject, schedule meeting
│   │
│   └── # Shared / Profile 
│       ├── profile_screen.dart         # Profile overview + completeness nudge
│       ├── edit_about_screen.dart      # Edit bio, skills, interests
│       ├── edit_tags_screen.dart       # Edit skill / interest tags
│       ├── edit_entries_screen.dart    # Edit experience / education entries
│       ├── edit_alu_screen.dart        # Edit ALU campus, program, year
│       └── edit_startup_screen.dart    # Edit startup profile (founders)
│
├── components/                    # Reusable widgets
│   ├── app_text_field.dart
│   ├── category_row.dart
│   ├── initials_avatar.dart
│   ├── opportunity_card.dart
│   ├── status_badge.dart
│   └── verified_badge.dart
│
├── theme/
│   ├── app_colors.dart
│   ├── app_spacing.dart
│   ├── app_theme.dart
│   └── app_typography.dart
│
└── utils/
    ├── greeting.dart              # Time-based greeting helper
    ├── match_score.dart           # Skill match % computation
    └── matching.dart              # Set-diff skill gap logic
```

---

## Firestore Data Model

```
users/{uid}
  - email, name, role (student | founder)
  - skills[], interests[], experience[], education[]
  - aluCampus, aluProgram, aluYear
  - savedOpportunityIds[], isVerified, website

opportunities/{id}
  - startupId (→ users), startupName*, startupVerified*
  - title, description, requiredSkills[]
  - category, location, timeCommitment, deadline

applications/{id}
  - opportunityId (→ opportunities), opportunityTitle*
  - startupId (→ users), startupName*
  - applicantId (→ users), applicantName*, applicantEmail*
  - message, availability, portfolioUrl, cvUrl
  - status: submitted | reviewing | accepted | rejected
  - meetings[]: { scheduledAt, link, note }   ← embedded array

* denormalized for zero-join list queries
```

---

## Getting Started

### Prerequisites
- Flutter SDK ≥ 3.0
- Dart ≥ 3.0
- A Firebase project with **Authentication** and **Firestore** enabled (Spark plan is sufficient)

### Setup

1. **Clone the repo**
   ```bash
   git clone https://github.com/your-username/hatch.git
   cd hatch
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Connect Firebase**
   ```bash
   # Install the FlutterFire CLI if you haven't already
   dart pub global activate flutterfire_cli

   # Configure for your Firebase project
   flutterfire configure
   ```
   This generates `lib/firebase_options.dart` automatically.

4. **Run the app**
   ```bash
   flutter run
   ```

### First-time Firestore setup

Hatch uses two user roles: `student` and `founder`. After signing up, set a user's `role` field in Firestore manually (or build an onboarding flow). To allow a founder to post roles, also set `isVerified: true` on their user document.

---

## Architecture Notes

**Why Riverpod 3?**
Providers are top-level compile-time constants — no string-based lookups, no context threading. `AsyncValue` handles loading/error/data uniformly. `.family` lets screens pass IDs to providers cleanly.

**Why denormalize?**
Firestore doesn't support joins. Copying `startupName`, `applicantEmail`, etc. into the application document means every list screen is a single-collection query — fast and cheap.

**Why `FieldValue.arrayUnion` for meetings?**
A read-modify-write pattern would lose concurrent entries. `arrayUnion` is atomic on the Firestore server, so two founders scheduling at the same moment can't overwrite each other.

**Why no `intl` package?**
To keep dependencies minimal. Date formatting uses lightweight static string-array helpers that produce the same output.


