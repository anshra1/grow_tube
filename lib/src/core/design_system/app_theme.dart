import 'package:flutter/material.dart';
import 'package:levelup_tube/src/core/design_system/app_colors.dart';
import 'package:levelup_tube/src/core/design_system/app_typography.dart';

@immutable
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  const AppColorsExtension({
    required this.success,
    required this.warning,
    required this.textPrimary,
    required this.textSecondary,
  });

  final Color success;
  final Color warning;
  final Color textPrimary;
  final Color textSecondary;

  @override
  ThemeExtension<AppColorsExtension> copyWith({
    Color? success,
    Color? warning,
    Color? textPrimary,
    Color? textSecondary,
  }) {
    return AppColorsExtension(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
    );
  }

  @override
  ThemeExtension<AppColorsExtension> lerp(
    covariant ThemeExtension<AppColorsExtension>? other,
    double t,
  ) {
    if (other is! AppColorsExtension) {
      return this;
    }

    return AppColorsExtension(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
    );
  }

  // Factory for light mode (and potentially dark mode variants if we add them later)
  static const light = AppColorsExtension(
    success: AppColors.success,
    warning: AppColors.warning,
    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
  );

  static const dark = AppColorsExtension(
    success: AppColors.success,
    warning: AppColors.warning,
    textPrimary: Color(0xFFF5F5F5),
    textSecondary: Color(0xFFB0B8C4),
  );
}

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: AppTypography.main,
      extensions: const [AppColorsExtension.light],
    );
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: AppTypography.main,
      extensions: const [AppColorsExtension.dark],
    );
  }
}
