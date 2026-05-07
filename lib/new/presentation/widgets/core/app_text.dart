// lib/presentation/widgets/core/app_text.dart
import 'package:flutter/material.dart';

class AppText {
  static TextStyle get heading1 => const TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.2,
    letterSpacing: -0.5,
  );
  static TextStyle get heading2 => const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.2,
    letterSpacing: -0.3,
  );
  static TextStyle get heading3 =>
      const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, height: 1.3);
  static TextStyle get heading4 =>
      const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, height: 1.3);
  static TextStyle get bodyLarge =>
      const TextStyle(fontSize: 16, fontWeight: FontWeight.normal, height: 1.5);
  static TextStyle get bodyMedium =>
      const TextStyle(fontSize: 14, fontWeight: FontWeight.normal, height: 1.5);
  static TextStyle get bodySmall =>
      const TextStyle(fontSize: 12, fontWeight: FontWeight.normal, height: 1.5);
  static TextStyle get caption => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0.2,
  );
  static TextStyle get button => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.3,
  );
}
