import 'package:flutter/material.dart';
import 'package:mx_youtube_player/youtube_player_iframe.dart';

class HomePage extends StatefulWidget {
  final String? videoId;
  const HomePage({super.key, this.videoId});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.videoId ?? 'tcodrIK2P_I',
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: false, // Essential for custom controls
        showFullscreenButton: false,
        playsInline: true,
        strictRelatedVideos: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
