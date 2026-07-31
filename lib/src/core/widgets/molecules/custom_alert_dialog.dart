import 'package:flutter/material.dart';
import 'package:levelup_tube/src/core/design_system/app_radius.dart';
import 'package:levelup_tube/src/core/design_system/app_sizes.dart';
import 'package:levelup_tube/src/core/extensions/context_extensions.dart';

class CustomAlertDialog extends StatelessWidget {
  const CustomAlertDialog({
    required this.title,
    required this.content,
    required this.cancelText,
    required this.confirmText,
    required this.onCancel,
    required this.onConfirm,
    super.key,
    this.confirmTextColor,
    this.confirmBackgroundColor,
    this.icon,
    this.iconColor,
  });

  final String title;
  final Widget content;
  final String cancelText;
  final String confirmText;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  final Color? confirmTextColor;
  final Color? confirmBackgroundColor;
  final IconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(AppSizes.p16),
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.roundedXL),
      backgroundColor: context.colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSizes.p8),
                  DefaultTextStyle(
                    style:
                        context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ) ??
                        const TextStyle(),
                    child: content,
                  ),
                  const SizedBox(height: AppSizes.p24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: onCancel,
                        style: TextButton.styleFrom(
                          foregroundColor: context.colorScheme.onSurface,
                        ),
                        child: Text(
                          cancelText,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: AppSizes.p8),
                      FilledButton(
                        onPressed: onConfirm,
                        style: FilledButton.styleFrom(
                          backgroundColor:
                              confirmBackgroundColor ?? context.colorScheme.error,
                          foregroundColor:
                              confirmTextColor ?? context.colorScheme.onError,
                          shape: const RoundedRectangleBorder(
                            borderRadius: AppRadius.roundedM,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.p24,
                            vertical: AppSizes.p12,
                          ),
                        ),
                        child: Text(
                          confirmText,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
