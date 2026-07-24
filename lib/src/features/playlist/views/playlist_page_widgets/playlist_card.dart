import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:levelup_tube/src/core/design_system/app_radius.dart';
import 'package:levelup_tube/src/core/design_system/app_shadows.dart';
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
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
              onTap();
            },
            onLongPress: onLongPress,
            child: Padding(
              padding: const EdgeInsets.only(left: 4, right: 4),
              child: SizedBox(
                height: 100,
                width: double.infinity,
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          // Thumbnail with playlist icon overlay
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: SizedBox(
                              width: 144, // Constrain thumbnail width
                              child: ClipRRect(
                                borderRadius: AppRadius.roundedM,
                                child: AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: playlist.localThumbnailPath != null &&
                                          playlist.localThumbnailPath!.isNotEmpty &&
                                          File(playlist.localThumbnailPath!).existsSync()
                                      ? Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            Image.file(
                                              File(playlist.localThumbnailPath!),
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) =>
                                                  _placeholderBox(context),
                                            ),
                                            // Playlist icon overlay (bottom-right)
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
                                                      '${playlist.videoCount}',
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
                                      : playlist.thumbnailUrl != null
                                          ? Stack(
                                              fit: StackFit
                                                  .expand, // Ensures children fill the AspectRatio
                                              children: [
                                                CachedNetworkImage(
                                                  imageUrl: playlist.thumbnailUrl!,
                                                  fit: BoxFit
                                                      .cover, // Use cover for better fit
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
                                                // Playlist icon overlay (bottom-right)
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
                                                          '${playlist.videoCount}',
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
                              padding: const EdgeInsetsGeometry.symmetric(vertical: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    playlist.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: context.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: context.colorScheme.onSurface,
                                    ),
                                  ),
                                  const Gap(2),
                                  Text(
                                    _getSubtitle(),
                                    maxLines: 1,
                                    style: context.textTheme.labelSmall?.copyWith(
                                      color: context.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(2),
                    // More Options Icon & Pin
                    Padding(
                      padding: const EdgeInsetsGeometry.symmetric(vertical: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: onOptionsTap ?? onLongPress,
                            child: Icon(
                              Icons.more_vert,
                              color: context.colorScheme.onSurface,
                              size: 20,
                            ),
                          ),
                          if (playlist.isPinned)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Icon(
                                CupertinoIcons.pin,
                                color: context.colorScheme.onSurface,
                                size: 12,
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
