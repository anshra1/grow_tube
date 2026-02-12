# Global Widget Structure (Atomic Design)

This document defines how **shared, cross-feature widgets** are organized. These are widgets used by **2 or more features** and live in `lib/src/core/widgets/`.

---

## Folder Structure

```text
lib/src/core/widgets/
 ├── atoms/         <-- Basic building blocks (Buttons, Inputs, Texts)
 ├── molecules/     <-- Groups of atoms (Search Bars, User Cards)
 ├── organisms/     <-- Complex UI sections (Headers, Footers)
 ├── template/      <-- Page layouts without content
 └── pages/         <-- (Rarely used, mostly for generic status pages)
```

---

## Atomic Design Levels

### 1. Atoms
The smallest, indivisible UI elements. Cannot be broken down further.
- **Examples:** `AppPrimaryButton`, `AppTextField`, `AppText`, `AppIcon`
- **Rule:** Pure presentation. No business logic. Accepts data via constructor.

### 2. Molecules
A combination of 2+ atoms that form a functional unit.
- **Examples:** `SearchBar` (TextField + Icon), `UserClassCard` (Avatar + Name + Badge)
- **Rule:** Molecules compose atoms. They may have simple internal state (e.g., focus), but no feature-specific logic.

### 3. Organisms
Complex, self-contained UI sections made of atoms and molecules.
- **Examples:** `AppHeader` (Logo + Navigation + SearchBar), `AppFooter` (Links + CopyrightText)
- **Rule:** Can contain layout logic. May interact with a Bloc/Cubit if needed.

### 4. Templates
Page-level layout structures **without** content. They define the skeleton.
- **Examples:** `AuthPageTemplate` (Logo + Form Area + Footer), `SettingsPageTemplate` (Title + List Area)
- **Rule:** Templates define *where* things go, not *what* they are.

### 5. Pages
Rarely used at the core level. Reserved for generic pages that aren't feature-specific.
- **Examples:** `NotFoundPage`, `MaintenancePage`, `ErrorPage`

---

## Promotion Rule (When to Move a Widget Here)

```text
Widget used in 1 feature  →  Keep it LOCAL (inside the feature's page/widgets folder)
Widget used in 2+ features →  PROMOTE it to lib/src/core/widgets/ at the correct Atomic level
```

### Promotion Checklist
1. ✅ Is this widget used by **2 or more** different features?
2. ✅ Is the widget **generic enough** (no feature-specific logic baked in)?
3. ✅ Does it accept all data via **constructor parameters** (no hardcoded feature data)?

If all 3 are true → move it to `lib/src/core/widgets/` under the right level.

---

## Naming Convention

| Level      | Prefix          | Example                    |
|------------|-----------------|----------------------------|
| Atoms      | `App` prefix    | `AppPrimaryButton`         |
| Molecules  | Descriptive     | `SearchBar`, `UserCard`    |
| Organisms  | Descriptive     | `AppHeader`, `AppFooter`   |
| Templates  | `*Template`     | `AuthPageTemplate`         |
| Pages      | `*Page`         | `NotFoundPage`             |

---

## AI Instructions

When creating or modifying widgets:
1. **Check if a similar widget already exists** in `lib/src/core/widgets/` before creating a new one.
2. **Never put feature-specific logic** in a global widget. Pass callbacks instead.
3. If you find a widget being imported across features, **suggest promoting it** to the appropriate Atomic level.
