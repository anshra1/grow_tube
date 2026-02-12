# SkillTube — Product Requirements Document

> **Audience:** Interns, new developers, and AI assistants.
> This is the **single source of truth** for what SkillTube does and how it should behave.
> **Version:** 3.0 · **Updated:** 2026-02-12

---

## 1. Core Mission

SkillTube is a **distraction-free learning app** that layers professional video controls over YouTube educational content. It strips away entertainment noise (comments, recommendations, Shorts) and adds MX Player–style gestures plus automatic progress tracking — turning passive watching into intentional, trackable learning.

---

## 2. Architecture Overview

| Concern | Choice |
|---|---|
| Platform | Flutter (cross-platform) |
| State Management | Bloc — syncs player state across Hero and Full-Screen modes |
| Navigation | `go_router` — declarative routing |
| Local Storage | ObjectBox (local-first persistence) |
| Orientation | Dashboard: **portrait-locked**. Player: **landscape-forced** via `SystemChrome` |
| Content Structure | **Flat list only** — no folders or categories |
| Data Model | See [`doc/data/video_entity_schema.md`](../data/video_entity_schema.md) |

### 2.1 Routes

| Route | Screen | Notes |
|-------|--------|-------|
| `/` | Dashboard | Hero Header + Video Feed. Portrait-locked. |
| `/player/:videoId` | Landscape Focus Mode | Forces landscape. Auto-resumes from `lastWatchedPosition`. |

---

## 3. Dashboard (Home Screen — Portrait)

The home screen has two sections:

### 3.1 Hero Header (Sticky — Top)

- Always displays the **last-played video**.
- **First-Launch Fallback:** If videos exist in the database but none have been played yet, the Hero defaults to the **most recently added video** (by `addedAt`). The badge reads **"Play"** instead of **"Resume"**.
- **Initial state:** static thumbnail with a prominent **"Resume" badge** (or **"Play"** if never watched).
- **Play:** tapping the Play icon starts the video inline, in portrait, inside the Hero section. The user can scroll the feed while the video plays.
- **Full-Screen:** tapping the dedicated **Full-Screen icon** transitions to Landscape Focus Mode.
- **Minimizing:** When returning from Landscape Mode, the video **continues playing** (or pauses) inside this Hero Header.
- **Touch-Lock rule:** tapping the video body itself does **nothing** — prevents accidental interaction while scrolling.

### 3.2 Video Feed (Below Hero)

- A flat, vertical-scrolling list of every saved video.
- Each card shows: **static thumbnail**, title, channel, duration, and a **blue progress bar** at the bottom reflecting watch progress from the database.
- **No Auto-Play.** Cards display static thumbnails only — no inline video playback in the feed. This avoids performance issues with multiple YouTube iframe players.
- **Tap shortcut:** tapping any card immediately launches that video in **Landscape Focus Mode**.

### 3.3 Empty State
- **Condition:** When the database has **0 videos**.
- **Display:** A centered, distraction-free illustration (e.g., "Zen Mode") with the text "No videos strictly meant for learning."
- **Action:** A prominent "Add Video" button that opens the URL input modal.

---

## 4. Landscape Focus Mode (The "MX-Tube" Player)

Entering full-screen forces **landscape orientation**. The Dashboard is always **portrait-locked** — only this player screen rotates.

### 4.1 Gesture Zones

| Gesture | Effect |
|---|---|
| Left half — vertical swipe | **Brightness** up/down |
| Right half — vertical swipe | **Volume** up/down |
| Horizontal swipe (anywhere) | **Seek / scrub** through timeline |
| Pinch out | **Crop to fill** (remove black bars) |
| Pinch in | **Fit to screen** (original aspect) |
| Tap blank area | **Toggle HUD** visibility |

### 4.2 HUD (Heads-Up Display)

- **Tap-to-Toggle:** Tapping blank area toggles HUD. Controls **auto-hide** after a few seconds of inactivity.
- **Center Overlay:** Large Play/Pause/Replay icon + Buffering/Loading indicator.
- **Top bar:** Back button · Marquee title · Options menu (three-dot):
    - **Quality Selector:** Auto, 1080p, 720p, 480p, 360p, etc.
    - **Playback Speed:** 0.25×, 0.5×, 0.75×, 1.0×, 1.25×, 1.5×, 1.75×, 2.0×.
    - **Captions/Subtitles:** Toggle On/Off (uses YouTube's built-in CC tracks).
- **Bottom bar:** Draggable seek bar showing current position **and buffered content** · Current time / Duration labels.

### 4.3 Advanced Features
- **Picture-in-Picture (PiP): `[DEFERRED — post-v1]`** System PiP to play video in a floating window over other apps. Requires Android API 26+. iOS support TBD. Will be specified in a separate doc when prioritized.

### 4.4 Exit Path

Pressing **Back** or swiping down returns to the Dashboard. The video state is preserved in the Hero Header.

---

## 5. Exit Transition to Hero Header
- **Behavior:** Swiping down (or Back) from full-screen does **NOT** create a bottom mini-player.
- **Target:** The video minimizes back into the **Hero Header** (Section 3.1) at the top of the feed.
- **State:** The video continues playing (or pauses) seamlessly inside the Hero container.
- **Scroll:** The Hero Header remains at the top; scrolling the feed pushes it out of view.

---

## 6. Progress Persistence (Hybrid Save)

> **Goal:** The user should **never** manually save or mark a video as complete. Everything is automatic.

### 6.1 Primary — Event-Based Save (Instant)

An immediate database write of `lastWatchedPosition` fires on:

1. **Pause** — user taps pause.
2. **Navigation** — user exits landscape or minimizes to dashboard.
3. **App lifecycle** — app goes to background (phone call, app switch).
4. **Dispose** — player widget is destroyed.

### 6.2 Secondary — Safety Heartbeat (60-second interval)

- While actively playing, the app silently writes progress every **60 seconds**.
- **Worst-case data loss:** 60 seconds (covers battery death, OS kill, crashes).

### 6.3 Auto-Resume

- On opening any video, the app queries the database for that `youtubeId`.
- If a record exists, the player **automatically seeks** to the stored `lastWatchedPosition`.

### 6.4 UI Sync

- When a user returns from landscape, **both** the Hero header and the feed card must **reactively update** their progress bars to reflect the latest position.

### 6.5 Implementation Notes

- All database writes are **asynchronous** — never block the UI thread.
- The `PositionChanged` listener feeds both the event triggers and the heartbeat timer.

### 6.6 Edge Cases & Completion Rules
- **Completion Threshold (>95%):** If a user watches more than 95% of the video, it is considered "Finished". The next time the video is opened, it starts from **0:00** (beginning).
- **Duration Mismatch:** If the stored `lastWatchedPosition` is greater than the video's current duration (e.g. video was shortened), reset to **0:00**.

---

## 7. Content Management

### 7.1 Adding Videos

- **`+` FAB (Floating Action Button):** A Material 3 FAB pinned to the bottom-right of the Dashboard. Tapping opens a modal with a URL input field. This button is **always visible** on the Dashboard (in addition to the "Add Video" button in the Empty State).
- **Auto-Paste:** one-tap button inside the modal grabs a YouTube link from the system clipboard.
- **Metadata Fetch:** on submission, the app uses `youtube_explode_dart` to pull **title, thumbnail, channel name, and duration** locally (no API key required).

### 7.2 Deleting Videos

- **Long-press** on a feed card → delete confirmation dialog.
- Removes the video **and** its watch history from the database.

### 7.3 Error Handling
- **Mechanism:** All errors are shown via **Toasts** (`toastification` package), triggered from a `BlocListener` on error states. No modal dialogs for errors.
- **Scenarios:**
    - **Invalid URL:** "Please paste a valid YouTube link."
    - **Offline:** "No internet connection. Cannot fetch video details."
    - **Video Unavailable:** "Video is private or deleted."
    - **Duplicate Video:** "This video is already in your library."

---

## 8. Key Rules for the Intern / AI

1. **Flat structure only.** Do not build category, folder, or playlist logic.
2. **Touch-Lock on Hero.** The Hero player body ignores taps — full-screen is only reachable via the Full-Screen icon.
3. **Feed card = landscape shortcut.** Tapping a feed card skips portrait and goes straight to Landscape Focus Mode.
4. **State sync is mandatory.** Progress bars on Hero and feed cards must update immediately when returning from landscape.
5. **No manual save UX.** There is no "Mark as Complete" button. Persistence is entirely automatic.
6. **Summary:** *"Focus on the transition. Tapping a list card takes you to a pro-player (Landscape). Tapping the home-screen player does nothing — you use the icon to go back to landscape. The app always saves progress to the local database so the user never loses their place."*
7. **No Authentication.** The app is strictly local-first. There is no login, signup, or cloud sync. The app opens directly to the Dashboard.

---

## 9. Audit & Discussion Points

1.  **Authentication & Onboarding**: [RESOLVED] Confirmed strictly local-first. No auth/onboarding needed.
2.  **Player Spec Contradictions**: [RESOLVED v3] Merged all details into this doc. Deleted `video_player_feature.md`.
3.  **Database Name Mismatch**: [RESOLVED] Fixed `userflow.mmd` to use "ObjectBox".
4.  **Empty State**: [RESOLVED] Added Section 3.3 defining "Zen Mode" illustration and Add Video prompt.
5.  **Error Handling**: [RESOLVED v3] Added Section 7.3 with Toasts via `BlocListener`, including duplicate video error.
6.  **Auto-Resume Edge Cases**: [RESOLVED] Added Section 6.6 defining >95% completion resets to 0:00.
7.  **Mini-Player Details**: [RESOLVED] Removed "Floating Bar". The Hero Header is the only inline player.
8.  **YouTube API**: [RESOLVED v3] Using `youtube_explode_dart` — added to `pubspec.yaml`. Removed stale `flutter_secure_storage`.
9.  **Versioning**: [RESOLVED] Updated to version 3.0.
10. **Module Mapping**: [DEFERRED] Will map once all features are defined.
11. **Cross-References**: [SKIPPED] Not needed.
12. **Flat List vs Categories**: [RESOLVED] Confirmed flat list only. No categories or playlists.
13. **Hero First-Launch**: [RESOLVED v3] Falls back to most recently added video with "Play" badge.
14. **Auto-Play Feed**: [RESOLVED v3] Removed. Static thumbnails only — avoids multi-iframe performance issues.
15. **FAB Placement**: [RESOLVED v3] Material 3 FAB on Dashboard + "Add Video" in Empty State.
16. **Data Entity Schema**: [RESOLVED v3] Created `doc/data/video_entity_schema.md`.
17. **Navigation / Routing**: [RESOLVED v3] Added §2.1 Routes table. Two screens: Dashboard (`/`) and Player (`/player/:videoId`).
18. **Orientation Lock**: [RESOLVED v3] Dashboard portrait-locked. Player landscape-forced.
19. **PiP**: [DEFERRED v3] Marked as post-v1. Core loop first.
20. **Auth Error Types**: [RESOLVED v3] Removed `AuthException`/`AuthFailure` from `error_protocol.md`.
21. **Video Error Types**: [RESOLVED v3] Added `VideoException`/`VideoFailure` to `error_protocol.md`.
22. **Duplicate Video**: [RESOLVED v3] Added to §7.3 error scenarios.