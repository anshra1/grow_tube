# How to Use mx_youtube_player

This guide provides instructions on how to run, use, and implement your custom `mx_youtube_player` package.

## 1. Run the Example App

The quickest way to see the new MX Player style in action is to run the example app included in the project.

1.  **Open a terminal.**

2.  **Navigate to the example directory:**
    ```bash
    cd /home/ansh/mx_youtube_player/example
    ```

3.  **Run the Flutter app:**
    ```bash
    flutter run
    ```
    This will launch the example on your connected device or simulator. You will see a full-screen player with the custom gesture controls ready to use:
    -   **Vertical Drag (Right Side):** Controls Volume.
    -   **Vertical Drag (Left Side):** Controls Screen Brightness.
    -   **Horizontal Drag:** Seeks through the video.
    -   **Double Tap:** Toggles Play/Pause.

## 2. Use it in Your Own Flutter Project

To use this local version of the player in another Flutter project, you need to add it as a `path` dependency.

1.  **Open your project's `pubspec.yaml` file.**

2.  **Add the dependency:**
    Under the `dependencies:` section, add the following lines. This tells Flutter to use the package from your local directory instead of from pub.dev.

    ```yaml
    dependencies:
      flutter:
        sdk: flutter
      # ... other dependencies

      mx_youtube_player:
        path: /home/ansh/mx_youtube_player 
    ```

3.  **Get the dependencies:**
    Save the `pubspec.yaml` file and run this command in your project's terminal:
    ```bash
    flutter pub get
    ```

## 3. Basic Code Implementation

Here is a minimal example of how to use the `MxPlayerScaffold` in a Flutter screen.

1.  **Import the package** in your Dart file:
    ```dart
    import 'package:mx_youtube_player/youtube_player_iframe.dart';
    ```

2.  **Create your player widget:**
    This example creates a simple screen that launches the player. Notice that `showControls` is set to `false` in the parameters, as the `MxPlayerOverlay` now handles all user interaction.

    ```dart
    import 'package:flutter/material.dart';
    import 'package:mx_youtube_player/youtube_player_iframe.dart';

    void main() {
      runApp(const MyApp());
    }

    class MyApp extends StatelessWidget {
      const MyApp({super.key});

      @override
      Widget build(BuildContext context) {
        return const MaterialApp(
          home: PlayerScreen(),
        );
      }
    }

    class PlayerScreen extends StatefulWidget {
      const PlayerScreen({super.key});

      @override
      State<PlayerScreen> createState() => _PlayerScreenState();
    }

    class _PlayerScreenState extends State<PlayerScreen> {
      late final YoutubePlayerController _controller;

      @override
      void initState() {
        super.initState();

        // Initialize the controller with a video ID and disable default controls
        _controller = YoutubePlayerController.fromVideoId(
          videoId: 'dQw4w9WgXcQ', // Example Video ID
          autoPlay: true,
          params: const YoutubePlayerParams(
            showControls: false, // Essential for the custom overlay to work
            showFullscreenButton: false,
            playsInline: true,
          ),
        );
      }

      @override
      Widget build(BuildContext context) {
        // Use the MxPlayerScaffold for the complete MX Player experience
        return MxPlayerScaffold(
          controller: _controller,
        );
      }

      @override
      void dispose() {
        _controller.close();
        super.dispose();
      }
    }
    ```
