import 'package:flutter/material.dart';
import 'package:levelup_tube/src/core/extensions/context_extensions.dart';
import 'package:levelup_tube/src/features/library/models/video.dart';
import 'package:levelup_tube/src/features/library/views/widgets/dashboard_video_list.dart';
import 'package:levelup_tube/src/features/library/views/widgets/dashboard_video_list_shimmer.dart';
import 'package:levelup_tube/src/features/library/views/widgets/dashboard_video_player.dart';
import 'package:shimmer/shimmer.dart';

class VideoListWithPlayer extends StatelessWidget {
  const VideoListWithPlayer({
    required this.isLoading,
    required this.isEmpty,
    super.key,
    this.videos = const [],
    this.heroVideo,
    this.forcePlayTimestamp,
    this.onVideoTap,
    this.onVideoLongPress,
    this.onOptionsTap,
    this.onProgressUpdate,
    this.emptyWidget,
    this.heroPadding = const EdgeInsets.symmetric(horizontal: 16),
    this.heroShimmerRadius,
  });

  final bool isLoading;
  final bool isEmpty;
  final List<Video> videos;
  final Video? heroVideo;
  final int? forcePlayTimestamp;
  final void Function(Video)? onVideoTap;
  final void Function(Video)? onVideoLongPress;
  final void Function(Video)? onOptionsTap;
  final void Function(int, int)? onProgressUpdate;
  final Widget? emptyWidget;
  final EdgeInsetsGeometry heroPadding;
  final BorderRadius? heroShimmerRadius;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        // Hero Player
        Padding(
          padding: heroPadding,
          child: isLoading
              ? AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Shimmer.fromColors(
                    baseColor: context.colorScheme.surfaceContainerHighest,
                    highlightColor: context.colorScheme.surfaceContainer,
                    child: Container(
                      decoration: BoxDecoration(
                        color: context.colorScheme.surface,
                        borderRadius: heroShimmerRadius,
                      ),
                    ),
                  ),
                )
              : heroVideo != null
              ? DashboardVideoPlayer(
                  video: heroVideo!,
                  forcePlayTimestamp: forcePlayTimestamp,
                  onProgressUpdate: onProgressUpdate,
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(height: 16),
        // Video List
        Expanded(
          child: isLoading
              ? const DashboardVideoListShimmer()
              : isEmpty
              ? emptyWidget ?? const SizedBox.shrink()
              : DashboardVideoList(
                  videos: videos,
                  onVideoTap: onVideoTap,
                  onVideoLongPress: onVideoLongPress,
                  onOptionsTap: onOptionsTap,
                ),
        ),
      ],
    );
  }
}
