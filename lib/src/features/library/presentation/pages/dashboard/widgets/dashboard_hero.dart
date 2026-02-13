import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:omni_video_player/omni_video_player.dart';
import 'package:skill_tube/src/core/design_system/app_radius.dart';
import 'package:skill_tube/src/features/library/domain/entities/video.dart';
import 'package:skill_tube/src/features/library/presentation/bloc/library_bloc.dart';
import 'package:skill_tube/src/features/library/presentation/bloc/library_event.dart';

class DashboardHero extends StatefulWidget {
  const DashboardHero({required this.video, super.key});

  final Video video;

  @override
  State<DashboardHero> createState() => _DashboardHeroState();
}

class _DashboardHeroState extends State<DashboardHero> {
  OmniPlaybackController? _controller;
  Timer? _heartbeatTimer;

  @override
  void initState() {
    super.initState();
    _startHeartbeat();
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      _saveProgress();
    });
  }

  void _saveProgress() {
    final controller = _controller;
    if (controller != null) {
      final position = controller.currentPosition.inSeconds;
      // Only save if position is greater than 0 to avoid overwriting valid
      // progress with 0 during initialization/disposal glitches.
      // Completion is handled by the main player.
      if (position > 0) {
        context.read<LibraryBloc>().add(
          LibraryVideoProgressUpdatedEvent(
            youtubeId: widget.video.youtubeId,
            positionSeconds: position,
          ),
        );
      }
    }
  }

  void _update() {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _heartbeatTimer?.cancel();
    _saveProgress();
    _controller?.removeListener(_update);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: AppRadius.roundedXL,
        child: OmniVideoPlayer(
          key: ValueKey(widget.video.youtubeId),
          callbacks: VideoPlayerCallbacks(
            onControllerCreated: (controller) {
              _controller?.removeListener(_update);
              _controller = controller..addListener(_update);

              // Explicit seek fallback
              final startPos = widget.video.isCompleted
                  ? 0
                  : widget.video.lastWatchedPositionSeconds;

              if (startPos > 0) {
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (mounted && _controller != null) {
                    _controller!.seekTo(Duration(seconds: startPos));
                  }
                });
              }
            },
                                onFullScreenToggled: (isFullScreen) async {
                                  if (isFullScreen) {
                                    final controller = _controller;
                                    if (controller != null) {
                                      final position = controller.currentPosition.inSeconds;
                                      controller.pause(); // STOP the background player
                      
                                      // Save the exact position so the next screen picks it up
                                      context.read<LibraryBloc>().add(
                                            LibraryVideoProgressUpdatedEvent(
                                              youtubeId: widget.video.youtubeId,
                                              positionSeconds: position,
                                            ),
                                          );
                                    }
                      
                                                  // When the fullscreen button is tapped, navigate to the dedicated
                      
                                                  // player page.
                      
                                                  
                      
                                                  // PRE-EMPTIVELY set orientation to landscape to avoid flicker
                      
                                                  await SystemChrome.setPreferredOrientations([
                      
                                                    DeviceOrientation.landscapeLeft,
                      
                                                    DeviceOrientation.landscapeRight,
                      
                                                  ]);
                      
                                    
                      
                                                  if (context.mounted) {
                      
                                                    await context.push('/player/${widget.video.youtubeId}');
                      
                                                  }
                      
                                    
                      
                                                  // FORCE portrait mode immediately when we come back
                      
                                                  SystemChrome.setPreferredOrientations([
                      
                                                    DeviceOrientation.portraitUp,
                      
                                                  ]);
                      
                                                }
                      
                                              },            onSeekRequest: (target) => true,
          ),
          configuration: VideoPlayerConfiguration(
            videoSourceConfiguration:
                VideoSourceConfiguration.youtube(
                  videoUrl: Uri.parse(
                    'https://www.youtube.com/watch?v=${widget.video.youtubeId}',
                  ),
                  preferredQualities: const [OmniVideoQuality.high720],
                ).copyWith(
                  autoPlay: false,
                  initialPosition: Duration(
                    seconds: widget.video.isCompleted
                        ? 0
                        : widget.video.lastWatchedPositionSeconds,
                  ),
                  allowSeeking: true,
                ),
            playerTheme: OmniVideoPlayerThemeData().copyWith(
              icons: VideoPlayerIconTheme().copyWith(
                error: Icons.warning,
                playbackSpeedButton: Icons.speed,
              ),
              overlays: VideoPlayerOverlayTheme().copyWith(
                backgroundColor: Colors.black,
                alpha: 150,
              ),
            ),
            playerUIVisibilityOptions: PlayerUIVisibilityOptions().copyWith(
              showSeekBar: true,
              showCurrentTime: true,
              showDurationTime: true,
              showRemainingTime: true,
              showLoadingWidget: true,
              showErrorPlaceholder: true,
              showReplayButton: true,
              showFullScreenButton: true,
              showSwitchVideoQuality: true,
              showPlaybackSpeedButton: true,
              showMuteUnMuteButton: true,
              showPlayPauseReplayButton: true,
              enableForwardGesture: true,
              enableBackwardGesture: true,
              fitVideoToBounds: true,
            ),
            customPlayerWidgets: CustomPlayerWidgets().copyWith(
              loadingWidget: const CircularProgressIndicator(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
