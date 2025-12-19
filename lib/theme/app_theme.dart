import 'package:flutter/material.dart';
import 'package:synquerra/theme/colors.dart'; // Ensure this matches your file path

class AppTheme {
  // --- SHARED APP BAR CONFIG (Constant White Text/Icons) ---
  static const AppBarTheme _fixedAppBarTheme = AppBarTheme(
    backgroundColor: AppColors.navBlue, // Always Blue
    foregroundColor: Colors.white, // Force Text/Icons to be White
    elevation: 0,
    iconTheme: IconThemeData(color: Colors.white),
    actionsIconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  );

  // --- LIGHT THEME ---
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // 1. Backgrounds
    scaffoldBackgroundColor: AppColors.background, // Your light background
    primaryColor: AppColors.navBlue,

    // 2. App Bar (Fixed)
    appBarTheme: _fixedAppBarTheme,

    // 3. Card Style (Light)
    cardTheme: CardThemeData(
      color: AppColors.backgroundContainer, // Your light container color
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.black.withOpacity(0.05)),
      ),
    ),

    // 4. Color Scheme
    colorScheme: const ColorScheme.light(
      primary: AppColors.navBlue,
      surface: AppColors.backgroundContainer,
      onSurface: AppColors.darkText, // Text on cards
      surfaceContainerHighest: Color(0xFFE5E8EB), // Input fields background
    ),

    // 5. Text Theme (Light Mode)
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.darkText, fontSize: 18),
      bodyMedium: TextStyle(color: AppColors.lightText, fontSize: 16),
      titleMedium: TextStyle(
        color: AppColors.darkText,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  // --- DARK THEME ---
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    // 1. Backgrounds
    scaffoldBackgroundColor:
        AppColors.backgroundDarkMode, // Your dark background
    primaryColor: AppColors.navBlue,

    // 2. App Bar (Fixed - Identical to Light Mode)
    appBarTheme: _fixedAppBarTheme,

    // 3. Card Style (Dark)
    cardTheme: CardThemeData(
      color: AppColors.backgroundContainerDark, // Your dark container color
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withOpacity(0.05)),
      ),
    ),

    // 4. Color Scheme
    colorScheme: const ColorScheme.dark(
      primary: AppColors.navBlue,
      surface: AppColors.backgroundContainerDark,
      onSurface: Colors.white, // Text on cards
      surfaceContainerHighest: Color(0xFF2C2F33), // Input fields background
    ),

    // 5. Text Theme (Dark Mode)
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white, fontSize: 18),
      bodyMedium: TextStyle(color: Colors.white70, fontSize: 16),
      titleMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
  );
}
