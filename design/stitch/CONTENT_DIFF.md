# Content Diff: Stitch Designs vs. Redesign Audit Contracts

This document records the exact string-by-string comparison between all visible UI text in the Google Stitch redesign templates and the authoritative preserved contracts defined in [`docs/REDESIGN_AUDIT.md`](../../docs/REDESIGN_AUDIT.md#L240-L297) §6.

> [!IMPORTANT]
> **Authoritative Precedence Rule:**
> [`docs/REDESIGN_AUDIT.md`](../../docs/REDESIGN_AUDIT.md) §6 is **strictly authoritative**. The existing widget tests rely on exact string predicates (`appTextField(label)`, `find.text(...)`). All entries marked **reworded** or **added** must be overridden back to the audit contracts during UI implementation.

---

## 1. Authentication Screens

### 1.1 Login Screen (`login` / `LoginPage`)

| Screen | Stitch Text | Audit Text (§6) | Status | Resolution / Action Required |
| :--- | :--- | :--- | :--- | :--- |
| **Login** | `"Welcome Seafarer"` | `'Welcome Seafarer'` | `same` | Retain as screen heading. |
| **Login** | `"Sign in to your account to continue building your professional maritime profile."` | *None (legacy had none or simple subtitle)* | `added` | Allowed as decorative subtitle (does not break tests). |
| **Login** | `"Maritime Identity / Email"` | `'Email'` | `reworded` | **Override to `'Email'`**. Test finder `appTextField('Email')` will fail otherwise. |
| **Login** | `"officer@merchantfleet.com"` | `null` / empty placeholder | `added` | Safe placeholder. |
| **Login** | `"Secret Passkey"` | `'Password'` | `reworded` | **Override to `'Password'`**. Test finder `appTextField('Password')` will fail otherwise. |
| **Login** | `"Enter your password"` | `null` / empty placeholder | `added` | Safe placeholder. |
| **Login** | `"Forgot?"` | *None* | `added` | **Drop / Defer**. App has no forgot-password route or API. |
| **Login** | `"Remember vessel credential"` | *None* | `added` | **Drop / Defer**. Biometric credential persistence is out of scope. |
| **Login** | `"Sign In"` | `'Sign In'` | `same` | Retain on primary submit button. |
| **Login** | `"Sign Up"` | `'Don\'t have an account? Sign Up'` / `'Sign Up'` | `same` | Retain navigation link to registration. |
| **Login** | `"REGISTRY N° 1892"` | *None* | `added` | Decorative header badge; keep cosmetic only. |
| **Login** | `"IMO Comp."`, `"STCW Validated"`, `"256-Bit SSL"` | *None* | `added` | Decorative trust badges; keep visual only. |

---

### 1.2 Sign Up Screen (`signup` / `SignUpPage`)

| Screen | Stitch Text | Audit Text (§6) | Status | Resolution / Action Required |
| :--- | :--- | :--- | :--- | :--- |
| **Sign Up** | `"Create Account"` | `'Create Account'` | `same` | Retain as screen title. |
| **Sign Up** | `"Sign Up"` | `'Sign Up'` | `same` | Retain submit button text. |
| **Sign Up** | `"First Name"` | `'First name'` | `reworded` | **Override to `'First name'`** (lowercase 'n'). Test finder `appTextField('First name')` is case-sensitive. |
| **Sign Up** | `"Last Name"` | `'Last name'` | `reworded` | **Override to `'Last name'`** (lowercase 'n'). Test finder `appTextField('Last name')` is case-sensitive. |
| **Sign Up** | `"Email Address"` | `'Email'` | `reworded` | **Override to `'Email'`**. Test finder `appTextField('Email')` will fail otherwise. |
| **Sign Up** | `"Password"` | `'Password'` | `same` | Retain exact field label. |
| **Sign Up** | `"Confirm Password"` | `'Confirm Password'` | `same` | Retain exact field label. |
| **Sign Up** | `"Already have an account?"` | `'Already have an account?'` | `same` | Retain prompt text. |
| **Sign Up** | `"Sign In"` | `'Sign In'` | `same` | Retain login link text. |
| **Sign Up** | `"I consent to STCW sea-time logging guidelines and the Merchant Registry Code of Conduct."` | *None* | `added` | **Drop / Defer**. Form validator does not require this checkbox; will cause validation regression if enforced. |
| **Sign Up** | `"Min. 8 characters, alphanumeric required"` | *None* | `added` | Helper text; informational only. |
| **Sign Up** | `"256-Bit Maritime Vault Encryption"` | *None* | `added` | Decorative footer badge. |

---

## 2. Personal Details & Home Overview

### 2.1 My Bio Data View Mode (`bio_data_overview`, `bio_data_pro_active`, `bio_data_free_tier` / `HomePage`)

| Screen | Stitch Text | Audit Text (§6) | Status | Resolution / Action Required |
| :--- | :--- | :--- | :--- | :--- |
| **Home View** | `"Bio Data Overview"` / `"Officer Bio-Data"` / `"Bio Data"` | `'My Bio Data'` | `reworded` | **Override AppBar title to `'My Bio Data'`**. Exact title checked in `home_page_test.dart`. |
| **Home View** | `"Official Documents"` / `"Documents & Certificates"` | `'Documents'` | `reworded` | **Override section header to `'Documents'`**. |
| **Home View** | `"Courses & Certifications"` / `"STCW Endorsements"` | `'Courses'` | `reworded` | **Override section header to `'Courses'`**. |
| **Home View** | `"Sea Service Record"` / `"Sea Service Ledger"` | `'Sea Experience'` | `reworded` | **Override section header to `'Sea Experience'`**. |
| **Home View** | Replaced `Table` with card tiles | Column: `'Name of vessel'` | `removed` | Cards approved. Keep the same label text on each card. Check test usage first. |
| **Home View** | Replaced `Table` with card tiles | Column: `'Company name'` | `removed` | Cards approved. Keep the same label text on each card. Check test usage first. |
| **Home View** | Replaced `Table` with card tiles | Column: `'Type of vessel'` | `removed` | Cards approved. Keep the same label text on each card. Check test usage first. |
| **Home View** | Replaced `Table` with card tiles | Column: `'G.R.T'` | `removed` | Cards approved. Keep the same label text on each card. Check test usage first. |
| **Home View** | Replaced `Table` with card tiles | Column: `'B.H.P'` | `removed` | Cards approved. Keep the same label text on each card. Check test usage first. |
| **Home View** | Replaced `Table` with card tiles | Column: `'Rank'` | `removed` | Cards approved. Keep the same label text on each card. Check test usage first. |
| **Home View** | Replaced `Table` with card tiles | Column: `'From'` | `removed` | Cards approved. Keep the same label text on each card. Check test usage first. |
| **Home View** | Replaced `Table` with card tiles | Column: `'To'` | `removed` | Cards approved. Keep the same label text on each card. Check test usage first. |
| **Home View** | Replaced `Table` with card tiles | Column: `'Period'` | `removed` | Cards approved. Keep the same label text on each card. Check test usage first. |
| **Home View** | Material glyphs (`picture_as_pdf`, `description`, `edit`) | SVG icons: `'assets/icons/pdf_icon.svg'`, `'file_doc.svg'`, `'edit.svg'` | `reworded` | **Must use exact SVG asset paths**. Finder `svgAssetTapTarget()` searches these asset paths. |
| **Home View** | *None* | AppBar Logout button (`SignOutEvent`) | `removed` | **Must restore Logout action** in AppBar. |
| **Home View** | *None* | SnackBar: `'DOCX Export is a Pro feature. Please subscribe to unlock.'` | `removed` | **Preserve logic & snackbar**. PAY-SEC-001/002 gating rule. |
| **Home View** | *None* | SnackBar Action: `'Upgrade'` | `removed` | **Preserve SnackBar action**. Routes to paywall. |
| **Home View** | *None* | SnackBar: `'Generating DOCX...'` | `removed` | **Preserve SnackBar feedback**. |
| **Home View** | `"Not Found"` | `'Not Found'` | `same` | Matches `NotFoundWidget` title. |
| **Home View** | `"No Sea Experience, please add your experience by clicking add button"` | `'No Sea Experience, please add your experience by clicking add button'` | `same` | Matches `NotFoundWidget` subtitle verbatim. |
| **Home View** | `"Pro Active"` / `"Free Tier"` | `'Pro Active'`, `'Free Tier'` | `same` | Status badge texts match `ProfileSubscriptionCard`. |
| **Home View** | `"Upgrade to Pro"`, `"Manage"`, `"Restore"` | `'Upgrade to Pro'`, `'Manage'`, `'Restore'` | `same` | Button labels match `ProfileSubscriptionCard`. |
| **Home View** | `"Subscription"`, `"Purchase History"` | `'Subscription'`, `'Purchase History'` | `same` | Matches `ProfileSubscriptionCard` section headers. |
| **Home View** | `"Review"`, `"Full Folio"`, `"New Entry"` | *None* | `added` | Out of scope / decorative. |
| **Home View** | Bottom Nav (`Bio-Data`, `Documents`, `Sea Time`, `Settings`) | *None* | `added` | **Drop / Defer**. App has no bottom navigation shell. |

---

### 2.2 My Bio Data Edit Mode (`edit_bio_data` / `EditDetails`)

| Screen | Stitch Text | Audit Text (§6) | Status | Resolution / Action Required |
| :--- | :--- | :--- | :--- | :--- |
| **Edit Details** | `"Edit Bio-Data"` | AppBar: `'My Bio Data'` | `reworded` | **Override AppBar title to `'My Bio Data'`** (exact title in source `edit_details.dart:226`). |
| **Edit Details** | `"Post / Rank Applied For"` | `'Post Applied For'` | `reworded` | **Override to `'Post Applied For'`**. Test finder `appTextField('Post Applied For')` will fail otherwise. |
| **Edit Details** | `"First Name"` | `'First name'` | `reworded` | **Override to `'First name'`** (lowercase 'n'). |
| **Edit Details** | `"Last Name / Surname"` | `'Last name'` | `reworded` | **Override to `'Last name'`**. Test finder `appTextField('Last name')` will fail otherwise. |
| **Edit Details** | `"Father's Full Legal Name"` | `"Father's Name"` | `reworded` | **Override to `"Father's Name"`**. Test finder `appTextField("Father's Name")` will fail otherwise. |
| **Edit Details** | `"Date of Birth"` | `'Date of Birth'` | `same` | Matches `appDatePicker('Date of Birth')`. |
| **Edit Details** | `"Nationality"` | `'Nationality'` | `same` | Matches `appTextField('Nationality')`. |
| **Edit Details** | `"Passport Number"` | `'${wrapper.name} Number'` | `same` | Follows dynamic document pattern. |
| **Edit Details** | `"Passport Validity"` | `'${wrapper.name} Validity'` | `same` | Follows dynamic document pattern. |
| **Edit Details** | `"Issued Place"` | `'${wrapper.name} Issued Place'` | `same` | Follows dynamic document pattern. |
| **Edit Details** | `"Issue Date"` | `'${wrapper.name} Issued Date'` | `reworded` | **Override to `'Issued Date'`** (needs 'd'). Test finder matches `'${wrapper.name} Issued Date'`. |
| **Edit Details** | `"Issued Place / Authority"` | `'${wrapper.name} Issued Place'` | `reworded` | **Override to `'Issued Place'`**. |
| **Edit Details** | `"Add Document"` | `'Add New Documents Type'` | `reworded` | **Override to `'Add New Documents Type'`** for sheet title. |
| **Edit Details** | `"Add Course"` | `'Add New Courses Type'` | `reworded` | **Override to `'Add New Courses Type'`** for sheet title. |
| **Edit Details** | `"Add Vessel"` | `'Add Experience'` | `reworded` | **Override to `'Add Experience'`** / `'Add Sea Experience'`. |
| **Edit Details** | `"Save Changes"` | `'Save Changes'` | `same` | Submit button matches verbatim. |
| **Edit Details** | *None* | SnackBar: `'Profile Updated Successfully'` | `removed` | **Preserve SnackBar feedback**. |
| **Edit Details** | `"Discard / Return to Registry"` | *None* | `added` | **Drop / Defer**. Back arrow pops page. |
| **Edit Details** | Icons: `photo_camera`, `delete`, `edit_note` | Icons: `delete_outline`, `edit_note`, `cancel`, `assets/icons/camera-add.svg`, `add-icon.svg` | `reworded` | **Must preserve test icons**: `Icons.delete_outline`, `Icons.edit_note`, and SVG asset paths. |

---

## 3. Wizards & Onboarding

### 3.1 Profile Completion Wizard (`profile_completion_wizard` / `ProfileCompletion`)

| Screen | Stitch Text | Audit Text (§6) | Status | Resolution / Action Required |
| :--- | :--- | :--- | :--- | :--- |
| **Wizard** | `"Profile Completion Wizard"` | *No AppBar* (Section 1: `'Personal Information'`) | `reworded` | Source has no AppBar; retains `StepProgress` indicator and section title `'Personal Information'`. |
| **Wizard** | `"Officer Dossier Enrollment"` | *None* | `added` | Safe decorative subtitle. |
| **Wizard** | `"Post Applied For"` | `'Post Applied For'` | `same` | Matches step 1 field label. |
| **Wizard** | `"First name"` | `'First name'` | `same` | Matches step 1 field label. |
| **Wizard** | `"Last name"` | `'Last name'` | `same` | Matches step 1 field label. |
| **Wizard** | `"Father's Name"` | `"Father's Name"` | `same` | Matches step 1 field label. |
| **Wizard** | `"Date of Birth"` | `'Date of Birth'` | `same` | Matches step 1 date picker. |
| **Wizard** | `"Nationality"` | `'Nationality'` | `same` | Matches step 1 field label. |
| **Wizard** | `"Next Step: Endorse Documents"` | `'Next'` | `reworded` | **Override to `'Next'`** (source button is `_currentPage == 2 ? "Done" : "Next"`). |
| **Wizard** | `"Take photo from camera"` | `'Take photo from camera'` | `same` | Matches `BottomSheetUploadImage` ListTile verbatim. |
| **Wizard** | `"Choose from gallery"` | `'Choose from gallery'` | `same` | Matches `BottomSheetUploadImage` ListTile verbatim. |
| **Wizard** | `"Cancel"` | `'Cancel'` | `same` | Dismiss action. |
| **Wizard** | *Missing Steps 2 & 3* | Step 2 (`Documents`), Step 3 (`Courses`) | `removed` | **Preserve Steps 2 & 3 in Flutter UI** using StepProgressController. |

---

### 3.2 Onboarding Page (`onboarding` / `OnboardingPage`)

| Screen | Stitch Text | Current Source Copy (`onboarding_page.dart`) | Status | Resolution / Action Required |
| :--- | :--- | :--- | :--- | :--- |
| **Onboarding** | `"Skip"` | `'Skip'` | `same` | Retain skip action button in top right. |
| **Onboarding** | `"Continue"` | `'Next'` (slides 1–3) / `'Get Started'` (slide 4) | `reworded` | Bottom CTA is `'Next'` on slides 1–3 and `'Get Started'` on final slide. |
| **Onboarding** | `"Sovereign Maritime Dossier"` | Slide 1 Title: `'Professional Profile'` | `reworded` | **Keep current copy**: `'Professional Profile'`. |
| **Onboarding** | (Stitch slide 1 body) | Slide 1 Description: `'Keep your personal information and essential travel documents organized in one secure place.'` | `reworded` | **Keep current copy** unless instructed otherwise. |
| **Onboarding** | `"Global Sea-Time Ledger"` | Slide 2 Title: `'Certification Tracker'` | `reworded` | **Keep current copy**: `'Certification Tracker'`. |
| **Onboarding** | (Stitch slide 2 body) | Slide 2 Description: `'Manage your professional courses and mandatory training records with ease.'` | `reworded` | **Keep current copy** unless instructed otherwise. |
| **Onboarding** | `"Direct Officer Placement"` | Slide 3 Title: `'Service History'` | `reworded` | **Keep current copy**: `'Service History'`. |
| **Onboarding** | (Stitch slide 3 body) | Slide 3 Description: `'Maintain a detailed log of your sea experience and vessel history after every voyage.'` | `reworded` | **Keep current copy** unless instructed otherwise. |
| **Onboarding** | (Missing slide 4) | Slide 4 Title: `'Export & Share'` | `removed` | **Keep current slide 4**: `'Export & Share'`. |
| **Onboarding** | (Missing slide 4) | Slide 4 Description: `'Generate professional bio-data reports in PDF or spreadsheet formats to share with agencies.'` | `removed` | **Keep current slide 4 copy** unless instructed otherwise. |

---

---

## 4. Newly Added Modal Sheets & Wizard Steps

### 4.1 Upgrade to Pro Paywall (`upgrade_to_pro` / `SubscriptionPage`)

| Screen | Stitch Text | Audit Text (§6) | Status | Resolution / Action Required |
| :--- | :--- | :--- | :--- | :--- |
| **Paywall** | `"Upgrade to Pro"` | `'Upgrade to Pro'` | `same` | Matches AppBar title verbatim. |
| **Paywall** | `"SEAFARER PRO"` | `'SEAFARER PRO'` | `same` | Matches header brass badge verbatim. |
| **Paywall** | `"Unlock advanced DOCX export and premium features."` | `'Unlock advanced DOCX export and premium features.'` | `same` | Matches subtitle verbatim. |
| **Paywall** | `"Weekly"` | `'Weekly'` | `same` | Matches weekly package identifier. |
| **Paywall** | `"Monthly"` | `'Monthly'` | `same` | Matches monthly package identifier. |
| **Paywall** | `"MOST POPULAR"` | `'MOST POPULAR'` | `same` | Matches monthly plan badge verbatim. |
| **Paywall** | `"Yearly"` | `'Yearly'` | `same` | Matches yearly package identifier. |
| **Paywall** | `"BEST VALUE"` | `'BEST VALUE'` | `same` | Matches yearly plan badge verbatim. |
| **Paywall** | `"Auto-renewing subscription"` | *None* | `added` | Informational billing tag. |
| **Paywall** | `"Upgrade to Pro"` (bottom CTA button) | *None* (No separate button; each plan card is itself the purchase tap target) | `added` | **Note:** In source (`subscription_page.dart:253-255`) and tests (`subscription_page_test.dart:19-21`), tapping a plan card dispatches `PurchasePlan(plan)` immediately; no separate purchase button exists today. |
| **Paywall** | `"Restore Purchases"` | `'Restore Purchases'` | `same` | Matches restore button verbatim. |
| **Paywall** | `"Terms of Use"` | `'Terms of Use'` | `same` | Matches legal link verbatim. |
| **Paywall** | `"Privacy Policy"` | `'Privacy Policy'` | `same` | Matches legal link verbatim. |

---

### 4.2 Add Sea Experience Bottom Sheet (`add_sea_experience` / `edit_details.dart:548`)

| Screen | Stitch Text | Audit Text (§6) | Status | Resolution / Action Required |
| :--- | :--- | :--- | :--- | :--- |
| **Experience Sheet** | `"Add Sea Experience"` | `'Add Sea Experience'` | `same` | Matches modal sheet title verbatim. |
| **Experience Sheet** | `"Ship Name"` | `'Ship Name'` | `same` | Matches vessel name field label. |
| **Experience Sheet** | `"Company Name"` | `'Company Name'` | `same` | Matches company field label. |
| **Experience Sheet** | `"Type"` | `'Type'` | `same` | Matches vessel type field label. |
| **Experience Sheet** | `"Rank"` | `'Rank'` | `same` | Matches seafarer rank field label. |
| **Experience Sheet** | `"From"` | `'From'` | `same` | Matches sign-on date label. |
| **Experience Sheet** | `"To"` | `'To'` | `same` | Matches sign-off date label. |
| **Experience Sheet** | `"GRT"` | `'GRT'` | `same` | Matches gross tonnage field label. |
| **Experience Sheet** | `"BHP"` | `'BHP'` | `same` | Matches brake horsepower field label. |
| **Experience Sheet** | `"Period:"` | `'Period:'` | `same` | Matches auto-calculated period header verbatim. |
| **Experience Sheet** | `"(in months)"` | `'(in months)'` | `same` | Matches unit descriptor verbatim. |
| **Experience Sheet** | `"Add Experience"` | `'Add Experience'` | `same` | Matches primary submit button verbatim. |

---

### 4.3 Add New Documents Type Bottom Sheet (`add_new_documents_type` / `edit_details.dart:505`)

| Screen | Stitch Text | Audit Text (§6) | Status | Resolution / Action Required |
| :--- | :--- | :--- | :--- | :--- |
| **Document Sheet** | `"Add New Documents Type"` | `'Add New Documents Type'` | `same` | Matches modal sheet title verbatim. |
| **Document Sheet** | `"Documents Name"` | `'Documents Name'` | `same` | Matches custom type name field. |
| **Document Sheet** | `"Add to List"` | `'Add to List'` | `same` | Matches primary submit button verbatim. |

---

### 4.4 Profile Completion Step 2 & Step 3 (`profile_completion_step2_documents`, `profile_completion_step3_courses`)

| Screen | Stitch Text | Audit Text / Source Copy | Status | Resolution / Action Required |
| :--- | :--- | :--- | :--- | :--- |
| **Wizard Step 2** | `"Profile Completion"` | *No AppBar* (Section 2: `'Documents'`) | `reworded` | Source has no AppBar; retains `StepProgress` indicator and section title `'Documents'`. |
| **Wizard Step 2** | `"Passport Number"` | `'Passport Number'` | `same` | Matches Passport field label. |
| **Wizard Step 2** | `"Passport Validity"` | `'Passport Validity'` | `same` | Matches Passport validity date label. |
| **Wizard Step 2** | `"Issued Place"` | `'Passport Issued Place'` | `reworded` | Retain dynamic prefix `'${wrapper.name} Issued Place'`. |
| **Wizard Step 2** | `"Issued Date"` | `'Passport Issued Date'` | `reworded` | Retain dynamic prefix `'${wrapper.name} Issued Date'`. |
| **Wizard Step 2** | `"+ Add Document Type"` | `'Add New Documents Type'` | `reworded` | Action opens `add_new_documents_type` sheet. |
| **Wizard Step 2** | `"Next Step: Courses"` | `'Next'` | `reworded` | **Override to `'Next'`** (source button is `_currentPage == 2 ? "Done" : "Next"`). |
| **Wizard Step 3** | `"Profile Completion"` | *No AppBar* (Section 3: `'Courses'`) | `reworded` | Source has no AppBar; retains `StepProgress` indicator and section title `'Courses'`. |
| **Wizard Step 3** | `"Courses & Certifications"` | `'Courses'` | `reworded` | Retain section title. |
| **Wizard Step 3** | `"CERTIFICATE NUMBER"` | `'${wrapper.name} Number'` | `reworded` | Retain dynamic prefix `'${wrapper.name} Number'`. |
| **Wizard Step 3** | `"VALIDITY DATE"` | `'${wrapper.name} Validity'` | `reworded` | Retain dynamic prefix `'${wrapper.name} Validity'`. |
| **Wizard Step 3** | `"+ Add Course"` | `'Add New Courses Type'` | `reworded` | Action opens Add Course bottom sheet. |
| **Wizard Step 3** | `"Complete Profile →"` | `'Done'` | `reworded` | **Override to `'Done'`** (source button is `_currentPage == 2 ? "Done" : "Next"`). |
