# Button System

> This project uses a custom button system. Do NOT use raw Flutter buttons.

---

## Rules

1. **Never use** `ElevatedButton`, `TextButton`, `OutlinedButton`, or `IconButton` directly
2. **Always use** `App*Button` widgets from `lib/src/core/widgets/atoms/buttons/`
3. **One `AppPrimaryButton` per screen** maximum
4. **Always provide `tooltip`** for `AppIconButton`
5. **Use `state` property** for loading/disabled, never swap child manually
6. **Use Sentence case** for button text: "Create account" not "Create Account" or "CREATE ACCOUNT"

---

## Button Selection

| Action Type | Widget | Example |
|-------------|--------|---------|
| Main action (submit, save, confirm) | `AppPrimaryButton` | "Submit order" |
| Secondary action (back, save draft) | `AppSecondaryButton` | "Save draft" |
| Tertiary/accent action | `AppTertiaryButton` | "View details" |
| Medium emphasis with border | `AppOutlineButton` | "Filter" |
| Low emphasis (cancel, dismiss) | `AppGhostButton` | "Cancel" |
| Dangerous action (delete, remove) | `AppDestructiveButton` | "Delete account" |
| OAuth login | `AppSocialButton` | Google, Apple, Facebook, GitHub |
| Text link | `AppLinkButton` | "Forgot password?" |
| Icon only | `AppIconButton` | Notification bell, settings gear |

---

## Import Path

```dart
import 'package:solearium/src/core/widgets/atoms/buttons/app_primary_button.dart';
```

---

## Properties (All Buttons)

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `onPressed` | `VoidCallback?` | required | Tap callback. Set to `null` = disabled |
| `child` | `Widget` | required | Content (usually `Text`) |
| `leading` | `Widget?` | `null` | Icon before text |
| `trailing` | `Widget?` | `null` | Icon after text |
| `state` | `AppButtonState` | `enabled` | One of: `enabled`, `disabled`, `loading` |
| `shape` | `AppButtonShape` | `pill` | One of: `pill`, `rounded`, `rectangular` |
| `padding` | `EdgeInsetsGeometry?` | `null` | Custom padding |
| `borderRadius` | `BorderRadius?` | `null` | Override shape |

---

## States

```dart
// Enabled (default)
state: AppButtonState.enabled

// Disabled - grayed out, onPressed ignored
state: AppButtonState.disabled

// Loading - shows spinner, onPressed ignored
state: AppButtonState.loading
```

---

## Shapes

| Value | Border Radius | Description |
|-------|---------------|-------------|
| `AppButtonShape.pill` | Stadium (fully rounded) | Default |
| `AppButtonShape.rounded` | 12px | Softer corners |
| `AppButtonShape.rectangular` | 4px | Sharp corners |

---

## Code Patterns

### Basic Usage

```dart
AppPrimaryButton(
  onPressed: () => handleSubmit(),
  child: const Text('Submit'),
)
```

### With Loading State

```dart
AppPrimaryButton(
  state: isLoading ? AppButtonState.loading : AppButtonState.enabled,
  onPressed: () => handleSubmit(),
  child: const Text('Submit'),
)
```

### With Leading Icon

```dart
AppPrimaryButton(
  leading: const Icon(Icons.add, size: 18),
  onPressed: () => createItem(),
  child: const Text('Create'),
)
```

### With Trailing Icon

```dart
AppSecondaryButton(
  trailing: const Icon(Icons.arrow_forward, size: 18),
  onPressed: () => goNext(),
  child: const Text('Next'),
)
```

### Disabled

```dart
AppPrimaryButton(
  state: AppButtonState.disabled,
  onPressed: () {},
  child: const Text('Submit'),
)
```

### Social Login

```dart
AppSocialButton(
  brand: SocialBrand.google, // google | apple | facebook | github
  onPressed: () => signInWithGoogle(),
)
```

### Icon Button

```dart
AppIconButton(
  icon: const Icon(Icons.notifications),
  tooltip: 'Notifications', // Required for accessibility
  onPressed: () => openNotifications(),
)
```

### Link Button

```dart
AppLinkButton(
  text: 'Forgot Password?',
  onPressed: () => resetPassword(),
)
```

---

## Correct vs Incorrect

### Button Type

```dart
// ❌ WRONG
ElevatedButton(onPressed: () {}, child: Text('Submit'))

// ✅ CORRECT  
AppPrimaryButton(onPressed: () {}, child: const Text('Submit'))
```

### Loading State

```dart
// ❌ WRONG - manual spinner
AppPrimaryButton(
  child: isLoading ? CircularProgressIndicator() : Text('Submit'),
)

// ✅ CORRECT - use state property
AppPrimaryButton(
  state: isLoading ? AppButtonState.loading : AppButtonState.enabled,
  child: const Text('Submit'),
)
```

### Cancel Button

```dart
// ❌ WRONG - primary button for cancel
AppPrimaryButton(child: Text('Cancel'))

// ✅ CORRECT - ghost button for cancel
AppGhostButton(child: const Text('Cancel'))
```

### Multiple Actions

```dart
// ❌ WRONG - two primary buttons
Row(children: [
  AppPrimaryButton(child: Text('Save')),
  AppPrimaryButton(child: Text('Cancel')),
])

// ✅ CORRECT - one primary, one ghost
Row(children: [
  AppGhostButton(child: const Text('Cancel')),
  AppPrimaryButton(child: const Text('Save')),
])
```

### Destructive Action

```dart
// ❌ WRONG - styling primary as red
AppPrimaryButton(child: Text('Delete'))

// ✅ CORRECT - use destructive button
AppDestructiveButton(
  onPressed: () => confirmDelete(),
  child: const Text('Delete'),
)
```

### Icon Button Accessibility

```dart
// ❌ WRONG - no tooltip
AppIconButton(icon: Icon(Icons.delete), onPressed: () {})

// ✅ CORRECT - has tooltip
AppIconButton(
  icon: const Icon(Icons.delete),
  tooltip: 'Delete item',
  onPressed: () {},
)
```

---

## File Structure

```
lib/src/core/widgets/atoms/buttons/
├── app_base_button.dart         # Internal only - do not use directly
├── app_button_state.dart        # AppButtonState enum
├── app_button_shape.dart        # AppButtonShape enum
├── app_primary_button.dart      # Main CTA
├── app_secondary_button.dart    # Secondary actions
├── app_tertiary_button.dart     # Tertiary actions
├── app_outline_button.dart      # Border-only
├── app_ghost_button.dart        # Minimal emphasis
├── app_destructive_button.dart  # Dangerous actions
├── app_social_button.dart       # OAuth providers
├── app_link_button.dart         # Text links
└── app_icon_button.dart         # Icon-only
```

---

## Example File

Run to see all buttons:

```bash
flutter run -t examples/app_buttons_example.dart
```
