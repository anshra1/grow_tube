import 'package:flutter/material.dart';
import 'package:skill_tube/src/core/utils/extensions/context_extensions.dart';

/// A widget that displays text where specific target substrings are highlighted
/// with a different color.
class AppRichText extends StatelessWidget {
  const AppRichText({
    required this.firstText,
    required this.highlightedText,
    this.style,
    this.highlightStyle,
    this.textAlign = TextAlign.center,
    super.key,
  });

  /// The first part of the text (default color).
  final String firstText;

  /// The second part of the text (highlighted color).
  final String highlightedText;

  /// The base text style. Uses [AppTypography.headlineMedium] by default.
  final TextStyle? style;

  /// The highlight text style. Uses [AppColors.secondary] color by default.
  final TextStyle? highlightStyle;

  /// How the text should be aligned horizontally.
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final defaultStyle =
        style ??
        context.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: context.colorScheme.onSurface,
        );

    final effectiveHighlightStyle =
        highlightStyle ??
        defaultStyle?.copyWith(
          color: context.colorScheme.primary,
        );

    return RichText(
      textAlign: textAlign,
      text: TextSpan(
        style: defaultStyle,
        children: [
          TextSpan(text: firstText),
          TextSpan(text: ' $highlightedText', style: effectiveHighlightStyle),
        ],
      ),
    );
  }
}
