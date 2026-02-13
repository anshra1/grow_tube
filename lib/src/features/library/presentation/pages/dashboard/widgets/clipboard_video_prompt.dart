import 'package:flutter/material.dart';
import 'package:skill_tube/src/core/constants/app_icons.dart';
import 'package:skill_tube/src/core/design_system/app_radius.dart';
import 'package:skill_tube/src/core/design_system/app_sizes.dart';
import 'package:skill_tube/src/core/utils/extensions/context_extensions.dart';

class ClipboardVideoPrompt extends StatelessWidget {
  const ClipboardVideoPrompt({
    required this.url,
    required this.onAdd,
    required this.onWatch,
    required this.onDismiss,
    super.key,
  });

  final String url;
  final VoidCallback onAdd;
  final VoidCallback onWatch;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSizes.p8),
      padding: const EdgeInsets.all(AppSizes.p16),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHighest,
        borderRadius: AppRadius.roundedXL,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'YouTube Link Detected',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: onDismiss,
                icon: const Icon(Icons.close),
                iconSize: 20,
              ),
            ],
          ),
          gapH8,
          Text(
            url,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          gapH16,
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(AppIcons.add),
                  label: const Text('Add to Library'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.colorScheme.onSurface,
                    side: BorderSide(color: context.colorScheme.outline),
                  ),
                ),
              ),
              gapW12,
              Expanded(
                child: FilledButton.icon(
                  onPressed: onWatch,
                  icon: const Icon(AppIcons.play),
                  label: const Text('Watch Now'),
                  style: FilledButton.styleFrom(
                    backgroundColor: context.colorScheme.primary,
                    foregroundColor: context.colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
