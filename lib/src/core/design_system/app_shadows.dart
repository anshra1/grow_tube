import 'package:flutter/material.dart';

/// Elevation and shadow system following Material Design 3 guidelines.
///
/// Shadows are designed to work with both light and dark themes.
/// Use elevation levels consistently across the app.
class AppShadows {
  const AppShadows._();

  // ============================================================
  // Shadow Colors
  // ============================================================

  static const Color _shadowColor = Color(0x1A000000); // 10% black
  static const Color _shadowColorDark = Color(0x33000000); // 20% black

  // ============================================================
  // Elevation Levels (Material Design 3)
  // ============================================================

  /// Level 0: Flat surfaces, no elevation
  static const List<BoxShadow> elevation0 = [];

  /// Level 1: Cards, surfaces (1dp)
  static const List<BoxShadow> elevation1 = [
    BoxShadow(
      color: _shadowColor,
      blurRadius: 3,
      offset: Offset(0, 1),
    ),
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  /// Level 2: App bar, sticky headers (3dp)
  static const List<BoxShadow> elevation2 = [
    BoxShadow(
      color: _shadowColor,
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  /// Level 3: Bottom sheets, modals (6dp)
  static const List<BoxShadow> elevation3 = [
    BoxShadow(
      color: _shadowColor,
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 3,
      offset: Offset(0, 2),
    ),
  ];

  /// Level 4: Dialogs (8dp)
  static const List<BoxShadow> elevation4 = [
    BoxShadow(
      color: _shadowColorDark,
      blurRadius: 14,
      offset: Offset(0, 6),
    ),
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  /// Level 5: FAB, navigation drawer (12dp)
  static const List<BoxShadow> elevation5 = [
    BoxShadow(
      color: _shadowColorDark,
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 5,
      offset: Offset(0, 3),
    ),
  ];

  // ============================================================
  // Named Shadows for Specific Components
  // ============================================================

  /// For cards and list items
  static const List<BoxShadow> card = elevation1;

  /// For app bars and headers
  static const List<BoxShadow> appBar = elevation2;

  /// For bottom sheets
  static const List<BoxShadow> bottomSheet = elevation3;

  /// For dialogs and modals
  static const List<BoxShadow> dialog = elevation4;

  /// For FAB and floating elements
  static const List<BoxShadow> fab = elevation5;
}
