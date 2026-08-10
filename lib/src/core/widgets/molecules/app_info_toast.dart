import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:levelup_tube/src/core/design_system/app_radius.dart';

class AppInfoToast extends StatefulWidget {
  const AppInfoToast({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.actionLabel,
    this.onAction,
    this.onClose,
    this.isError = false,
    this.isLoading = false,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onClose;
  final bool isError;
  final bool isLoading;

  @override
  State<AppInfoToast> createState() => _AppInfoToastState();
}

class _AppInfoToastState extends State<AppInfoToast>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _pulseController;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _pulseAnimation;

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
   
    final containerColor = widget.isError ? theme.colorScheme.errorContainer : theme.colorScheme.primaryContainer;
    final onContainerColor = widget.isError ? theme.colorScheme.onErrorContainer : theme.colorScheme.onPrimaryContainer;
    final primaryColor = widget.isError ? theme.colorScheme.error : theme.colorScheme.primary;
    final onPrimaryColor = widget.isError ? theme.colorScheme.onError : theme.colorScheme.onPrimary;

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
              color: containerColor,
              border: Border.all(color: primaryColor.withValues(alpha: 0.32)),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.14),
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
                    painter: _ArcPainter(color: primaryColor),
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
                            color: onContainerColor.withValues(alpha: 0.14),
                            border: Border.all(
                              color: onContainerColor.withValues(alpha: 0.45),
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            widget.icon,
                            color: onContainerColor,
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
                              widget.title,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: onContainerColor,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.1,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.subtitle,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: onContainerColor.withValues(alpha: 0.7),
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (widget.actionLabel != null && widget.onAction != null) ...[
                        const SizedBox(width: 10),
                        // CTA
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          child: widget.isLoading
                              ? SizedBox(
                                  key: const ValueKey('loading'),
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(primaryColor),
                                  ),
                                )
                              : FilledButton.icon(
                                  key: const ValueKey('btn'),
                                  onPressed: widget.onAction,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    foregroundColor: onPrimaryColor,
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
                                  label: Text(
                                    widget.actionLabel!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                        ),
                      ],
                      if (widget.onClose != null) ...[
                        const SizedBox(width: 4),
                        IconButton(
                          icon: Icon(Icons.close, color: onContainerColor.withValues(alpha: 0.7), size: 20),
                          onPressed: widget.onClose,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          style: IconButton.styleFrom(
                            minimumSize: const Size(32, 32),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
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
