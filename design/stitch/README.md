# Stitch Screens Inventory & App Mapping

This directory contains the exported screens, screenshots (`screenshot.png`), and HTML/CSS (`code.html`) generated for the **Seafarer Bio-Data Redesign** project in Google Stitch (Project ID: `2053276486938912345`).

All screens strictly adhere to the unified **Maritime Reserve** design system (Asset ID: `assets/7c6a589dea274a7a889fe1356757c231`).

---

## 1. Complete Screen Mapping Table

Mapped against the screen and modal inventory in [`docs/REDESIGN_AUDIT.md`](../../docs/REDESIGN_AUDIT.md#L126-L144) (§3).

| # | Screen Real Name | Screen ID | Folder Path | Mapped App Screen / Component | Status / Notes |
| :- | :--- | :--- | :--- | :--- | :--- |
| **1** | **Login** | `412bce66973b4795b2e2aa0a72913706` | [`./login/`](./login) | `LoginPage`<br>([`login_page.dart`](../../lib/features/auth/presentation/pages/login_page.dart)) | Complete. Redesigns auth card, maritime crest, email, password fields. |
| **2** | **Sign Up** | `efa18b1809434d889994470dbd3a09ef` | [`./signup/`](./signup) | `SignUpPage`<br>([`signup_page.dart`](../../lib/features/auth/presentation/pages/signup_page.dart)) | Complete. Redesigns registration form with maritime aesthetics. |
| **3** | **Bio-Data Overview** | `2d377f68ca3241ef8851e30673407dc3` | [`./bio_data_overview/`](./bio_data_overview) | `HomePage` (View Mode)<br>([`home_page.dart`](../../lib/features/personal_details/presentation/view/home_page.dart)) | Complete. Primary overview screen displaying officer info, documents, certificates, and sea experience. |
| **4** | **Edit Bio-Data** | `eb013c5d77744c94a45d7b0940667731` | [`./edit_bio_data/`](./edit_bio_data) | `EditDetails` (Edit Mode)<br>([`edit_details.dart`](../../lib/features/personal_details/presentation/view/edit_details.dart)) | Complete. Dynamic editable form for attributes, documents, courses, and sea service entries. |
| **5** | **Profile Completion Wizard & Photo Sheet** | `68975faac42b47b2a76b2f6e8aeef591` | [`./profile_completion_wizard/`](./profile_completion_wizard) | `ProfileCompletion` (Step 1)<br>([`profile_completion.dart`](../../lib/features/personal_details/presentation/view/profile_completion.dart)) & `BottomSheetUploadImage` | Complete. Step 1 (Personal Details) with bottom sheet for camera/gallery photo upload. |
| **6** | **Onboarding** | `8cba33171a714e87b48e6c28d18b02f7` | [`./onboarding/`](./onboarding) | `OnboardingPage`<br>([`onboarding_page.dart`](../../lib/features/onboarding/onboarding_page.dart)) | Complete. Walkthrough carousel introducing the digital maritime dossier. |
| **7** | **Bio-Data (Free Tier & Empty State)** | `35ed2ff3e049419d8e9d3b74476aeb44` | [`./bio_data_free_tier/`](./bio_data_free_tier) | `HomePage` with Free Tier & Empty States (`NotFoundWidget`) | Complete. Overview state showing Free Tier banner with "Upgrade to Pro" badge and empty Sea Experience card. |
| **8** | **Bio-Data (Pro Active)** | `b8e790a73968428a831d3ba034136cd6` | [`./bio_data_pro_active/`](./bio_data_pro_active) | `HomePage` with Pro Active Status & `ProfileSubscriptionCard` | Complete. Overview state highlighting active Pro subscription card, Manage, and Restore actions. |
| **9** | **Upgrade to Pro (Paywall)** | `5fa3de6b53c14ca5b9252a27583b8463` | [`./upgrade_to_pro/`](./upgrade_to_pro) | `SubscriptionPage`<br>([`subscription_page.dart`](../../lib/features/subscription/presentation/view/subscription_page.dart)) | Complete. 3 plan cards (Weekly, Monthly [MOST POPULAR], Yearly [BEST VALUE]), brass border on selected, primary purchase CTA, and legal footer. |
| **10** | **Add Sea Experience (Bottom Sheet)** | `c16d17423e664b108e336c07dbcafd7b` | [`./add_sea_experience/`](./add_sea_experience) | Sea Experience Sheet<br>([`edit_details.dart:548`](../../lib/features/personal_details/presentation/view/edit_details.dart)) | Complete. 24px rounded top bottom sheet with drag handle, close icon, 8 fields, Period in months calculation, and sticky primary button. |
| **11** | **Add New Documents Type (Bottom Sheet)** | `9f4b8a7689da4c4cb238aebc15dd888e` | [`./add_new_documents_type/`](./add_new_documents_type) | Add Document / Course Sheet<br>([`edit_details.dart:505`](../../lib/features/personal_details/presentation/view/edit_details.dart)) | Complete. Compact bottom sheet with drag handle, "Documents Name" text input, and "Add to List" primary button. |
| **12** | **Profile Completion - Step 2 (Documents)** | `0838554835b148ddba3de4e89f3f52fb` | [`./profile_completion_step2_documents/`](./profile_completion_step2_documents) | `ProfileCompletion` (Step 2 PageView)<br>([`profile_completion.dart`](../../lib/features/personal_details/presentation/view/profile_completion.dart)) | Complete. Matches Step 1 wizard shell: step progress indicator (Step 1 complete, Step 2 active, Step 3 upcoming), document entry cards, "+ Add Document" card, and sticky Next button. |
| **13** | **Profile Completion - Step 3 (Courses)** | `1834ea7cbd384a21b9b89cf15bb48f1b` | [`./profile_completion_step3_courses/`](./profile_completion_step3_courses) | `ProfileCompletion` (Step 3 PageView)<br>([`profile_completion.dart`](../../lib/features/personal_details/presentation/view/profile_completion.dart)) | Complete. Matches Step 1 & 2 wizard shell: step progress indicator (Steps 1 & 2 complete, Step 3 active final), course entry cards, "+ Add Course" card, and sticky "Complete Profile →" / Finish button. |

---

## 2. File Organization

Each screen directory contains:
- `screenshot.png`: High-resolution render of the mobile design as generated by Stitch.
- `code.html`: Complete, self-contained HTML document featuring Tailwind CSS configuration, typography, layout, icons, and micro-interactions.

```
design/stitch/
├── README.md
├── tokens.md
├── CONTENT_DIFF.md
├── OVERRIDES.md
├── login/
│   ├── code.html
│   └── screenshot.png
├── signup/
│   ├── code.html
│   └── screenshot.png
├── bio_data_overview/
│   ├── code.html
│   └── screenshot.png
├── edit_bio_data/
│   ├── code.html
│   └── screenshot.png
├── profile_completion_wizard/
│   ├── code.html
│   └── screenshot.png
├── onboarding/
│   ├── code.html
│   └── screenshot.png
├── bio_data_free_tier/
│   ├── code.html
│   └── screenshot.png
├── bio_data_pro_active/
│   ├── code.html
│   └── screenshot.png
├── upgrade_to_pro/
│   ├── code.html
│   └── screenshot.png
├── add_sea_experience/
│   ├── code.html
│   └── screenshot.png
├── add_new_documents_type/
│   ├── code.html
│   └── screenshot.png
├── profile_completion_step2_documents/
│   ├── code.html
│   └── screenshot.png
└── profile_completion_step3_courses/
    ├── code.html
    └── screenshot.png
```
