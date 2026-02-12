# Implementation Plan: MX-Tube Hybrid Player

This plan outlines the steps to build the features defined in `lib/features.md`. The implementation is divided into three phases: Core Player (MX Style), Home Feed (YouTube Style), and Advanced UX.

## Phase 1: Full Screen Player (MX Style)
**Goal:** Perfect the immersive playback experience with gestures and controls.

### 1.1 Core Gesture Controls
*   [ ] **Refine Gestures:** Remove `onDoubleTap` to ensure instant UI toggling.
*   [ ] **Volume & Brightness:** Verify existing implementation (already present in `mx_player_overlay.dart`).
*   [ ] **Pinch-to-Zoom:** Implement `InteractiveViewer` or `Transform.scale` to handle aspect ratio changes (Fit vs. Crop).

### 1.2 On-Screen Controls (HUD) UI
*   [ ] **Top Bar:**
    *   Add `Video Title` (fetch from metadata).
    *   Add `PopupMenuButton` (Three Dots) for settings.
*   [ ] **Center Overlay:**
    *   Implement `CircularProgressIndicator` for the buffering state.
    *   Refine the large Play/Pause icon animation.
*   [ ] **Bottom Bar:**
    *   **Custom Seek Bar:** Create a custom widget (or use `ProgressBar` from a package) that displays:
        *   Total Duration (Background track).
        *   Buffered Position (Secondary track).
        *   Current Position (Primary track & Thumb).
    *   **Timestamps:** Format and display `Current / Total` time.

### 1.3 Player Settings (The "Three Dots" Menu)
*   [ ] **Playback Speed:** Implement menu to set `controller.setPlaybackRate()`.
*   [ ] **Quality:** (Note: YouTube IFrame API has limited quality enforcement, but we can display options if available).
*   [ ] **Captions:** Toggle `controller.toggleCaptions()`.

## Phase 2: Home Screen (YouTube Style)
**Goal:** Create a seamless browsing experience with a mini-player.

### 2.1 Video Feed
*   [ ] **Data Source:** Create a mock list of video data (Title, Channel, Thumbnail URL, Video ID).
*   [ ] **UI Layout:** Build a `ListView` with "Card" style items.

### 2.2 Inline Auto-Play
*   [ ] **Visibility Detection:** Use `visibility_detector` or scroll listeners to find the center video.
*   [ ] **Auto-Play Logic:**
    *   Play the center video **muted**.
    *   Pause when scrolled away.

### 2.3 Mini-Player Architecture
*   [ ] **State Management:** Lift the `YoutubePlayerController` to a global/higher state (e.g., using `Provider` or `Riverpod`) so it persists between screens.
*   [ ] **Mini-Player Widget:** Create a persistent bottom widget that appears when the user leaves the full-screen player.
    *   **Expand/Collapse Animation:** Smooth transition from Mini to Full.

## Phase 3: Advanced UX
**Goal:** Add system-level integrations.

### 3.1 Picture-in-Picture (PiP)
*   [ ] **Android Integration:** Use `floating` or `pip_view` package (or platform channels) to support Android Native PiP.
*   [ ] **Trigger:** Add a PiP button to the Top Bar settings or gesture (e.g., swiping home).

## Implementation Sequence
1.  **Fix Phase 1 (Core Player):** This is the foundation. We will start by fixing `mx_player_overlay.dart`.
2.  **Build Phase 2 (Home Feed):** This makes it a real app.
3.  **Add Phase 3 (PiP):** The final polish.
