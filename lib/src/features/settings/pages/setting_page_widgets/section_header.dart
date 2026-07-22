import 'package:flutter/material.dart';
import 'package:levelup_tube/src/core/design_system/app_sizes.dart';
import 'package:levelup_tube/src/core/extensions/context_extensions.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({required this.title, super.key});
  final String title;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.p16,
          AppSizes.p16,
          AppSizes.p16,
          AppSizes.p8,
        ),
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: context.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
