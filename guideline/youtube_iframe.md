
Sign in
Help

youtube_player_iframe 5.2.2 copy "youtube_player_iframe: ^5.2.2" to clipboard
Published 6 months ago • verified publishersarbagyastha.com.np
SDKFlutterPlatformAndroidiOSmacOSweb
656
Readme
Changelog
Example
Installing
Versions
Scores
Youtube Player iFrame

Youtube Player iFrame
Pub Web Demo BSD-3 License Top Language GitHub issues Stars

Flutter plugin for seamlessly playing or streaming YouTube videos inline using the official iFrame Player API. This package offers extensive customization by exposing nearly the full range of the iFrame Player API's features, ensuring complete flexibility and control.

Demo Screenshot

Features 🌟
Youtube Player iFrame
Youtube Player iFrame
Pub Web Demo BSD-3 License Top Language GitHub issues Stars

Flutter plugin for seamlessly playing or streaming YouTube videos inline using the official iFrame Player API. This package offers extensive customization by exposing nearly the full range of the iFrame Player API's features, ensuring complete flexibility and control.

Demo Screenshot

Features 🌟 
▶️ Inline Playback: Provides seamless inline video playback within your app.
🎬 Caption Support: Fully supports captions for enhanced accessibility.
🔑 No API Key Required: Easily integrates without the need for an API key.
🎛️ Custom Controls: Offers extensive support for custom video controls.
📊 Metadata Retrieval: Capable of retrieving detailed video metadata.
📡 Live Stream Support: Compatible with live streaming videos.
⏩ Adjustable Playback Rate: Allows users to change the playback speed.
🛠️ Custom Control Builders: Exposes builders for creating bespoke video controls.
🎵 Playlist Support: Supports both custom playlists and YouTube's native playlist feature.
📱 Fullscreen Gestures: Enables fullscreen gestures, such as swiping up or down to enter or exit fullscreen mode.
This package uses webview_flutter under-the-hood.

Setup 
See webview_flutter's doc for the requirements.

Using the player 
Start by creating a controller.

final _controller = YoutubePlayerController(
  params: YoutubePlayerParams(
    mute: false,
    showControls: true,
    showFullscreenButton: true,
  ),
);

_controller.loadVideoById(...); // Auto Play
_controller.cueVideoById(...); // Manual Play
_controller.loadPlaylist(...); // Auto Play with playlist
_controller.cuePlaylist(...); // Manual Play with playlist

// If the requirement is just to play a single video.
final _controller = YoutubePlayerController.fromVideoId(
  videoId: '<video-id>',
  autoPlay: false,
  params: const YoutubePlayerParams(showFullscreenButton: true),
);
Then the player can be used in two ways:

Using YoutubePlayer
This widget can be used when fullscreen support is not required.

YoutubePlayer(
  controller: _controller,
  aspectRatio: 16 / 9,
);

Using YoutubePlayerScaffold
This widget can be used when fullscreen support for the player is required.

YoutubePlayerScaffold(
  controller: _controller,
  aspectRatio: 16 / 9,
  builder: (context, player) {
    return Column(
      children: [
        player,
        Text('Youtube Player'),
      ],
    );
  },
)
See the example app for detailed usage.

Inherit the controller to descendant widgets 
The package provides YoutubePlayerControllerProvider.

YoutubePlayerControllerProvider(
  controller: _controller,
  child: Builder(
    builder: (context){
      // Access the controller as: 
      // `YoutubePlayerControllerProvider.of(context)` 
      // or `controller.ytController`.
    },
  ),
);
Want to customize the player? 
The package provides YoutubeValueBuilder, which can be used to create any custom controls.

For example, let's create a custom play pause button.

YoutubeValueBuilder(
   controller: _controller, // This can be omitted, if using `YoutubePlayerControllerProvider`
   builder: (context, value) {
      return IconButton(
         icon: Icon( 
           value.playerState == PlayerState.playing
             ? Icons.pause
             : Icons.play_arrow,
         ),
         onPressed: value.isReady
            ? () {
              value.playerState == PlayerState.playing
                ? context.ytController.pause()
                : context.ytController.play();
              }
            : null,
      );
   },
);
Contributors 
656
likes
140
points
121k
downloads
screenshot

Publisher
verified publishersarbagyastha.com.np

Weekly Downloads
2025.03.30 - 2026.02.22
Metadata
Flutter port of the official YouTube iFrame player API. Supports web & mobile platforms.

Homepage
Repository (GitHub)
View/report issues

Topics
#youtube #video #player #iframe #multimedia

Documentation
API reference

License
BSD-2-Clause (license)

Dependencies
flutter, meta, url_launcher, webview_flutter, webview_flutter_android, webview_flutter_wkwebview, youtube_player_iframe_web

More
Packages that depend on youtube_player_iframe

Packages that implement youtube_player_iframe

Dart languageReport packagePolicyTermsAPI TermsSecurityPrivacyHelpRSSbug report
