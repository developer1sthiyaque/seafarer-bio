# Standing Redesign Overrides & Architectural Constraints

This document defines the binding rules, precedence policies, icon asset directives, and out-of-scope deferred elements governing the UI overhaul of the Seafarer Bio-Data application.

---

## 1. Standing Implementation Rules

### Rule 1: Audit Precedence (Authoritative Ground Truth)
* **Text Strings & Form Labels:** Whenever a discrepancy arises between a label in a Stitch design and [`docs/REDESIGN_AUDIT.md`](../../docs/REDESIGN_AUDIT.md#L240-L297) §6, **the audit string always wins**. Existing widget tests use strict string finders (`appTextField('First name')`, `appDatePicker('Date of Birth')`, `find.text('My Bio Data')`).
* **SVG Asset Paths:** Test finders locate interactive action targets using `svgAssetTapTarget(assetName)`. The exact asset file paths must be preserved.
* **Form Keys:** State management keys (`_formLoginKey`, `_signUpFormKey`, `_formKey`, `_form1Key`, `_form2Key`, `_form3Key`) must remain attached to their respective `Form` widgets.
* **BLoC Events & Navigation Routes:** Screen interactions must dispatch the exact BLoC events (`SignInEvent`, `SignUpEvent`, `UpdateFullProfileEvent`, `SignOutEvent`, `FetchPlans`, `PurchasePlan`, `RestorePurchase`) and navigate using `AppRoutes`.

### Rule 2: Visual Reference Only (No Direct Porting)
* The HTML, CSS, and Tailwind code generated in Stitch serves exclusively as a **visual and aesthetic reference** (color tokens, font choices, padding rhythm, surface elevations).
* **Never port Stitch HTML directly** via WebViews, inline HTML parsers, or unstructured DOM-like layouts.
* All UI must be constructed using idiomatic Flutter Material 3 widgets (`Scaffold`, `AppBar`, `Form`, `Table`, `PageView`, `SingleChildScrollView`, `ElevatedButton`).
* Flutter state management (`BlocConsumer`, `BlocBuilder`, `BlocListener`) and controller bindings must never be replaced by static or ad-hoc UI state.

### Rule 3: Thin-Line Vector SVG Preservation (No Material Icon Substitution)
* Do **not** replace the app's custom SVG action icons with generic Material icon glyphs (`Icons.pdf`, `Icons.edit`, etc.).
* Redraw each of the **8 required SVG icons** as crisp, modern, thin-line (1.5px–2px stroke) vector assets that match the new navy/brass aesthetic.
* Save the redrawn vectors under the **exact existing file paths** so that automated test finders continue to locate them without code modification.

### Rule 4: Preserved Material Icons
* Keep `Icons.delete_outline`, `Icons.edit_note`, and `Icons.cancel`; only restyle their color and size. Do not replace them with other icons or drop them.

### Rule 5: Label String Casing (Audit & Source Truth)
* Label strings keep the exact casing from audit §6 (or current source). Never uppercase a label string in code (e.g. use `'First name'`, `'Last name'`, `'Father\'s Name'`).

### Rule 6: Source Precedence for Unlisted Strings
* For any string not in audit §6, the current Flutter source is the truth, not Stitch and not CONTENT_DIFF.

### Rule 7: Out-of-Scope Behavior Exclusion
* Any visual element in Stitch that implies new backend endpoints, new database fields, third-party authentication protocols, or untracked state must be **deferred**.
* Do not introduce dummy buttons or unbacked checkboxes that confuse the user or break existing validation logic.

---

## 2. The 8 Required SVG Icons

These 8 SVG icon assets must be maintained under their exact paths in `assets/icons/`:

| # | Asset File Path | Screen / Location | Redesign Styling Directive | Test Finder Contract |
| :- | :--- | :--- | :--- | :--- |
| **1** | `assets/icons/pdf_icon.svg` | `HomePage` AppBar Action | Thin-line document glyph with crisp "PDF" emblem in primary container navy or secondary brass. | `svgAssetTapTarget('assets/icons/pdf_icon.svg')` |
| **2** | `assets/icons/file_doc.svg` | `HomePage` AppBar Action | Thin-line Word document glyph with subtle text lines. | `svgAssetTapTarget('assets/icons/file_doc.svg')` |
| **3** | `assets/icons/edit.svg` | `HomePage` AppBar Action | Elegant thin-line pencil/quill icon. | `svgAssetTapTarget('assets/icons/edit.svg')` |
| **4** | `assets/icons/add-icon.svg` | `EditDetails` Section Add Actions | Minimal thin-line plus encircled icon. Index 0: Documents, Index 1: Courses, Index 2: Sea Experience. | `svgAssetTapTarget('assets/icons/add-icon.svg')` |
| **5** | `assets/icons/camera-add.svg`| Avatar Upload Action | Thin-line camera with a small corner plus badge. | `svgAssetTapTarget('assets/icons/camera-add.svg')` |
| **6** | `assets/icons/close-square.svg`| Sea Experience Modal Sheet | Modern square with rounded corners enclosing a thin diagonal cross. | `svgAssetTapTarget('assets/icons/close-square.svg')` |
| **7** | `assets/icons/eye.svg` | Login / SignUp Password Toggle | Thin-line open eye icon indicating visible passkey. | `svgAsset('assets/icons/eye.svg')` |
| **8** | `assets/icons/eye_off.svg` | Login / SignUp Password Toggle | Thin-line eye with diagonal strike indicating obscured passkey. | `svgAsset('assets/icons/eye_off.svg')` |

---

## 3. Deferred Stitch Elements (Out of Scope)

The following UI elements found in the Stitch redesign designs imply new backend schemas, third-party services, or architectural additions that are not part of the active app model. They are strictly **deferred** from this redesign:

### 3.1 Persistent 5-Tab Bottom Navigation Bar
* **Stitch Screens:** `bio_data_overview`, `bio_data_pro_active`, `bio_data_free_tier`
* **Elements:** Bottom navigation bar with tabs: `Bio-Data`, `Documents`, `Sea Time`, `Settings`, and `Search`.
* **Reason for Deferral:** The current architecture uses a focused single-scaffold overview (`HomePage`) with an `AppBar` containing action icons (Export, Edit, Pro, Sign Out). Introducing bottom navigation would require architecting a multi-tab persistent shell, sub-routes, and new screens that do not exist in the domain model.

### 3.2 Biometric Credential & Hardware Passkey Authentication
* **Stitch Screen:** `login`
* **Elements:** `"Remember vessel credential"` checkbox with fingerprint icon, `"Hardware Key & Bio ID Compatible"`.
* **Reason for Deferral:** The backend is powered by standard Firebase Auth (Email/Password). Local biometric encryption (e.g. `local_auth`) and hardware key storage are not currently implemented.

### 3.3 "Forgot Password?" Flow
* **Stitch Screen:** `login`
* **Elements:** `"Forgot?"` text button.
* **Reason for Deferral:** The app currently has no password-reset route, use case, or screen. Adding this button would create a dead click target unless an entire reset password flow is scoped and tested.

### 3.4 STCW Code of Conduct & Merchant Registry Mandatory Checkbox
* **Stitch Screen:** `signup`
* **Elements:** Checkbox: `"I consent to STCW sea-time logging guidelines and the Merchant Registry Code of Conduct."`
* **Reason for Deferral:** The `SignUpEvent` and `SignUpUseCase` take `firstname`, `lastname`, `email`, and `password`. The Firestore schema has no boolean field for maritime registry consent. Enforcing this checkbox would alter form validation contracts and fail existing unit/widget tests.

### 3.5 Cryptographic Attestation & Blockchain Seal Badges (DROP)
* **Stitch Screens:** `login`, `onboarding`, `bio_data_overview`, `bio_data_pro_active`
* **Elements:** `"REGISTRY N° 1892"`, `"STCW Validated"`, `"IMO Comp."`, `"256-Bit Maritime Vault Encryption"`, `"Cryptographic STCW Validation"`, `"IMO Global Cross-Check"`, `"Digitally Verified · Directorate of Shipping"`.
* **Policy: DROP.** Do not render any registry numbers, `"STCW Validated"`, `"IMO Comp."`, encryption claims, or `"Digitally Verified"` text. Crest/logo graphics only.

### 3.6 Computed Aggregate Metrics & Auxiliary Profile Fields
* **Stitch Screens:** `bio_data_overview`, `bio_data_pro_active`, `bio_data_free_tier`
* **Elements:**
  * `"Service Dossier · Registry № 4481-B"`
  * `"Age 39"` (calculated on the fly from DOB)
  * `"Total Recorded Days: 2,410 Sea Days Logged"`
  * `"14 Vessels (LNG / Capesize)"`
  * `"Discharge Book (CDC) MUM-148922"`
  * `"STCW Status: Valid Full Endorsed"`
* **Reason for Deferral:** The Firestore `Profile` entity does not store aggregated vessel counts, lifetime sea-day calculations, or verification flags. Adding them to the UI without backend fields will result in empty or hardcoded dummy values.

### 3.7 In-Flight Document Endorsement Pills
* **Stitch Screens:** `edit_bio_data`, `profile_completion_wizard`
* **Elements:** Status chips on document cards: `"STCW Certified"`, `"Original Verified"`, `"MCA Approved • Complete"`.
* **Reason for Deferral:** Documents in the current domain model contain only `name`, `number`, `issueDate`, `issuePlace`, and `validityDate`. There is no document status enum or approval workflow in the app.

### 3.8 Auxiliary Action Buttons
* **Stitch Screens:** `bio_data_overview`, `edit_bio_data`
* **Elements:** `"Review"`, `"Discard / Return to Registry"`, `"Full Folio"`.
* **Reason for Deferral:** Standard Flutter navigation handles page dismissal via the AppBar back button and "Save Changes" submits the form. Auxiliary dismiss/review actions are redundant and out of scope.
