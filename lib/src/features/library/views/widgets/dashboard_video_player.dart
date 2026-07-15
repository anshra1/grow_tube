//
// ignore_for_file: invalid_use_of_internal_member

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:levelup_tube/main.dart';
import 'package:levelup_tube/src/core/design_system/app_radius.dart';
import 'package:levelup_tube/src/features/connectivity/presentation/bloc/connectivity_cubit.dart';
import 'package:levelup_tube/src/features/library/models/video.dart';
import 'package:levelup_tube/src/features/library/viewmodels/library_bloc.dart';
import 'package:levelup_tube/src/features/library/viewmodels/library_event.dart';
import 'package:levelup_tube/src/features/navigation/cubit/fullscreen_video_cubit.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:toastification/toastification.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class DashboardVideoPlayer extends StatefulWidget {
  const DashboardVideoPlayer({
    required this.video,
    this.forcePlayTimestamp,
    this.onProgressUpdate,
    super.key,
  });

  final Video video;
  final int? forcePlayTimestamp;
  final void Function(String youtubeId, int positionSeconds)?
  onProgressUpdate;

  @override
  State<DashboardVideoPlayer> createState() =>
      _DashboardVideoPlayerState();
}

class _DashboardVideoPlayerState extends State<DashboardVideoPlayer>
    with SingleTickerProviderStateMixin {
  YoutubePlayerController? _controller;
  StreamSubscription<YoutubePlayerValue>? _errorSubscription;
  Timer? _heartbeatTimer;
  final OverlayPortalController _overlayController =
      OverlayPortalController();
  final _youtubePlayerKey = GlobalKey();
  StreamSubscription<ConnectivityStatus>? _connectivitySubscription;

  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
    _maybeInitializeController();
    _listenConnectivity();
    _startHeartbeat();
  }

  @override
  void didUpdateWidget(covariant DashboardVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller == null) return;
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
      _controller?.loadVideoById(
        videoId: widget.video.youtubeId,
        startSeconds: startPos,
      );
    } else if (widget.forcePlayTimestamp != null &&
        widget.forcePlayTimestamp != oldWidget.forcePlayTimestamp) {
      // User tapped the currently active video again in the list.
      _handleRetry();
    }
  }

  Future<void> _handleRetry() async {
    if (_controller == null) {
      // Case A: Controller was never created (device was offline at init time).
      // Reinitialize the whole controller so the player can start fresh.
      _reinitializeController();
      return;
    }

    // Case B: Controller exists, let's see what it's doing
    final state = await _controller!.playerState;

    if (state == PlayerState.playing) {
      // Don't interrupt perfectly playing video!
      if (mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.info,
          style: ToastificationStyle.fillColored,
          title: const Text('Already playing'),
          autoCloseDuration: const Duration(seconds: 2),
          alignment: Alignment.bottomCenter,
        );
      }
    } else if (state == PlayerState.buffering) {
      // Video is stuck loading, kickstart it!
      final pos = await _controller!.currentTime;
      await _controller!.loadVideoById(
        videoId: widget.video.youtubeId,
        startSeconds: pos,
      );
      if (mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.success,
          style: ToastificationStyle.fillColored,
          title: const Text('Restarted from same place'),
          autoCloseDuration: const Duration(seconds: 2),
          alignment: Alignment.bottomCenter,
        );
      }
    } else if (state == PlayerState.paused) {
      // Simply unpause
      await _controller!.playVideo();
    } else {
      // Broken state (unknown/unstarted)
      await _controller!.loadVideoById(
        videoId: widget.video.youtubeId,
        startSeconds: 0,
      );
    }
  }

  void _listenConnectivity() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = context
        .read<ConnectivityCubit>()
        .stream
        .distinct()
        .listen((status) {
          if (status == ConnectivityStatus.online &&
              _controller == null) {
            _reinitializeController();
          }
        });
  }

  void _maybeInitializeController() {
    if (context.read<ConnectivityCubit>().state !=
        ConnectivityStatus.online) {
      return;
    }
    _initializeController();
  }

  void _reinitializeController() {
    _errorSubscription?.cancel();
    _controller?.close();
    _controller = null;
    _initializeController();
    if (mounted) {
      setState(() {});
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

    final controller = YoutubePlayerController(
      params: const YoutubePlayerParams(
        enableCaption: false,
        origin: 'https://www.youtube-nocookie.com',
      ),
    );

    _controller = controller;

    // On app launch: cue the video (shows thumbnail/controls, does NOT auto-play).
    // Auto-play only happens when the user explicitly taps a video (see didUpdateWidget).
    controller.cueVideoById(
      videoId: widget.video.youtubeId,
      startSeconds: startPos,
    );

    _errorSubscription = controller.listen((value) {
      if (value.error != YoutubeError.none) {
        talker.error(
          'VideoPlayer: YouTube error ${value.error.code} '
          '(${value.error.name}) for video ${widget.video.youtubeId}',
        );
      }
    });
  }

  Future<void> _toggleFullScreen() async {
    if (!_overlayController.isShowing) {
      // 1. Enter Fullscreen (mounts the overlay)
      setState(_overlayController.toggle);
      context.read<FullscreenVideoCubit>().enterFullscreen();

      // 2. Instantly jump to black (hide the player while it stretches to landscape)
      _animController.value = 1.0;

      // 3. Trigger hardware rotation
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      await SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.immersiveSticky,
      );

      // 4. Wait for hardware rotation to complete
      await Future<void>.delayed(const Duration(milliseconds: 300));

      // 5. Fade out the black box to reveal the newly-sized landscape player
      if (mounted) {
        await _animController.reverse();
      }
    } else {
      // 1. Fade the black box IN to hide the landscape player before it shrinks
      await _animController.forward(from: 0);

      // 2. Trigger hardware rotation back to portrait
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
      await SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge,
      );

      // 3. Wait for hardware rotation to complete
      await Future<void>.delayed(const Duration(milliseconds: 300));

      // 4. Remove the overlay entirely and reset the black box
      if (mounted) {
        setState(_overlayController.toggle);
        _animController.value = 0.0;
        context.read<FullscreenVideoCubit>().exitFullscreen();
      }
    }
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 60), (
      _,
    ) {
      _saveProgress();
    });
  }

  Future<void> _saveProgress({String? youtubeId}) async {
    try {
      final controller = _controller;
      if (controller == null) return;
      final positionTime = await controller.currentTime;
      final position = positionTime.toInt();
      final targetId = youtubeId ?? widget.video.youtubeId;

      if (position > 0 && mounted) {
        if (widget.onProgressUpdate != null) {
          widget.onProgressUpdate!(targetId, position);
        } else {
          context.read<LibraryBloc>().add(
            LibraryVideoProgressUpdatedEvent(
              youtubeId: targetId,
              positionSeconds: position,
            ),
          );
        }
      }
    } on Exception catch (_) {}
  }

  @override
  void dispose() {
    context.read<FullscreenVideoCubit>().exitFullscreen();
    _animController.dispose();
    _heartbeatTimer?.cancel();
    _errorSubscription?.cancel();
    _saveProgress();
    _connectivitySubscription?.cancel();
    _controller?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // A stable GlobalKey prevents the Youtube WebView from being fully destroyed
    // when it moves from the inline Column to the Positioned Overlay.
    final controller = _controller;
    final player = controller == null
        ? null
        : YoutubePlayer(
            key: _youtubePlayerKey,
            controller: controller,
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
            ? const AspectRatio(
                aspectRatio: 16 / 9,
                child: SizedBox(),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: ClipRRect(
                      borderRadius: AppRadius.roundedXL,
                      child: player ?? Container(color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: _toggleFullScreen,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.screen_rotation,
                              size: 18,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Landscape',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
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
                  child: ColoredBox(
                    color: Colors.black,
                    child: player ?? const SizedBox.shrink(),
                  ),
                ),
                // The blackout box that covers the player during transitions
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _fadeAnimation,
                    builder: (context, child) {
                      return IgnorePointer(
                        child: Container(
                          color: Colors.black.withValues(
                            alpha: _fadeAnimation.value,
                          ),
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
