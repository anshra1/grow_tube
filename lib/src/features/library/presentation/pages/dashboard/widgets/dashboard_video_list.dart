import 'package:flutter/material.dart';
import 'package:skill_tube/src/core/design_system/app_sizes.dart';
import 'package:skill_tube/src/features/library/domain/entities/video.dart';
import 'package:skill_tube/src/features/library/presentation/pages/dashboard/widgets/dashboard_video_card.dart';

class DashboardVideoList extends StatelessWidget {
  const DashboardVideoList({required this.videos, super.key});

  final List<Video> videos;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.p16,
      ).copyWith(bottom: AppSizes.p48),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final video = videos[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSizes.p16),
          child: DashboardVideoCard(video: video),
        );
      },
    );
  }
}
