import 'package:flutter/material.dart';
import 'package:mx_youtube_player/src/widgets/mx_player_overlay.dart';
import 'package:mx_youtube_player/youtube_player_iframe.dart';

class MxInlinePlayer extends StatelessWidget {
  final YoutubePlayerController controller;
  final String title;
  final String? channelName;

  const MxInlinePlayer({
    super.key,
    required this.controller,
    required this.title,
    this.channelName,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: YoutubePlayer(controller: controller, aspectRatio: 16 / 9),
          ),
        ),
        MxPlayerOverlay(
          controller: controller,
          title: title,
          channelName: channelName,
          isHeroMode: true,
        ),
      ],
    );
  }
}
