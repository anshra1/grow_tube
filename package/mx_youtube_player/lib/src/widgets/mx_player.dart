import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mx_youtube_player/youtube_player_iframe.dart';

/// A simplified MX Player widget that combines the player and the overlay.
class MxPlayer extends StatelessWidget {
  final YoutubePlayerController controller;
  final String title;
  final String? channelName;
  final bool isHeroMode;
  final double aspectRatio;
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;

  const MxPlayer({
    super.key,
    required this.controller,
    required this.title,
    this.channelName,
    this.isHeroMode = false,
    this.aspectRatio = 16 / 9,
    this.gestureRecognizers = const <Factory<OneSequenceGestureRecognizer>>{},
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Stack(
        children: [
          YoutubePlayer(
            controller: controller,
            aspectRatio: aspectRatio,
            gestureRecognizers: gestureRecognizers,
          ),
          MxPlayerOverlay(
            controller: controller,
            title: title,
            channelName: channelName,
            isHeroMode: isHeroMode,
          ),
        ],
      ),
    );
  }
}
