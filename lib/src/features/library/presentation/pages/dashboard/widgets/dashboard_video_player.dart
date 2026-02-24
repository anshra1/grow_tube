// ignore_for_file: invalid_use_of_internal_member

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skill_tube/main.dart';
import 'package:skill_tube/src/core/design_system/app_radius.dart';
import 'package:skill_tube/src/features/library/domain/entities/video.dart';
import 'package:skill_tube/src/features/library/presentation/bloc/library_bloc.dart';
import 'package:skill_tube/src/features/library/presentation/bloc/library_event.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class DashboardVideoPlayer extends StatefulWidget {
  const DashboardVideoPlayer({
    required this.video,
    this.isFullScreen = false,
    this.onFullScreenChanged,
    super.key,
  });

  final Video video;
  final bool isFullScreen;
  final ValueChanged<bool>? onFullScreenChanged;

  @override
  State<DashboardVideoPlayer> createState() => _DashboardVideoPlayerState();
}

class _DashboardVideoPlayerState extends State<DashboardVideoPlayer> {
  late YoutubePlayerController _controller;
  StreamSubscription<YoutubePlayerValue>? _errorSubscription;
  Timer? _heartbeatTimer;
  // GlobalKey keeps the YoutubePlayer's WebView alive across layout changes
  final _youtubePlayerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
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

    // This fires when controller.enterFullScreen() / exitFullScreen()
    // is called from Dart (via our button or vertical drag gesture).
    _controller.setFullScreenListener((isFullScreen) async {
      if (isFullScreen) {
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      } else {
        await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      }

      widget.onFullScreenChanged?.call(isFullScreen);
      _saveProgress();
    });
  }

  void _toggleFullScreen() {
    if (widget.isFullScreen) {
      _controller.exitFullScreen();
    } else {
      _controller.enterFullScreen();
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
    _heartbeatTimer?.cancel();
    _errorSubscription?.cancel();
    _saveProgress();
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Create the player ONCE with a stable key.
    // Flutter will move it between layouts without recreating the WebView.
    final player = YoutubePlayer(
      key: _youtubePlayerKey,
      controller: _controller,
      aspectRatio: 16 / 9,
      enableFullScreenOnVerticalDrag: true,
    );

    if (widget.isFullScreen) {
      return SizedBox.expand(child: player);
    }

    // Normal: 16:9 with rounded corners + landscape button below
    return Column(
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
    );
  }
}
