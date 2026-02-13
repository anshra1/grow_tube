import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:skill_tube/src/core/design_system/app_radius.dart';
import 'package:skill_tube/src/core/design_system/app_shadows.dart';
import 'package:skill_tube/src/core/design_system/app_sizes.dart';
import 'package:skill_tube/src/core/utils/extensions/context_extensions.dart';
import 'package:skill_tube/src/features/library/domain/entities/video.dart';
import 'package:skill_tube/src/features/library/presentation/bloc/library_bloc.dart';
import 'package:skill_tube/src/features/library/presentation/bloc/library_event.dart';
import 'package:skill_tube/src/features/library/presentation/pages/dashboard/widgets/delete_video_dialog.dart';

class DashboardVideoCard extends StatelessWidget {
  const DashboardVideoCard({required this.video, super.key});

  final Video video;

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

    return GestureDetector(
      onTap: () async {
        await context.push('/player/${video.youtubeId}');
        // Force portrait when returning from the player
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      },
      onLongPress: () {
        showDialog(
          context: context,
          builder: (dialogContext) => DeleteVideoDialog(
            videoTitle: video.title,
            onDelete: () {
              context.read<LibraryBloc>().add(LibraryVideoDeletedEvent(video.id));
            },
          ),
        );
      },
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
            // Thumbnail with Duration Overlay
            Stack(
              children: [
                ClipRRect(
                  borderRadius: AppRadius.roundedM,
                  child: SizedBox(
                    width: 120,
                    height: 70,
                    child: Image.network(
                      video.thumbnailUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(color: context.colorScheme.surfaceContainerHighest),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
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
            gapW16,
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

                  Gap(2),
                  Text(
                    video.channelName,
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  gapH8,
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
                                backgroundColor: context.colorScheme.primary.withValues(
                                  alpha: 0.1,
                                ),
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
          ],
        ),
      ),
    );
  }
}
