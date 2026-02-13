import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omni_video_player/omni_video_player.dart';
import 'package:skill_tube/src/core/di/injection_container.dart' as di;
import 'package:skill_tube/src/features/library/domain/entities/video.dart';
import 'package:skill_tube/src/features/library/presentation/bloc/library_bloc.dart';
import 'package:skill_tube/src/features/library/presentation/bloc/library_event.dart';
import 'package:skill_tube/src/features/player/presentation/bloc/player_bloc.dart';
import 'package:skill_tube/src/features/player/presentation/bloc/player_event.dart';
import 'package:skill_tube/src/features/player/presentation/bloc/player_state.dart';

class PlayerPage extends StatelessWidget {
  final String videoId;

  const PlayerPage({super.key, required this.videoId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<PlayerBloc>()..add(PlayerVideoLoadedEvent(videoId)),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: BlocBuilder<PlayerBloc, PlayerState>(
          builder: (context, state) {
            return switch (state) {
              PlayerInitialState() || PlayerLoadingState() => const Center(
                  child: CircularProgressIndicator(),
                ),
              PlayerFailureState(:final message) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Theme.of(context).colorScheme.error,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          message,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Go Back'),
                        ),
                      ],
                    ),
                  ),
                ),
              PlayerLoadedState(:final video) => _VideoPlayerView(video: video),
            };
          },
        ),
      ),
    );
  }
}

class _VideoPlayerView extends StatefulWidget {
  final Video video;

  const _VideoPlayerView({required this.video});

  @override
  State<_VideoPlayerView> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends State<_VideoPlayerView> {
  OmniPlaybackController? _controller;
  Timer? _heartbeatTimer;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
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
      // Safeguard: Don't save 0 from heartbeat or dispose to avoid
      // overwriting progress during edge cases. Explicit finish handles 0 reset.
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

  @override
  void dispose() {
    _heartbeatTimer?.cancel();
    _saveProgress();
    _controller?.removeListener(_update);
    super.dispose();
  }

  bool _wasPlaying = false;

  void _update() {
    final controller = _controller;
    if (controller != null) {
      if (_wasPlaying && !controller.isPlaying) {
        // Just paused
        _saveProgress();
      }
      _wasPlaying = controller.isPlaying;
    }

    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return OmniVideoPlayer(
      key: ValueKey(widget.video.youtubeId),
      callbacks: VideoPlayerCallbacks(
        onControllerCreated: (controller) {
          debugPrint(
            'PlayerPage: Controller created. Seeking to ${widget.video.lastWatchedPositionSeconds}s',
          );
          _controller?.removeListener(_update);
          _controller = controller..addListener(_update);

          // Explicitly seek as a backup to initialPosition
          final startPos = widget.video.isCompleted
              ? 0
              : widget.video.lastWatchedPositionSeconds;

          if (startPos > 0) {
            // Delay slightly to ensure iframe is ready for seek command
            Future.delayed(const Duration(milliseconds: 800), () {
              if (mounted && _controller != null) {
                _controller!.seekTo(Duration(seconds: startPos));
                _controller!.play(); // Force play after seek
              }
            });
          } else {
            // Even if startPos is 0, ensure it plays
            Future.delayed(const Duration(milliseconds: 800), () {
              if (mounted && _controller != null) {
                _controller!.play();
              }
            });
          }
        },
        onFullScreenToggled: (isFullScreen) {
          if (!isFullScreen) {
            // If the user taps the exit fullscreen button, go back to dashboard
            if (context.mounted) Navigator.of(context).pop();
          }
        },
        onOverlayControlsVisibilityChanged: (areVisible) {},
        onCenterControlsVisibilityChanged: (areVisible) {},
        onMuteToggled: (isMute) {},
        onSeekStart: (pos) {},
        onSeekEnd: (pos) {},
        onSeekRequest: (target) => true,
        onFinished: () {
          // Completion Rules: reset to 0:00 when finished.
          context.read<LibraryBloc>().add(
            LibraryVideoProgressUpdatedEvent(
              youtubeId: widget.video.youtubeId,
              positionSeconds: 0,
            ),
          );
        },
        onReplay: () {},
      ),
      configuration: VideoPlayerConfiguration(
        videoSourceConfiguration:
            VideoSourceConfiguration.youtube(
              videoUrl: Uri.parse(
                'https://www.youtube.com/watch?v=${widget.video.youtubeId}',
              ),
              preferredQualities: const [
                OmniVideoQuality.high720,
                OmniVideoQuality.medium480,
              ],
              availableQualities: const [
                OmniVideoQuality.high1080,
                OmniVideoQuality.high720,
                OmniVideoQuality.medium480,
                OmniVideoQuality.medium360,
                OmniVideoQuality.low144,
              ],
              enableYoutubeWebViewFallback: true,
            ).copyWith(
              autoPlay: true,
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
          enableOrientationLock: true,
          fitVideoToBounds: true,
        ),
        customPlayerWidgets: CustomPlayerWidgets().copyWith(
          loadingWidget: const CircularProgressIndicator(color: Colors.white),
        ),
      ),
    );
  }
}
