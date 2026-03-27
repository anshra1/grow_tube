// ignore_for_file: invalid_use_of_internal_member

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:levelup_tube/main.dart';
import 'package:levelup_tube/src/core/design_system/app_radius.dart';
import 'package:levelup_tube/src/features/library/domain/entities/video.dart';
import 'package:levelup_tube/src/features/library/presentation/bloc/library_bloc.dart';
import 'package:levelup_tube/src/features/library/presentation/bloc/library_event.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class DashboardVideoPlayer extends StatefulWidget {
  const DashboardVideoPlayer({required this.video, super.key});

  final Video video;

  @override
  State<DashboardVideoPlayer> createState() => _DashboardVideoPlayerState();
}

class _DashboardVideoPlayerState extends State<DashboardVideoPlayer>
    with SingleTickerProviderStateMixin {
  late YoutubePlayerController _controller;
  StreamSubscription<YoutubePlayerValue>? _errorSubscription;
  Timer? _heartbeatTimer;
  final OverlayPortalController _overlayController = OverlayPortalController();
  final _youtubePlayerKey = GlobalKey();

  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(parent: _animController, curve: Curves.easeInOut);
    _initializeController();
    _startHeartbeat();
  }

  @override
  void didUpdateWidget(covariant DashboardVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.video.youtubeId != oldWidget.video.youtubeId) {
      _saveProgress(youtubeId: oldWidget.video.youtubeId);

      final startPos = widget.video.isCompleted
          ? 0.0
          : widget.video.lastWatchedPositionSeconds.toDouble();

      talker.log(
        'VideoPlayer: Switching to video ${widget.video.youtubeId} '
        '(startPos: $startPos)',
        logLevel: LogLevel.info,
      );

      // User explicitly tapped a video → auto-play it.
      _controller.loadVideoById(videoId: widget.video.youtubeId, startSeconds: startPos);
    }
  }

  void _initializeController() {
    final startPos = widget.video.isCompleted
        ? 0.0
        : widget.video.lastWatchedPositionSeconds.toDouble();

    talker.log(
      'VideoPlayer: Initializing with video ${widget.video.youtubeId} '
      '(startPos: $startPos)',
      logLevel: LogLevel.info,
    );

    _controller = YoutubePlayerController(
      params: const YoutubePlayerParams(
        mute: false,
        showControls: true,
        showFullscreenButton: false,
        enableJavaScript: true,
        strictRelatedVideos: false,
        playsInline: true,
        origin: 'https://www.youtube-nocookie.com',
      ),
    );

    // On app launch: cue the video (shows thumbnail/controls, does NOT auto-play).
    // Auto-play only happens when the user explicitly taps a video (see didUpdateWidget).
    _controller.cueVideoById(videoId: widget.video.youtubeId, startSeconds: startPos);

    _errorSubscription = _controller.listen((value) {
      if (value.error != YoutubeError.none) {
        talker.error(
          'VideoPlayer: YouTube error ${value.error.code} '
          '(${value.error.name}) for video ${widget.video.youtubeId}',
        );
      }
    });
  }

  void _toggleFullScreen() async {
    if (!_overlayController.isShowing) {
      // 1. Enter Fullscreen (mounts the overlay)
      setState(() => _overlayController.toggle());

      // 2. Instantly jump to black (hide the player while it stretches to landscape)
      _animController.value = 1.0;

      // 3. Trigger hardware rotation
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

      // 4. Wait for hardware rotation to complete
      await Future.delayed(const Duration(milliseconds: 300));

      // 5. Fade out the black box to reveal the newly-sized landscape player
      if (mounted) {
        _animController.reverse();
      }
    } else {
      // 1. Fade the black box IN to hide the landscape player before it shrinks
      await _animController.forward(from: 0.0);

      // 2. Trigger hardware rotation back to portrait
      await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

      // 3. Wait for hardware rotation to complete
      await Future.delayed(const Duration(milliseconds: 300));

      // 4. Remove the overlay entirely and reset the black box
      if (mounted) {
        setState(() => _overlayController.toggle());
        _animController.value = 0.0;
      }
    }
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      _saveProgress();
    });
  }

  Future<void> _saveProgress({String? youtubeId}) async {
    try {
      final positionTime = await _controller.currentTime;
      final position = positionTime.toInt();
      final targetId = youtubeId ?? widget.video.youtubeId;

      if (position > 0 && mounted) {
        context.read<LibraryBloc>().add(
          LibraryVideoProgressUpdatedEvent(
            youtubeId: targetId,
            positionSeconds: position,
          ),
        );
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _animController.dispose();
    _heartbeatTimer?.cancel();
    _errorSubscription?.cancel();
    _saveProgress();
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // A stable GlobalKey prevents the Youtube WebView from being fully destroyed
    // when it moves from the inline Column to the Positioned Overlay.
    final player = YoutubePlayer(
      key: _youtubePlayerKey,
      controller: _controller,
      aspectRatio: 16 / 9,
      enableFullScreenOnVerticalDrag: false,
    );

    return PopScope(
      canPop: !_overlayController.isShowing,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _overlayController.isShowing) {
          _toggleFullScreen();
        }
      },
      child: OverlayPortal(
        controller: _overlayController,
        // When fullscreen, leave behind an empty 16:9 box in the structural list
        // so the UI beneath it doesn't snap upwards.
        child: _overlayController.isShowing
            ? const AspectRatio(aspectRatio: 16 / 9, child: SizedBox())
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: ClipRRect(borderRadius: AppRadius.roundedXL, child: player),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: _toggleFullScreen,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.screen_rotation,
                              size: 18,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Landscape',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
        // This is beamed to the top-level Overlay when isShowing is true
        overlayChildBuilder: (context) {
          return Positioned.fill(
            child: Stack(
              children: [
                // The underlying player, which might stretch during rotation
                Positioned.fill(
                  child: Container(color: Colors.black, child: player),
                ),
                // The blackout box that covers the player during transitions
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _fadeAnimation,
                    builder: (context, child) {
                      return IgnorePointer(
                        child: Container(
                          color: Colors.black.withOpacity(_fadeAnimation.value),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
