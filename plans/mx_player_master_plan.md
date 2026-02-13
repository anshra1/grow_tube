# Master Plan: MX Player Enhancements (v2 - Post-Audit)

This plan has been revised following the "Antigravity" Audit Report (2026-02-13) to address the integration gap between the `mx_youtube_player` package and the main SkillTube application.

---

## 1. Executive Summary: The Integration Gap
The current codebase has a functional prototype player in `package/mx_youtube_player`, but the main app features (`Dashboard`, `Library`) currently use static image placeholders. This plan establishes a "Phase 0" to bridge this gap before implementing pro-learning features.

---

## 2. Phase 0: Baseline Integration & Infrastructure
**Goal:** Get the player on screen and make it dynamic.

1.  **Full-Screen Route:** 
    - Create `PlayerPage` in `lib/src/features/player/presentation/screens`.
    - Register `/player/:videoId` route in `go_router`.
2.  **Dynamic HUD Refactor:** 
    - Update `MxPlayerOverlay` to accept `title` and `channelName` as parameters instead of hardcoded placeholders.
3.  **State Externalization:** 
    - Move gesture handling, HUD timers, and overlay state from `MxPlayerOverlay` (StatefulWidget) to a dedicated `MxPlayerController` or `Cubit`.
4.  **Dashboard Inline Playback:**
    - Replace the static image in `DashboardHero` with the `MxPlayer` widget.
    - **Technical Risk:** Manage gesture competition between the `WebView` and `SliverList` scrolling.

---

## 3. Phase 1: HUD Options & Loading Logic
**Goal:** Implement professional controls and feedback.

1.  **Three-Dot Options Menu:**
    - **Playback Speed:** 0.25x to 2.0x selector.
    - **Quality Selector:** Manual resolution switching.
    - **Captions:** Toggle for CC tracks.
2.  **Buffering UI:** 
    - Add a `StreamBuilder` listening to `playerStateStream`.
    - Display a `CircularProgressIndicator` overlay when state is `buffering`.

---

## 4. Phase 2: Visual Polish & Progress
**Goal:** Match MX Player's visual standards.

1.  **Buffered Seek Bar:**
    - Implement a custom seek bar that shows the `buffered` percentage (semi-transparent grey) behind the `Slider`.
2.  **Marquee Title:** 
    - Implement a scrolling marquee for long video titles in the top bar.
3.  **Replay Logic:**
    - Detect `PlayerState.ended`.
    - Switch center icon to `Icons.replay`.

---

## 5. Phase 3: Advanced Gestures & Touch-Lock
**Goal:** Finalize specialized learning interactions.

1.  **Pinch-to-Zoom:** 
    - Implement `onScaleUpdate` to toggle between `BoxFit.contain` and `BoxFit.cover`.
2.  **Hero Mode (Touch-Lock):**
    - Enforce the "Lock" rule: When playing inline in the Dashboard Hero, ignore all swipes/taps on the video body. Only the "Full Screen" icon remains interactive to prevent accidental seeking while scrolling the feed.

---

## 6. Success Criteria
- [x] **Audit Passed:** Plan acknowledges missing `PlayerPage`.
- [ ] User can navigate from Dashboard to Full-Screen Player.
- [ ] Dashboard Hero plays video inline.
- [ ] Playback speed can be adjusted via HUD.
- [ ] Seek bar visualizes buffered content.
- [ ] Hero player body is "touch-locked" during scroll.
