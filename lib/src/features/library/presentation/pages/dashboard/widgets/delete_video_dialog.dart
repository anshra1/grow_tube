import 'package:flutter/material.dart';
import 'package:skill_tube/src/core/constants/app_strings.dart';
import 'package:skill_tube/src/core/design_system/app_radius.dart';
import 'package:skill_tube/src/core/design_system/app_sizes.dart';
import 'package:skill_tube/src/core/utils/extensions/context_extensions.dart';

class DeleteVideoDialog extends StatelessWidget {
  const DeleteVideoDialog({
    required this.videoTitle,
    required this.onDelete,
    super.key,
  });

  final String videoTitle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.all(AppSizes.p16),
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.roundedXL),
      backgroundColor: context.colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      title: Text(
        AppStrings.dashboardDeleteTitle,
        style: context.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: context.colorScheme.onSurface,
        ),
        textAlign: TextAlign.center,
      ),
      content: Text.rich(
        TextSpan(
          children: [
            const TextSpan(text: AppStrings.dashboardDeleteConfirm),
            const TextSpan(text: ' '),
            TextSpan(
              text: '"$videoTitle"',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const TextSpan(text: '?'),
          ],
        ),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: context.textTheme.bodyMedium?.copyWith(
          color: context.colorScheme.onSurfaceVariant,
        ),
        textAlign: TextAlign.center,
      ),
      actionsPadding: const EdgeInsets.fromLTRB(
        AppSizes.p16,
        0,
        AppSizes.p16,
        AppSizes.p16,
      ),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            AppStrings.commonCancel,
            style: TextStyle(color: context.colorScheme.onSurfaceVariant),
          ),
        ),
        TextButton(
          onPressed: () {
            onDelete();
            Navigator.of(context).pop();
          },
          style: TextButton.styleFrom(
            foregroundColor: context.colorScheme.error,
          ),
          child: const Text(
            AppStrings.commonDelete,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
