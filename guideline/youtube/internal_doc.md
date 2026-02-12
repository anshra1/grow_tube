# Youtube Player IFrame - AI Documentation

## 1. Package Overview
`youtube_player_iframe` is a Flutter plugin that interfaces with the official YouTube IFrame Player API. It allows for inline playback of YouTube videos on both Android and iOS (via `webview_flutter`) and the Web. It is designed to be robust, offering extensive customization and control over the player.

## 2. Core Components

### 2.1 YoutubePlayerController
The central class for controlling the player. It implements the `YoutubePlayerIFrameAPI` which mixes in several function sets: `QueueingFunctions`, `VideoInformation`, `PlayerSettings`, `PlaybackControls`, and `PlaybackStatus`.

**Initialization:**
```dart
// Default initialization
final controller = YoutubePlayerController(
  params: const YoutubePlayerParams(
    mute: false,
    showControls: true,
    showFullscreenButton: true,
  ),
);

// Initialize with a specific video
final controller = YoutubePlayerController.fromVideoId(
  videoId: 'VIDEO_ID',
  autoPlay: true, 
  params: const YoutubePlayerParams(showFullscreenButton: true),
);
```

**Key Methods & Properties:**

#### Playback Controls
- `playVideo()`: Plays the video.
- `pauseVideo()`: Pauses the video.
- `stopVideo()`: Stops loading and playback. Can leave player in various non-playing states.
- `seekTo({required double seconds, bool allowSeekAhead = false})`: Seeks to a specific time. `allowSeekAhead` triggers a new request if outside buffer.
- `nextVideo()`: Plays the next video in the playlist.
- `previousVideo()`: Plays the previous video in the playlist.
- `playVideoAt(int index)`: Plays a specific video in the playlist by index.

#### Audio Controls
- `mute()`: Mutes the player.
- `unMute()`: Unmutes the player.
- `setVolume(int volume)`: Sets volume (0-100).
- `isMuted`: Future<bool>.
- `volume`: Future<int>.

#### Video Loading (Queueing)
- `loadVideoById(...)` / `cueVideoById(...)`: Load/Cue a video by ID.
- `loadVideoByUrl(...)` / `cueVideoByUrl(...)`: Load/Cue a video by YouTube URL.
- `loadPlaylist(...)` / `cuePlaylist(...)`: Load/Cue a playlist.
  - Arguments:
    - `list`: List of IDs (video IDs or playlist ID).
    - `listType`: `ListType.playlist` (default) or `ListType.userUploads`.
    - `index`: Start index.
    - `startSeconds`: Start time.

#### Player Settings & Status
- `setSize(double width, double height)`: Sets the iframe size.
- `setPlaybackRate(double suggestedRate)`: Sets playback speed (e.g., 0.5, 1.0, 1.5, 2.0).
- `playbackRate`: Future<double>.
- `availablePlaybackRates`: Future<List<double>>.
- `setLoop({required bool loopPlaylists})`: Loops the *playlist*. For single videos, it loops the single video if it's treated as a playlist of one.
- `setShuffle({required bool shufflePlaylists})`: Shuffles the playlist.
- `videoLoadedFraction`: Future<double> (0.0 to 1.0).
- `playerState`: Future<PlayerState>.
- `currentTime`: Future<double>.

#### Video Information
- `duration`: Future<double>.
- `videoUrl`: Future<String>.
- `videoEmbedCode`: Future<String>.
- `videoData`: Future<VideoData> (Detailed info: title, author, quality, etc.).
- `playlist`: Future<List<String>> (Current list of video IDs).
- `playlistIndex`: Future<int>.

**State Streams:**
- `stream` / `value`: Provides `YoutubePlayerValue` (General state).
- `videoStateStream`: Provides `YoutubeVideoState` (High-frequency position/buffer updates).

**Cleanup:**
- `close()`: Disposes resources.

### 2.2 YoutubePlayerParams
Configuration object for the player's initial state.

**Properties:**
- `mute` (bool): Start muted.
- `showControls` (bool): Show native YouTube controls.
- `showFullscreenButton` (bool): Show the fullscreen button in the player.
- `enableCaption` (bool): Enable closed captions by default.
- `captionLanguage` (String): ISO 639-1 code.
- `loop` (bool): Loop video or playlist.
- `enableJavaScript` (bool): Required for controller interaction (default: true).
- `pointerEvents` (PointerEvents): `auto`, `initial`, `none`.
- `strictRelatedVideos` (bool): Restrict related videos to the same channel.
- `playsInline` (bool): iOS specific, plays inline instead of fullscreen.
- `color` (String): 'red' or 'white' (progress bar color).
- `interfaceLanguage` (String): Interface language code.
- `enableKeyboard` (bool): Enable keyboard shortcuts (default true for Web).

## 3. Widgets

### 3.1 YoutubePlayer
The core widget.
```dart
YoutubePlayer(
  controller: _controller,
  aspectRatio: 16 / 9,
  enableFullScreenOnVerticalDrag: true,
  gestureRecognizers: {}, // Pass gesture recognizers to the WebView
  backgroundColor: Colors.black, // WebView background color
)
```

### 3.2 YoutubePlayerScaffold
A high-level widget that manages orientation and fullscreen transitions.
- **Context Access**: It injects `YoutubePlayerControllerProvider`. Descendants can access the controller via `YoutubePlayerControllerProvider.of(context)` or `context.ytController` (if extension is imported).
- **Orientation**: Automatically handles rotation to landscape for fullscreen (configurable via `autoFullScreen`, `defaultOrientations`, `fullscreenOrientations`).
- **Builder**: `builder: (context, player) { ... }`. The `player` widget passed here is the `YoutubePlayer`.

```dart
YoutubePlayerScaffold(
  controller: _controller,
  autoFullScreen: true,
  builder: (context, player) {
    return Scaffold(
      body: Column(
        children: [player, Text('My Video')],
      ),
    );
  },
)
```

### 3.3 FullscreenYoutubePlayer
A standalone widget to launch a video directly in a fullscreen route.
```dart
// Static launch method
FullscreenYoutubePlayer.launch(
  context,
  videoId: 'VIDEO_ID',
  startSeconds: 0,
);
```

### 3.4 YoutubeValueBuilder
Builder that rebuilds on `YoutubePlayerValue` changes (State, Error, MetaData).
```dart
YoutubeValueBuilder(
  controller: _controller,
  builder: (context, value) {
    return Text(value.title);
  },
)
```

## 4. Data Structures & Enums

### YoutubePlayerValue
- `playerState` (PlayerState)
- `playbackRate` (double)
- `playbackQuality` (String)
- `error` (YoutubeError)
- `metaData` (YoutubeMetaData)
- `fullScreenOption` (FullScreenOption): Contains `enabled` (bool) and `locked` (bool).

### YoutubeMetaData
- `videoId` (String)
- `title` (String)
- `author` (String)
- `duration` (Duration)

### VideoData
Detailed video information returned by `controller.videoData`.
- `videoId` (String)
- `title` (String)
- `author` (String)
- `videoQuality` (String)
- `videoQualityFeatures` (List<Object>)

### YoutubeVideoState
- `position` (Duration)
- `loadedFraction` (double)

### Enums
- **PlayerState**: `unknown`, `unstarted` (-1), `ended` (0), `playing` (1), `paused` (2), `buffering` (3), `cued` (5).
- **YoutubeError**: `none`, `invalidParam`, `html5Error`, `videoNotFound`, `notEmbeddable`, `unknown`.
- **ListType**: `playlist`, `userUploads`.

## 5. Usage Patterns & Best Practices

1.  **Fullscreen Handling**:
    -   Prefer `YoutubePlayerScaffold`. It automatically updates `SystemChrome` (hides UI overlays) and rotates the screen.
    -   If implementing custom fullscreen, use `controller.enterFullScreen()` / `exitFullScreen()`. Listen to changes via `controller.setFullScreenListener`.
2.  **State Updates**:
    -   Use `YoutubeValueBuilder` for general UI updates (Play/Pause buttons, Title).
    -   Use `StreamBuilder(stream: controller.videoStateStream)` for progress bars and seek sliders to avoid unnecessary rebuilds of the entire UI.
3.  **Playlist Management**:
    -   Use `loadPlaylist` with `ListType.playlist` for standard YouTube playlists (pass the Playlist ID as the first item in the list).
    -   Use `loadPlaylist` with a list of Video IDs for custom queues.
    -   Use `setShuffle` and `setLoop` to control playback order.

## 6. Example: Custom Controls

```dart
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class CustomPlayer extends StatefulWidget {
  @override
  _CustomPlayerState createState() => _CustomPlayerState();
}

class _CustomPlayerState extends State<CustomPlayer> {
  final _controller = YoutubePlayerController.fromVideoId(
    videoId: 'tcodrIK2P_I',
    params: const YoutubePlayerParams(showControls: false), // Custom controls
  );

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerScaffold(
      controller: _controller,
      builder: (context, player) {
        return Scaffold(
          body: Column(
            children: [
              player,
              // Progress Bar
              StreamBuilder<YoutubeVideoState>(
                stream: _controller.videoStateStream,
                builder: (context, snapshot) {
                  final position = snapshot.data?.position.inSeconds.toDouble() ?? 0.0;
                  final duration = _controller.metadata.duration.inSeconds.toDouble();
                  return Slider(
                    value: position,
                    max: duration > 0 ? duration : 1.0,
                    onChanged: (val) {
                      _controller.seekTo(seconds: val, allowSeekAhead: true);
                    },
                  );
                },
              ),
              // Play/Pause Button
              YoutubeValueBuilder(
                builder: (context, value) {
                  return IconButton(
                    icon: Icon(
                      value.playerState == PlayerState.playing
                          ? Icons.pause
                          : Icons.play_arrow,
                    ),
                    onPressed: () {
                      value.playerState == PlayerState.playing
                          ? _controller.pauseVideo()
                          : _controller.playVideo();
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }
}
```
