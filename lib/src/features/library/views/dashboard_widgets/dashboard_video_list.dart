import 'package:flutter/material.dart';
import 'package:levelup_tube/src/core/design_system/app_sizes.dart';
import 'package:levelup_tube/src/features/library/models/video.dart';
import 'package:levelup_tube/src/features/library/views/dashboard_widgets/dashboard_video_card.dart';

class DashboardVideoList extends StatelessWidget {
  const DashboardVideoList({
    required this.videos,
    this.onVideoTap,
    this.onVideoLongPress,
    this.onOptionsTap,
    super.key,
  });

  final List<Video> videos;
  /// Optional override for individual video tap.
  /// If null, each card uses its default behavior (LibraryVideoSelectedEvent).
  final void Function(Video)? onVideoTap;
  /// Optional override for individual video long-press.
  /// If null, each card uses its default behavior (delete dialog).
  final void Function(Video)? onVideoLongPress;
  /// Optional override for the existing three-dot control.
  final void Function(Video)? onOptionsTap;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.p8,
      ),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final video = videos[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSizes.p16),
          child: DashboardVideoCard(
            video: video,
            onTap: onVideoTap != null ? () => onVideoTap!(video) : null,
            onLongPress: onVideoLongPress != null ? () => onVideoLongPress!(video) : null,
            onOptionsTap: onOptionsTap != null
                ? () => onOptionsTap!(video)
                : null,
          ),
        );
      },
    );
  }
}
