import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:levelup_tube/src/core/design_system/app_radius.dart';
import 'package:levelup_tube/src/core/design_system/app_shadows.dart';
import 'package:levelup_tube/src/core/design_system/app_sizes.dart';
import 'package:levelup_tube/src/core/utils/extensions/context_extensions.dart';

class DashboardVideoListShimmer extends StatelessWidget {
  const DashboardVideoListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.p16,
      ).copyWith(bottom: AppSizes.p48),
      itemCount: 5, // Show 5 skeleton items
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSizes.p16),
          child: Shimmer.fromColors(
            baseColor: context.colorScheme.surfaceContainerHighest,
            highlightColor: context.colorScheme.surface,
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
                  // Thumbnail skeleton
                  Container(
                    width: 120,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppRadius.roundedM,
                    ),
                  ),
                  const SizedBox(width: AppSizes.p16),

                  // Content skeleton
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Title line 1
                        Container(
                          width: double.infinity,
                          height: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(height: AppSizes.p4),
                        // Title line 2
                        Container(width: 140, height: 14, color: Colors.white),
                        const SizedBox(height: AppSizes.p8),

                        // Channel name
                        Container(width: 80, height: 10, color: Colors.white),
                        const SizedBox(height: AppSizes.p12),

                        // Progress Bar & Percentage
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              height: 4,
                              color: Colors.white,
                            ),
                            const SizedBox(height: AppSizes.p4),
                            Container(width: 60, height: 10, color: Colors.white),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
