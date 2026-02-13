# Omni Video Player Integration Plan

This plan outlines the steps to integrate `omni_video_player` into the `grow_tube` project, replacing the existing `mx_youtube_player` implementation.

## Goal
Replace the custom `mx_youtube_player` package with the `omni_video_player` package to provide a more robust and feature-rich video playback experience, including native fullscreen support and better handling of YouTube sources.

## User Review Required
> [!IMPORTANT]
> This change involves replacing the core video player component.
> Existing custom UI in `MxPlayerOverlay` will be replaced by `omni_video_player`'s built-in UI or a simplified customization.
> We will need to verify that `omni_video_player` supports all required features (e.g., seeking, quality selection, playback speed) which are listed as supported in its documentation.

## Proposed Changes

### 1. Dependencies
- **Action**: Add `omni_video_player` to `grow_tube/pubspec.yaml`.
- **Action**: Remove `mx_youtube_player` from `grow_tube/pubspec.yaml`.
- **Action**: Run `flutter pub get`.

### 2. Dashboard Hero (`dashboard_hero.dart`)
- **File**: `lib/src/features/library/presentation/pages/dashboard/widgets/dashboard_hero.dart`
- **Action**: Replace `MxInlinePlayer` usage with `OmniVideoPlayer`.
- **Details**:
    - Remove `YoutubePlayerController` initialization.
    - Use `OmniVideoPlayer` with `VideoSourceConfiguration.youtube`.
    - Pass the video URL constructed from the video ID (e.g., `https://www.youtube.com/watch?v=$videoId`).
    - Handle aspect ratio (16:9) if not automatically handled.

### 3. Player Page (`player_page.dart`)
- **File**: `lib/src/features/player/presentation/screens/player_page.dart`
- **Action**: Replace `MxLandscapePlayer` usage with `OmniVideoPlayer`.
- **Details**:
    - Remove `YoutubePlayerController` logic.
    - Implement `OmniVideoPlayer` similarly to `DashboardHero` but potentially with `autoPlay: true` or specific valid fullscreen configuration.
    - Since `omni_video_player` handles fullscreen natively, we might simply need to provide the player widget.
    - Check if we need to enforce landscape orientation manually or if the player handles it.

### 4. Cleanup
- **Action**: Delete `package/mx_youtube_player` directory if it is no longer referenced.
- **Action**: Remove `mx_youtube_player` from `grow_tube/pubspec.yaml` workspace configuration if applicable.

## Verification Plan

### Automated Tests
- Build the app to ensure no compilation errors.
- Run existing tests (if any) that might be affected (though UI tests for players are rare).

### Manual Verification
1.  **Dashboard Player**:
    - Launch the app.
    - Check if the video in the "Dashboard Hero" section loads and plays.
    - Verify controls (play/pause).
2.  **Fullscreen Player**:
    - Tap the fullscreen button or the video in Dashboard to open `PlayerPage`.
    - Verify the video loads and plays in landscape/fullscreen mode.
    - Test seeking, volume control, and playback speed.
    - Test minimizing/exiting fullscreen.
3.  **YouTube Source**:
    - Verify that YouTube videos (the primary content) load correctly using `omni_video_player`'s extraction.

