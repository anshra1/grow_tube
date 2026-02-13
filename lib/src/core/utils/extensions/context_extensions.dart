import 'package:flutter/material.dart';
import 'package:skill_tube/src/core/design_system/app_theme.dart';

extension ContextExtensions on BuildContext {
  // ============================================================
  // Theme Shortcuts
  // ============================================================

  /// Access the current ThemeData
  ThemeData get theme => Theme.of(this);

  /// Access the current TextTheme
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Access the current ColorScheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Access the current ColorScheme (alias)
  ColorScheme get colors => colorScheme;

  /// Access the AppColorsExtension
  AppColorsExtension get appColors =>
      Theme.of(this).extension<AppColorsExtension>() ?? AppColorsExtension.light;

  /// Check if current theme is dark mode
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  // ============================================================
  // Screen Size Shortcuts
  // ============================================================

  /// Screen width
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// Screen height
  double get screenHeight => MediaQuery.sizeOf(this).height;

  /// Shorthand for screen width
  double get width => screenWidth;

  /// Shorthand for screen height
  double get height => screenHeight;

  // ============================================================
  // Safe Area Shortcuts
  // ============================================================

  /// Top safe area padding (status bar)
  double get topPadding => MediaQuery.of(this).padding.top;

  /// Bottom safe area padding (home indicator)
  double get bottomPadding => MediaQuery.of(this).padding.bottom;

  /// Left safe area padding
  double get leftPadding => MediaQuery.of(this).padding.left;

  /// Right safe area padding
  double get rightPadding => MediaQuery.of(this).padding.right;

  /// All safe area padding as EdgeInsets
  EdgeInsets get safePadding => MediaQuery.of(this).padding;

  // ============================================================
  // Keyboard & View Insets
  // ============================================================

  /// Check if keyboard is currently visible
  bool get isKeyboardOpen => MediaQuery.of(this).viewInsets.bottom > 0;

  /// Keyboard height (0 if closed)
  double get keyboardHeight => MediaQuery.of(this).viewInsets.bottom;

  // ============================================================
  // Device Pixel Ratio
  // ============================================================

  /// Device pixel ratio for image resolution
  double get devicePixelRatio => MediaQuery.of(this).devicePixelRatio;

  // ============================================================
  // Focus Management
  // ============================================================

  /// Dismiss keyboard by unfocusing
  void dismissKeyboard() => FocusScope.of(this).unfocus();
}
