# Master Plan: MX Player Enhancements for `mx_youtube_player`

This document serves as the single source of truth for the status and implementation roadmap of the "MX-Tube" player. It combines the current feature audit with the detailed technical strategy required to meet the PRD v3.0 specifications.

---

## 1. Current Status: Features Already Implemented ✅
The core gesture-based infrastructure is functional within the `package/mx_youtube_player`.

| Feature | Description | Status |
| :--- | :--- | :--- |
| **Landscape Scaffold** | Automatically forces landscape orientation and immersive mode. | Done |
| **Brightness Control** | Vertical swipe on the left half of the screen adjusts brightness. | Done |
| **Volume Control** | Vertical swipe on the right half of the screen adjusts volume. | Done |
| **Seek/Scrub** | Horizontal swipe anywhere seeks through the timeline. | Done |
| **HUD Toggle** | Tapping a blank area toggles the visibility of controls. | Done |
| **Quick Play/Pause** | Double-tap gesture to play or pause the video. | Done |
| **Auto-Hide** | Controls automatically hide after 4 seconds of inactivity. | Done |

---

## 2. The Problem Statement
The project currently has a "Library" and "Dashboard" but lacks integration with the video player. Specifically:
- **No Player Integration:** The Dashboard Hero and Feed cards are static images; they do not yet host the `MxPlayer` widget.
- **Missing Player Screen:** There is no dedicated full-screen player page/route in the main app.
- **Missing Pro-learning Features:** No way to change playback speed, quality, or captions. No buffered progress visualization or pinch-to-zoom.

---

## 3. Detailed Features To Be Added ❌

### A. HUD Enhancements
- **Options Menu (Three-dot):**
    - **Playback Speed:** Selector for 0.25x to 2.0x.
    - **Quality Selector:** Manual resolution switching (Auto, 1080p, 720p, etc.).
    - **Captions:** Toggle for YouTube CC tracks.
- **Marquee Title:** Scrolling text for long video titles.
- **Loading Indicator:** Visual spinner when the video is buffering.

### B. Visual & Progress Polish
- **Buffered Progress:** Visualize the downloaded portion on the seek bar.
- **Replay UI:** Transition the center play button to a replay icon when the video ends.

### C. Advanced Gestures & Rules
- **Pinch-to-Zoom:** Toggle between "Crop to Fill" and "Fit to Screen".
- **Hero Mode (Touch-Lock):** Implement inline playback in Dashboard with a rule to disable all gestures except "Full Screen".

---

## 4. Unified Implementation Plan 🛠️

### Phase 0: Integration & Baseline
1.  **Dedicated Player Screen:** Create `PlayerPage` in `lib/src/features/player/presentation/screens` and set up routing via `go_router`.
2.  **Dashboard Integration:** 
    -   Implement inline playback in `DashboardHero` using `MxPlayer`.
    -   Refactor `MxPlayerOverlay` to accept dynamic titles and metadata.
3.  **Refactor Overlay State:** Move gesture and timer logic from `MxPlayerOverlay` into a dedicated controller or `Cubit` to handle growing complexity.

### Phase 1: HUD Options & Loading Logic
1.  **Options Menu:** Add a `PopupMenuButton` in the Top Bar.
2.  **Controller Sync:** Link menu actions to `controller.setPlaybackRate`, `setPlaybackQuality`, and `toggleCaptions`.
3.  **Buffering UI:** Use a `StreamBuilder` on `controller.playerStateStream` to display a center `CircularProgressIndicator` during buffering.

### Phase 2: Progress Bar & Visual Refinement
1.  **Buffered Seek Bar:** Replace standard `Slider` with a stacked widget showing `LinearProgressIndicator` (buffered) behind the `Slider`.
2.  **Marquee Title:** Implement scrolling logic for the video title.
3.  **End-of-Video State:** Detect `PlayerState.ended` to show the Replay icon and reset seek to 0 on tap.

### Phase 3: Advanced Gestures & Architectural Rules
1.  **Pinch Handling:** Implement `onScaleUpdate` in the main `GestureDetector` to toggle `BoxFit.cover` (Pinch Out) and `BoxFit.contain` (Pinch In).
2.  **Touch-Lock Implementation:** Enforce the rule where the `DashboardHero` player ignores all gestures except the "Full Screen" icon to prevent interaction conflicts during scrolling.

---

## 5. Success Criteria
- [ ] User can navigate to a full-screen player from any video card.
- [ ] Video plays inline in the Dashboard Hero section.
- [ ] User can change playback speed to 1.5x via HUD.
- [ ] User can "Pinch to Fill" the screen in landscape mode.
- [ ] The seek bar shows a grey line indicating how much video is buffered.
- [ ] The Hero player on the Dashboard does not seek when the user accidentally swipes it while scrolling.
