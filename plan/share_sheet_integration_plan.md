## Goal Description
Integrate the "Share Sheet" functionality into the app, allowing users to share YouTube URLs directly from other apps (like YouTube or Twitter) into `grow_tube` (`levelup_tube`). This will reuse the existing UI components and logic (from the `clipboard` feature) to validate the URL and trigger the exact same bottom sheet prompts.

## User Review Required
> [!CAUTION]
> Integrating share functionality on **iOS** requires significant native setup in Xcode (creating a Share Extension target, adding App Groups, and updating Podfiles). 
> 
> My plan below covers the full **Android** implementation. Are you okay with focusing on Android first, or do you need the iOS setup completed immediately as well?

## Open Questions
- **History Tracking**: The clipboard feature currently adds processed URLs to a `_recentUrls` history (keeping the last 3) to avoid triggering multiple times for the same copied link. I plan to use this exact same history for Shared URLs. Does this sound correct?

## Proposed Changes

---

### App Dependencies
We will add a package to handle the native bridge between Android/iOS share intents and Flutter.

#### [MODIFY] pubspec.yaml
Add `receive_sharing_intent: ^1.5.0` (or the latest stable version) to the `dependencies` block.

---

### Android Native Configuration
We need to declare to the Android OS that this app can accept shared text/URLs.

#### [MODIFY] android/app/src/main/AndroidManifest.xml
We will add the following intent filter inside the `MainActivity` `<activity>` tag:
```xml
<intent-filter>
    <action android:name="android.intent.action.SEND" />
    <category android:name="android.intent.category.DEFAULT" />
    <data android:mimeType="text/plain" />
</intent-filter>
```

---

### Application Logic - Feature Mixin
We will create a new mixin that parallels your `ClipboardMonitorMixin`, but instead of polling the clipboard on resume, it actively listens for incoming share events.

#### [NEW] lib/src/features/clipboard/mixins/share_intent_monitor_mixin.dart
```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:levelup_tube/src/features/clipboard/service/clipboard_service.dart';

mixin ShareIntentMonitorMixin<T extends StatefulWidget> on State<T> {
  final ClipboardService _clipboardService = ClipboardService();
  StreamSubscription? _intentDataStreamSubscription;

  @override
  void initState() {
    super.initState();
    _initShareIntent();
  }

  void _initShareIntent() {
    // 1. Listen for intent while app is already in memory
    _intentDataStreamSubscription = ReceiveSharingIntent.instance.getMediaStream().listen((value) {
      if (value.isNotEmpty) {
        _processSharedText(value.first.path); // Contains the shared URL/Text
      }
    });

    // 2. Listen for intent when app is opened from a closed state
    ReceiveSharingIntent.instance.getInitialMedia().then((value) {
      if (value.isNotEmpty) {
        _processSharedText(value.first.path);
        ReceiveSharingIntent.instance.reset(); // Clear the intent
      }
    });
  }

  @override
  void dispose() {
    _intentDataStreamSubscription?.cancel();
    super.dispose();
  }

  void _processSharedText(String text) {
    if (_clipboardService.hasBeenProcessed(text)) return;

    // Check for Playlist
    final playlistId = _clipboardService.extractYouTubePlaylistId(text);
    if (playlistId != null) {
      if (mounted) {
        _clipboardService.markAsProcessed(text);
        onSharePlaylistDetected(text, playlistId);
      }
      return;
    }

    // Check for Video
    final videoId = _clipboardService.extractYouTubeId(text);
    if (videoId == null) return;

    if (mounted) {
      _clipboardService.markAsProcessed(text);
      onShareUrlDetected(text, videoId);
    }
  }

  void onShareUrlDetected(String url, String videoId);
  void onSharePlaylistDetected(String url, String playlistId);
}
```

---

### Application Logic - UI Binding
We will attach this new mixin to the main screen, and tell it to trigger the exact same bottom sheet logic as the clipboard.

#### [MODIFY] lib/src/features/navigation/pages/main_scaffold.dart
We will add the new `ShareIntentMonitorMixin` to `_MainScaffoldState`:

```diff
- class _MainScaffoldState extends State<MainScaffold>
-     with WidgetsBindingObserver, ClipboardMonitorMixin {
+ class _MainScaffoldState extends State<MainScaffold>
+     with WidgetsBindingObserver, ClipboardMonitorMixin, ShareIntentMonitorMixin {

... (inside the state class) ...

+  @override
+  void onShareUrlDetected(String url, String videoId) {
+    // Route exactly to the clipboard handler
+    onClipboardUrlDetected(url, videoId);
+  }
+
+  @override
+  void onSharePlaylistDetected(String url, String playlistId) {
+    // Route exactly to the clipboard handler
+    onClipboardPlaylistDetected(url, playlistId);
+  }
```

## Verification Plan
### Automated Verification
1. Run `flutter analyze` to ensure no syntax or typing errors were introduced.
2. Verify Android build succeeds with the new manifest entries.

### Manual Verification
1. Build the app on an Android device or emulator.
2. Open YouTube or a web browser.
3. Share a YouTube Video URL.
4. Select the app from the Share Sheet.
5. Verify the app opens and immediately displays the "Add to Playlist" / "Watch Now" bottom sheet.
