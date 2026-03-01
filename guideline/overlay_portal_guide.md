# Using OverlayPortal for Fullscreen Video

`OverlayPortal` is a powerful Flutter widget designed to display a child widget above all other content on the screen (the `Overlay`). It acts as a declarative alternative to manually inserting and removing `OverlayEntry` objects.

It is particularly useful for full-screen video players because it allows the player to "escape" its constraints in the widget tree while retaining access to `InheritedWidget`s like Themes and BLoCs.

## The Core Concept

Unlike `OverlayEntry`, which physically detaches a widget from your layout structural tree, an `OverlayPortal` sits exactly where you placed it in the widget tree (e.g., inside a `Column`). 

It has three main parts:
1. **`controller`**: An `OverlayPortalController` that acts as an ON/OFF switch.
2. **`child`**: The widget that renders *inline* in the normal UI layout when the portal is OFF, or acts as a placeholder when the portal is ON.
3. **`overlayChildBuilder`**: The widget that gets beamed to the absolute top of the screen (into the `Overlay`) *only* when the controller is turned ON.

---

## Step-by-Step Implementation Guide

### 1. Initialize the Controller
Create an `OverlayPortalController` inside a `StatefulWidget`. This controller does not need to be disposed.

```dart
class _MyVideoPlayerState extends State<MyVideoPlayer> {
  final OverlayPortalController _overlayController = OverlayPortalController();

  void _toggleFullScreen() {
    // Calling toggle() triggers a rebuild of the portal
    _overlayController.toggle(); 
    
    // Manage device hardware rotation alongside the portal state
    if (_overlayController.isShowing) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }
}
```

### 2. Build the OverlayPortal
Wrap your video player logic in the `OverlayPortal`. Use the `child` property to define what should be rendered in the normal layout structural flow. 

When `_overlayController.isShowing` is true, the `overlayChildBuilder` executes, and the generated widget is drawn on top of the entire app.

```dart
@override
Widget build(BuildContext context) {
  // Use PopScope to intercept the Android hardware back button 
  // so it closes the full-screen video instead of closing the entire app.
  return PopScope(
    canPop: !_overlayController.isShowing,
    onPopInvoked: (didPop) {
      if (!didPop && _overlayController.isShowing) {
        _toggleFullScreen();
      }
    },
    child: OverlayPortal(
      controller: _overlayController,
      
      // 1. WHAT STAYS BEHIND IN THE WIDGET TREE
      // When fullscreen is active, we render an empty 16:9 box 
      // so the UI below the player doesn't collapse upwards.
      child: _overlayController.isShowing 
          ? const AspectRatio(aspectRatio: 16/9, child: SizedBox()) 
          : _buildInlinePlayer(), // Normal 16:9 video player container
          
      // 2. WHAT GETS BEAMED TO THE TOP LAYER
      // This builder is ONLY called when _overlayController.show() happens.
      overlayChildBuilder: (BuildContext context) {
        // Use Positioned.fill to force the child to stretch across the entire screen
        return Positioned.fill(
          child: Container(
            color: Colors.black,
            child: _buildFullscreenPlayer(), 
          ),
        );
      },
    ),
  );
}
```

## Why OverlayPortal over OverlayEntry?

1. **Safety**: `OverlayPortal` guarantees that the overlay child will not outlive the `OverlayPortal` itself. If the user navigates to an entirely different screen, Flutter automatically tears down the portal and its overlay child. With `OverlayEntry`, failing to call `entry.remove()` creates a massive memory/UI leak.
2. **Context Continuity**: Because `OverlayPortal` lives inside your structural tree, the `overlayChildBuilder` has access to the exact same `BuildContext` as the inline `child`. This means `BlocProvider.of(context)` works perfectly inside the full-screen player without needing to manually pass the BLoC to a new route.
3. **Simplicity**: You never have to call `Overlay.of(context).insert()`. State management is entirely driven by the reactive `OverlayPortalController`.
