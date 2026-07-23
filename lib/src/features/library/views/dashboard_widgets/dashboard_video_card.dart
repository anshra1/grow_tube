import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:levelup_tube/src/core/design_system/app_radius.dart';
import 'package:levelup_tube/src/core/design_system/app_shadows.dart';
import 'package:levelup_tube/src/core/design_system/app_sizes.dart';
import 'package:levelup_tube/src/core/di/injection_container.dart' as di;
import 'package:levelup_tube/src/core/extensions/context_extensions.dart';
import 'package:levelup_tube/src/features/connectivity/presentation/bloc/connectivity_cubit.dart';
import 'package:levelup_tube/src/features/connectivity/presentation/widgets/connectivity_toast_controller.dart';
import 'package:levelup_tube/src/features/library/models/video.dart';
import 'package:levelup_tube/src/features/library/views/dashboard_widgets/delete_video_dialog.dart';
import 'package:levelup_tube/src/features/playlist/viewmodels/playlist_detail_cubit.dart';

class DashboardVideoCard extends StatelessWidget {
  const DashboardVideoCard({
    required this.video,
    this.onTap,
    this.onLongPress,
    this.onOptionsTap,
    super.key,
  });

  final Video video;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
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
        ? (video.lastWatchedPositionSeconds / video.durationSeconds).clamp(0.0, 1.0)
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
              if (onTap != null) {
                onTap!();
                return;
              }
              if (context.read<ConnectivityCubit>().state == ConnectivityStatus.offline) {
                _toastController.nudgeOffline();
                return;
              }
              context.read<PlaylistDetailCubit>().selectVideo(video);
            },
            onLongPress: handleOptions,
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
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: AppRadius.roundedM,
                                child: SizedBox(
                                  width: 120,
                                  height: 67,
                                  child: CachedNetworkImage(
                                    scale: 1.2,
                                    imageUrl: video.thumbnailUrl,
                                    fit: BoxFit.cover, // Fill the whole box
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
                          const Gap(16),
                          // content
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
                                const Gap(2),
                                Text(
                                  video.channelName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.textTheme.labelSmall?.copyWith(
                                    color: context.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const Gap(8),
                                // Progress Bar & Percentage
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: ClipRRect(
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
                                        ),
                                      ],
                                    ),
                                    const Gap(4),
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
                        ],
                      ),
                    ),
                    const Gap(2),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: onOptionsTap,
                          child: Icon(
                            Icons.more_vert,
                            color: context.colorScheme.onSurface,
                            size: 20,
                          ),
                        ),
                        if (video.isPinned)
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
