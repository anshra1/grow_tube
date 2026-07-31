import 'package:flutter/material.dart';
import 'package:levelup_tube/src/core/constants/app_strings.dart';
import 'package:levelup_tube/src/core/widgets/molecules/custom_alert_dialog.dart';

class CustomDeleteDialog extends StatelessWidget {
  const CustomDeleteDialog({
    required this.title,
    required this.description,
    required this.onConfirm,
    this.highlightText,
    this.confirmText,
    this.icon,
    super.key,
  });

  final String title;
  final String description;
  final String? highlightText;
  final String? confirmText;
  final IconData? icon;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final Widget content = highlightText != null
        ? Text.rich(
            TextSpan(
              children: [
                TextSpan(text: description),
                const TextSpan(text: ' '),
                TextSpan(
                  text: '"$highlightText"',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(text: '?'),
              ],
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          )
        : Text(
            description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          );

    return CustomAlertDialog(
      title: title,
      content: content,
      cancelText: AppStrings.commonCancel,
      confirmText: confirmText ?? AppStrings.commonDelete,
      icon: icon ?? Icons.delete_outline,
      onCancel: () => Navigator.of(context).pop(),
      onConfirm: onConfirm,
    );
  }
}
