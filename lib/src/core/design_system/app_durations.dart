import 'package:flutter/material.dart';

/// Standardized animation durations and curves.
///
/// Use these consistently to create cohesive motion throughout the app.
/// Durations follow Material Design 3 motion guidelines.
class AppDurations {
  const AppDurations._();

  // ============================================================
  // Durations
  // ============================================================

  /// No animation
  static const Duration instant = Duration.zero;

  /// Micro-interactions: button press, ripple start
  static const Duration fastest = Duration(milliseconds: 100);

  /// Quick feedback: toggles, checkboxes, small transitions
  static const Duration fast = Duration(milliseconds: 150);

  /// Standard animations: buttons, cards, icon
  static const Duration normal = Duration(milliseconds: 200);

  /// Medium transitions: bottom sheets, dialogs appearing
  static const Duration medium = Duration(milliseconds: 300);

  /// Slower transitions: page transitions, complex animations
  static const Duration slow = Duration(milliseconds: 400);

  /// Complex orchestrated animations
  static const Duration slower = Duration(milliseconds: 500);

  /// Loading shimmer loop duration
  static const Duration shimmer = Duration(milliseconds: 1500);

  // ============================================================
  // Stagger Delays (for list animations)
  // ============================================================

  /// Delay between list item animations
  static const Duration staggerDelay = Duration(milliseconds: 50);

  /// Delay for cascading animations
  static const Duration cascadeDelay = Duration(milliseconds: 100);
}

/// Standardized animation curves.
///
/// Use these consistently to create cohesive motion throughout the app.
class AppCurves {
  const AppCurves._();

  // ============================================================
  // Standard Curves
  // ============================================================

  /// Default curve for most animations
  static const Curve standard = Curves.easeInOutCubic;

  /// For elements entering the screen
  static const Curve enter = Curves.easeOutCubic;

  /// For elements exiting the screen
  static const Curve exit = Curves.easeInCubic;

  /// For emphasized/bounce effects
  static const Curve emphasized = Curves.easeOutBack;

  /// Linear for shimmer and continuous animations
  static const Curve linear = Curves.linear;

  // ============================================================
  // Specific Use Cases
  // ============================================================

  /// Button press and release
  static const Curve button = Curves.easeOut;

  /// Page transitions
  static const Curve pageTransition = Curves.easeInOutCubic;

  /// Bottom sheet slide
  static const Curve bottomSheet = Curves.easeOutCubic;

  /// Dialog scale
  static const Curve dialog = Curves.easeOutBack;

  /// FAB scale animation
  static const Curve fab = Curves.easeInOut;
}
