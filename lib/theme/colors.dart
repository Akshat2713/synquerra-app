import 'package:flutter/material.dart';

/// Centralized color constants for the entire app
/// This file contains ONLY color definitions - no logic, no extensions
class AppColors {
  AppColors._(); // Prevent instantiation

  // ===== BRAND COLORS =====
  static const Color brandPrimary = Color(0xFF007AFF);
  static const Color brandSecondary = Color(0xFF5856D6);
  static const Color brandTertiary = Color(0xFF34C759);

  // ===== SEMANTIC COLORS =====
  // Error
  static const Color error = Color(0xFFFF3B30);
  static const Color errorLight = Color(0xFFFF6B6B);
  static const Color errorDark = Color(0xFFC41E1E);

  // Success
  static const Color success = Color(0xFF34C759);
  static const Color successLight = Color(0xFF6BDB8F);
  static const Color successDark = Color(0xFF248A3D);

  // Warning
  static const Color warning = Color(0xFFFF9500);
  static const Color warningLight = Color(0xFFFFB340);
  static const Color warningDark = Color(0xFFC47100);

  // Info
  static const Color info = Color(0xFF5856D6);
  static const Color infoLight = Color(0xFF7A78E0);
  static const Color infoDark = Color(0xFF3F3E9C);

  // ===== LIGHT THEME COLORS =====
  // Backgrounds & Surfaces
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color lightSurface = Colors.white;
  static const Color lightSurfaceSecondary = Color(0xFFF8F8F8);
  static const Color lightSurfaceTertiary = Color(0xFFF0F0F0);

  // Borders & Dividers
  static const Color lightBorder = Color(0xFFE0E0E0);
  static const Color lightDivider = Color(0xFFEEEEEE);

  // Text
  static const Color lightTextPrimary = Color(0xFF000000);
  static const Color lightTextSecondary = Color(0xFF6B6B6B);
  static const Color lightTextTertiary = Color(0xFF8E8E93);
  static const Color lightTextDisabled = Color(0xFFB8B8B8);

  // Icons
  static const Color lightIconPrimary = Color(0xFF4A4A4A);
  static const Color lightIconSecondary = Color(0xFF8E8E93);
  static const Color lightIconDisabled = Color(0xFFC6C6C8);

  // ===== DARK THEME COLORS =====
  // Backgrounds & Surfaces
  static const Color darkBackground = Color(0xFF071021);
  static const Color darkSurface = Color(0xFF0F1B29);
  static const Color darkSurfaceSecondary = Color(0xFF1A2635);
  static const Color darkSurfaceTertiary = Color(0xFF253141);

  // Borders & Dividers
  static const Color darkBorder = Color(0xFF2C2F33);
  static const Color darkDivider = Color(0xFF353A40);

  // Text
  static const Color darkTextPrimary = Colors.white;
  static const Color darkTextSecondary = Color(0xFFE0E0E0);
  static const Color darkTextTertiary = Color(0xFFB0B0B0);
  static const Color darkTextDisabled = Color(0xFF707070);

  // Icons
  static const Color darkIconPrimary = Colors.white;
  static const Color darkIconSecondary = Color(0xFFB8B8B8);
  static const Color darkIconDisabled = Color(0xFF666666);

  // ===== ACCENT COLORS =====
  static const Color vibrantBlue = Color(0xFF0A84FF);
  static const Color vibrantPurple = Color(0xFFBF5AF2);
  static const Color vibrantPink = Color(0xFFFF2D55);
  static const Color vibrantOrange = Color(0xFFFF9F0A);
  static const Color vibrantTeal = Color(0xFF64D2FF);

  // Now proper Color constants with hex opacity values
  static const Color shadowLight = Color(0x0C000000); // 5% opacity black
  static const Color shadowMedium = Color(0x1A000000); // 10% opacity black
  static const Color shadowHeavy = Color(0x26000000); // 15% opacity black

  static const Color shadowDarkLight = Color(0x08FFFFFF); // 3% opacity white
  static const Color shadowDarkMedium = Color(0x0DFFFFFF); // 5% opacity white
  static const Color shadowDarkHeavy = Color(0x14FFFFFF); // 8% opacity white

  // ===== GRADIENTS =====
  static const List<Color> primaryGradient = [
    Color(0xFF007AFF),
    Color(0xFF5856D6),
  ];

  static const List<Color> successGradient = [
    Color(0xFF34C759),
    Color(0xFF30B0C7),
  ];

  static const List<Color> errorGradient = [
    Color(0xFFFF3B30),
    Color(0xFFFF6B4A),
  ];

  static const List<Color> warningGradient = [
    Color(0xFFFF9500),
    Color(0xFFFFB340),
  ];

  /// Old colours
  static const Color emergencyRed = Color(0xFFFF3B30); // bright red for danger
  static const Color safeGreen = Color(0xFF34C759); // green for all good
  static const Color warningAmber = Color(0xFFFF9500); // amber for caution
  static const Color navBlue = Color(0xFF007AFF); // blue for navigation
  static const Color background = Color.fromARGB(255, 220, 220, 220); // white
  static const Color darkText = Color(0xFF000000); // black text
  static const Color lightText = Color(0xFF8E8E93); // light gray for subtext
  static const Color backgroundContainer =
      Colors.white; // light gray container bg
  static const Color containerSurfaceHighest = Color(
    0xFFE5E8EB,
  ); // gray for borders

  // Dark mode
  static const Color backgroundDarkMode = Color(0xFF071021);
  static const Color backgroundContainerDark = Color(0xFF0F1B29);

  static const Color containerSurfaceHighestDark = Color(0xFF2C2F33);

  static const Color darkThemeText = Colors.white;
  static const Color darkThemeTextSecondary = Colors.white70;
}
