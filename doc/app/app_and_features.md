# SkillTube — Product Requirements Document

> **Audience:** Interns, new developers, and AI assistants.
> This is the **single source of truth** for what SkillTube does and how it should behave.

---

## 1. Core Mission

SkillTube is a **distraction-free learning app** that layers professional video controls over YouTube educational content. It strips away entertainment noise (comments, recommendations, Shorts) and adds MX Player–style gestures plus automatic progress tracking — turning passive watching into intentional, trackable learning.

---

## 2. Architecture Overview

| Concern | Choice |
|---|---|
| Platform | Flutter (cross-platform) |
| State Management | Bloc — syncs player state across Hero, Full-Screen, and Mini-Player modes |
| Local Storage | ObjectBox (local-first persistence) |
| Orientation | Manual `SystemChrome` overrides for the player view |
| Content Structure | **Flat list only** — no folders or categories |

---

## 3. Dashboard (Home Screen — Portrait)

The home screen has two sections:

### 3.1 Hero Header (Sticky — Top)

- Always displays the **last-played video**.
- **Initial state:** static thumbnail with a prominent **"Resume" badge**.
- **Play:** tapping the Play icon starts the video inline, in portrait, inside the Hero section. The user can scroll the feed while the video plays.
- **Full-Screen:** tapping the dedicated **Full-Screen icon** transitions to Landscape Focus Mode.
- **Touch-Lock rule:** tapping the video body itself does **nothing** — prevents accidental interaction while scrolling.

### 3.2 Video Feed (Below Hero)

- A flat, vertical-scrolling list of every saved video.
- Each card shows: thumbnail, title, channel, duration, and a **blue progress bar** at the bottom reflecting watch progress from the database.
- **Tap shortcut:** tapping any card immediately launches that video in **Landscape Focus Mode**.

---

## 4. Landscape Focus Mode (The "MX-Tube" Player)

Entering full-screen forces **landscape orientation**.

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

- **Top bar:** Back button · Marquee title · Options (Speed, Quality, Captions).
- **Bottom bar:** Draggable seek bar · Current time / Duration labels.

### 4.3 Exit Path

Pressing **Back** or swiping down returns to the Dashboard. The video state is preserved in the Hero Header.

---

## 5. Mini-Player (Floating Bar)

- Swiping down from full-screen (or pressing Back) minimizes the video to a **floating bar at the bottom** of the Home Screen.
- Controls: **Play/Pause** and **Close (✕)**.

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

---

## 7. Content Management

### 7.1 Adding Videos

- **`+` button** opens a modal with a URL input field.
- **Auto-Paste:** one-tap button grabs a YouTube link from the system clipboard.
- **Metadata Fetch:** on submission, the app pulls **title, thumbnail, and duration** via the YouTube API.

### 7.2 Deleting Videos

- **Long-press** on a feed card → delete confirmation dialog.
- Removes the video **and** its watch history from the database.

---

## 8. Key Rules for the Intern / AI

1. **Flat structure only.** Do not build category, folder, or playlist logic.
2. **Touch-Lock on Hero.** The Hero player body ignores taps — full-screen is only reachable via the Full-Screen icon.
3. **Feed card = landscape shortcut.** Tapping a feed card skips portrait and goes straight to Landscape Focus Mode.
4. **State sync is mandatory.** Progress bars on Hero and feed cards must update immediately when returning from landscape.
5. **No manual save UX.** There is no "Mark as Complete" button. Persistence is entirely automatic.
6. **Summary:** *"Focus on the transition. Tapping a list card takes you to a pro-player (Landscape). Tapping the home-screen player does nothing — you use the icon to go back to landscape. The app always saves progress to the local database so the user never loses their place."*