# Toastification Package Guide for AI

> **Package Version**: 3.0.3  
> **Last Updated**: January 2026

## Quick Reference

### Installation

```yaml
# pubspec.yaml
dependencies:
  toastification: ^3.0.3
```

### Import

```dart
import 'package:toastification/toastification.dart';
```

---

## Setup Options

### Option 1: With Context (Standard)

Use `context` directly in `toastification.show()`.

### Option 2: Without Context (Recommended)

Wrap your app with `ToastificationWrapper`:

```dart
return ToastificationWrapper(
  child: MaterialApp(),
);
```

### Option 3: Using GlobalNavigatorKey

```dart
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// In MaterialApp
MaterialApp(
  navigatorKey: navigatorKey,
  // ...
)

// Show toast
toastification.show(
  overlayState: navigatorKey.currentState?.overlay,
  title: Text('Hello!'),
);
```

---

## Show Methods

### 1. `toastification.show()` - Predefined Styles

```dart
toastification.show(
  context: context, // optional with ToastificationWrapper
  type: ToastificationType.success,
  style: ToastificationStyle.flat,
  title: Text('Success!'),
  description: Text('Operation completed.'),
  autoCloseDuration: const Duration(seconds: 5),
);
```

### 2. `toastification.showCustom()` - Custom Widget

```dart
toastification.showCustom(
  context: context,
  autoCloseDuration: const Duration(seconds: 5),
  builder: (context, holder) {
    return YourCustomWidget(
      onDismiss: () => toastification.dismissById(holder.id),
    );
  },
);
```

---

## ToastificationType (5 Types)

| Type | Use Case |
|------|----------|
| `ToastificationType.success` | Operation completed successfully |
| `ToastificationType.error` | Error or failure notification |
| `ToastificationType.warning` | Warning or caution message |
| `ToastificationType.info` | Informational message |

---

## ToastificationStyle (5 Styles)

| Style | Description |
|-------|-------------|
| `ToastificationStyle.flat` | Subtle border, no background fill |
| `ToastificationStyle.fillColored` | Solid colored background |
| `ToastificationStyle.flatColored` | Colored borders and text, no fill |
| `ToastificationStyle.minimal` | Clean design with accent line |
| `ToastificationStyle.simple` | Single line text, minimal design |

---

## Common Parameters for `show()`

```dart
toastification.show(
  // === REQUIRED ===
  title: Text('Title'),

  // === CONTEXT (one required) ===
  context: context,                    // OR use ToastificationWrapper
  overlayState: navigatorKey.currentState?.overlay, // OR use GlobalNavigatorKey

  // === TYPE & STYLE ===
  type: ToastificationType.success,    // success, error, warning, info
  style: ToastificationStyle.flat,     // flat, fillColored, flatColored, minimal, simple

  // === TIMING ===
  autoCloseDuration: const Duration(seconds: 5),
  animationDuration: const Duration(milliseconds: 300),

  // === CONTENT ===
  description: Text('Description text'),
  icon: const Icon(Icons.check),
  showIcon: true,

  // === POSITIONING ===
  alignment: Alignment.topRight,       // topLeft, topCenter, topRight, bottomLeft, etc.
  direction: TextDirection.ltr,

  // === APPEARANCE ===
  primaryColor: Colors.green,
  backgroundColor: Colors.white,
  foregroundColor: Colors.black,
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  borderRadius: BorderRadius.circular(12),
  boxShadow: [
    BoxShadow(
      color: Color(0x07000000),
      blurRadius: 16,
      offset: Offset(0, 16),
    ),
  ],

  // === BEHAVIOR ===
  showProgressBar: true,
  closeOnClick: false,
  pauseOnHover: true,
  dragToClose: true,
  applyBlurEffect: true,

  // === CLOSE BUTTON ===
  closeButton: ToastCloseButton(
    showType: CloseButtonShowType.onHover, // always, onHover, none
    buttonBuilder: (context, onClose) {
      return IconButton(
        onPressed: onClose,
        icon: const Icon(Icons.close),
      );
    },
  ),

  // === CALLBACKS ===
  callbacks: ToastificationCallbacks(
    onTap: (toastItem) => print('Tapped'),
    onCloseButtonTap: (toastItem) => print('Close tapped'),
    onAutoCompleteCompleted: (toastItem) => print('Auto closed'),
    onDismissed: (toastItem) => print('Dismissed'),
  ),

  // === CUSTOM ANIMATION ===
  animationBuilder: (context, animation, alignment, child) {
    return FadeTransition(opacity: animation, child: child);
  },
);
```

---

## Dismiss Methods

```dart
// Dismiss specific notification
toastification.dismiss(notificationItem);

// Dismiss by ID
toastification.dismissById('notification_id');

// Dismiss all
toastification.dismissAll(delayForAnimation: true);

// Dismiss first/last
toastification.dismissFirst();
toastification.dismissLast();

// Find notification
final item = toastification.findToastificationItem('id');
```

---

## Global Configuration

### App-Wide Configuration

```dart
MaterialApp(
  builder: (context, child) {
    return ToastificationConfigProvider(
      config: const ToastificationConfig(
        alignment: Alignment.topRight,
        margin: EdgeInsets.fromLTRB(0, 16, 0, 110),
        itemWidth: 440,
        animationDuration: Duration(milliseconds: 500),
        blockBackgroundInteraction: false,
      ),
      child: child!,
    );
  },
);
```

### Page-Specific Configuration

```dart
ToastificationConfigProvider(
  config: const ToastificationConfig(
    alignment: Alignment.center,
    itemWidth: 400,
  ),
  child: Scaffold(body: YourPage()),
);
```

---

## Custom Toast with `showCustom()`

```dart
toastification.showCustom(
  context: context,
  autoCloseDuration: const Duration(seconds: 5),
  alignment: Alignment.topRight,
  dismissDirection: DismissDirection.none,
  animationBuilder: (context, animation, alignment, child) {
    return FadeTransition(opacity: animation, child: child);
  },
  builder: (context, holder) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Title', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text('Message', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          IconButton(
            onPressed: () => toastification.dismissById(holder.id),
            icon: Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  },
);
```

---

## AI Implementation Patterns

### Pattern 1: Success/Error Response

```dart
void showResult(bool success, String message) {
  toastification.show(
    context: context,
    type: success ? ToastificationType.success : ToastificationType.error,
    style: ToastificationStyle.fillColored,
    title: Text(success ? 'Success' : 'Error'),
    description: Text(message),
    autoCloseDuration: const Duration(seconds: 3),
    alignment: Alignment.topRight,
  );
}
```

### Pattern 2: Loading Toast with Manual Dismiss

```dart
ToastificationItem? loadingToast;

void showLoading() {
  loadingToast = toastification.show(
    context: context,
    type: ToastificationType.info,
    title: Text('Loading...'),
    autoCloseDuration: null, // Won't auto close
    showProgressBar: false,
  );
}

void hideLoading() {
  if (loadingToast != null) {
    toastification.dismiss(loadingToast!);
  }
}
```

### Pattern 3: Action Toast

```dart
toastification.showCustom(
  context: context,
  autoCloseDuration: const Duration(seconds: 5),
  builder: (context, holder) {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.blue,
      child: Row(
        children: [
          Text('Item deleted', style: TextStyle(color: Colors.white)),
          TextButton(
            onPressed: () {
              // Undo action
              toastification.dismissById(holder.id);
            },
            child: Text('UNDO', style: TextStyle(color: Colors.yellow)),
          ),
        ],
      ),
    );
  },
);
```

---

## Best Practices

1. **Always wrap with `ToastificationWrapper`** for context-free usage
2. **Use appropriate types** - `success`, `error`, `warning`, `info`
3. **Keep duration short** - 3-5 seconds for most messages
4. **Position consistently** - Pick one alignment (usually `topRight`)
5. **Use `fillColored` for important messages** - Higher visibility
6. **Use `minimal` or `simple` for subtle notifications**
7. **Set `pauseOnHover: true`** - Improves UX
8. **Use callbacks** for analytics or additional logic

---

## Quick Copy Templates

### Success Toast

```dart
toastification.show(
  context: context,
  type: ToastificationType.success,
  style: ToastificationStyle.fillColored,
  title: Text('Success'),
  description: Text('Operation completed successfully'),
  autoCloseDuration: const Duration(seconds: 3),
);
```

### Error Toast

```dart
toastification.show(
  context: context,
  type: ToastificationType.error,
  style: ToastificationStyle.fillColored,
  title: Text('Error'),
  description: Text('Something went wrong'),
  autoCloseDuration: const Duration(seconds: 5),
);
```

### Warning Toast

```dart
toastification.show(
  context: context,
  type: ToastificationType.warning,
  style: ToastificationStyle.flatColored,
  title: Text('Warning'),
  description: Text('Please check your input'),
  autoCloseDuration: const Duration(seconds: 4),
);
```

### Info Toast

```dart
toastification.show(
  context: context,
  type: ToastificationType.info,
  style: ToastificationStyle.minimal,
  title: Text('Info'),
  description: Text('New update available'),
  autoCloseDuration: const Duration(seconds: 3),
);
```
