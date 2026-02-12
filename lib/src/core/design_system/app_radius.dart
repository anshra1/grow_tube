import 'package:flutter/material.dart';

class AppRadius {
  const AppRadius._();

  static const double s = 4;
  static const double m = 8;
  static const double l = 12;
  static const double xl = 16;
  static const double xxl = 24;
  static const double full = 999; // For capsules/circles

  // Radius Objects
  static const Radius radiusS = Radius.circular(s);
  static const Radius radiusM = Radius.circular(m);
  static const Radius radiusL = Radius.circular(l);
  static const Radius radiusXL = Radius.circular(xl);

  // BorderRadius Objects
  static const BorderRadius roundedS = BorderRadius.all(radiusS);
  static const BorderRadius roundedM = BorderRadius.all(radiusM);
  static const BorderRadius roundedL = BorderRadius.all(radiusL);
  static const BorderRadius roundedXL = BorderRadius.all(radiusXL);
}
