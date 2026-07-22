import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:levelup_tube/src/core/design_system/app_radius.dart';
import 'package:levelup_tube/src/core/design_system/app_sizes.dart';
import 'package:levelup_tube/src/core/di/injection_container.dart' as di;
import 'package:levelup_tube/src/core/extensions/context_extensions.dart';
import 'package:levelup_tube/src/features/connectivity/presentation/bloc/connectivity_cubit.dart';
import 'package:levelup_tube/src/features/connectivity/presentation/widgets/connectivity_toast_controller.dart';
import 'package:levelup_tube/src/features/library/models/video.dart';
import 'package:levelup_tube/src/features/library/views/dashboard_widgets/delete_video_dialog.dart';
import 'package:levelup_tube/src/features/playlist/viewmodels/playlist_detail_cubit.dart';
import 'package:shimmer/shimmer.dart';

class DashboardVideoCard extends StatelessWidget {
  const DashboardVideoCard({
    required this.video,
    this.onTap,
    this.onLongPress,
    this.onOptionsTap,
    super.key,
  });

  final Video video;

  /// Optional override for tap behavior.
  /// If null, defaults to LibraryVideoSelectedEvent dispatch.
  final VoidCallback? onTap;

  /// Optional override for long-press behavior.
  /// If null, defaults to showing the delete video dialog.
  final VoidCallback? onLongPress;

  /// Optional override for the existing three-dot control.
  final VoidCallback? onOptionsTap;
  static final ConnectivityToastController _toastController = di
      .sl<ConnectivityToastController>();

  String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final progress = video.durationSeconds > 0
        ? (video.lastWatchedPositionSeconds / video.durationSeconds).clamp(
            0.0,
            1.0,
          )
        : 0.0;

    final percentage = (progress * 100).toInt();

    final handleOptions =
        onLongPress ??
        () {
          showDialog<void>(
            context: context,
            builder: (dialogContext) => DeleteVideoDialog(
              videoTitle: video.title,
              onDelete: () {
                context.read<PlaylistDetailCubit>().removeVideo(video.id);
              },
            ),
          );
        };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: AppRadius.roundedL,
          border: Border.all(
            color: context.colorScheme.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
        child: ClipRRect(
          borderRadius: AppRadius.roundedL,
          child: InkWell(
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
              if (onTap != null) {
                onTap!();
                return;
              }
              if (context.read<ConnectivityCubit>().state ==
                  ConnectivityStatus.offline) {
                _toastController.nudgeOffline();
                return;
              }
              context.read<PlaylistDetailCubit>().selectVideo(video);
            },
            onLongPress: handleOptions,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thumbnail with Duration Overlay
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: AppRadius.roundedM,
                        child: SizedBox(
                          width: 140,
                          height: 79,
                          child: CachedNetworkImage(
                            imageUrl: video.thumbnailUrl,
                            fit: BoxFit.cover,
                            memCacheWidth: 420,
                            memCacheHeight: 237,
                            placeholder: (context, url) => Shimmer.fromColors(
                              baseColor: context.colorScheme.surfaceContainerHighest,
                              highlightColor: context.colorScheme.surface,
                              child: Container(color: Colors.white),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: context.colorScheme.surfaceContainerHighest,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
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
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(12),
                  // content
                  Expanded(
                    child: SizedBox(
                      height: 79,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            video.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: context.colorScheme.onSurface,
                              height: 1.2,
                            ),
                          ),
                          const Gap(4),
                          // Text(
                          //   video.channelName,
                          //   maxLines: 1,
                          //   overflow: TextOverflow.ellipsis,
                          //   style: context.textTheme.labelMedium?.copyWith(
                          //     color: context.colorScheme.onSurfaceVariant,
                          //     fontWeight: FontWeight.w500,
                          //   ),
                          // ),
                          const Spacer(),
                          // Progress Bar & Percentage
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: AppRadius.roundedS,
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 4,
                                  backgroundColor: context.colorScheme.primary
                                      .withValues(alpha: 0.1),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    context.colorScheme.primary,
                                  ),
                                ),
                              ),
                              gapH4,
                              Text(
                                '$percentage% watched',
                                style: context.textTheme.labelSmall?.copyWith(
                                  color: percentage > 0
                                      ? context.colorScheme.primary
                                      : context.colorScheme.onSurfaceVariant,
                                  fontWeight: percentage > 0
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (video.isPinned) ...[
                    const Gap(8),
                    Icon(
                      Icons.push_pin,
                      color: context.colorScheme.primary,
                      size: 18,
                    ),
                  ]
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
