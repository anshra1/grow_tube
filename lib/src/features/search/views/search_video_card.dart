import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:levelup_tube/src/core/design_system/app_radius.dart';
import 'package:levelup_tube/src/core/design_system/app_shadows.dart';
import 'package:levelup_tube/src/core/design_system/app_sizes.dart';
import 'package:levelup_tube/src/core/extensions/context_extensions.dart';
import 'package:levelup_tube/src/features/library/models/video.dart';

class SearchVideoCard extends StatelessWidget {
  const SearchVideoCard({
    required this.video,
    this.customSubtitle,
    this.onTap,
    super.key,
  });

  final Video video;
  final String? customSubtitle;
  final VoidCallback? onTap;

  String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
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
          child: InkWell(
            borderRadius: AppRadius.roundedL,
            overlayColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.pressed)) {
                return context.colorScheme.primary.withValues(alpha: 0.12);
              }
              return null;
            }),
            onTap: () {
              Feedback.forTap(context);
              HapticFeedback.heavyImpact();
              HapticFeedback.vibrate();
              onTap?.call();
            },
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.p4),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          // Thumbnail with Duration Overlay
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: AppRadius.roundedM,
                                  child: SizedBox(
                                    width: 120,
                                    height: 67,
                                    child: CachedNetworkImage(
                                      imageUrl: video.thumbnailUrl,
                                      fit: BoxFit.cover,
                                      errorWidget: (context, url, error) => Image.asset(
                                        'assets/images/no_image_available.png',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 4,
                                  right: 4,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.8),
                                      borderRadius: AppRadius.roundedS,
                                    ),
                                    child: Text(
                                      _formatDuration(video.durationSeconds),
                                      style: context.textTheme.labelSmall?.copyWith(
                                        color: Colors.white,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Gap(16),
                          // Content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  video.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: context.colorScheme.onSurface,
                                  ),
                                ),
                                const Gap(4),
                                Text(
                                  video.channelName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.textTheme.labelSmall?.copyWith(
                                    color: context.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                if (customSubtitle != null) ...[
                                  const Gap(6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: context.colorScheme.secondaryContainer,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      customSubtitle!,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: context.colorScheme.onSecondaryContainer,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
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
        ),
      ),
    );
  }
}
