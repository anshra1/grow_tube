import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class AddHeroBanner extends StatelessWidget {
  const AddHeroBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          //  Icon(Icons.add_circle_outline, size: 64, color: theme.colorScheme.primary),
          const Gap(16),
          Text(
            'Add to Your Library',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const Gap(8),
          Text(
            'Add a video, create a playlist, or import from YouTube',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
          const Gap(8),
        ],
      ),
    );
  }
}
