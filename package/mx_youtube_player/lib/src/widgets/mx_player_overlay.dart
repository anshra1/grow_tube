import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'package:mx_youtube_player/src/widgets/buffered_progress_bar.dart';
import 'package:mx_youtube_player/src/widgets/marquee_text.dart';
import 'package:mx_youtube_player/youtube_player_iframe.dart';
import 'package:screen_brightness/screen_brightness.dart';

class MxPlayerOverlay extends StatefulWidget {
  final YoutubePlayerController controller;
  final String title;
  final String? channelName;
  final bool isHeroMode;
  final VoidCallback? onToggleZoom;

  const MxPlayerOverlay({
    super.key,
    required this.controller,
    required this.title,
    this.channelName,
    this.isHeroMode = false,
    this.onToggleZoom,
  });

  @override
  State<MxPlayerOverlay> createState() => _MxPlayerOverlayState();
}

class _MxPlayerOverlayState extends State<MxPlayerOverlay> {
  // Gesture State
  bool _showControls = false;
  Timer? _controlsTimer;
  String? _centerText;
  IconData? _centerIcon;
  bool _showCenterOverlay = false;
  Timer? _centerOverlayTimer;

  // Drag & Scale State
  double? _initialVolume;
  double? _currentVolume;
  double? _initialBrightness;
  double? _currentBrightness;
  double? _startSeekSeconds;
  bool _isSeekDrag = false;

  // Debounce for zoom to prevent flickering
  DateTime _lastZoomTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _showControls = true;
    _startHideTimer();
  }

  void _startHideTimer() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _showCenterFeedback(String text, IconData icon) {
    setState(() {
      _centerText = text;
      _centerIcon = icon;
      _showCenterOverlay = true;
    });

    _centerOverlayTimer?.cancel();
    _centerOverlayTimer = Timer(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _showCenterOverlay = false;
        });
      }
    });
  }

  void _onScaleStart(ScaleStartDetails details, BoxConstraints constraints) async {
    // Initialize Volume
    _initialVolume = await FlutterVolumeController.getVolume();
    _currentVolume = _initialVolume;

    // Initialize Brightness
    try {
      _initialBrightness = await ScreenBrightness().current;
    } catch (e) {
      _initialBrightness = 0.5;
    }
    _currentBrightness = _initialBrightness;

    // Initialize Seek
    _startSeekSeconds = await widget.controller.currentTime;
    _isSeekDrag = false;
  }

  void _onScaleUpdate(ScaleUpdateDetails details, BoxConstraints constraints) async {
    // 1. Handle Zoom (Pinch)
    if (details.pointerCount == 2) {
      if (DateTime.now().difference(_lastZoomTime).inMilliseconds > 500) {
        if (details.scale > 1.5 || details.scale < 0.5) {
          widget.onToggleZoom?.call();
          _lastZoomTime = DateTime.now();
          _showCenterFeedback(details.scale > 1.0 ? 'Fill' : 'Fit', Icons.aspect_ratio);
        }
      }
      return;
    }

    // 2. Handle Drag (1 Finger)
    // Determine gesture type based on delta dominence
    final dx = details.focalPointDelta.dx;
    final dy = details.focalPointDelta.dy;

    // Seek (Horizontal)
    if (dx.abs() > dy.abs() && dx.abs() > 2.0 && !_isSeekDrag) {
      // Start horizontal drag if strictly horizontal
      _isSeekDrag = true;
    }

    // Vertical (Volume/Brightness)
    if (dy.abs() > dx.abs() && !_isSeekDrag) {
      final width = constraints.maxWidth;
      final isRightSide = details.focalPoint.dx > width / 2;

      // Calculate vertical delta (normalized 0-1)
      // Negative delta means drag UP (increase)
      final deltaLimit = -dy / constraints.maxHeight * 2;

      if (isRightSide) {
        // Volume
        _currentVolume = (_currentVolume ?? 0) + deltaLimit;
        _currentVolume = _currentVolume!.clamp(0.0, 1.0);
        FlutterVolumeController.setVolume(_currentVolume!);
        _showCenterFeedback('${(_currentVolume! * 100).toInt()}%', Icons.volume_up);
      } else {
        // Brightness
        _currentBrightness = (_currentBrightness ?? 0.5) + deltaLimit;
        _currentBrightness = _currentBrightness!.clamp(0.0, 1.0);
        ScreenBrightness().setScreenBrightness(_currentBrightness!);
        _showCenterFeedback(
          '${(_currentBrightness! * 100).toInt()}%',
          Icons.brightness_6,
        );
      }
      return;
    }

    // Handle Seek Update
    if (_isSeekDrag) {
      final duration = await widget.controller.duration;
      final deltaSeconds = (dx / constraints.maxWidth) * 90; // 90s swipe range

      var newPos = (_startSeekSeconds ?? 0) + deltaSeconds;
      newPos = newPos.clamp(0.0, duration);

      // Update startSeek to accumulate for next frame?
      // No, focalPointDelta is per frame. We need accumulated delta or update start base.
      _startSeekSeconds = newPos; // This works for simplistic accumulation

      final formattedTime = _formatDuration(Duration(seconds: newPos.toInt()));
      _showCenterFeedback(formattedTime, Icons.fast_forward);

      widget.controller.seekTo(seconds: newPos, allowSeekAhead: false);
    }
  }

  void _onScaleEnd(ScaleEndDetails details) {
    _initialVolume = null;
    _initialBrightness = null;
    _startSeekSeconds = null;
    _isSeekDrag = false;
  }

  void _togglePlayPause() async {
    final state = await widget.controller.playerState;
    if (state == PlayerState.playing) {
      widget.controller.pauseVideo();
      _showCenterFeedback('Paused', Icons.pause);
    } else {
      widget.controller.playVideo();
      _showCenterFeedback('Playing', Icons.play_arrow);
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return duration.inHours > 0
        ? '${duration.inHours}:$minutes:$seconds'
        : '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final content = Stack(
          children: [
            // Buffering Indicator
            if (!widget.isHeroMode)
              StreamBuilder<YoutubePlayerValue>(
                stream: widget.controller.stream,
                builder: (context, snapshot) {
                  final state = snapshot.data?.playerState;
                  if (state == PlayerState.buffering) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.orange),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

            // Center Feedback (Volume/Brightness/Seek)
            if (_showCenterOverlay && !widget.isHeroMode)
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_centerIcon, color: Colors.white, size: 40),
                      const SizedBox(height: 8),
                      Text(
                        _centerText ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Controls Overlay
            if (_showControls && !widget.isHeroMode)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top Bar
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Navigator.maybePop(context),
                          ),
                          Expanded(
                            child: MarqueeText(
                              text: widget.title,
                              style: const TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                          // Options Menu
                          PopupMenuButton<double>(
                            icon: const Icon(Icons.more_vert, color: Colors.white),
                            onSelected: (speed) {
                              widget.controller.setPlaybackRate(speed);
                              _showCenterFeedback('${speed}x', Icons.speed);
                            },
                            itemBuilder: (context) =>
                                [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0].map((speed) {
                                  return PopupMenuItem(
                                    value: speed,
                                    child: Text('${speed}x Playback Speed'),
                                  );
                                }).toList(),
                          ),
                        ],
                      ),
                    ),

                    // Center Play Button
                    StreamBuilder<YoutubePlayerValue>(
                      stream: widget.controller.stream,
                      builder: (context, snapshot) {
                        final state = snapshot.data?.playerState ?? PlayerState.unknown;
                        IconData icon = Icons.play_circle_fill;
                        VoidCallback action = _togglePlayPause;

                        if (state == PlayerState.playing) {
                          icon = Icons.pause_circle_filled;
                          action = widget.controller.pauseVideo;
                        } else if (state == PlayerState.ended) {
                          icon = Icons.replay_circle_filled;
                          action = () {
                            widget.controller.seekTo(seconds: 0);
                            widget.controller.playVideo();
                          };
                        } else {
                          icon = Icons.play_circle_fill;
                          action = widget.controller.playVideo;
                        }

                        return IconButton(
                          iconSize: 64,
                          icon: Icon(icon, color: Colors.white),
                          onPressed: () {
                            action();
                            // Show feedback
                            if (state == PlayerState.playing) {
                              _showCenterFeedback('Paused', Icons.pause);
                            } else if (state == PlayerState.ended) {
                              _showCenterFeedback('Replay', Icons.replay);
                            } else {
                              _showCenterFeedback('Playing', Icons.play_arrow);
                            }
                          },
                        );
                      },
                    ),

                    // Bottom Bar
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          StreamBuilder<YoutubeVideoState>(
                            stream: widget.controller.videoStateStream,
                            builder: (context, snapshot) {
                              final position =
                                  snapshot.data?.position.inSeconds.toDouble() ?? 0.0;
                              final duration = widget
                                  .controller
                                  .metadata
                                  .duration
                                  .inSeconds
                                  .toDouble();

                              return Row(
                                children: [
                                  Text(
                                    _formatDuration(Duration(seconds: position.toInt())),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  Expanded(
                                    child: BufferedProgressBar(
                                      position: position,
                                      buffered:
                                          duration *
                                          (snapshot.data?.loadedFraction ?? 0.0),
                                      duration: duration,
                                      onChanged: (val) {
                                        widget.controller.seekTo(seconds: val);
                                      },
                                    ),
                                  ),
                                  Text(
                                    _formatDuration(Duration(seconds: duration.toInt())),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              );
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.fullscreen, color: Colors.white),
                                onPressed: () => widget.controller.toggleFullScreen(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // In Hero Mode, we only show a floating Fullscreen button
            if (widget.isHeroMode)
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: IconButton(
                    icon: const Icon(Icons.fullscreen, color: Colors.white, size: 28),
                    onPressed: () => widget.controller.toggleFullScreen(),
                  ),
                ),
              ),
          ],
        );

        if (widget.isHeroMode) {
          return content;
        }

        return GestureDetector(
          onTap: () {
            setState(() {
              _showControls = !_showControls;
              if (_showControls) _startHideTimer();
            });
          },
          onDoubleTap: _togglePlayPause,
          onScaleStart: (d) => _onScaleStart(d, constraints),
          onScaleUpdate: (d) => _onScaleUpdate(d, constraints),
          onScaleEnd: _onScaleEnd,
          behavior: HitTestBehavior.translucent,
          child: content,
        );
      },
    );
  }
}
