import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';
import 'package:levelup_tube/src/core/design_system/app_radius.dart';
import 'package:levelup_tube/src/core/design_system/app_sizes.dart';
import 'package:levelup_tube/src/features/connectivity/presentation/bloc/connectivity_cubit.dart';
import 'package:levelup_tube/src/features/connectivity/presentation/widgets/connectivity_toast_controller.dart';
import 'package:levelup_tube/src/core/di/injection_container.dart' as di;
import 'package:levelup_tube/src/core/extensions/context_extensions.dart';
import 'package:levelup_tube/src/features/library/domain/entities/video.dart';
import 'package:levelup_tube/src/features/library/presentation/bloc/library_bloc.dart';
import 'package:levelup_tube/src/features/library/presentation/bloc/library_event.dart';
import 'package:levelup_tube/src/features/library/presentation/pages/widgets/delete_video_dialog.dart';

class DashboardVideoCard extends StatelessWidget {
  const DashboardVideoCard({
    required this.video,
    this.onTap,
    this.onLongPress,
    super.key,
  });

  final Video video;
  /// Optional override for tap behavior.
  /// If null, defaults to LibraryVideoSelectedEvent dispatch.
  final VoidCallback? onTap;
  /// Optional override for long-press behavior.
  /// If null, defaults to showing the delete video dialog.
  final VoidCallback? onLongPress;
  static final ConnectivityToastController _toastController =
      di.sl<ConnectivityToastController>();

  String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final progress = video.durationSeconds > 0
        ? (video.lastWatchedPositionSeconds / video.durationSeconds).clamp(0.0, 1.0)
        : 0.0;

    final percentage = (progress * 100).toInt();

    final handleOptions = onLongPress ?? () {
      showDialog(
        context: context,
        builder: (dialogContext) => DeleteVideoDialog(
          videoTitle: video.title,
          onDelete: () {
            context.read<LibraryBloc>().add(
              LibraryVideoDeletedEvent(video.id),
            );
          },
        ),
      );
    };

    return InkWell(
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
        context.read<LibraryBloc>().add(LibraryVideoSelectedEvent(video));
      },
      onLongPress: handleOptions,
      child: Padding(
        padding: const EdgeInsets.only(left: 0, right: 0, top: 4, bottom: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail with Duration Overlay
            Stack(
              children: [
                ClipRRect(
                  borderRadius: AppRadius.roundedM,
                  child: SizedBox(
                    width: 160,
                    height: 90,
                    child: CachedNetworkImage(
                      imageUrl: video.thumbnailUrl,
                      fit: BoxFit.cover,
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
            const Gap(8),
            // content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: context.colorScheme.onSurface,
                    ),
                  ),
                  // const Gap(4),
                  // Text(
                  //   video.channelName,
                  //   maxLines: 1,
                  //   overflow: TextOverflow.ellipsis,
                  //   style: context.textTheme.labelMedium?.copyWith(
                  //     color: context.colorScheme.onSurfaceVariant,
                  //   ),
                  // ),
                  gapH8,
                  // Progress Bar & Percentage
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: AppRadius.roundedS,
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 4,
                                backgroundColor: context
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.1),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  context.colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      gapH4,
                      Text(
                        '$percentage% watched',
                        style: context.textTheme.labelSmall?.copyWith(
                          color: percentage > 0
                              ? context.colorScheme.primary
                              : context.colorScheme.onSurfaceVariant,
                          fontWeight: percentage > 0
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // More Options Icon
            GestureDetector(
              onTap: handleOptions,
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
}
