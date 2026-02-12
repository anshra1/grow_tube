# Solearium UI Engineering Standards

> **Status:** Mandatory
> **Target:** Production Readiness
> **Scope:** All Flutter UI Components

This document defines the strict engineering standards required to merge UI code into the production branch. These rules ensure performance, responsiveness, and code quality.

---

## 📱 I. Layout & Responsiveness

### 1. The Safe Area Mandate
**Rule:** All screens must handle device notches and home indicators.
- **Why?** Content clipped by the iPhone "notch" or Android camera cutout looks amateur.
- **Solution:** Wrap the body of your Scaffold in `SafeArea`, or manually apply `MediaQuery.paddingOf(context)` if you need edge-to-edge content.

### 2. The "Fluid Text" Rule
**Rule:** Never assume text fits on one line.
- **Why?** Users with large accessibility font sizes or long languages will cause RenderFlex overflows.
- **Solution:**
    - Wrap text in `Flexible` or `Expanded` within Rows/Columns.
    - Use `maxLines` and `overflow: TextOverflow.ellipsis` where specific height is required.

### 3. The Adaptive Layout Rule
**Rule:** Do not use fixed screen dimensions (e.g., `if (width > 375)`).
- **Why?** Fails on foldables, tablets, and split-screen modes.
- **Solution:** Use `LayoutBuilder` for component-level responsiveness or standard Breakpoints (compact, medium, expanded) for page-level logic.

### 4. The Keyboard Awareness Rule
**Rule:** Input forms must handle the software keyboard gracefully.
- **Why?** The keyboard often obscures the submit button or active input field.
- **Solution:**
    - Wrap forms in `SingleChildScrollView` or `CustomScrollView`.
    - Verify `resizeToAvoidBottomInset` behavior in Scaffold.
    - Implement "Tap outside to dismiss" functionality.

---

## ⚡ II. Performance & Optimization

### 5. The const Imperative
**Rule:** Use `const` constructors wherever possible.
- **Why?** `const` widgets are canonicalized and never rebuild. This effectively removes them from the widget tree rebuild cycle, drastically improving FPS.
- **Solution:** Enable the `prefer_const_constructors` lint rule and auto-fix on save.

### 6. The Pure Build Method
**Rule:** Never perform heavy logic, HTTP calls, or complex formatting inside the `build()` method.
- **Why?** `build()` can be called 60 times per second. Blocking it causes "jank" (stutter).
- **Solution:**
    - Move logic to Bloc/Provider/Controller.
    - Move one-time formatting to `initState` or memoized getters.

### 7. The List Optimization Rule
**Rule:** Never use `SingleChildScrollView` + `Column` for long lists.
- **Why?** It renders every item instantly, causing massive memory spikes and lag.
- **Solution:** Use `ListView.builder` or `CustomScrollView` + `SliverList`. This lazily renders only the items currently on screen.

### 8. Smart Image Caching
**Rule:** Never use `Image.network` for recurring images.
- **Why?** It redownloads the image on every scroll/rebuild, wasting data and battery.
- **Solution:** Use `CachedNetworkImage` with proper placeholders.

---

## ♿ III. Accessibility & UX Quality

### 9. The 48dp Touch Target Rule
**Rule:** All interactive elements must have a hit-test area of at least 48x48dp.
- **Why?** Prevents frustration for users with larger fingers or motor impairments.
- **Solution:** Use `IconButton` (built-in 48dp) or wrap smaller widgets in `InkWell`/`GestureDetector` with `behavior: HitTestBehavior.translucent` and adequate padding.

### 10. The "No Dead States" Rule
**Rule:** A UI screen must handle all 3 data states: Loading, Error, and Empty.
- **Why?** A blank white screen while data loads looks broken.
- **Solution:**
    - **Loading:** Use Shimmer effects (skeleton loaders), not just spinners.
    - **Error:** Show a friendly message with a "Retry" button.
    - **Empty:** Show a specific illustration/text when a list has 0 items.

### 11. Widget Extraction over Helper Methods
**Rule:** Use separate Widget classes instead of helper methods to split up UI.
- **Why?** `_buildHeader()` helper methods rebuild every time the parent rebuilds. Separated `HeaderWidget()` classes can be `const` and skip rebuilds independently.

**Solution:**

```dart
// ❌ BAD
Widget _buildHeader() { 
  return Text('Header');
}

// ✅ GOOD
class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text('Header');
  }
}
```

---

## 🧭 IV. Navigation & Routing

### 12. The Back Button Contract
**Rule:** Every screen must handle the system back button and gesture correctly.
- **Why?** Android's hardware/gesture back and iOS swipe-back can leave the app in undefined states if not handled.
- **Solution:**
    - Use `PopScope` (replaces deprecated `WillPopScope`) to intercept back navigation when needed (e.g., unsaved forms).
    - Never assume `Navigator.pop` is the only way a user leaves a screen.

### 13. The Double-Tap Guard
**Rule:** Prevent duplicate navigation on rapid taps.
- **Why?** Users can tap a button twice before navigation completes, pushing the same route twice.
- **Solution:**
    - Debounce navigation actions or disable the button after the first tap.
    - Use a `_isNavigating` flag or a throttle utility.

### 14. The Deep Link Readiness Rule
**Rule:** Every named route must be navigable from a cold start.
- **Why?** Push notifications and dynamic links land users on specific screens. If the screen assumes prior navigation state, it crashes.
- **Solution:**
    - Screens must fetch their own data from route arguments, never rely on inherited state from a previous screen.
    - Use route guards to redirect unauthenticated users.

### 15. The Hero Animation Safety Rule
**Rule:** Hero tags must be globally unique per visible screen.
- **Why?** Duplicate hero tags cause runtime assertions and visual glitches.
- **Solution:** Use a combination of entity type + unique ID (e.g., `hero-video-$videoId`).

---

## 🔄 V. State Management & Rebuilds

### 16. The Selective Rebuild Rule
**Rule:** Always use `buildWhen` in `BlocBuilder` and `listenWhen` in `BlocListener`.
- **Why?** Without these, the widget rebuilds on every single state emission, even if nothing relevant changed.
- **Solution:**
    ```dart
    // ✅ GOOD
    BlocBuilder<VideoBloc, VideoState>(
      buildWhen: (previous, current) =>
          previous.videos != current.videos,
      builder: (context, state) { ... },
    )
    ```

### 17. The Granular Bloc Scope Rule
**Rule:** Provide Blocs at the lowest necessary level in the widget tree.
- **Why?** A Bloc provided at the root causes every descendant to be eligible for rebuild, even unrelated screens.
- **Solution:** Provide page-specific Blocs via `BlocProvider` at the page level, not `MaterialApp`.

### 18. The No-setState-for-Shared-State Rule
**Rule:** Do not use `setState` for state that multiple widgets need.
- **Why?** `setState` rebuilds the entire `StatefulWidget`. If siblings need the same data, you end up lifting state and rebuilding everything.
- **Solution:** Use Bloc/Cubit for shared state. Reserve `setState` only for truly local, ephemeral UI state (e.g., a toggle animation).

### 19. The Stream Subscription Cleanup Rule
**Rule:** Every `StreamSubscription` must be cancelled in `dispose()`.
- **Why?** Uncancelled subscriptions cause memory leaks and callbacks firing on disposed widgets.
- **Solution:**
    - Call `subscription.cancel()` in `dispose()`.
    - Prefer `BlocListener` (auto-manages lifecycle) over manual stream listening.

---

## 🎨 VI. Theming & Styling

### 20. The No Hardcoded Colors Rule
**Rule:** Never use raw `Color(0xFF...)` or `Colors.blue` directly in widget code.
- **Why?** Hardcoded colors break dark mode, make rebranding impossible, and scatter design decisions across files.
- **Solution:** Always pull from `Theme.of(context).colorScheme` or your app's `AppColors` tokens.

### 21. The TextTheme Mandate
**Rule:** All text must use styles from `Theme.of(context).textTheme`.
- **Why?** Ensures consistent typography, respects accessibility size settings, and enables global style changes.
- **Solution:**
    ```dart
    // ❌ BAD
    Text('Hello', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))

    // ✅ GOOD
    Text('Hello', style: Theme.of(context).textTheme.titleMedium)
    ```

### 22. The Spacing Token Rule
**Rule:** Use defined spacing constants, not magic numbers.
- **Why?** `SizedBox(height: 12)` scattered everywhere is impossible to maintain. If the design system spacing changes, you hunt through hundreds of files.
- **Solution:** Define spacing tokens (e.g., `AppSpacing.sm`, `AppSpacing.md`) and use them consistently.

### 23. The Dark Mode Parity Rule
**Rule:** Every screen must be visually verified in both light and dark themes.
- **Why?** A white `Container` on a white background in light mode looks fine but becomes invisible text-on-white in dark mode if not themed.
- **Solution:** Use semantic color roles (`surface`, `onSurface`, `primary`, etc.) instead of absolute colors.

---

## 🎬 VII. Animation & Motion

### 24. The Implicit-First Animation Rule
**Rule:** Prefer implicit animations over explicit ones.
- **Why?** `AnimatedContainer`, `AnimatedOpacity`, and `AnimatedSwitcher` are simpler, less error-prone, and auto-handle interpolation.
- **Solution:** Only use `AnimationController` + `Tween` when you need fine-grained control (staggered sequences, physics-based motion).

### 25. The Controller Disposal Rule
**Rule:** Every `AnimationController` must be disposed in `dispose()`.
- **Why?** Undisposed controllers cause memory leaks and ticker exceptions ("Ticker was not disposed").
- **Solution:**
    - Always use `SingleTickerProviderStateMixin` (one controller) or `TickerProviderStateMixin` (multiple).
    - Call `_controller.dispose()` in `dispose()`.

### 26. The Motion Duration Rule
**Rule:** Keep UI transition durations between 150ms–350ms.
- **Why?** Animations shorter than 150ms feel abrupt; longer than 350ms feel sluggish.
- **Solution:** Use `Duration(milliseconds: 200)` as the default. Use 300ms+ only for page transitions or complex sequences.

### 27. The Respect Reduced Motion Rule
**Rule:** Honor the user's accessibility "reduce motion" setting.
- **Why?** Users with vestibular disorders can experience nausea from animations.
- **Solution:**
    - Check `MediaQuery.disableAnimationsOf(context)`.
    - When true, set animation durations to `Duration.zero` or use instant transitions.

---

## 🛡️ VIII. Error Handling & Feedback

### 28. The User Feedback Hierarchy Rule
**Rule:** Choose the right feedback mechanism for the severity.
- **Why?** A full-screen dialog for a minor error is annoying. A tiny SnackBar for a critical failure goes unnoticed.
- **Solution:**

| Severity | Mechanism |
|----------|-----------|
| Info / Success | SnackBar (auto-dismiss) |
| Validation Error | Inline field error text |
| Recoverable Error | SnackBar with "Retry" action |
| Critical / Blocking | Dialog with explanation |

### 29. The Optimistic UI Rule
**Rule:** Show instant visual feedback, then reconcile with the server.
- **Why?** Waiting for a network roundtrip before updating the UI makes the app feel slow.
- **Solution:**
    - Update UI immediately on user action.
    - Revert if the server returns an error.
    - Show a subtle error indicator if reconciliation fails.

### 30. The Form Validation UX Rule
**Rule:** Show field validation errors inline and only after interaction.
- **Why?** Showing all errors on page load is overwhelming. Showing errors only on submit is too late.
- **Solution:**
    - Validate on `onChanged` or `onFieldSubmitted`, not on `build`.
    - Use `AutovalidateMode.onUserInteraction`.

### 31. The Loading State Interactivity Rule
**Rule:** Disable interactive elements during async operations.
- **Why?** Users can submit a form twice if the button remains active during network calls.
- **Solution:**
    - Set button's `onPressed` to `null` while loading.
    - Show a progress indicator inside the button itself.

---

## 📲 IX. Platform & Lifecycle

### 32. The App Lifecycle Awareness Rule
**Rule:** Handle `AppLifecycleState` changes for resource-heavy screens.
- **Why?** Video players, camera feeds, and real-time connections should pause when the app goes to background to save battery and data.
- **Solution:**
    - Use `WidgetsBindingObserver` and override `didChangeAppLifecycleState`.
    - Pause media on `paused`/`inactive`, resume on `resumed`.

### 33. The Permission Request UX Rule
**Rule:** Explain why a permission is needed before requesting it.
- **Why?** Users deny permissions when the OS prompt appears without context. Once denied, recovery is painful (Settings redirect).
- **Solution:**
    - Show a custom explanation dialog first (e.g., "We need camera access to scan QR codes").
    - Only call the system permission API after the user taps "Continue".

### 34. The Orientation Lock Rule
**Rule:** Lock orientation unless the feature explicitly requires both.
- **Why?** Unexpected rotation breaks layouts that weren't designed for landscape.
- **Solution:**
    - Lock to portrait by default: `SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])`.
    - Unlock for specific features (e.g., fullscreen video player) and re-lock on exit.

### 35. The Platform-Adaptive Widget Rule
**Rule:** Use Material widgets on Android, Cupertino feel where needed on iOS.
- **Why?** Users expect platform-native behaviors (e.g., iOS-style back swipe, Android-style ripple).
- **Solution:**
    - Use `Platform.isIOS` checks sparingly for behavioral differences (date pickers, dialogs).
    - Keep the core design system unified; only adapt interaction patterns.

---

## 🧪 X. Testing & Debuggability

### 36. The Semantic Key Rule
**Rule:** All interactive and testable widgets must have a `Key`.
- **Why?** Widget tests need stable selectors. Without keys, `find.byType` can match the wrong widget when multiples exist.
- **Solution:**
    - Use `ValueKey('login_button')` or `Key('email_field')` for test-critical widgets.
    - Follow a naming convention: `feature_element` (e.g., `auth_submit_button`).

### 37. The Semantic Label Rule
**Rule:** All icons and images must have semantic labels.
- **Why?** Screen readers (TalkBack/VoiceOver) read these labels. Without them, the app is unusable for visually impaired users.
- **Solution:**
    ```dart
    // ❌ BAD
    Icon(Icons.delete)

    // ✅ GOOD
    Icon(Icons.delete, semanticLabel: 'Delete item')
    ```

### 38. The Debug Properties Rule
**Rule:** Override `debugFillProperties` in custom widgets with complex state.
- **Why?** Makes Flutter DevTools' widget inspector dramatically more useful for debugging.
- **Solution:**
    ```dart
    @override
    void debugFillProperties(DiagnosticPropertiesBuilder properties) {
      super.debugFillProperties(properties);
      properties.add(StringProperty('videoId', videoId));
      properties.add(FlagProperty('isPlaying', value: isPlaying));
    }
    ```

### 39. The Golden Test Readiness Rule
**Rule:** Wrap reusable components so they can be rendered in isolation.
- **Why?** Golden (snapshot) tests catch unintended visual regressions.
- **Solution:**
    - Components must not require deep widget tree setup (e.g., don't depend on 5 ancestor providers).
    - Provide a minimal `MaterialApp` + `Scaffold` wrapper for golden tests.
