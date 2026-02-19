import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omni_video_player/omni_video_player.dart';
import 'package:skill_tube/src/core/design_system/app_radius.dart';
import 'package:skill_tube/src/features/library/domain/entities/video.dart';
import 'package:skill_tube/src/features/library/presentation/bloc/library_bloc.dart';
import 'package:skill_tube/src/features/library/presentation/bloc/library_event.dart';

class DashboardVideoPlayer extends StatefulWidget {
  const DashboardVideoPlayer({required this.video, this.onFullScreenChanged, super.key});

  final Video video;
  final ValueChanged<bool>? onFullScreenChanged;

  @override
  State<DashboardVideoPlayer> createState() => _DashboardVideoPlayerState();
}

class _DashboardVideoPlayerState extends State<DashboardVideoPlayer> {
  OmniPlaybackController? _controller;
  Timer? _heartbeatTimer;
  late VideoPlayerConfiguration _playerConfiguration;

  @override
  void initState() {
    super.initState();
    _initializeConfiguration();
    _startHeartbeat();
  }

  @override
  void didUpdateWidget(covariant DashboardVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.video.youtubeId != oldWidget.video.youtubeId) {
      _initializeConfiguration();
    }
  }

  void _initializeConfiguration() {
    _playerConfiguration = VideoPlayerConfiguration(
      videoSourceConfiguration:
          VideoSourceConfiguration.youtube(
            videoUrl: Uri.parse(
              'https://www.youtube.com/watch?v=${widget.video.youtubeId}',
            ),
            preferredQualities: const [OmniVideoQuality.high720],
          ).copyWith(
            autoPlay: true, // Auto-play when explicitly selected/loaded
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
        enableOrientationLock: true,
      ),
      customPlayerWidgets: CustomPlayerWidgets().copyWith(
        loadingWidget: const CircularProgressIndicator(color: Colors.white),
      ),
    );
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
        // Debounce setState to avoid rapid updates if not needed,
        // but here we just ensure we are mounted.
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
              widget.onFullScreenChanged?.call(isFullScreen);

              if (isFullScreen) {
                await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
                await SystemChrome.setPreferredOrientations([
                  DeviceOrientation.landscapeLeft,
                  DeviceOrientation.landscapeRight,
                ]);
              } else {
                await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
                await SystemChrome.setPreferredOrientations([
                  DeviceOrientation.portraitUp,
                ]);
              }

              final controller = _controller;
              if (controller != null) {
                // Save progress on toggle, just in case
                final position = controller.currentPosition.inSeconds;
                if (position > 0) {
                  context.read<LibraryBloc>().add(
                    LibraryVideoProgressUpdatedEvent(
                      youtubeId: widget.video.youtubeId,
                      positionSeconds: position,
                    ),
                  );
                }
              }
            },
            onSeekRequest: (target) => true,
          ),
          configuration: _playerConfiguration,
        ),
      ),
    );
  }
}
