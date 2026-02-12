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
