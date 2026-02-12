import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'package:mx_youtube_player/youtube_player_iframe.dart';
import 'package:screen_brightness/screen_brightness.dart';

class MxPlayerOverlay extends StatefulWidget {
  final YoutubePlayerController controller;

  const MxPlayerOverlay({super.key, required this.controller});

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
  
  // Drag State
  double? _initialDragValue;
  double? _currentDragValue;
  bool _isVolumeDrag = false;
  bool _isBrightnessDrag = false;
  bool _isSeekDrag = false;
  double _startSeekSeconds = 0;

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

  void _onVerticalDragStart(DragStartDetails details, BoxConstraints constraints) async {
    final width = constraints.maxWidth;
    final isRightSide = details.localPosition.dx > width / 2;

    if (isRightSide) {
      _isVolumeDrag = true;
      _initialDragValue = await FlutterVolumeController.getVolume();
    } else {
      _isBrightnessDrag = true;
      try {
        _initialDragValue = await ScreenBrightness().current;
      } catch (e) {
        _initialDragValue = 0.5;
      }
    }
  }

  void _onVerticalDragUpdate(DragUpdateDetails details, BoxConstraints constraints) {
    if (_initialDragValue == null) return;

    final delta = -details.primaryDelta! / constraints.maxHeight * 2; // Sensitivity
    _currentDragValue = (_currentDragValue ?? _initialDragValue!) + delta;
    _currentDragValue = _currentDragValue!.clamp(0.0, 1.0);

    if (_isVolumeDrag) {
      FlutterVolumeController.setVolume(_currentDragValue!);
      _showCenterFeedback(
        '${(_currentDragValue! * 100).toInt()}%',
        Icons.volume_up,
      );
    } else if (_isBrightnessDrag) {
      ScreenBrightness().setScreenBrightness(_currentDragValue!);
      _showCenterFeedback(
        '${(_currentDragValue! * 100).toInt()}%',
        Icons.brightness_6,
      );
    }
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    _isVolumeDrag = false;
    _isBrightnessDrag = false;
    _initialDragValue = null;
    _currentDragValue = null;
  }

  Future<void> _onHorizontalDragStart(DragStartDetails details) async {
    _isSeekDrag = true;
    _startSeekSeconds = await widget.controller.currentTime;
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details, BoxConstraints constraints) async {
    if (!_isSeekDrag) return;

    final duration = await widget.controller.duration;
    final deltaSeconds = (details.primaryDelta! / constraints.maxWidth) * 90; // 90s swipe range
    
    var newPos = _startSeekSeconds + deltaSeconds;
    newPos = newPos.clamp(0.0, duration);
    
    _startSeekSeconds = newPos; // Accumulate for smooth dragging
    
    final formattedTime = _formatDuration(Duration(seconds: newPos.toInt()));
    _showCenterFeedback(formattedTime, Icons.fast_forward);
    
    widget.controller.seekTo(seconds: newPos, allowSeekAhead: false);
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
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
        return GestureDetector(
          onTap: () {
            setState(() {
              _showControls = !_showControls;
              if (_showControls) _startHideTimer();
            });
          },
          onDoubleTap: _togglePlayPause,
          onVerticalDragStart: (d) => _onVerticalDragStart(d, constraints),
          onVerticalDragUpdate: (d) => _onVerticalDragUpdate(d, constraints),
          onVerticalDragEnd: _onVerticalDragEnd,
          onHorizontalDragStart: _onHorizontalDragStart,
          onHorizontalDragUpdate: (d) => _onHorizontalDragUpdate(d, constraints),
          onHorizontalDragEnd: _onHorizontalDragEnd,
          behavior: HitTestBehavior.translucent,
          child: Stack(
            children: [
              // Center Feedback (Volume/Brightness/Seek)
              if (_showCenterOverlay)
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
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),

              // Controls Overlay
              if (_showControls)
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
                            const Expanded(
                              child: Text(
                                'Video Title', // Placeholder
                                style: TextStyle(color: Colors.white, fontSize: 18),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Center Play Button
                      IconButton(
                        iconSize: 64,
                        icon: const Icon(Icons.play_circle_fill, color: Colors.white),
                        onPressed: _togglePlayPause,
                      ),

                      // Bottom Bar
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            StreamBuilder<YoutubeVideoState>(
                              stream: widget.controller.videoStateStream,
                              builder: (context, snapshot) {
                                final position = snapshot.data?.position.inSeconds.toDouble() ?? 0.0;
                                final duration = widget.controller.metadata.duration.inSeconds.toDouble();
                                
                                return Row(
                                  children: [
                                    Text(
                                      _formatDuration(Duration(seconds: position.toInt())),
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                    Expanded(
                                      child: SliderTheme(
                                        data: SliderThemeData(
                                          activeTrackColor: Colors.orange, // MX Style
                                          thumbColor: Colors.orange,
                                          inactiveTrackColor: Colors.grey,
                                          trackHeight: 2.0,
                                        ),
                                        child: Slider(
                                          value: position.clamp(0.0, duration > 0 ? duration : 1.0),
                                          min: 0,
                                          max: duration > 0 ? duration : 1.0,
                                          onChanged: (val) {
                                            widget.controller.seekTo(seconds: val);
                                          },
                                        ),
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
            ],
          ),
        );
      },
    );
  }
}
