# Plan: MX Player Enhancements for `mx_youtube_player`

This document outlines the problem, solution, and detailed implementation plan for bringing the `mx_youtube_player` package in line with the Product Requirements Document (PRD v3.0).

---

## 1. Problem Statement

The current implementation of `MxPlayerOverlay` and `MxPlayerScaffold` provides basic YouTube playback and core gestures (Volume, Brightness, Seek), but lacks several critical features defined in the PRD for a "Pro-learning" experience:
- **Missing Options:** No way to change playback speed, video quality, or toggle captions.
- **Visual Gaps:** The seek bar does not show buffered content, and there is no explicit loading/buffering indicator.
- **Gesture Incompleteness:** Pinch-to-zoom (Crop to fill) is not implemented.
- **UI Polish:** The title is static and doesn't handle overflow gracefully (needs marquee).
- **Hero Mode Logic:** The "Touch-Lock" rule for the Dashboard Hero player is not yet implemented.

---

## 2. Solution Overview

We will enhance the `mx_youtube_player` package by:
1.  **Expanding the HUD:** Adding a "Three-dot" options menu and a buffered progress bar.
2.  **Improving Gestures:** Implementing scale-based zoom and refining the touch-lock mechanism for Hero mode.
3.  **Refining UX:** Adding buffering indicators and marquee titles to ensure a professional feel.

---

## 3. Detailed Implementation Plan

### Phase 1: HUD & Options Menu (Control Logic)
- **Playback Options:** Add a `PopupMenuButton` in the top bar.
    - **Speed:** Options from 0.25x to 2.0x using `controller.setPlaybackRate`.
    - **Quality:** Options using `controller.setPlaybackQuality`.
    - **Captions:** Toggle using `controller.toggleCaptions`.
- **Loading Indicator:** Use a `StreamBuilder` on `controller.playerStateStream`. Show a `CircularProgressIndicator` when the state is `buffering`.
- **Marquee Title:** Implement a scrolling title for long video names.

### Phase 2: Advanced Gestures & Aspect Ratio
- **Pinch-to-Zoom:**
    - Add a `BoxFit` state (default: `BoxFit.contain`).
    - Use `onScaleUpdate` in `GestureDetector`.
    - **Pinch Out:** Switch to `BoxFit.cover`.
    - **Pinch In:** Switch to `BoxFit.contain`.
- **Hero Mode (Touch-Lock):**
    - Add an `isHeroMode` boolean to `MxPlayerOverlay`.
    - If `true`, disable gestures on the video body, only allowing the "Full Screen" icon to trigger navigation.

### Phase 3: Visual Polish & Seek Bar
- **Buffered Seek Bar:**
    - Replace `Slider` with a custom painter or a stacked widget.
    - Draw a semi-transparent bar behind the thumb reflecting the `buffered` percentage from `YoutubeVideoState`.
- **Replay Logic:**
    - Detect `PlayerState.ended`.
    - Change center play icon to `Icons.replay`.
    - Seek to 0 on tap.

---

## 4. Success Criteria
- [ ] User can change playback speed to 1.5x via HUD.
- [ ] User can "Pinch to Fill" the screen in landscape mode.
- [ ] The seek bar shows a grey line indicating how much video is buffered.
- [ ] The Hero player on the Dashboard does not seek when the user accidentally swipes it while scrolling.
