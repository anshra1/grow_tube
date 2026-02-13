import 'package:flutter/material.dart';
import 'package:skill_tube/src/core/constants/app_icons.dart';
import 'package:skill_tube/src/core/constants/app_strings.dart';
import 'package:skill_tube/src/core/design_system/app_radius.dart';
import 'package:skill_tube/src/core/design_system/app_shadows.dart';
import 'package:skill_tube/src/core/design_system/app_sizes.dart';
import 'package:skill_tube/src/core/utils/extensions/context_extensions.dart';
import 'package:skill_tube/src/features/library/domain/entities/video.dart';

class DashboardHero extends StatelessWidget {
  const DashboardHero({required this.video, super.key});

  final Video video;

  @override
  Widget build(BuildContext context) {
    // Determine progress
    final progress = video.durationSeconds > 0
        ? (video.lastWatchedPositionSeconds / video.durationSeconds).clamp(0.0, 1.0)
        : 0.0;

    final currentStr = _formatDuration(video.lastWatchedPositionSeconds);
    final totalStr = _formatDuration(video.durationSeconds);

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: AppRadius.roundedXL,
          color: context.colorScheme.surface,
          boxShadow: AppShadows.elevation3,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            Image.network(
              video.thumbnailUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: context.colorScheme.surfaceContainerHighest,
              ),
            ),

            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    context.colorScheme.scrim.withValues(alpha: 0.8),
                  ],
                  stops: const [0.4, 0.9],
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(AppSizes.p20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Badge
                  if (progress > 0)
                    Container(
                      margin: const EdgeInsets.only(bottom: AppSizes.p12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.p12,
                        vertical: AppSizes.p4,
                      ),
                      decoration: BoxDecoration(
                        color: context.colorScheme.primary,
                        borderRadius: AppRadius.roundedXL,
                      ),
                      child: Text(
                        AppStrings.dashboardResume,
                        style: context.textTheme.labelSmall?.copyWith(
                          color: context.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                  // Category
                  Text(
                    video.channelName.toUpperCase(),
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colorScheme.primaryContainer,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                  gapH4,

                  // Title
                  Text(
                    video.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.headlineSmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant, // Or custom on-scrim color
                      height: 1.2,
                    ),
                  ),
                  gapH12,

                  // Progress Row
                  Row(
                    children: [
                      // Play Button
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: context.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          AppIcons.play,
                          color: context.colorScheme.onPrimary,
                          size: 24,
                        ),
                      ),
                      gapW12,

                      // Progress Bar & Times
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  currentStr,
                                  style: context.textTheme.labelSmall?.copyWith(
                                    color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                                  ),
                                ),
                                Text(
                                  totalStr,
                                  style: context.textTheme.labelSmall?.copyWith(
                                    color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                            gapH4,
                            ClipRRect(
                              borderRadius: AppRadius.roundedS,
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 4,
                                backgroundColor: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  context.colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    if (seconds <= 0) return '00:00';
    final duration = Duration(seconds: seconds);
    final min = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final sec = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (duration.inHours > 0) {
      return '${duration.inHours}:$min:$sec';
    }
    return '$min:$sec';
  }
}

  String _formatDuration(int seconds) {
    if (seconds <= 0) return '00:00';
    final duration = Duration(seconds: seconds);
    final min = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final sec = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (duration.inHours > 0) {
      return '${duration.inHours}:$min:$sec';
    }
    return '$min:$sec';
  }
