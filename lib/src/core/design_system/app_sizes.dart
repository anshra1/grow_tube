import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Component dimensions, touch targets, and standard sizes.
///
/// All sizes follow Material Design 3 accessibility guidelines.
/// Touch targets are minimum 48dp for accessibility.
class AppSizes {
  const AppSizes._();

  // ============================================================
  // Padding & Spacing
  // ============================================================
  static const double p4 = 4;
  static const double p8 = 8;
  static const double p12 = 12;
  static const double p16 = 16;
  static const double p20 = 20;
  static const double p24 = 24;
  static const double p32 = 32;
  static const double p48 = 48;
  static const double p64 = 64;

  // ============================================================
  // Touch Targets (Accessibility)
  // ============================================================

  /// Minimum touch target size (Material Design requirement)
  static const double minTouchTarget = 48;

  /// Recommended touch target for comfortable tapping
  static const double recommendedTouchTarget = 56;

  // ============================================================
  // Button Heights
  // ============================================================

  /// Small button height (compact UI)
  static const double buttonHeightSm = 36;

  /// Medium button height (default)
  static const double buttonHeightMd = 44;

  /// Large button height (primary actions)
  static const double buttonHeightLg = 52;

  /// Extra large button height (full-width CTAs)
  static const double buttonHeightXl = 56;

  // ============================================================
  // Input Heights
  // ============================================================

  /// Standard text field height
  static const double inputHeight = 56;

  /// Compact text field height
  static const double inputHeightCompact = 48;

  /// Search bar height
  static const double searchBarHeight = 56;

  // ============================================================
  // Navigation Components
  // ============================================================

  /// App bar height
  static const double appBarHeight = 56;

  /// Large app bar height (with extended content)
  static const double appBarHeightLarge = 152;

  /// Bottom navigation bar height (including safe area)
  static const double bottomNavHeight = 80;

  /// Tab bar height
  static const double tabBarHeight = 48;

  // ============================================================
  // Floating Action Button
  // ============================================================

  /// Mini FAB size
  static const double fabSizeMini = 40;

  /// Standard FAB size
  static const double fabSize = 56;

  /// Extended FAB height
  static const double fabExtendedHeight = 56;

  // ============================================================
  // List Items
  // ============================================================

  /// Single-line list item height
  static const double listItemHeightSingle = 56;

  /// Two-line list item height
  static const double listItemHeightDouble = 72;

  /// Three-line list item height
  static const double listItemHeightTriple = 88;

  // ============================================================
  // Cards
  // ============================================================

  /// Minimum card width
  static const double cardMinWidth = 280;

  /// Maximum card width (for readability)
  static const double cardMaxWidth = 400;

  // ============================================================
  // Dialogs
  // ============================================================

  /// Minimum dialog width
  static const double dialogMinWidth = 280;

  /// Maximum dialog width
  static const double dialogMaxWidth = 560;

  // ============================================================
  // Bottom Sheets
  // ============================================================

  /// Bottom sheet handle height
  static const double bottomSheetHandleHeight = 4;

  /// Bottom sheet handle width
  static const double bottomSheetHandleWidth = 32;

  /// Bottom sheet top padding (above handle)
  /// Bottom sheet top padding (above handle)
  static const double bottomSheetTopPadding = 12;
}

// Global Gap Constants
const gapH4 = SizedBox(height: AppSizes.p4);
const gapH8 = SizedBox(height: AppSizes.p8);
const gapH12 = SizedBox(height: AppSizes.p12);
const gapH16 = SizedBox(height: AppSizes.p16);
const gapH24 = SizedBox(height: AppSizes.p24);
const gapH32 = SizedBox(height: AppSizes.p32);
const gapH48 = SizedBox(height: AppSizes.p48);

const gapW4 = SizedBox(width: AppSizes.p4);
const gapW8 = SizedBox(width: AppSizes.p8);
const gapW12 = SizedBox(width: AppSizes.p12);
const gapW16 = SizedBox(width: AppSizes.p16);
const gapW24 = SizedBox(width: AppSizes.p24);

/// Standard icon sizes.
class AppIconSizes {
  const AppIconSizes._();

  /// Extra small icon (badges, indicators)
  static const double xs = 16;

  /// Small icon (secondary actions)
  static const double sm = 20;

  /// Medium icon (default size)
  static const double md = 24;

  /// Large icon (primary actions, navigation)
  static const double lg = 32;

  /// Extra large icon (feature highlights)
  static const double xl = 48;

  /// Illustration icon
  static const double xxl = 64;
}
