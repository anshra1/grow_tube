import 'package:flutter/material.dart';
import 'package:skill_tube/src/core/widgets/atoms/buttons/app_base_button.dart';
import 'package:skill_tube/src/core/widgets/atoms/buttons/app_button_shape.dart';
import 'package:skill_tube/src/core/widgets/atoms/buttons/app_button_state.dart';

/// A tertiary button used for contrasting accents or less prominent actions.
/// Typically uses the tertiary container color from the theme.
class AppTertiaryButton extends StatelessWidget {
  const AppTertiaryButton({
    required this.onPressed,
    required this.child,
    super.key,
    this.leading,
    this.trailing,
    this.state = AppButtonState.enabled,
    this.shape = AppButtonShape.rounded,
    this.elevation = 0.0,
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
      backgroundColor: theme.colorScheme.tertiaryContainer,
      foregroundColor: theme.colorScheme.onTertiaryContainer,
      elevation: elevation,
      borderRadius: borderRadius,
      padding: padding,
      child: child,
    );
  }
}
