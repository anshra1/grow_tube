# Omni Player Integration Plan

**Objective:** To replace the custom `package/mx_youtube_player` with the more robust and feature-rich `omni_video_player` package. This will provide a better user experience with native fullscreen support, superior YouTube stream handling, and a clear path for future feature enhancements.

---

## 1. Pre-integration Audit & Configuration

### 1.1. Dependency Management
- **Action:** Add `omni_video_player: ^3.7.2` to `pubspec.yaml`.
- **Action:** Remove the `mx_youtube_player` dependency from `pubspec.yaml`.
- **Action:** Run `flutter pub get` to update dependencies.

### 1.2. Platform Configuration (as per `omni_video_player` docs)
- **Android (`AndroidManifest.xml`):**
    - Verify `<uses-permission android:name="android.permission.INTERNET"/>` is present.
    - Add `android:usesCleartextTraffic="true"` inside the `<application>` tag if non-https videos might be used (though not expected for YouTube).
- **iOS (`Info.plist`):**
    - Verify `NSAppTransportSecurity` is configured to allow internet access if needed for non-https sources. For YouTube (https), this should not be an issue.

---

## 2. Phase 1: Player Replacement

### 2.1. Dashboard Inline Player
- **File:** `lib/src/features/library/presentation/pages/dashboard/widgets/dashboard_hero.dart` (File path to be verified).
- **Action:**
    1. Remove the `MxInlinePlayer` widget.
    2. Remove any associated `YoutubePlayerController` logic.
    3. Implement the `OmniVideoPlayer` widget.
    4. Configure it with `VideoSourceConfiguration.youtube`, passing the video URL. Example:
       ```dart
       OmniVideoPlayer(
         sourceConfiguration: VideoSourceConfiguration.youtube(
           videoUrl: Uri.parse('https://www.youtube.com/watch?v=VIDEO_ID'),
           // The docs state 360p is the only option on iOS for muxed streams.
           // We can still prefer higher qualities for Android.
           preferredQualities: [OmniVideoQuality.high720],
         ),
       )
       ```
- **Note:** The `omni_video_player` docs mention a `forceYoutubeWebViewOnly` flag for "Made for Kids" videos. We should keep this in mind if we encounter playback issues.

### 2.2. Full-Screen Player Page
- **File:** `lib/src/features/player/presentation/screens/player_page.dart` (File path to be verified).
- **Action:**
    1. Remove the `MxLandscapePlayer` widget.
    2. Remove any associated controller logic for the old player.
    3. Implement `OmniVideoPlayer`.
    4. The `omni_video_player` handles fullscreen natively. We should ensure the transition from the dashboard to this page correctly initializes the player in fullscreen mode, potentially with `autoPlay: true`.

---

## 3. Phase 2: Cleanup and Verification

### 3.1. Code Cleanup
- **Action:** Delete the entire `package/mx_youtube_player` directory.
- **Action:** Perform a global search for "mx_youtube_player", "MxInlinePlayer", "MxLandscapePlayer", and "YoutubePlayerController" to ensure all references are removed from the codebase.

### 3.2. Manual Verification Checklist
1.  **Dashboard Playback:**
    - [ ] App loads without errors.
    - [ ] Video in the `DashboardHero` loads and plays inline.
    - [ ] Basic controls (play/pause/sound) work on the inline player.
2.  **Full-Screen Transition & Playback:**
    - [ ] Tapping the inline player's fullscreen button (or the video itself, depending on implementation) navigates to `PlayerPage`.
    - [ ] Video plays automatically in fullscreen/landscape mode.
    - [ ] All controls are functional: seek bar, play/pause, volume, playback speed, and quality selection (on Android).
3.  **Edge Cases:**
    - [ ] Test with different YouTube videos to ensure consistent playback.
    - [ ] Verify behavior on both Android and iOS to account for platform differences noted in the `omni_video_player` docs (e.g., quality selection).

---

## 4. Risks and Considerations
- **UI/UX Changes:** The UI of `omni_video_player` will be different from the custom `MxPlayerOverlay`. We may need to customize it to match the app's design system if the default look and feel is not sufficient.
- **Gesture Conflicts:** The `mx_player_master_plan` mentioned potential gesture conflicts on the dashboard. We need to verify that `omni_video_player` co-exists with the scrolling view on the dashboard.
- **"Made for Kids" videos:** As noted, these may require a special configuration (`forceYoutubeWebViewOnly: true`). We should decide how to handle this - either by forcing WebView for all or by detecting such videos if possible. For now, we'll proceed with the default behavior.
