import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Brand Colors
  static const Color primary = Color(0xFF137FEC); // From Mockup
  static const Color primary200 = Color(0xFF90CAF9); // Lighter shade
  static const Color onPrimary = Colors.white;
  static const Color primaryContainer = Color(0xFFE3F2FD);

  // Secondary Brand Colors
  static const Color secondary = Color(0xFF03DAC6);
  static const Color onSecondary = Colors.black;

  // Status Colors
  static const Color error = Color(0xFFB00020);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);

  // Neutrals
  static const Color background = Color(0xFFF6F7F8); // background-light
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(
    0xFF101922,
  ); // background-dark used as text? or standard black
  static const Color textSecondary = Color(0xFF6B7280); // gray-500
}
