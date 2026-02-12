import 'package:flutter/material.dart';
import 'package:skill_tube/src/core/design_system/app_colors.dart';
import 'package:skill_tube/src/core/design_system/app_radius.dart';
import 'package:skill_tube/src/core/design_system/app_sizes.dart';
import 'package:skill_tube/src/core/design_system/app_typography.dart';
import 'package:skill_tube/src/core/utils/extensions/context_extensions.dart';
import 'package:skill_tube/src/features/library/domain/entities/video.dart';

class DashboardVideoList extends StatelessWidget {
  const DashboardVideoList({required this.videos, super.key});

  final List<Video> videos;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.p24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.p16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'My Videos',
                      style: AppTypography.h3.copyWith(
                        color: context.colors.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // TODO: Navigate to full list? Or just scroll?
                        // "See all"
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        textStyle: AppTypography.labelLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text('See all'),
                    ),
                  ],
                ),
              );
            }

            // Adjust index because of header
            final video = videos[index - 1];
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.p16),
              child: DashboardVideoCard(video: video),
            );
          },
          childCount: videos.length + 1, // +1 for header
        ),
      ),
    );
  }
}

class DashboardVideoCard extends StatelessWidget {
  const DashboardVideoCard({required this.video, super.key});

  final Video video;

  @override
  Widget build(BuildContext context) {
    final progress = video.durationSeconds > 0
        ? (video.lastWatchedPositionSeconds / video.durationSeconds).clamp(0.0, 1.0)
        : 0;

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r12),
        border: Border.all(
          color: context.isDarkMode ? Colors.white10 : Colors.black.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSizes.p12),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.r8),
            child: SizedBox(
              width: 112, // w-28 = 7rem = 112px
              height: 80, // h-20 = 5rem = 80px
              child: Image.network(
                video.thumbnailUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: Colors.grey[800]),
              ),
            ),
          ),
          gapW16,
          // content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        video.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.colors.textPrimary,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const Icon(Icons.more_vert_rounded, size: 20, color: Colors.grey),
                  ],
                ),
                gapH4,
                Text(
                  video.channelName,
                  style: AppTypography.labelSmall.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
                gapH8,
                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.r4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: context.isDarkMode
                        ? Colors.grey[800]
                        : Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
