import 'package:flutter/material.dart';
import 'package:skill_tube/src/core/widgets/atoms/buttons/app_base_button.dart';
import 'package:skill_tube/src/core/widgets/atoms/buttons/app_button_shape.dart';
import 'package:skill_tube/src/core/widgets/atoms/buttons/app_button_state.dart';

/// A button used for destructive actions like delete, remove, or sign out.
/// Typically uses the error color from the theme.
class AppDestructiveButton extends StatelessWidget {
  const AppDestructiveButton({
    required this.onPressed,
    required this.child,
    super.key,
    this.leading,
    this.trailing,
    this.state = AppButtonState.enabled,
    this.shape = AppButtonShape.rounded,
    this.outlined = false,
    this.elevation,
    this.borderRadius,
  });
  final VoidCallback? onPressed;
  final Widget child;
  final Widget? leading;
  final Widget? trailing;
  final AppButtonState state;
  final AppButtonShape shape;
  final bool outlined;
  final double? elevation;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final errorColor = theme.colorScheme.error;
    final onErrorColor = theme.colorScheme.onError;
    final effectiveElevation = elevation ?? (outlined ? 0.0 : 2.0);

    if (outlined) {
      return AppBaseButton(
        onPressed: onPressed,
        leading: leading,
        trailing: trailing,
        state: state,
        shape: shape,
        backgroundColor: Colors.transparent,
        foregroundColor: errorColor,
        elevation: effectiveElevation,
        borderSide: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return BorderSide(color: theme.disabledColor);
          }
          return BorderSide(color: errorColor);
        }),
        borderRadius: borderRadius,
        child: child,
      );
    }

    return AppBaseButton(
      onPressed: onPressed,
      leading: leading,
      trailing: trailing,
      state: state,
      shape: shape,
      backgroundColor: errorColor,
      foregroundColor: onErrorColor,
      elevation: effectiveElevation,
      borderRadius: borderRadius,
      child: child,
    );
  }
}
