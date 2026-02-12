import 'package:flutter/material.dart';
import 'package:skill_tube/src/core/widgets/atoms/buttons/app_button_state.dart';

/// A button that looks like a hyperlink.
/// Used for inline actions or "Forgot Password" type links.
class AppLinkButton extends StatelessWidget {
  const AppLinkButton({
    required this.onPressed,
    required this.text,
    super.key,
    this.state = AppButtonState.enabled,
    this.style,
    this.color,
  });
  final VoidCallback? onPressed;
  final String text;
  final AppButtonState state;
  final TextStyle? style;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.primary;
    final effectiveStyle = style ?? theme.textTheme.bodyMedium;

    final isLoading = state == AppButtonState.loading;
    final isDisabled = state == AppButtonState.disabled;
    final effectiveOnPressed = (isDisabled || isLoading) ? null : onPressed;

    return TextButton(
      onPressed: effectiveOnPressed,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        foregroundColor: effectiveColor,
        disabledForegroundColor: theme.disabledColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: isLoading
          ? _buildLoadingIndicator(theme)
          : Text(
              text,
              style: effectiveStyle?.copyWith(
                color: effectiveColor,
              ),
            ),
    );
  }

  Widget _buildLoadingIndicator(ThemeData theme) {
    return SizedBox(
      height: 14,
      width: 14,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(color ?? theme.colorScheme.primary),
      ),
    );
  }
}
