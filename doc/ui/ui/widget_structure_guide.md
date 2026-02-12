# Feature Structure Guide

> A practical guide to organizing widgets and pages as your app grows.

---

## Why This Matters

As your app grows, finding the right file becomes harder. This guide helps you:
- Know exactly where to put new widgets
- Find existing code quickly
- Keep folders manageable (not 50+ files in one place!)

---

## 🧱 Widget Hierarchy (Atomic Design)

Organize widgets by **granularity**:

```
lib/src/core/widgets/
├── atoms/        → Smallest building blocks (buttons, text, icons)
├── molecules/    → Combinations of atoms (input with label)
├── organisms/    → Complex components (forms, cards, headers)
└── templates/    → Layout skeletons (page layouts, scaffolds)
```

| Level | Example | Reusability |
|-------|---------|-------------|
| **Atoms** | `AppButton`, `AppText`, `AppIcon` | Used everywhere |
| **Molecules** | `SearchBar`, `UserAvatar` | Used across features |
| **Organisms** | `TaskCard`, `UserProfileHeader` | Feature-specific |
| **Templates** | `AuthPageLayout`, `DashboardLayout` | Structural patterns |

---

## 🌐 Core vs Feature Widgets

```
lib/src/
├── core/
│   └── widgets/          → ✅ Shared across ALL features
│
└── features/
    └── tasks/
        └── widgets/      → 🔒 Only used within "tasks" feature
```

> [!TIP]
> **Rule**: If a widget is used in **2+ features**, move it to `core/widgets/`.

---

## 🔀 Scaling Large Features (Sub-Features)

When a feature has **7+ pages or 50+ widgets**, split into sub-domains:

```
lib/src/features/
└── e_commerce/                    # The "mega feature"
    ├── cart/                      # Sub-feature 1
    │   ├── presentation/
    │   │   ├── pages/
    │   │   └── widgets/
    │   ├── domain/
    │   └── data/
    │
    ├── products/                  # Sub-feature 2
    │   └── ...
    │
    ├── orders/                    # Sub-feature 3
    │   └── ...
    │
    └── shared/                    # 🔑 Shared within e_commerce only
        └── widgets/
```

---

## 📂 Widget Grouping by Page Context

When 50+ widgets exist, group by **which page uses them**:

```
features/tasks/presentation/
├── pages/
│   ├── task_list_page.dart
│   ├── task_detail_page.dart
│   └── task_create_page.dart
│
└── widgets/
    ├── task_list/                 # Widgets for task_list_page
    │   ├── task_card.dart
    │   ├── task_filter_bar.dart
    │   └── empty_task_state.dart
    │
    ├── task_detail/               # Widgets for task_detail_page
    │   ├── task_header.dart
    │   └── comment_section.dart
    │
    ├── task_create/               # Widgets for task_create_page
    │   ├── task_form.dart
    │   └── priority_picker.dart
    │
    └── common/                    # Shared across task pages
        ├── priority_badge.dart
        └── status_chip.dart
```

---

## 🧩 Component Composition Pattern

For complex widgets (200+ lines), create **sub-components**:

```
widgets/
└── task_card/                     # Complex widget folder
    ├── task_card.dart             # Main exported widget
    ├── _task_card_header.dart     # Private sub-component
    ├── _task_card_body.dart       # Private sub-component
    └── _task_card_footer.dart     # Private sub-component
```

```dart
// task_card.dart
class TaskCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TaskCardHeader(...),
        _TaskCardBody(...),
        _TaskCardFooter(...),
      ],
    );
  }
}
```

---

## 🏗️ Layered Page Structure

For complex pages, use sections:

```
features/dashboard/presentation/pages/
└── dashboard_page/
    ├── dashboard_page.dart           # Entry point (thin)
    ├── sections/                     # Page sections
    │   ├── stats_section.dart
    │   ├── recent_activity_section.dart
    │   └── quick_actions_section.dart
    └── widgets/                      # Page-specific widgets
        ├── stat_card.dart
        └── activity_item.dart
```

---

## 📊 The 7±2 Rule

> [!IMPORTANT]
> No folder should have more than **7-10 items** directly visible. If it does → **create subfolders**.

| Before (❌ Overwhelming) | After (✅ Organized) |
|--------------------------|----------------------|
| `widgets/` with 50 files | `widgets/task_list/` (8 files) |
|                          | `widgets/task_detail/` (10 files) |
|                          | `widgets/common/` (5 files) |

---

## 📋 Quick Decision Matrix

| Scenario | Solution |
|----------|----------|
| Feature has 3+ distinct user flows | Split into sub-features |
| Widget used only by 1 page | Put in `widgets/page_name/` folder |
| Widget used by 2+ pages in same feature | Put in `widgets/common/` |
| Widget used across features | Move to `core/widgets/` |
| Single widget > 200 lines | Break into sub-components with `_` prefix |
| Folder has > 10 files | Create subfolders |

---

## 🏷️ Naming Conventions

| Type | Pattern | Example |
|------|---------|---------|
| **Pages** | `*_page.dart` | `login_page.dart` |
| **Widgets** | Descriptive name | `task_card.dart` |
| **Core Widgets** | `app_*.dart` prefix | `app_button.dart` |
| **Private Components** | `_*.dart` prefix | `_task_card_header.dart` |
| **Barrel Files** | `*.dart` (folder name) | `widgets.dart` |

---

## 📦 Barrel Files

Export everything from a folder for clean imports:

```dart
// widgets/widgets.dart
export 'task_card.dart';
export 'priority_badge.dart';
export 'status_chip.dart';
```

Then import becomes:
```dart
import 'package:app/features/tasks/widgets/widgets.dart';
```
