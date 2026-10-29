# Design System Tokens

Extracted directly from the **Seafarer Bio-Data Redesign** project on Stitch (`https://stitch.googleapis.com/mcp`, Project ID: `2053276486938912345`).

The design language combines **Maritime Heritage / Classical Nautical Authority** (deep midnight navies, warm brass/gold accents, warm parchment neutrals) with **Modern Mobile Cleanliness** (crisp card elevations, subtle border accents, and high-readability typography).

---

## 1. Color Palette

All colors conform to the Material 3 semantic tonal system with specialized maritime palette mapping.

### Primary (Midnight Fleet Navy)
Used for key branding elements, high-contrast actions, primary containers, and prominent badges.

| Token Name | Hex Code | Flutter `Color` | Usage / Semantic Role |
| :--- | :--- | :--- | :--- |
| `primary` | `#000615` | `Color(0xFF000615)` | Deepest maritime navy; root primary accent |
| `primary-container` | `#0b1f3a` | `Color(0xFF0B1F3A)` | Anchor navy; header cards, badges, dark buttons |
| `on-primary` | `#ffffff` | `Color(0xFFFFFFFF)` | Text/icons on primary surfaces |
| `on-primary-container` | `#7587a7` | `Color(0xFF7587A7)` | Secondary text inside dark navy cards |
| `primary-fixed` | `#d6e3ff` | `Color(0xFFD6E3FF)` | Soft maritime blue tinted background |
| `primary-fixed-dim` | `#b5c7ea` | `Color(0xFFB5C7EA)` | Subdued blue tint |
| `on-primary-fixed` | `#071c36` | `Color(0xFF071C36)` | Dark navy text on `primary-fixed` containers |
| `on-primary-fixed-variant` | `#364764` | `Color(0xFF364764)` | Medium navy text on fixed containers |
| `inverse-primary` | `#b5c7ea` | `Color(0xFFB5C7EA)` | Inverted primary for dark-surface toggles |

### Secondary (Nautical Brass & Warm Gold)
Used for Pro badges, active states, verification pills, sextant badges, and premium highlights.

| Token Name | Hex Code | Flutter `Color` | Usage / Semantic Role |
| :--- | :--- | :--- | :--- |
| `secondary` | `#795916` | `Color(0xFF795916)` | Warm brass; registry emblems, active pill text |
| `secondary-container` | `#fdd182` | `Color(0xFFFDD182)` | Warm gold container; highlighted badges |
| `on-secondary` | `#ffffff` | `Color(0xFFFFFFFF)` | White text on solid brass buttons |
| `on-secondary-container` | `#775815` | `Color(0xFF775815)` | Dark brass text on gold badge containers |
| `secondary-fixed` | `#ffdea7` | `Color(0xFFFFDEA7)` | Light champagne gold container |
| `secondary-fixed-dim` | `#ebc073` | `Color(0xFFEBC073)` | Subdued warm gold |
| `on-secondary-fixed` | `#271900` | `Color(0xFF271900)` | Deep bronze text on gold containers |
| `on-secondary-fixed-variant` | `#5e4200` | `Color(0xFF5E4200)` | Medium bronze text on gold containers |

### Surface & Background (Warm Nautical Ivory / Parchment)
Soft, warm-tinted neutral tones that prevent sterile harsh white interfaces and mimic official logbooks.

| Token Name | Hex Code | Flutter `Color` | Usage / Semantic Role |
| :--- | :--- | :--- | :--- |
| `background` | `#faf9f6` | `Color(0xFFFAF9F6)` | Global scaffold background (warm parchment) |
| `surface` | `#faf9f6` | `Color(0xFFFAF9F6)` | Base surface |
| `surface-dim` | `#dbdad7` | `Color(0xFFDBDAD7)` | Dimmed surface under overlays |
| `surface-bright` | `#faf9f6` | `Color(0xFFFAF9F6)` | High-luminance surface |
| `surface-container-lowest` | `#ffffff` | `Color(0xFFFFFFFF)` | Card backgrounds, text fields, bottom sheets |
| `surface-container-low` | `#f4f3f0` | `Color(0xFFF4F3F0)` | Subtle pill background, input unfocused fill |
| `surface-container` | `#efeeeb` | `Color(0xFFEFEEEB)` | Grouped section containers, avatar backdrops |
| `surface-container-high` | `#e9e8e5` | `Color(0xFFE9E8E5)` | Elevated inner containers, modal headers |
| `surface-container-highest` | `#e3e2df` | `Color(0xFFE3E2DF)` | Divider borders, subtle separators |
| `surface-variant` | `#e3e2df` | `Color(0xFFE3E2DF)` | Subtle fill for deactivated items |
| `surface-tint` | `#4d5f7d` | `Color(0xFF4D5F7D)` | Elevation overlay tint |

### Text & Outline Neutrals
Carefully graded dark slates for high readability and contrast.

| Token Name | Hex Code | Flutter `Color` | Usage / Semantic Role |
| :--- | :--- | :--- | :--- |
| `on-background` | `#1b1c1a` | `Color(0xFF1B1C1A)` | Primary body and title text |
| `on-surface` | `#1b1c1a` | `Color(0xFF1B1C1A)` | Standard text on white/light containers |
| `on-surface-variant` | `#44474d` | `Color(0xFF44474D)` | Secondary labels, descriptions, subtitles |
| `outline` | `#75777e` | `Color(0xFF75777E)` | Active input borders, icons, search icons |
| `outline-variant` | `#c4c6ce` | `Color(0xFFC4C6CE)` | Inactive input borders, subtle card outlines |
| `inverse-surface` | `#2f312f` | `Color(0xFF2F312F)` | Inverted dark snackbar background |
| `inverse-on-surface` | `#f2f1ee` | `Color(0xFFF2F1EE)` | Light text on dark snackbars |

### Status, Error & Tertiary
Used for validation alerts, destructive actions, and maritime seal accents.

| Token Name | Hex Code | Flutter `Color` | Usage / Semantic Role |
| :--- | :--- | :--- | :--- |
| `error` | `#ba1a1a` | `Color(0xFFBA1A1A)` | Validation error text, delete actions |
| `error-container` | `#ffdad6` | `Color(0xFFFFDAD6)` | Error banner and alert backdrops |
| `on-error` | `#ffffff` | `Color(0xFFFFFFFF)` | White text on solid error badges |
| `on-error-container` | `#93000a` | `Color(0xFF93000A)` | Dark red text inside error container |
| `tertiary` | `#170001` | `Color(0xFF170001)` | Deep wax seal dark accent |
| `tertiary-container` | `#470007` | `Color(0xFF470007)` | Deep burgundy wax seal card |
| `on-tertiary` | `#ffffff` | `Color(0xFFFFFFFF)` | Light icon on tertiary |
| `on-tertiary-container` | `#d46462` | `Color(0xFFD46462)` | Light burgundy text on tertiary container |
| `tertiary-fixed` | `#ffdad8` | `Color(0xFFFFDAD8)` | Soft burgundy pill |
| `tertiary-fixed-dim` | `#ffb3af` | `Color(0xFFFFB3AF)` | Subdued burgundy |
| `on-tertiary-fixed` | `#410006` | `Color(0xFF410006)` | Deep burgundy text |
| `on-tertiary-fixed-variant` | `#812628` | `Color(0xFF812628)` | Medium burgundy text |

---

## 2. Typography

The design system establishes a deliberate hierarchy between **Playfair Display** (for classical maritime editorial titles and display headings) and **Plus Jakarta Sans** (for crystal-clear forms, tables, body copy, and UI controls).

### Font Families
- **Display / Editorial Serifs:** `'Playfair Display'`, serif
- **Body / Controls Sans-Serif:** `'Plus Jakarta Sans'`, sans-serif
- **System Icons:** `'Material Symbols Outlined'`, fallback to Cupertino / Material Icons

### Type Scale

| Style Token | Font Family | Size | Line Height | Weight | Letter Spacing | Usage |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `headline-xl` | Playfair Display | `40px` | `48px` | 600 (SemiBold) | `-0.02em` (`-0.8px`) | Desktop display headers |
| `headline-xl-mobile` | Playfair Display | `30px` | `38px` | 600 (SemiBold) | `-0.01em` (`-0.3px`) | Main screen titles (`Welcome Seafarer`, `Sovereign Dossier`) |
| `headline-lg` | Playfair Display | `32px` | `40px` | 600 (SemiBold) | `-0.015em` (`-0.48px`)| Desktop section headers |
| `headline-lg-mobile` | Playfair Display | `24px` | `32px` | 600 (SemiBold) | `-0.01em` (`-0.24px`)| Primary screen headers (`Officer Dossier`, `Create Account`) |
| `headline-md` | Playfair Display | `20px` | `28px` | 600 (SemiBold) | `normal` | Section cards (`Personal Attributes`, `Registry Documents`) |
| `headline-sm` | Playfair Display | `17px` | `24px` | 600 (SemiBold) | `normal` | Subsection headers, vessel names (`MV Coral`, `M/V Nordic`) |
| `title-md` | Plus Jakarta Sans | `16px` | `22px` | 600 (SemiBold) | `-0.005em` (`-0.08px`)| Card titles, list headers, prominent labels |
| `body-lg` | Plus Jakarta Sans | `16px` | `24px` | 400 (Regular) | `normal` | Prominent body explanations |
| `body-md` | Plus Jakarta Sans | `14px` | `20px` | 400 (Regular) | `normal` | Form inputs, standard body text, table cells |
| `body-sm` | Plus Jakarta Sans | `13px` | `18px` | 400 (Regular) | `normal` | Auxiliary descriptions, helper notes |
| `label-md` | Plus Jakarta Sans | `12px` | `16px` | 600 (SemiBold) | `+0.04em` (`+0.48px`)| Form field labels (uppercase/tracked), button text |
| `label-sm` | Plus Jakarta Sans | `11px` | `14px` | 600 (SemiBold) | `+0.06em` (`+0.66px`)| Micro-labels, input tags (`SECRET PASSKEY`, `MARITIME ID`) |
| `caption` | Plus Jakarta Sans | `10px` | `14px` | 500 (Medium) | `+0.08em` (`+0.8px`) | Registry numbers, timestamps, status pills |

---

## 3. Radii (Corner Rounding)

Curvature creates an approachable yet structured editorial card interface.

| Token | CSS Value | Pixel Equivalent | Flutter `BorderRadius` | Primary Usage |
| :--- | :--- | :--- | :--- | :--- |
| `DEFAULT` | `0.25rem` | `4px` | `BorderRadius.circular(4)` | Checkboxes, inner tags, small indicators |
| `md` | `0.375rem`| `6px` | `BorderRadius.circular(6)` | Tooltips, small badges |
| `lg` | `0.5rem` | `8px` | `BorderRadius.circular(8)` | Text input containers, action buttons, table rows |
| `xl` | `0.75rem`| `12px` | `BorderRadius.circular(12)`| Main content cards, form envelopes, modal containers |
| `2xl` | `1rem` | `16px` | `BorderRadius.circular(16)`| Hero profile cards, bottom sheet top corners (`rounded-t-2xl`)|
| `full` | `9999px` | `BorderRadius.circular(9999)` | `BorderRadius.circular(9999)`| Circular avatar frames, pill buttons, status badges |

---

## 4. Spacing System

Based on a strict 4px/8px modular grid.

| Token | CSS Value | Pixels | Usage in Mobile Screens |
| :--- | :--- | :--- | :--- |
| `space-xs` | `0.25rem` | `4px` | Micro gap between icon and label, tight padding |
| `space-sm` | `0.5rem` | `8px` | Padding within pills, gap between form label and input |
| `gutter-mobile` | `0.75rem`| `12px` | Horizontal gutter between related input fields in a row |
| `space-md` / `gutter` | `1.0rem` | `16px` | Standard padding inside cards, vertical form field spacing |
| `space-lg` / `margin` | `1.5rem` | `24px` | Outer screen margin (`px-margin-mobile`), card block spacing |
| `space-xl` | `2.0rem` | `32px` | Spacing between major page sections, hero block margins |

---

## 5. Border & Shadow Styles

### Elevation & Box Shadows

| Level | CSS Specification | Visual Effect / Flutter `BoxShadow` |
| :--- | :--- | :--- |
| `shadow-sm` | `0 1px 2px 0 rgb(0 0 0 / 0.05)` | `BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1))` — Cards, input fields |
| `shadow` | `0 1px 3px 0 rgb(0 0 0 / 0.1), 0 1px 2px -1px rgb(0 0 0 / 0.1)` | Subtle card elevation on ivory background |
| `shadow-md` | `0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1)` | Floating CTA buttons, active status cards |
| `shadow-lg` | `0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1)`| Bottom sheet modals, dropdown menus |
| `shadow-2xl`| `0 25px 50px -12px rgb(0 0 0 / 0.25)` | Elevated modal dialogs |
| `shadow-inner` | `inset 0 2px 4px 0 rgb(0 0 0 / 0.05)` | Avatar inset frame, recessed biometric pad |

### Border Styles

| Style Pattern | CSS Classes | Usage |
| :--- | :--- | :--- |
| **Card Border** | `border border-outline-variant/30` or `border border-surface-container-high` | Subtle boundary for cards on ivory background |
| **Input Inactive** | `bg-surface-container-low` (borderless or subtle `outline-variant/40`) | Low-contrast form field in rest state |
| **Input Focus** | `focus-within:bg-surface-container-lowest focus-within:shadow-sm` | Field elevates on tap with crisp focus |
| **Pro Accent Border** | `border border-secondary-fixed` (`#ffdea7`) | Highlights active Pro subscription cards |
| **Avatar Crest Frame** | `border-2 border-secondary/20` with `p-1.5 bg-surface-container` | Multi-layered nautical crest badge surrounding seafarer photo |
