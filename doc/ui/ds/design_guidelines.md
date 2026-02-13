# Design Guidelines & System

> **⚠️ STRICT RULE:** Adherence to this design system is mandatory. All UI code must follow these guidelines. PRs with hardcoded values will be rejected.

This document outlines the standards for implementing UI in the `skill_tube` project. We follow the **Material Design 3** system, adapted for our specific brand needs.

---

## 🛑 Top 5 Golden Rules

1.  **NO Hardcoded Colors**: Never use `Colors.red`, `Color(0xFF...)`, or Hex codes in widgets.
    *   **Why?** breaks dark mode, theming, and consistency.
    *   **Instead:** Use `context.colorScheme` or `context.appColors`.

2.  **Context-Aware Styling**: Always access styles via `context`.
    *   **Why?** Ensures widgets adapt to the current theme and user settings.
    *   **Instead:** Use `context.textTheme` for text styles.

3.  **No Magic Numbers**: Do not use raw numbers for padding, margins, or shapes.
    *   **Instead:** Use `AppSpacing`, `AppRadius`, `AppSizes`.

4.  **No Raw Strings (i18n)**: Never use string literals for user-facing text.
    *   **Why?** Makes localization impossible.
    *   **Instead:** Use `AppStrings.key` (currently static constants).

5.  **Icon Abstraction**: Never use `Icons.name` or raw asset paths.
    *   **Why?** Hard to switch icon sets or maintain consistency.
    *   **Instead:** Use `AppIcons.key`.

---

## 🎨 Colors

We use the standard Material 3 `ColorScheme` plus a custom extension `AppColorsExtension` for semantic colors.

### Accessing Colors
Use the `context` extensions provided in `context_extensions.dart`.

```dart
import 'package:skill_tube/src/core/utils/extensions/context_extensions.dart';

// ✅ GOOD
Container(
  color: context.colorScheme.primary, // Brand Primary
)

Icon(
  Icons.check,
  color: context.appColors.success, // Semantic Success (Green)
)

Text(
  'Error',
  style: TextStyle(color: context.colorScheme.error),
)

// ❌ BAD
Container(color: Colors.blue)
Container(color: Color(0xFF6200EE))
Container(color: AppColors.primary) // Don't use static AppColors directly in widgets!
```

### Available Palettes

*   **Brand**: `primary`, `secondary`, `tertiary` (via `context.colorScheme`)
*   **UI**: `surface`, `background`, `outline` (via `context.colorScheme`)
*   **Semantic** (via `context.appColors`):
    *   `success`
    *   `warning`
    *   `textPrimary`
    *   `textSecondary`

---

## ✍️ Typography

Text styles are centralized in the `TextTheme`. Do not manually construct `TextStyle` unless you are overriding a specific property (like color) of a theme style.

### Accessing Text Styles
Use `context.textTheme`.

```dart
// ✅ GOOD
Text(
  'Page Title',
  style: context.textTheme.headlineLarge,
)

Text(
  'Body text description.',
  style: context.textTheme.bodyMedium,
)

// Overriding color only
Text(
  'Warning!',
  style: context.textTheme.labelLarge?.copyWith(
    color: context.appColors.warning,
  ),
)

// ❌ BAD
Text(
  'Title',
  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), // No!
)
```

---

## 📐 Spacing & Layout

All padding, margins, and gaps must use `AppSpacing`.

### Imports
```dart
import 'package:skill_tube/src/core/design_system/app_spacing.dart';
```

### Usage

```dart
// ✅ GOOD: Padding
Padding(
  padding: AppSpacing.paddingM, // 16.0
  child: ...
)

// ✅ GOOD: Raw values (only when specific wrapper needed)
SizedBox(height: AppSpacing.xl) // 24.0

// ❌ BAD
Padding(padding: EdgeInsets.all(16.0))
SizedBox(height: 10)

| Token | Value | Logic |
| :--- | :--- | :--- |
| `AppSpacing.xxs` | 4.0 | Tight grouping |
| `AppSpacing.xs` | 8.0 | Related elements |
| `AppSpacing.s` | 12.0 | Content separation |
| `AppSpacing.m` | 16.0 | **Default** component padding |
| `AppSpacing.l` | 20.0 | Section padding |
| `AppSpacing.xl` | 24.0 | Major separation |
| `AppSpacing.xxl` | 32.0 | Layout blocks |
| `AppSpacing.xxxl`| 40.0 | Large spacing |
```

---

## 🔲 Borders & Radius

Use `AppRadius` for all border radii.

```dart
import 'package:skill_tube/src/core/design_system/app_radius.dart';

// ✅ GOOD
Container(
  decoration: BoxDecoration(
    borderRadius: AppRadius.roundedL, // 12.0
  ),
)

// ❌ BAD
borderRadius: BorderRadius.circular(10)

| Token | Value | Usage |
| :--- | :--- | :--- |
| `AppRadius.s` | 4.0 | Small tags, badges |
| `AppRadius.m` | 8.0 | Cards, inputs |
| `AppRadius.l` | 12.0 | Dialogs, bottom sheets |
| `AppRadius.xl` | 16.0 | Large containers |
| `AppRadius.xxl` | 24.0 | Very large containers |
| `AppRadius.full`| 999.0 | Pills, circular avatars |
```

---

## 📏 Sizes & Dimensions

Use `AppSizes` for standard component heights and widths.

```dart
import 'package:skill_tube/src/core/design_system/app_sizes.dart';

// ✅ GOOD
SizedBox(
  height: AppSizes.buttonHeightMd, // 44.0
  child: ElevatedButton(...),
)

// ❌ BAD
height: 45

| Token | Value | Description |
| :--- | :--- | :--- |
| **Touch Targets** | | |
| `AppSizes.minTouchTarget` | 48.0 | Minimum for accessibility |
| `AppSizes.recommendedTouchTarget` | 56.0 | Recommended for tapping |
| **Buttons** | | |
| `AppSizes.buttonHeightSm` | 36.0 | Small button |
| `AppSizes.buttonHeightMd` | 44.0 | Medium button (Default) |
| `AppSizes.buttonHeightLg` | 52.0 | Large button |
| `AppSizes.buttonHeightXl` | 56.0 | Extra large button |
| **Inputs** | | |
| `AppSizes.inputHeight` | 56.0 | Standard text field |
| `AppSizes.inputHeightCompact` | 48.0 | Compact text field |
| **Navigation** | | |
| `AppSizes.appBarHeight` | 56.0 | Standard App Bar |
| `AppSizes.bottomNavHeight` | 80.0 | Bottom Navigation Bar |
| `AppSizes.tabBarHeight` | 48.0 | Tab Bar |
| **Components** | | |
| `AppSizes.fabSize` | 56.0 | Floating Action Button |
| `AppSizes.listItemHeightSingle` | 56.0 | Single-line list item |
| `AppSizes.listItemHeightDouble` | 72.0 | Two-line list item |
```

---

## 🌑 Shadows & Elevation

Use `AppShadows` for consistent depth and elevation.

```dart
import 'package:skill_tube/src/core/design_system/app_shadows.dart';

// ✅ GOOD
Container(
  decoration: BoxDecoration(
    color: context.colorScheme.surface,
    boxShadow: AppShadows.card, // Elevation 1
  ),
)

// ❌ BAD
boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black)]

| Token | Usage |
| :--- | :--- |
| `AppShadows.elevation0` | Flat surfaces (Level 0) |
| `AppShadows.elevation1` | Cards, surfaces (Level 1) |
| `AppShadows.elevation2` | App bar, headers (Level 2) |
| `AppShadows.elevation3` | Bottom sheets, modals (Level 3) |
| `AppShadows.elevation4` | Dialogs (Level 4) |
| `AppShadows.elevation5` | FAB, navigation drawer (Level 5) |
```

---

## ⏱️ Animation Durations

Use `AppDurations` for consistent motion.

```dart
import 'package:skill_tube/src/core/design_system/app_durations.dart';

// ✅ GOOD
AnimatedOpacity(
  duration: AppDurations.fast, // 150ms
  ...
)

| Token | Value | Usage |
| :--- | :--- | :--- |
| `AppDurations.fastest` | 100ms | Micro-interactions |
| `AppDurations.fast` | 150ms | Quick feedback, toggles |
| `AppDurations.normal` | 200ms | Standard animations |
| `AppDurations.medium` | 300ms | Medium transitions |
| `AppDurations.slow` | 400ms | Slower transitions |
| `AppDurations.slower` | 500ms | Complex orchestrated animations |
| `AppDurations.shimmer` | 1500ms | Loading shimmer loop |
```

---

## 📝 Text & Strings

**Rule:** No raw strings in widgets.

### Where to define?
`lib/src/core/constants/app_strings.dart`

### Usage
```dart
import 'package:skill_tube/src/core/constants/app_strings.dart';

// ✅ GOOD
Text(AppStrings.loginTitle)

// ❌ BAD
Text('Welcome Back')
```

---

## 🖼️ Icons & Assets

**Rule:** Abstract all icons. No direct `Icons.xyz` usage in widgets.

### Where to define?
`lib/src/core/constants/app_icons.dart`

### Usage
```dart
import 'package:skill_tube/src/core/constants/app_icons.dart';

// ✅ GOOD
Icon(AppIcons.back)
Icon(AppIcons.settings)

// ❌ BAD
Icon(Icons.arrow_back_ios)
```

---

## Summary Checklist for Developers

Before asking for a review, verify:
- [ ] Are all colors using `context.colorScheme` or `context.appColors`?
- [ ] Are all text styles using `context.textTheme`?
- [ ] Is all padding/spacing using `AppSpacing`?
- [ ] Are all border radii using `AppRadius`?
- [ ] Are there zero magic numbers in the layout code?
- [ ] **Are there zero raw strings?**
- [ ] **Are all icons from `AppIcons`?**