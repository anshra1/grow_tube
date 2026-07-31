import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:levelup_tube/src/core/design_system/app_radius.dart';
import 'package:levelup_tube/src/core/design_system/app_shadows.dart';
import 'package:levelup_tube/src/core/extensions/context_extensions.dart';
import 'package:shimmer/shimmer.dart';

class PlaylistImportingCard extends StatelessWidget {
  const PlaylistImportingCard({
    required this.title,
    required this.currentProgress,
    required this.totalVideos,
    this.thumbnailUrl,
    super.key,
  });

  final String title;
  final int currentProgress;
  final int totalVideos;
  final String? thumbnailUrl;

  @override
  Widget build(BuildContext context) {
    final progress = totalVideos > 0 ? (currentProgress / totalVideos) : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Opacity(
        opacity: 0.7, // "Ghost" effect
        child: Container(
          decoration: BoxDecoration(
            borderRadius: AppRadius.roundedL,
            border: Border.all(
              color: context.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
            boxShadow: AppShadows.card,
          ),
          child: Material(
            color: context.colorScheme.surface,
            borderRadius: AppRadius.roundedL,
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.only(left: 4, right: 4),
              child: SizedBox(
                height: 100,
                width: double.infinity,
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          // Thumbnail placeholder or image
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: SizedBox(
                              height: 90,
                              width: 144, // Constrain thumbnail width
                              child: ClipRRect(
                                borderRadius: AppRadius.roundedM,
                                child: AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: thumbnailUrl != null
                                      ? Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            CachedNetworkImage(
                                              imageUrl: thumbnailUrl!,
                                              fit: BoxFit.cover,
                                              memCacheWidth: 480,
                                              memCacheHeight: 270,
                                              placeholder: (context, url) =>
                                                  Shimmer.fromColors(
                                                baseColor: context
                                                    .colorScheme
                                                    .surfaceContainerHighest,
                                                highlightColor: context
                                                    .colorScheme
                                                    .surfaceContainer,
                                                child: Container(color: Colors.white),
                                              ),
                                              errorWidget: (context, url, error) =>
                                                  _placeholderBox(context),
                                            ),
                                            // Playlist icon overlay
                                            Positioned(
                                              bottom: 4,
                                              right: 4,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 4,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.black.withValues(
                                                    alpha: 0.8,
                                                  ),
                                                  borderRadius: AppRadius.roundedS,
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    const Icon(
                                                      Icons.playlist_play,
                                                      color: Colors.white,
                                                      size: 14,
                                                    ),
                                                    const SizedBox(width: 2),
                                                    Text(
                                                      '$totalVideos',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : _placeholderBox(context),
                                ),
                              ),
                            ),
                          ),
                          const Gap(16),
                          // Content
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: context.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: context.colorScheme.onSurface,
                                    ),
                                  ),
                                  const Gap(4),
                                  Text(
                                    totalVideos == 0
                                        ? 'Fetching playlist data...'
                                        : 'Importing $currentProgress of $totalVideos...',
                                    maxLines: 1,
                                    style: context.textTheme.labelSmall?.copyWith(
                                      color: context.colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Gap(8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      minHeight: 4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Gap(16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _placeholderBox(BuildContext context) {
    return ColoredBox(
      color: context.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.playlist_play_rounded,
          color: context.colorScheme.onSurfaceVariant,
          size: 40,
        ),
      ),
    );
  }
}
