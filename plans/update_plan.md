
# Bug Fix: Video Player Swallowed Tap (State-Driven Retry)

## 1. Overview of the Problem

When a user taps the same video card again (e.g., to retry after a freeze or network drop),
the app **completely ignores the tap**.

This happens because `LibraryVideoLoadedState` uses `Equatable`. When the same video is
re-selected, `_onVideoSelected` emits a state with identical props → `BlocBuilder` sees no
change → widget never rebuilds → `didUpdateWidget` never fires → tap is silently dropped.

---

## 2. The Solution

Add a `forcePlayTimestamp` (`int?`) field to `LibraryVideoLoadedState`. This breaks
Equatable equality on every explicit user tap, forcing a widget rebuild even when the
video ID hasn't changed.

**Key rule:** `forcePlayTimestamp` is set **only** in `_onVideoSelected` (user-initiated),
**never** in `_refreshLibrary` — so heartbeat progress saves (every 60s) and background
refreshes never accidentally interrupt playback.

---

## 3. Changes

### Step 1: `library_state.dart` — Add `forcePlayTimestamp`

```dart
final class LibraryVideoLoadedState extends LibraryState {
  const LibraryVideoLoadedState({
    required this.libraryVideos,
    this.lastPlayVideo,
    this.forcePlayTimestamp, // NEW
  });

  final List<Video> libraryVideos;
  final Video? lastPlayVideo;
  final int? forcePlayTimestamp; // NEW

  @override
  List<Object?> get props => [libraryVideos, lastPlayVideo, forcePlayTimestamp]; // NEW
}
```

---

### Step 2: `library_bloc.dart` — Set timestamp only on user tap

```dart
Future<void> _onVideoSelected(
  LibraryVideoSelectedEvent event,
  Emitter<LibraryState> emit,
) async {
  final state = this.state;
  if (state is LibraryVideoLoadedState) {
    _selectedHeroId = event.video.youtubeId;
    emit(
      LibraryVideoLoadedState(
        libraryVideos: state.libraryVideos,
        lastPlayVideo: event.video,
        forcePlayTimestamp: DateTime.now().millisecondsSinceEpoch, // NEW
      ),
    );
  }
}
```

`_refreshLibrary` emits WITHOUT `forcePlayTimestamp` (defaults to null) — background
refreshes are silent and never touch the player.

---

### Step 3: `dashboard_video_player.dart` — Smart retry in `didUpdateWidget`

```dart
@override
void didUpdateWidget(covariant DashboardVideoPlayer oldWidget) {
  super.didUpdateWidget(oldWidget);

  final videoChanged = widget.video.youtubeId != oldWidget.video.youtubeId;
  final tapRetried = widget.forcePlayTimestamp != oldWidget.forcePlayTimestamp;

  if (videoChanged) {
    // ── Normal video switch ──────────────────────────────────────────────
    _saveProgress(youtubeId: oldWidget.video.youtubeId);
    final startPos = widget.video.isCompleted
        ? 0.0
        : widget.video.lastWatchedPositionSeconds.toDouble();
    _controller?.loadVideoById(
      videoId: widget.video.youtubeId,
      startSeconds: startPos,
    );

  } else if (tapRetried) {
    // ── Same video re-tapped (retry) ─────────────────────────────────────
    _handleRetry();
  }
}

Future<void> _handleRetry() async {
  if (_controller == null) {
    // Case A: Controller was never created (device was offline at init time).
    // Reinitialize the whole controller so the player can start fresh.
    _reinitializeController();
    return;
  }

  // Case B: Controller exists but player is frozen, buffering, or stuck.
  // currentTime returns 0.0 if video never started — correct start position.
  // loadVideoById is a hard-reload that recovers from ALL broken player states.
  final pos = await _controller?.currentTime ?? 0.0;
  _controller?.loadVideoById(
    videoId: widget.video.youtubeId,
    startSeconds: pos,
  );
}
```

---

## 4. Coverage: All Scenarios

| Scenario | What triggers | Retry action |
|---|---|---|
| User taps **different** video | `videoChanged == true` | `loadVideoById` from saved position |
| User taps **same** video, player is **frozen/buffering** | `tapRetried == true`, controller exists | `loadVideoById` from `currentTime` (or 0 if never started) |
| User taps **same** video, controller is **null** (was offline at launch) | `tapRetried == true`, controller is null | `_reinitializeController()` creates fresh controller |
| **Heartbeat** progress save (every 60s) | `_refreshLibrary` emits, no timestamp change | `didUpdateWidget` sees no relevant diff → **does nothing** ✅ |
| **Add/Delete** video triggers refresh | `_refreshLibrary` emits, no timestamp change | `didUpdateWidget` sees no relevant diff → **does nothing** ✅ |

---

## 5. Files to Change

| File | Change |
|---|---|
| `lib/.../bloc/library_state.dart` | Add `forcePlayTimestamp` field + add to props |
| `lib/.../bloc/library_bloc.dart` | Set `forcePlayTimestamp` in `_onVideoSelected` only |
| `lib/.../widgets/dashboard_video_player.dart` | Add `forcePlayTimestamp` param + `_handleRetry()` method |
| `lib/.../widgets/dashboard_video_player.dart` | Update `didUpdateWidget` to handle retry branch |
