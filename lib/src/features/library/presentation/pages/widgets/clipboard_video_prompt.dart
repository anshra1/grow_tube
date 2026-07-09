import 'package:flutter/material.dart';
import 'package:levelup_tube/src/core/constants/app_icons.dart';
import 'package:levelup_tube/src/core/design_system/app_radius.dart';
import 'package:levelup_tube/src/core/design_system/app_sizes.dart';
import 'package:levelup_tube/src/core/extensions/context_extensions.dart';

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
    final colors = context.colorScheme;

    return Container(
      margin: const EdgeInsets.all(AppSizes.p12),
      padding: const EdgeInsets.all(AppSizes.p16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.roundedXL,
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF0000).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: const Icon(
                  AppIcons.play,
                  color: Color(0xFFFF0000),
                ),
              ),
              gapW12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'YouTube Link Detected',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Watch now or add it to your list.',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onDismiss,
                style: IconButton.styleFrom(
                  backgroundColor: colors.surfaceContainerHigh,
                  foregroundColor: colors.onSurfaceVariant,
                ),
                icon: const Icon(Icons.close_rounded),
                iconSize: 20,
              ),
            ],
          ),
          gapH16,
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.p12,
              vertical: AppSizes.p12,
            ),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest.withValues(alpha: 0.6),
              borderRadius: AppRadius.roundedL,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.link_rounded,
                  size: AppIconSizes.sm,
                  color: colors.primary,
                ),
                gapW8,
                Expanded(
                  child: Text(
                    url,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          gapH16,
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(AppIcons.add),
                  label: const Text(
                    'Add to List',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    foregroundColor: colors.onSurface,
                    side: BorderSide(color: colors.outline),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.roundedL,
                    ),
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
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.roundedL,
                    ),
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
