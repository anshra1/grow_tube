# Video Entity Schema

> **Purpose:** Defines the data model for a saved video.
> This is the ObjectBox entity that powers the Dashboard feed, Hero Header, and progress tracking.

---

## Entity: `Video`

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `id` | `int` | Auto | 0 | ObjectBox auto-generated primary key |
| `youtubeId` | `String` | ✅ | — | YouTube video ID (11 chars). **Unique index.** |
| `title` | `String` | ✅ | — | Video title fetched via `youtube_explode_dart` |
| `channelName` | `String` | ✅ | — | Channel/author name |
| `thumbnailUrl` | `String` | ✅ | — | URL to the video thumbnail |
| `durationSeconds` | `int` | ✅ | — | Total video duration in seconds |
| `lastWatchedPositionSeconds` | `int` | ✅ | `0` | Last watched position in seconds. Reset to `0` when >95% watched (see PRD §6.6) |
| `addedAt` | `DateTime` | ✅ | `DateTime.now()` | When the video was added to the library |
| `lastPlayedAt` | `DateTime?` | ❌ | `null` | When the video was last played. `null` = never played. Used by Hero Header fallback logic (PRD §3.1) |

---

## Indexes

| Index | Fields | Type | Purpose |
|-------|--------|------|---------|
| Primary | `id` | Auto-increment | ObjectBox default |
| Unique | `youtubeId` | Unique | Prevent duplicate videos |

---

## Derived / Computed Properties

These are **not stored** in the database but computed at read time:

| Property | Logic | Used By |
|----------|-------|---------|
| `progressPercent` | `lastWatchedPositionSeconds / durationSeconds` | Feed card progress bar, Hero progress bar |
| `isCompleted` | `progressPercent > 0.95` | Completion reset logic (PRD §6.6) |
| `hasBeenPlayed` | `lastPlayedAt != null` | Hero Header badge ("Play" vs "Resume") |

---

## Rules

1. **On Add:** `youtubeId` must be unique. If the user tries to add a duplicate, show a toast: *"This video is already in your library."*
2. **On Delete:** Remove the entity **and** all associated data (the entity itself contains all watch history).
3. **On >95% Completion:** Set `lastWatchedPositionSeconds = 0`. The next open starts from the beginning.
4. **On Duration Mismatch:** If `lastWatchedPositionSeconds > durationSeconds`, reset to `0`.
5. **Hero Selection:** Query `ORDER BY lastPlayedAt DESC LIMIT 1`. If no result (all `null`), fall back to `ORDER BY addedAt DESC LIMIT 1`.

---

## ObjectBox Annotation (Implementation Reference)

```dart
@Entity()
class VideoEntity {
  @Id()
  int id = 0;

  @Unique()
  String youtubeId;

  String title;
  String channelName;
  String thumbnailUrl;
  int durationSeconds;
  int lastWatchedPositionSeconds;

  @Property(type: PropertyType.dateNano)
  DateTime addedAt;

  @Property(type: PropertyType.dateNano)
  DateTime? lastPlayedAt;
}
```

> **Note:** This is a Data Layer model (`VideoModel`). The Domain Entity (`Video`) will mirror these fields but without ObjectBox annotations. See `system_patterns.md` §2-3.
