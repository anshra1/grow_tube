# youtube_explode_dart — AI Reference

> **Package**: `youtube_explode_dart: ^2.3.5` (project version)
> **Purpose**: Query YouTube metadata (videos, playlists, channels) and download streams / closed captions **without an API key**.
> **How it works**: Parses raw page content + reverse-engineered AJAX requests. No official API, no quotas.

---

## Setup

```yaml
# pubspec.yaml
dependencies:
  youtube_explode_dart: ^2.3.5
```

```dart
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
```

### Entry Point

```dart
final yt = YoutubeExplode();
// ... use yt ...
yt.close(); // REQUIRED — closes the internal http client, prevents process hang.
```

> **⚠️ Always call `yt.close()`** when done. Failing to close will halt the Dart process.

---

## Core APIs

### 1. Video Metadata — `yt.videos`

```dart
// Accepts: video URL string, video ID string, or VideoId instance.
final Video video = await yt.videos.get('https://youtube.com/watch?v=Dpp1sIL1m5Q');

video.title;      // String  — "Scamazon Prime"
video.author;     // String  — "Jim Browning"
video.duration;   // Duration — 0:19:48.000000
```

#### Related Videos

```dart
final RelatedVideosList? relatedVideos = await yt.videos.getRelatedVideos(video);
// Returns null if none found.

// Pagination:
final RelatedVideosList? nextPage = await relatedVideos?.nextPage();
// Returns null when exhausted.
```

---

### 2. Streams — `yt.videos.streams`

#### Stream Categories

| Category | Contains | Quality Limit |
|---|---|---|
| **Muxed** (`manifest.muxed`) | Video + Audio | **≤ 360p30** |
| **Audio-only** (`manifest.audioOnly`) | Audio only | No limit |
| **Video-only** (`manifest.videoOnly`) | Video only | No limit |
| **HLS** (`manifest.hls`) | m3u8 streams | Varies |

> **Important**: Muxed streams max out at 360p. For higher quality, download audio-only + video-only separately and mux with FFmpeg.

#### Get Stream Manifest

```dart
final StreamManifest manifest = await yt.videos.streams.getManifest('VIDEO_ID');

// Optionally specify YouTube clients (their streams are merged):
final manifest = await yt.videos.streams.getManifest(
  'VIDEO_ID',
  ytClients: [
    YoutubeApiClient.ios,
    YoutubeApiClient.androidVr,
    // Also available: YoutubeApiClient.safari, etc.
  ],
);
```

#### Filter Streams

```dart
// Highest bitrate audio-only stream
final StreamInfo audioStream = manifest.audioOnly.withHighestBitrate();

// Video-only streams filtered by container
final Iterable<VideoOnlyStreamInfo> mp4Only =
    manifest.videoOnly.where((e) => e.container == StreamContainer.mp4);

// Highest quality muxed stream (capped at 360p)
final MuxedStreamInfo muxedStream = manifest.muxed.withHighestVideoQuality();

// HLS streams
final List<HlsStreamInfo> hlsStreams = manifest.hls;
```

#### Download a Stream

```dart
final Stream<List<int>> byteStream = yt.videos.streams.get(streamInfo);

// Write to file:
final file = File('output.mp4');
final fileStream = file.openWrite();
await byteStream.pipe(fileStream);
await fileStream.flush();
await fileStream.close();
```

#### Direct URL Access

```dart
// Each StreamInfo exposes a direct URL for external players:
final Uri streamUrl = streamInfo.url;
```

---

### 3. Playlists — `yt.playlists`

```dart
final Playlist playlist = await yt.playlists.get('PLAYLIST_ID_OR_URL');

playlist.title;   // String
playlist.author;  // String

// Iterate all videos (async stream):
await for (final video in yt.playlists.getVideos(playlist.id)) {
  video.title;
  video.author;
}

// Get first N videos:
final List<Video> first20 = await yt.playlists.getVideos(playlist.id).take(20).toList();
```

---

### 4. Closed Captions — `yt.videos.closedCaptions`

```dart
final ClosedCaptionManifest trackManifest =
    await yt.videos.closedCaptions.getManifest('VIDEO_ID');

final ClosedCaptionTrackInfo? trackInfo = trackManifest.getByLanguage('en');

if (trackInfo != null) {
  final ClosedCaptionTrack track = await yt.videos.closedCaptions.get(trackInfo);

  // Get caption at a specific time:
  final ClosedCaption? caption = track.getByTime(Duration(seconds: 61));
  final String? text = caption?.text; // "And the game was afoot."
}
```

---

### 5. Comments — `yt.videos.comments`

```dart
// Returns a list-like object with .nextPage() for pagination.
final CommentsList? comments = await yt.videos.comments.getComments(video);
// Returns null when no more comments.

final CommentsList? nextPage = await comments?.nextPage();

// Fetch replies for a specific comment:
final CommentsList? replies = await yt.videos.comments.getReplies(comment);
```

---

### 6. Search — `yt.search`

```dart
final SearchList results = await yt.search.search('search query');
// results behaves like a List<Video>.

// Pagination:
final SearchList? nextPage = await results.nextPage();
```

---

## Signature Solver (Advanced)

Some YouTube clients require JS challenge completion. Requires a JS runtime (Deno).

```dart
import 'package:youtube_explode_dart/solvers.dart';

final solver = await DenoEJSSolver.init();
final yt = YoutubeExplode(jsSolver: solver);
```

> **Note**: Only Deno runtime is currently implemented. Not needed for most use cases.

---

## Troubleshooting / Logging

```dart
import 'package:logging/logging.dart';

// Place before any YoutubeExplode code:
Logger.root.level = Level.FINER;
Logger.root.onRecord.listen((e) {
  print(e);
  if (e.error != null) {
    print(e.error);
    print(e.stackTrace);
  }
});
```

---

## Quick Reference Cheat Sheet

| Task | Code |
|---|---|
| Create client | `final yt = YoutubeExplode();` |
| Get video info | `await yt.videos.get(idOrUrl)` |
| Get stream manifest | `await yt.videos.streams.getManifest(id)` |
| Best audio stream | `manifest.audioOnly.withHighestBitrate()` |
| Download stream bytes | `yt.videos.streams.get(streamInfo)` |
| Get stream URL | `streamInfo.url` |
| Get playlist videos | `yt.playlists.getVideos(playlistId)` |
| Get captions | `await yt.videos.closedCaptions.getManifest(id)` |
| Get comments | `await yt.videos.comments.getComments(video)` |
| Search | `await yt.search.search('query')` |
| Related videos | `await yt.videos.getRelatedVideos(video)` |
| Close client | `yt.close()` |