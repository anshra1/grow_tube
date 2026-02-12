import 'package:flutter/material.dart';
import 'package:skill_tube/src/core/design_system/app_colors.dart';
import 'package:skill_tube/src/core/design_system/app_radius.dart';
import 'package:skill_tube/src/core/design_system/app_sizes.dart';
import 'package:skill_tube/src/core/design_system/app_typography.dart';
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
        : 0;

    // Remaining or watched time formatting?
    // Design has "12:40" and "24:15".
    final currentStr = _formatDuration(video.lastWatchedPositionSeconds);
    final totalStr = _formatDuration(video.durationSeconds);

    return AspectRatio(
      aspectRatio:
          16 /
          9, // Standard video ratio for hero? Design implies taller, maybe 4/3 or custom.
      // Design has h-48 (12rem = 192px).
      // Let's use a SizedBox with height ~200.
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.r16),
          color: context.colors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            Image.network(
              video.thumbnailUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: Colors.grey[800]),
            ),

            // Gradient Overlay
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black87, // Darker at bottom
                  ],
                  stops: [0.4, 0.9],
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
                        color: AppColors.primary.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(AppRadius.r16),
                      ),
                      child: Text(
                        'Resume',
                        style: AppTypography.labelSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                  // Category (Channel Name as proxy?)
                  Text(
                    video.channelName.toUpperCase(),
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.primary200, // or a lighter primary
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                    ),
                  ),
                  gapH4,

                  // Title
                  Text(
                    video.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.h3.copyWith(
                      color: Colors.white,
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
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
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
                                  style: AppTypography.labelSmall.copyWith(
                                    color: Colors.white70,
                                  ),
                                ),
                                Text(
                                  totalStr,
                                  style: AppTypography.labelSmall.copyWith(
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                            gapH4,
                            ClipRRect(
                              borderRadius: BorderRadius.circular(AppRadius.r4),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 4,
                                backgroundColor: Colors.white24,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.primary,
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
