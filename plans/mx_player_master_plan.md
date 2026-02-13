# Master Plan: MX Player Enhancements for `mx_youtube_player`

This document serves as the single source of truth for the status and implementation roadmap of the "MX-Tube" player. It combines the current feature audit with the detailed technical strategy required to meet the PRD v3.0 specifications.

---

## 1. Current Status: Features Already Implemented ✅
The core gesture-based infrastructure is functional.

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
The current implementation lacks critical "Pro-learning" features defined in the PRD:
- **Missing Options:** No way to change playback speed, video quality, or toggle captions.
- **Visual Gaps:** The seek bar does not show buffered content, and there is no explicit loading indicator.
- **Gesture Incompleteness:** Pinch-to-zoom (Crop to fill) is not implemented.
- **UI Polish:** The title is static and doesn't handle overflow; no "Replay" state.
- **Hero Mode Logic:** The "Touch-Lock" rule for the Dashboard is not enforced.

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
- **Hero Mode (Touch-Lock):** Disable all gestures except "Full Screen" when in the Dashboard feed.

---

## 4. Unified Implementation Plan 🛠️

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
2.  **Touch-Lock Implementation:** Add an `isHeroMode` flag. If true, use an `AbsorbPointer` or conditional logic to ignore gestures on the video body.

---

## 5. Success Criteria
- [ ] User can change playback speed to 1.5x via HUD.
- [ ] User can "Pinch to Fill" the screen in landscape mode.
- [ ] The seek bar shows a grey line indicating how much video is buffered.
- [ ] The Hero player on the Dashboard does not seek when the user accidentally swipes it while scrolling.
- [ ] A loading spinner appears if the internet connection is slow.
