import 'package:flutter/material.dart';
import 'package:skill_tube/src/core/widgets/atoms/buttons/app_base_button.dart';
import 'package:skill_tube/src/core/widgets/atoms/buttons/app_button_shape.dart';
import 'package:skill_tube/src/core/widgets/atoms/buttons/app_button_state.dart';

/// An outlined button with a border and transparent background.
/// Used for medium-emphasis actions.
class AppOutlineButton extends StatelessWidget {
  const AppOutlineButton({
    required this.onPressed,
    required this.child,
    super.key,
    this.leading,
    this.trailing,
    this.state = AppButtonState.enabled,
    this.shape = AppButtonShape.rounded,
    this.color,
    this.borderRadius,
    this.padding,
  });
  final VoidCallback? onPressed;
  final Widget child;
  final Widget? leading;
  final Widget? trailing;
  final AppButtonState state;
  final AppButtonShape shape;
  final Color? color;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;

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
      borderSide: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return BorderSide(color: theme.disabledColor);
        }
        return BorderSide(color: effectiveColor);
      }),
      borderRadius: borderRadius,
      padding: padding,
      child: child,
    );
  }
}
