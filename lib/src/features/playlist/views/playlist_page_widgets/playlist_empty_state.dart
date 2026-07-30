import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:levelup_tube/src/core/design_system/app_radius.dart';
import 'package:levelup_tube/src/core/design_system/app_sizes.dart';
import 'package:levelup_tube/src/core/extensions/context_extensions.dart';
import 'package:levelup_tube/src/core/widgets/atoms/buttons/app_primary_button.dart';

class PlaylistEmptyState extends StatefulWidget {
  const PlaylistEmptyState({super.key});

  @override
  State<PlaylistEmptyState> createState() => _PlaylistEmptyStateState();
}

class _PlaylistEmptyStateState extends State<PlaylistEmptyState>
    with TickerProviderStateMixin {
  late final AnimationController _bounceController;
  late final Animation<double> _bounceAnim;
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);
    _bounceAnim = Tween<double>(begin: 0, end: -12).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    _scaleAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.p24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Floating Playlist Icon ──
            SizedBox(
              height: 240,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // Pulsing Glow
                  AnimatedBuilder(
                    animation: _scaleAnim,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnim.value,
                        child: child,
                      );
                    },
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.primary.withValues(alpha: 0.08),
                        boxShadow: [
                          BoxShadow(
                            color: colors.primary.withValues(alpha: 0.12),
                            blurRadius: 50,
                            spreadRadius: 15,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Floating Card
                  AnimatedBuilder(
                    animation: _bounceAnim,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _bounceAnim.value),
                        child: child,
                      );
                    },
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHighest.withValues(alpha: 0.7),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colors.outlineVariant.withValues(alpha: 0.6),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colors.shadow.withValues(alpha: 0.08),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.queue_music_rounded,
                          size: 64,
                          color: colors.primary,
                        ),
                      ),
                    ),
                  ),
                  
                  // Accent elements
                  Positioned(
                    top: 20,
                    left: 10,
                    child: AnimatedBuilder(
                      animation: _bounceAnim,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, -_bounceAnim.value * 0.5),
                          child: child,
                        );
                      },
                      child: Icon(
                        Icons.star_rounded,
                        color: colors.tertiary.withValues(alpha: 0.6),
                        size: 24,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 30,
                    right: 15,
                    child: AnimatedBuilder(
                      animation: _bounceAnim,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, -_bounceAnim.value * 0.7),
                          child: child,
                        );
                      },
                      child: Icon(
                        Icons.play_circle_outline_rounded,
                        color: colors.secondary.withValues(alpha: 0.5),
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const Gap(16),
            
            // ── Text Section ──
            Text(
              'This Playlist is Empty',
              textAlign: TextAlign.center,
              style: context.textTheme.headlineSmall?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            const Gap(12),
            Text(
              'Go back to your library and save videos to this playlist to build your collection.',
              textAlign: TextAlign.center,
              style: context.textTheme.bodyLarge?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const Gap(32),
            // ── Add Button ──
            SizedBox(
              height: AppSizes.buttonHeightXl,
              width: double.infinity,
              child: AppPrimaryButton(
                onPressed: () => context.go('/add'),
                borderRadius: AppRadius.roundedL,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Add Video',
                      style: context.textTheme.titleMedium?.copyWith(
                        color: colors.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
