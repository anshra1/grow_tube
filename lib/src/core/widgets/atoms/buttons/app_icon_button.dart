import 'package:flutter/material.dart';

/// A standardized icon button for the app.
/// Wraps [IconButton] to provide consistent styling and behavior.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    required this.onPressed,
    required this.icon,
    super.key,
    this.tooltip,
    this.color,
    this.backgroundColor,
    this.iconSize,
    this.padding = const EdgeInsets.all(8),
  });
  final VoidCallback? onPressed;
  final Widget icon;
  final String? tooltip;
  final Color? color;
  final Color? backgroundColor;
  final double? iconSize;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IconButton(
      onPressed: onPressed,
      icon: icon,
      iconSize: iconSize ?? 20.0,
      padding: padding,
      tooltip: tooltip,
      color: color ?? theme.colorScheme.onSurfaceVariant,
      style: IconButton.styleFrom(
        backgroundColor: backgroundColor,
        hoverColor: (color ?? theme.colorScheme.onSurfaceVariant).withValues(
          alpha: 0.08,
        ),
        highlightColor: (color ?? theme.colorScheme.onSurfaceVariant)
            .withValues(
              alpha: 0.12,
            ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
