import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:levelup_tube/src/core/design_system/app_radius.dart';
import 'package:levelup_tube/src/core/extensions/context_extensions.dart';
import 'package:levelup_tube/src/features/playlist/models/playlist_model.dart';
import 'package:shimmer/shimmer.dart';

class PlaylistCard extends StatelessWidget {
  const PlaylistCard({
    required this.playlist,
    required this.onTap,
    this.onLongPress,
    this.onOptionsTap,
    super.key,
  });

  final PlaylistModel playlist;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onOptionsTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 4,
          right: 4,
          top: 4,
          bottom: 4,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail with playlist icon overlay
            ClipRRect(
              borderRadius: AppRadius.roundedM,
              child: SizedBox(
                width: 160,
                height: 90,
                child: playlist.thumbnailUrl != null
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          CachedNetworkImage(
                            imageUrl: playlist.thumbnailUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                Shimmer.fromColors(
                                  baseColor: context
                                      .colorScheme
                                      .surfaceContainerHighest,
                                  highlightColor: context
                                      .colorScheme
                                      .surfaceContainer,
                                  child: Container(
                                    color: Colors.white,
                                  ),
                                ),
                            errorWidget: (context, url, error) =>
                                _placeholderBox(context),
                          ),
                          // Playlist icon overlay (bottom-right)
                          Positioned(
                            bottom: 6,
                            right: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
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
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${playlist.videoCount}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
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
            const Gap(8),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //const Gap(2), // alignment tweak
                  Text(
                    playlist.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: context.colorScheme.onSurface,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    _getSubtitle(),
                    maxLines: 1,
                    style: context.textTheme.labelMedium?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            // More Options Icon
            const Gap(2),
            GestureDetector(
              onTap: onOptionsTap ?? onLongPress,
              child: Icon(
                Icons.more_vert,
                color: context.colorScheme.onSurface,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getSubtitle() {
    var subtitle = 'Private • Playlist';
    if (playlist.youtubePlaylistId != null) {
      subtitle = 'YouTube • Playlist';
    }
    return subtitle;
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
