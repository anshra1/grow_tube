# Unified Inline Player Feature Plan

## 1. Overview
The goal is to consolidate all video playback into the `DashboardVideoPlayer` widget, removing the dedicated `PlayerPage` and the associated navigation. `OmniVideoPlayer`'s built-in fullscreen capability will be used to handle immersive viewing directly from the dashboard.

### User Flow Changes:
1.  **Dashboard View**: User sees the hero video player at the top and a list of videos below.
2.  **Select Video**: Tapping any video card in the list immediately loads that video into the hero player at the top.
3.  **Watch**: The video starts playing inline.
4.  **Fullscreen**: Tapping the fullscreen button on the player rotates the device to landscape and expands the player to fill the screen, remaining on the same page.

---

## 2. Technical Implementation Plan

### Step 1: Update BLoC to handle video selection
*   **File**: `lib/src/features/library/presentation/bloc/library_event.dart`
    *   Add `LibraryVideoSelectedEvent(Video video)`.
*   **File**: `lib/src/features/library/presentation/bloc/library_bloc.dart`
    *   Handle `LibraryVideoSelectedEvent`. It should update the `heroVideo` in the state and emit `LibraryLoadedState`.
    *   Modify `LibraryVideoAddedAndPlayRequested` to simply update the hero video and refresh the list instead of emitting `LibraryPlayVideoSuccess`.

### Step 2: Update UI Components
*   **File**: `lib/src/features/library/presentation/pages/dashboard/widgets/dashboard_video_card.dart`
    *   Change `onTap` from `context.push('/player/...')` to `context.read<LibraryBloc>().add(LibraryVideoSelectedEvent(video))`.
*   **File**: `lib/src/features/library/presentation/pages/dashboard/widgets/dashboard_video_player.dart`
    *   Update `onFullScreenToggled`:
        *   Remove `context.push` navigation.
        *   If `isFullScreen` is true, set orientation to landscape.
        *   If `isFullScreen` is false, set orientation to portrait.
    *   Ensure the `OmniVideoPlayer` key or configuration reacts properly when the `video` property changes.

### Step 3: Cleanup Dashboard Logic
*   **File**: `lib/src/features/library/presentation/pages/dashboard/dashboard_page.dart`
    *   Remove the `LibraryPlayVideoSuccess` listener logic that navigates to `/player/:id`.
    *   Update `buildWhen` in `BlocConsumer` to handle the updated states.

### Step 4: Remove Dedicated Player Infrastructure
*   **File**: `lib/src/core/router/app_router.dart`
    *   Remove the `/player/:videoId` route.
*   **Files/Folders**:
    *   Delete `lib/src/features/player/` directory (after verifying no shared logic is lost).
    *   Update `lib/src/core/di/injection_container.dart` to remove `PlayerBloc` and related dependencies.

---

## 3. Success Criteria
*   Tapping a video card updates the hero player instantly.
*   Fullscreen button works correctly (rotates to landscape) without changing pages.
*   Exiting fullscreen returns the app to portrait mode on the dashboard.
*   All code related to the old `PlayerPage` is removed.
