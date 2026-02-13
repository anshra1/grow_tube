import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mx_youtube_player/youtube_player_iframe.dart';
import 'package:skill_tube/src/core/design_system/app_radius.dart';
import 'package:skill_tube/src/core/design_system/app_shadows.dart';
import 'package:skill_tube/src/features/library/domain/entities/video.dart';

class HeroVideoPlayer extends StatefulWidget {
  final Video video;

  const HeroVideoPlayer({super.key, required this.video});

  @override
  State<HeroVideoPlayer> createState() => _HeroVideoPlayerState();
}

class _HeroVideoPlayerState extends State<HeroVideoPlayer> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      params: YoutubePlayerParams(
        showControls: false,
        showFullscreenButton: false, // We use custom button
        pointerEvents: PointerEvents.none, // Allow touches to pass to GestureDetector
        mute: true, // Auto-play muted
        loop: true,
      ),
    );

    _controller.loadVideoById(
      videoId: widget.video.youtubeId,
      startSeconds: widget.video.isCompleted
          ? 0
          : widget.video.lastWatchedPositionSeconds.toDouble(),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/player/${widget.video.youtubeId}'),
      child: Container(
        height: 220, // Check specific height requirements or aspect ratio
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: AppRadius.roundedL,
          boxShadow: AppShadows.card,
        ),
        clipBehavior: Clip.antiAlias, // Clip the player corners
        child: Stack(
          children: [
            MxPlayerScaffold(
              controller: _controller,
              title: widget.video.title,
              channelName: widget.video.channelName,
              isHeroMode: true,
            ),
            // Gradient Overlay for text readability if needed
            // But MxPlayerOverlay already provides some overlays.
            // In Hero Mode, MxPlayerOverlay only shows Fullscreen button.
          ],
        ),
      ),
    );
  }
}
