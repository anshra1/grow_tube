import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:levelup_tube/src/core/design_system/app_radius.dart';
import 'package:levelup_tube/src/core/di/injection_container.dart' as di;
import 'package:levelup_tube/src/core/services/logging_service/app_logger.dart';
import 'package:levelup_tube/src/features/library/views/dashboard_widgets/dashboard_video_player.dart';
import 'package:toastification/toastification.dart';
import 'package:url_launcher/url_launcher.dart';

class ExternalUrlLanucher extends StatefulWidget {
  const ExternalUrlLanucher({
    required this.widget,
    required this.holder,
    super.key,
  });

  final DashboardVideoPlayer widget;
  final ToastificationItem holder;

  @override
  State<ExternalUrlLanucher> createState() => _ExternalUrlLanucherState();
}

class _ExternalUrlLanucherState extends State<ExternalUrlLanucher>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _pulseController;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _pulseAnimation;

  bool _isLaunching = false;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic));

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0, 0.65, curve: Curves.easeOut),
      ),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 1,
      end: 1.14,
    ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _launchYouTube() async {
    setState(() => _isLaunching = true);
    toastification.dismissById(widget.holder.id);
    try {
      final videoId = widget.widget.video.youtubeId;
      final lastPos = widget.widget.video.lastWatchedPositionSeconds;

      // Base URL using the standard youtube.com format
      final baseWebUrl = widget.widget.video.originalUrl ?? 'https://www.youtube.com/watch?v=$videoId';
      
      // Append timestamp if we have a saved position
      final url = Uri.parse(
        lastPos > 0 ? '$baseWebUrl&t=$lastPos' : baseWebUrl,
      );

      // 1. Try to open exclusively in the native YouTube app (App Links)
      final launchedInApp = await launchUrl(
        url,
        mode: LaunchMode.externalNonBrowserApplication,
      );

      // 2. If the user doesn't have the YouTube app installed, fallback to browser
      if (!launchedInApp) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
      }
    } on Exception catch (e) {
      di.sl<AppLogger>().error('Failed to launch URL: $e');
    } finally {
      if (mounted) setState(() => _isLaunching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
   
    final errorContainer = theme.colorScheme.errorContainer;
    final onErrorContainer = theme.colorScheme.onErrorContainer;
    final errorColor = theme.colorScheme.error;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: AppRadius.roundedXL,
              color: errorContainer,
              border: Border.all(color: errorColor.withValues(alpha: 0.32)),
              boxShadow: [
                BoxShadow(
                  color: errorColor.withValues(alpha: 0.14),
                  blurRadius: 18,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Decorative corner arc
                Positioned(
                  top: -18,
                  right: -18,
                  child: CustomPaint(
                    size: const Size(72, 72),
                    painter: _ArcPainter(color: errorColor),
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      // Pulsing icon badge
                      ScaleTransition(
                        scale: _pulseAnimation,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: onErrorContainer.withValues(alpha: 0.14),
                            border: Border.all(
                              color: onErrorContainer.withValues(alpha: 0.45),
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            Icons.play_circle_outline_rounded,
                            color: onErrorContainer,
                            size: 24,
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Playback Error',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: onErrorContainer,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.1,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Watch this video on YouTube instead.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: onErrorContainer.withValues(alpha: 0.7),
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 10),

                      // CTA
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: _isLaunching
                            ? SizedBox(
                                key: const ValueKey('loading'),
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(errorColor),
                                ),
                              )
                            : FilledButton.icon(
                                key: const ValueKey('btn'),
                                onPressed: _launchYouTube,
                                style: FilledButton.styleFrom(
                                  backgroundColor: errorColor,
                                  foregroundColor: theme.colorScheme.onError,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: AppRadius.roundedL,
                                  ),
                                  elevation: 0,
                                ),
                                icon: const Icon(Icons.open_in_new_rounded, size: 14),
                                label: const Text(
                                  'Open',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Decorative corner arc painter ─────────────────────────────────────────────

class _ArcPainter extends CustomPainter {
  _ArcPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (var i = 0; i < 3; i++) {
      paint.color = color.withValues(alpha: 0.10 + i * 0.04);
      final r = 18.0 + i * 16;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(size.width, 0), radius: r),
        math.pi / 2,
        math.pi / 2,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.color != color;
}
