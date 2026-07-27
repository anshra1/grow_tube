
import 'package:flutter/material.dart';
import 'package:levelup_tube/src/core/extensions/context_extensions.dart';
import 'package:shimmer/shimmer.dart';

class SettingCardShimmer extends StatelessWidget {
  const SettingCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.colorScheme.surfaceContainerHighest,
      highlightColor: context.colorScheme.surface,
      child: Column(
        children: List.generate(
          3,
          (index) => ListTile(
            leading: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            title: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 140,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            subtitle: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 80,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
