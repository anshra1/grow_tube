# Feature Specification: MX-Tube Hybrid Player

## 1. Home Screen (YouTube-Style Feed)
*   **Video Feed:** Vertical scrolling list of videos with thumbnails, titles, and channel names.
*   **Inline Auto-Play:** Videos automatically play **(muted)** when focused in the center of the screen, providing a seamless browsing experience.
*   **In-App Mini-Player:**
    *   When the user swipes down or presses "Back" from full screen, the video minimizes to a floating bar at the bottom.
    *   Allows browsing the feed while the video continues to play.
    *   **Controls:** Play/Pause, Close.

## 2. Full Screen Player (MX Player-Style Immersion)
This is the core hybrid mode: YouTube content with MX Player's superior gesture controls.

### Gesture Controls (The "MX" Experience)
*   **Volume Control:** Vertical swipe on the **right** half of the screen.
*   **Brightness Control:** Vertical swipe on the **left** half of the screen.
*   **Precise Seeking:** Horizontal swipe anywhere on the screen to scrub through the video timeline.
*   **Pinch-to-Zoom:**
    *   **Pinch Out:** Crop to fill (removes black bars).
    *   **Pinch In:** Fit to screen (original aspect ratio).

### On-Screen Controls (HUD)
*   **Tap-to-Toggle UI:** Tapping any blank area of the video immediately toggles the visibility of all controls (HUD). Controls also auto-hide after a few seconds of inactivity.
*   **Top Bar:**
    *   **Back Button:** Returns to Home/Mini-player.
    *   **Video Title:** Marquee text if too long.
    *   **More Options (Three Dots):**
        *   **Quality Selector:** (Auto, 1080p, 720p, 480p, etc.).
        *   **Playback Speed:** (0.25x to 2.0x).
        *   **Captions/Subtitles:** Toggle On/Off.
*   **Center Overlay:**
    *   Large Play/Pause/Replay icon (fades out during playback).
    *   Buffering/Loading indicator.
*   **Bottom Bar:**
    *   **Seek Bar (Progress Line):** Draggable slider showing current position and buffered content.
    *   **Time Stamps:** `Current Time / Total Duration`.

## 3. Advanced UX Enhancements
*   **System Picture-in-Picture (PiP):** Button to minimize the entire app and play the video in a floating Android window over *other* apps.
