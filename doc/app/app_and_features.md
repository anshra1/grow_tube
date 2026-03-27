# GrowTube — Product Requirements Document

> **Audience:** Interns, new developers, and AI assistants.
> This is the **single source of truth** for what GrowTube does and how it should behave.
> **Version:** 3.1 · **Updated:** 2026-02-19

---

## 1. Core Mission

GrowTube is a **distraction-free learning app** that layers professional video controls over YouTube educational content. It strips away entertainment noise (comments, recommendations, Shorts) and adds MX Player–style gestures plus automatic progress tracking — turning passive watching into intentional, trackable learning.

---

## 2. Architecture Overview

| Concern | Choice |
|---|---|
| Platform | Flutter (cross-platform) |
| State Management | Bloc — syncs player state and video list |
| Navigation | `go_router` — mostly single-route logic now |
| Local Storage | ObjectBox (local-first persistence) |
| Orientation | Dashboard: **portrait**. Fullscreen Player: **landscape-forced** via `SystemChrome` (seamless capability) |
| Content Structure | **Flat list only** — no folders or categories |
| Data Model | See [`doc/data/video_entity_schema.md`](../data/video_entity_schema.md) |

### 2.1 Routes

| Route | Screen | Notes |
|-------|--------|-------|
| `/` | Dashboard | Hero Player + Video Feed. Handles both inline and fullscreen modes. |
| (Removed) | Player Page | Merged into Dashboard for seamless transition. |

---

## 3. Dashboard (Home Screen — Portrait)

The home screen handles all interaction, including browsing and playback.

### 3.1 Unified Inline Player (Hero Section)

- **Location:** Sticky at the top of the screen.
- **Behavior:**
    - **Always Visible:** Displays the currently selected video (or last played).
    - **Inline Playback:** Tapping "Play" starts the video directly in the Hero section without navigation.
    - **Seamless Fullscreen:** Tapping the fullscreen icon expands the *same* player instance to cover the entire screen and rotates to landscape. No navigation or reloading occurs.
- **Touch-Lock:** Tapping the video body toggles controls.
- **Auto-Update:** When a user taps a video in the feed, it immediately loads and plays in this player.

### 3.2 Video Feed (Below Hero)

- A flat, vertical-scrolling list of every saved video.
- Each card shows: **static thumbnail**, title, channel, duration, and a **blue progress bar**.
- **Usage:** Tapping any card **updates the Hero Player** to that video and auto-plays it.
- **No Double-Play:** Only the Hero Player plays video. Feed cards are for selection.

### 3.3 Empty State
- **Condition:** When the database has **0 videos**.
- **Display:** A centered, distraction-free illustration (e.g., "Zen Mode") with the text "No videos strictly meant for learning."
- **Action:** A prominent "Add Video" button that opens the URL input modal.

---

## 4. Fullscreen Mode (The "MX-Tube" Experience)

Entered via the fullscreen button on the inline player.

- **Orientation:** Forces **landscape** mode. Hides system UI (immersive).
- **Persistence:** The player state (buffer, position) is preserved during the transition thanks to `GlobalKey` usage. **No reloading.**
- **Exit:** Tapping "back" or the shrink icon returns to the portrait Dashboard with the video continuing to play inline.

### 4.1 Gesture Zones & HUD
- **Gestures:** Brightness (left), Volume (right), Seek (horizontal).
- **HUD:** Standard controls (Play/Pause, Seek bar, Quality, Speed).

---

## 5. Progress Persistence (Hybrid Save)

> **Goal:** The user should **never** manually save or mark a video as complete. Everything is automatic.

### 5.1 Primary — Event-Based Save (Instant)
An immediate database write of `lastWatchedPosition` fires on:
1. **Pause** — user taps pause.
2. **Transition** — user toggles between inline and fullscreen.
3. **App lifecycle** — app goes to background.
4. **Dispose** — app is closed.

### 5.2 Secondary — Safety Heartbeat
- While playing, the app silently writes progress every **60 seconds**.

### 5.3 Auto-Resume
- Loading a video automatically seeks to the stored `lastWatchedPosition`.

---

## 6. Content Management

### 6.1 Adding Videos
- **`+` FAB:** Opens a modal with URL input.
- **Clipboard Monitor:** Automatically prompts to add a YouTube link if detected on the clipboard.
- **Metadata Fetch:** Uses `youtube_explode_dart`.

### 6.2 Deleting Videos
- **Long-press** on a feed card → delete confirmation.

### 6.3 Error Handling
- **Mechanism:** Toasts via `toastification`.

---

## 7. Key Rules for the Intern / AI

1.  **Single Page Architecture.** We effectively use a single screen (`DashboardPage`) for everything.
2.  **State Preservation.** The player must *never* reload when switching to fullscreen. Use `GlobalKey` and configuration caching.
3.  **Flat structure only.** No playlists or folders.
4.  **Local First.** No auth, no cloud.

---

## 8. Audit & Discussion Points

1.  **Unified Player**: [RESOLVED] Merged `PlayerPage` into `DashboardPage` for seamless transitions.
2.  **Navigation**: [RESOLVED] Removed dedicated player route.
3.  **State Management**: [RESOLVED] `LibraryBloc` handles video selection and updates the single source of truth (`heroVideo`).