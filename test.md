# Test Plan — Seafarer Bio Data App

## Context for Claude Code

This is a Flutter (assume `flutter_test`, `mocktail`/`mockito`, and `integration_test`
unless the repo says otherwise — check `pubspec.yaml` first) app for seafarers to
build a professional "Bio Data" profile and export it as **PDF** (free), **DOCX**
(subscribers only), and **XLS** (planned, not yet built — stub tests as `skip`).

Before writing any tests, inspect the repo to confirm:
- State management approach (Provider / Riverpod / Bloc / GetX)
- Navigation approach (Navigator 2.0, go_router, etc.)
- Existing models for `Profile`, `Document`, `Course`, `SeaExperience`, `Subscription`
- Existing services: `AuthService`, `ExportService` (PDF/DOCX), `SubscriptionService`

If a piece doesn't exist yet, write the test first (TDD) with a clear comment on the
expected interface, rather than skipping it.

## App Flow Under Test

1. **Auth** → Login / Signup / Forgot password / session persistence / logout
2. **Home ("My Bio Data")** → read-only profile view, shown in the attached screenshot:
   - Header fields: Post Applied For, First Name, Last Name, Father's Name,
     Date of Birth, Nationality, Photo (or "No Photo" placeholder)
   - **Documents** table: Document, Number, Date of issue, Place of issue, Validity
   - **Courses** table: Course, Number, Date of issue, Place of issue, Validity
   - **Sea Experience** table: Name of vessel, Company name, Type of vessel, G.R.T, etc.
   - AppBar actions: PDF icon (view/export, free), DOC icon (download, subscriber-gated
     → paywall dialog if not subscribed), Edit (pencil), Logout
3. **Edit Profile** → form for all sections above, validation, save
4. **Export** → PDF (always allowed), DOCX (gated), XLS (not implemented — future)
5. **Subscription paywall** → shown when a free user taps DOC icon

---

## 1. Unit Tests

### 1.1 Models
- `Profile.fromJson` / `toJson` round-trip preserves all fields (incl. nested
  `documents`, `courses`, `seaExperience` lists)
- Optional/nullable fields (e.g. no photo, empty tables) serialize/deserialize safely
- Date fields parse consistently regardless of locale/format edge cases (e.g. `17/7/1987`)
- Equality/`copyWith` behave correctly for `Profile`, `DocumentEntry`, `CourseEntry`,
  `SeaExperienceEntry`

### 1.2 Auth Service
- `login(email, password)` success → returns valid session/token
- `login` with wrong credentials → throws/returns `AuthFailure`
- `signup` with existing email → returns conflict error
- `logout()` clears local session/token storage
- Session restore on app start: valid token → auto-login; expired/invalid token →
  redirected to login
- Password reset request → success and failure paths

### 1.3 Subscription Service
- `isSubscribed` returns correct boolean from cached/remote status
- Subscription expiry: active-but-expired treated as not subscribed
- Upgrade purchase flow updates local subscription state
- Restore purchases updates state correctly

### 1.4 Export Service
- **PDF generation**
  - Builds successfully from a fully populated `Profile`
  - Builds successfully from a `Profile` with empty Documents/Courses/Sea Experience
    (no crash on empty tables)
  - Handles missing photo (renders "No Photo" placeholder equivalent, doesn't crash)
  - Handles long text (very long vessel/company names) without overflow/exception
  - Output is non-empty valid PDF bytes (magic header `%PDF`)
- **DOCX generation**
  - Only invoked when `isSubscribed == true`; service throws/guards otherwise
    (defense in depth even though UI already gates it)
  - Builds successfully from full and empty profiles
  - Output is a valid `.docx` (valid zip / OOXML structure)
- **XLS generation (future)**
  - `test('xls export - not yet implemented', () {...}, skip: 'Planned feature')`

### 1.5 Validators (Edit Profile form)
- Required fields (First Name, Last Name, DOB, Nationality) reject empty input
- Date fields reject invalid/malformed dates and future DOB
- Document/Course validity date must be after issue date
- Numeric fields (e.g. G.R.T) reject non-numeric input

---

## 2. Widget Tests

### 2.1 Auth Screens
- Login screen renders email/password fields + submit button
- Submitting empty form shows validation errors, no navigation
- Submitting valid credentials shows loading state then navigates to Home
- Failed login shows an error message/snackbar, stays on Login screen
- "Forgot password" link navigates to reset screen
- Signup screen mirrors the above for new-account creation

### 2.2 Home / Bio Data Screen (matches screenshot)
- Renders AppBar title "My Bio Data" and all four action icons (PDF, DOC, Edit, Logout)
- Renders all profile header fields with correct labels and values
  (Post Applied For, First Name, Last Name, Father's Name, DOB, Nationality)
- Shows "No Photo" placeholder when `photoUrl` is null; shows image when present
- Renders **Documents** table with correct column headers and row data;
  renders empty-state when no documents exist
- Renders **Courses** table with correct headers/data; empty-state when none
- Renders **Sea Experience** table with correct headers/data; empty-state when none
- Long table content is horizontally scrollable and doesn't overflow the screen
- Tapping the **PDF icon**:
  - Triggers PDF generation/view flow regardless of subscription status
  - Shows a loading indicator while generating
  - Shows a viewer/share sheet on success; shows error state on failure
- Tapping the **DOC icon**:
  - If subscribed → triggers DOCX download flow directly
  - If NOT subscribed → shows the **upgrade paywall dialog/bottom sheet** instead of
    downloading; dialog has an "Upgrade" CTA and a dismiss/cancel action
  - Dismissing the paywall does not attempt the download
  - Tapping "Upgrade" navigates to the subscription/purchase screen
- Tapping the **Edit icon** navigates to Edit Profile screen, pre-filled with current data
- Tapping the **Logout icon**:
  - Shows a confirmation dialog (if applicable)
  - On confirm, clears session and navigates back to Login screen

### 2.3 Edit Profile Screen
- Form pre-fills all existing profile values including table rows
- Adding a new Document/Course/Sea Experience row appends a new editable entry
- Removing a row deletes it from the list
- Field-level validation errors render inline
- Save button disabled while form invalid; enabled once valid
- Successful save navigates back to Home and reflects updated data
- Save failure (e.g. network error) shows error message, keeps user on screen

### 2.4 Paywall / Upgrade Dialog
- Renders subscription benefits/price copy
- "Upgrade" button triggers purchase flow
- "Not now"/close dismisses without side effects

---

## 3. Integration Tests

### 3.1 Auth → Home Happy Path
- Launch app (logged out) → Login screen shown
- Enter valid credentials → land on Home ("My Bio Data") with correct profile data
- Kill and relaunch app → session persists, lands directly on Home

### 3.2 Free User — PDF Export Works, DOCX Gated
- Log in as a **non-subscribed** user
- Tap PDF icon → PDF view/export completes end-to-end
- Tap DOC icon → paywall dialog appears (no download starts)
- Tap "Upgrade" → navigates to subscription screen
- Complete (mocked) purchase → return to Home → DOC icon now downloads directly

### 3.3 Subscribed User — Full Export Flow
- Log in as a **subscribed** user
- Tap PDF icon → export succeeds
- Tap DOC icon → export succeeds directly, no paywall shown
- Verify exported files are shared/saved via platform channel (mocked)

### 3.4 Edit Profile → Persisted End to End
- From Home, tap Edit → change First Name, add a new Sea Experience row,
  add a new Document row → Save
- Verify Home screen reflects all changes immediately
- Relaunch app → changes persisted (via backend/local cache)

### 3.5 Logout Flow
- From Home, tap Logout → confirm → app returns to Login screen
- Attempt to navigate back (Android back button) does not return to Home
- Relaunching app after logout does not auto-login

### 3.6 Empty Profile State
- New user with no Documents/Courses/Sea Experience data:
  Home renders without crashing, showing empty-state placeholders for each table,
  and PDF export still succeeds with those sections empty/omitted

---

## 4. Test Data / Fixtures to Create

- `fixtures/profile_full.json` — profile matching the screenshot exactly
  (Isthiyaque Kambathagothi, DOB 17/7/1987, Indian, one Passport document,
  one Medical course, no sea experience rows)
- `fixtures/profile_empty.json` — all optional sections empty
- `fixtures/profile_no_photo.json`
- Mock `AuthService`, `SubscriptionService` (subscribed / not-subscribed variants),
  and `ExportService` implementations for widget/integration tests

## 5. Out of Scope / Explicitly Skipped

- XLS export — mark all related tests `skip: 'Planned feature, not yet implemented'`
- Payment provider's own SDK internals — mock at the `SubscriptionService` boundary only

---

## Instructions to Claude Code

1. Read `pubspec.yaml` and existing `lib/` structure first; adapt file paths/class
   names below to what actually exists rather than inventing new architecture.
2. Write unit tests under `test/unit/`, widget tests under `test/widget/`,
   integration tests under `integration_test/`.
3. Use the fixtures in section 4; create them if they don't exist.
4. Mock network/platform boundaries (auth API, export/download, in-app purchase)
   — do not hit real services.
5. Prefer one assertion focus per test; use descriptive `group`/`test` names matching
   the section headers above so failures are easy to trace back to this doc.
6. Run the full suite after writing it and report any failures before considering
   the task done.
