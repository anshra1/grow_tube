import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:levelup_tube/src/core/design_system/app_radius.dart';
import 'package:levelup_tube/src/core/design_system/app_shadows.dart';
import 'package:levelup_tube/src/core/extensions/context_extensions.dart';
import 'package:shimmer/shimmer.dart';

class PlaylistListShimmer extends StatelessWidget {
  const PlaylistListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            height: 100, // matches PlaylistCard
            decoration: BoxDecoration(
              color: context.colorScheme.surface,
              borderRadius: AppRadius.roundedL,
              border: Border.all(
                color: context.colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
              boxShadow: AppShadows.card,
            ),
            child: Shimmer.fromColors(
              baseColor: context.colorScheme.surfaceContainerHighest,
              highlightColor: context.colorScheme.surface,
              child: Padding(
                padding: const EdgeInsets.only(left: 4, right: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          // Thumbnail skeleton
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: SizedBox(
                              width: 144,
                              child: AspectRatio(
                                aspectRatio: 16 / 9,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: AppRadius.roundedM,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const Gap(16),
                          // Content skeleton
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Title line 1
                                  Container(
                                    width: double.infinity,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const Gap(6),
                                  // Title line 2
                                  Container(
                                    width: 120,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const Gap(10),
                                  // Subtitle
                                  Container(
                                    width: 80,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4),
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
                    // More Options Icon skeleton
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
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
        );
      },
    );
  }
}
