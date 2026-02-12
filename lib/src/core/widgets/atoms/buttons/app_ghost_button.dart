import 'package:flutter/material.dart';
import 'package:skill_tube/src/core/widgets/atoms/buttons/app_base_button.dart';
import 'package:skill_tube/src/core/widgets/atoms/buttons/app_button_shape.dart';
import 'package:skill_tube/src/core/widgets/atoms/buttons/app_button_state.dart';

/// A ghost button (also known as a text button) with no background or border.
/// Used for low-emphasis actions.
class AppGhostButton extends StatelessWidget {
  const AppGhostButton({
    required this.onPressed,
    required this.child,
    super.key,
    this.leading,
    this.trailing,
    this.state = AppButtonState.enabled,
    this.shape = AppButtonShape.rounded,
    this.color,
    this.borderRadius,
  });
  final VoidCallback? onPressed;
  final Widget child;
  final Widget? leading;
  final Widget? trailing;
  final AppButtonState state;
  final AppButtonShape shape;
  final Color? color;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.primary;

    return AppBaseButton(
      onPressed: onPressed,
      leading: leading,
      trailing: trailing,
      state: state,
      shape: shape,
      backgroundColor: Colors.transparent,
      foregroundColor: effectiveColor,
      elevation: 0,
      borderRadius: borderRadius,
      child: child,
    );
  }
}
