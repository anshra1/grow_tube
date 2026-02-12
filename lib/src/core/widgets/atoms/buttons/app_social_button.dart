import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:skill_tube/src/core/widgets/atoms/buttons/app_base_button.dart';
import 'package:skill_tube/src/core/widgets/atoms/buttons/app_button_shape.dart';
import 'package:skill_tube/src/core/widgets/atoms/buttons/app_button_state.dart';

enum SocialBrand { google, apple, facebook, github }

/// A specialized button for social logins.
/// specific styling for different providers.
class AppSocialButton extends StatelessWidget {
  const AppSocialButton({
    required this.onPressed,
    required this.brand,
    super.key,
    this.state = AppButtonState.enabled,
    this.text,
    this.shape = AppButtonShape.rounded,
    this.borderRadius,
    this.padding,
  });
  final VoidCallback? onPressed;
  final SocialBrand brand;
  final AppButtonState state;
  final String? text; // Optional override
  final AppButtonShape shape;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color bgColor;
    Color fgColor;
    BorderSide? border;
    IconData? iconData;
    String? svgAsset;
    String label;

    switch (brand) {
      case SocialBrand.google:
        bgColor = isDark ? const Color(0xFF4285F4) : Colors.white;
        fgColor = isDark ? Colors.white : Colors.black87;
        border = isDark ? null : const BorderSide(color: Color(0xFFDADCE0));
        svgAsset = 'assets/images/google_logo.svg';
        label = 'Continue with Google';
      case SocialBrand.apple:
        bgColor = isDark ? Colors.white : Colors.black;
        fgColor = isDark ? Colors.black : Colors.white;
        iconData = Icons.apple;
        label = 'Continue with Apple';
      case SocialBrand.facebook:
        bgColor = isDark ? const Color(0xFF1877F2) : Colors.white;
        fgColor = isDark ? Colors.white : Colors.black87;
        border = isDark ? null : const BorderSide(color: Color(0xFFDADCE0));
        svgAsset = 'assets/images/facebook_logo.svg';
        label = 'Continue with Facebook';
      case SocialBrand.github:
        bgColor = const Color(0xFF24292e);
        fgColor = Colors.white;
        iconData = Icons.code; // Placeholder for Github
        label = 'Continue with GitHub';
    }

    return AppBaseButton(
      onPressed: onPressed,
      state: state,
      backgroundColor: bgColor,
      foregroundColor: fgColor,
      borderSide: border,
      elevation: 1,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: borderRadius,
      shape: shape,
      child: Row(
        children: [
          // Icon on the left
          if (svgAsset != null)
            SvgPicture.asset(
              svgAsset,
              width: 24,
              height: 24,
            )
          else if (iconData != null)
            Icon(iconData, size: 24),

          // Centered Text
          Expanded(
            child: Text(
              text ?? label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis, // Prevent overflow
            ),
          ),

          // Invisible spacer on the right to balance the icon's width
          // ensuring the text is perfectly centered relative to the button
          const SizedBox(width: 24),
        ],
      ),
    );
  }
}
