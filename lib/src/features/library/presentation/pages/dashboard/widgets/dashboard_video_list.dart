import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skill_tube/src/core/constants/app_icons.dart';
import 'package:skill_tube/src/core/constants/app_strings.dart';
import 'package:skill_tube/src/core/design_system/app_radius.dart';
import 'package:skill_tube/src/core/design_system/app_shadows.dart';
import 'package:skill_tube/src/core/design_system/app_sizes.dart';
import 'package:skill_tube/src/core/utils/extensions/context_extensions.dart';
import 'package:skill_tube/src/features/library/domain/entities/video.dart';
import 'package:skill_tube/src/features/library/presentation/pages/dashboard/widgets/dashboard_hero.dart';

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
                      AppStrings.dashboardMyVideos,
                      style: context.textTheme.headlineSmall?.copyWith(
                        color: context.colorScheme.onSurface,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // "See all"
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: context.colorScheme.primary,
                        textStyle: context.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text(AppStrings.dashboardSeeAll),
                    ),
                  ],
                ),
              );
            }

            // Adjust index because of header
            final video = videos[index - 1];

            // First video uses Hero Player
            if (index == 1) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.p16),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: DashboardHero(video: video),
                ),
              );
            }

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
        : 0.0;

    return GestureDetector(
      onTap: () => context.push('/player/${video.youtubeId}'),
      child: Container(
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: AppRadius.roundedL,
          border: Border.all(
            color: context.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
          boxShadow: AppShadows.card,
        ),
        padding: const EdgeInsets.all(AppSizes.p12),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: AppRadius.roundedM,
              child: SizedBox(
                width: 112, // w-28 = 7rem = 112px
                height: 80, // h-20 = 5rem = 80px
                child: Image.network(
                  video.thumbnailUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: context.colorScheme.surfaceContainerHighest,
                  ),
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
                          style: context.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: context.colorScheme.onSurface,
                            height: 1.2,
                          ),
                        ),
                      ),
                      Icon(
                        AppIcons.more,
                        size: 20,
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                  gapH4,
                  Text(
                    video.channelName,
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  gapH8,
                  // Progress Bar
                  ClipRRect(
                    borderRadius: AppRadius.roundedS,
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(context.colorScheme.primary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
