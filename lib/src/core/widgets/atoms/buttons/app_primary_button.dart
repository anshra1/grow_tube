import 'package:flutter/material.dart';
import 'package:skill_tube/src/core/widgets/atoms/buttons/app_base_button.dart';
import 'package:skill_tube/src/core/widgets/atoms/buttons/app_button_shape.dart';
import 'package:skill_tube/src/core/widgets/atoms/buttons/app_button_state.dart';

/// A primary button used for the main action on a screen.
/// Typically has a solid background color (primary theme color) and contrasting text.
class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    required this.onPressed,
    required this.child,
    super.key,
    this.leading,
    this.trailing,
    this.state = AppButtonState.enabled,
    this.shape = AppButtonShape.rounded,
    this.elevation = 2.0,
    this.borderRadius,
    this.padding,
  });
  final VoidCallback? onPressed;
  final Widget child;
  final Widget? leading;
  final Widget? trailing;
  final AppButtonState state;
  final AppButtonShape shape;
  final double? elevation;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppBaseButton(
      onPressed: onPressed,
      leading: leading,
      trailing: trailing,
      state: state,
      shape: shape,
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      elevation: elevation,
      borderRadius: borderRadius,
      padding: padding,
      child: child,
    );
  }
}
