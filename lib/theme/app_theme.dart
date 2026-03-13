import 'package:flutter/material.dart';
import 'package:synquerra/theme/colors.dart'; // Updated import path
import 'app_text_styles.dart'; // Import text styles

/// Theme data configuration for the entire app
/// This file handles ONLY theme creation and configuration
class AppTheme {
  AppTheme._(); // Prevent instantiation

  // --- SHARED APP BAR CONFIG (Constant White Text/Icons) ---
  static const AppBarTheme _fixedAppBarTheme = AppBarTheme(
    backgroundColor:
        AppColors.brandPrimary, // Using brandPrimary instead of navBlue
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    iconTheme: IconThemeData(color: Colors.white),
    actionsIconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15,
    ),
  );

  // --- SHARED CARD THEME (Base configuration) ---
  static CardThemeData _baseCardTheme({
    required Color color,
    required Color borderColor,
  }) {
    return CardThemeData(
      color: color,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
    );
  }

  // --- SHARED ELEVATED BUTTON THEME ---
  static ElevatedButtonThemeData _elevatedButtonTheme(Color primaryColor) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        minimumSize: const Size(88, 48),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        textStyle: AppTextStyles.buttonMedium,
      ),
    );
  }

  // --- SHARED INPUT DECORATION THEME ---
  static InputDecorationTheme _inputDecorationTheme({
    required Color fillColor,
    required Color borderColor,
    required Color focusedBorderColor,
    required Color errorColor,
  }) {
    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: focusedBorderColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: errorColor, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: errorColor, width: 2),
      ),
      labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      hintStyle: TextStyle(color: AppColors.lightTextTertiary, fontSize: 14),
      errorStyle: TextStyle(color: AppColors.error, fontSize: 12),
    );
  }

  // --- LIGHT THEME ---
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // 1. Core Colors
      primaryColor: AppColors.brandPrimary,
      scaffoldBackgroundColor: AppColors.lightBackground,
      cardColor: AppColors.lightSurface,
      dividerColor: AppColors.lightDivider,
      focusColor: AppColors.brandPrimary.withOpacity(0.12),
      hoverColor: AppColors.brandPrimary.withOpacity(0.04),
      highlightColor: AppColors.brandPrimary.withOpacity(0.08),
      splashColor: AppColors.brandPrimary.withOpacity(0.12),
      disabledColor: AppColors.lightTextDisabled,

      // 2. App Bar
      appBarTheme: _fixedAppBarTheme.copyWith(
        backgroundColor: AppColors.brandPrimary,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
        ),
      ),

      // 3. Card Theme
      cardTheme: _baseCardTheme(
        color: AppColors.lightSurface,
        borderColor: AppColors.lightBorder.withOpacity(0.5),
      ),

      // 4. Button Themes
      elevatedButtonTheme: _elevatedButtonTheme(AppColors.brandPrimary),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.brandPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: AppTextStyles.buttonMedium,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.brandPrimary,
          side: const BorderSide(color: AppColors.brandPrimary),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTextStyles.buttonMedium,
        ),
      ),

      // 5. Input Decoration Theme
      inputDecorationTheme: _inputDecorationTheme(
        fillColor: AppColors.lightSurfaceSecondary,
        borderColor: AppColors.lightBorder,
        focusedBorderColor: AppColors.brandPrimary,
        errorColor: AppColors.error,
      ),

      // 6. Text Theme
      textTheme: TextTheme(
        displayLarge: AppTextStyles.heading1.copyWith(
          color: AppColors.lightTextPrimary,
        ),
        displayMedium: AppTextStyles.heading2.copyWith(
          color: AppColors.lightTextPrimary,
        ),
        displaySmall: AppTextStyles.heading3.copyWith(
          color: AppColors.lightTextPrimary,
        ),
        headlineMedium: AppTextStyles.heading4.copyWith(
          color: AppColors.lightTextPrimary,
        ),
        headlineSmall: AppTextStyles.heading5.copyWith(
          color: AppColors.lightTextPrimary,
        ),
        titleLarge: AppTextStyles.heading6.copyWith(
          color: AppColors.lightTextPrimary,
        ),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.lightTextPrimary,
        ),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.lightTextSecondary,
        ),
        bodySmall: AppTextStyles.bodySmall.copyWith(
          color: AppColors.lightTextTertiary,
        ),
        labelLarge: AppTextStyles.buttonLarge.copyWith(
          color: AppColors.brandPrimary,
        ),
        labelMedium: AppTextStyles.buttonMedium.copyWith(
          color: AppColors.brandPrimary,
        ),
        labelSmall: AppTextStyles.buttonSmall.copyWith(
          color: AppColors.brandPrimary,
        ),
      ),

      // 7. Icon Theme
      iconTheme: const IconThemeData(
        color: AppColors.lightIconPrimary,
        size: 24,
      ),

      primaryIconTheme: const IconThemeData(
        color: AppColors.brandPrimary,
        size: 24,
      ),

      // 8. Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        selectedItemColor: AppColors.brandPrimary,
        unselectedItemColor: AppColors.lightIconSecondary,
        selectedIconTheme: IconThemeData(color: AppColors.brandPrimary),
        unselectedIconTheme: IconThemeData(color: AppColors.lightIconSecondary),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // 9. Tab Bar Theme
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.brandPrimary,
        unselectedLabelColor: AppColors.lightTextSecondary,
        indicatorColor: AppColors.brandPrimary,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: AppColors.lightDivider,
      ),

      // 10. Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: AppTextStyles.heading5.copyWith(
          color: AppColors.lightTextPrimary,
        ),
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.lightTextSecondary,
        ),
      ),

      // 11. Color Scheme
      colorScheme: ColorScheme.light(
        primary: AppColors.brandPrimary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.brandPrimary,
        onPrimaryContainer: Colors.white,
        secondary: AppColors.brandSecondary,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.brandSecondary,
        onSecondaryContainer: Colors.white,
        tertiary: AppColors.brandTertiary,
        onTertiary: Colors.white,
        error: AppColors.error,
        onError: Colors.white,
        errorContainer: AppColors.errorLight,
        onErrorContainer: AppColors.errorDark,
        background: AppColors.lightBackground,
        onBackground: AppColors.lightTextPrimary,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightTextPrimary,
        surfaceVariant: AppColors.lightSurfaceSecondary,
        onSurfaceVariant: AppColors.lightTextSecondary,
        outline: AppColors.lightBorder,
        outlineVariant: AppColors.lightDivider,
        shadow: AppColors.shadowMedium,
        scrim: AppColors.shadowHeavy,
        inverseSurface: AppColors.darkSurface,
        onInverseSurface: AppColors.darkTextPrimary,
        inversePrimary: AppColors.brandPrimary.withOpacity(0.8),
        surfaceTint: AppColors.brandPrimary,
      ),
    );
  }

  // --- DARK THEME ---
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // 1. Core Colors
      primaryColor: AppColors.brandPrimary,
      scaffoldBackgroundColor: AppColors.darkBackground,
      cardColor: AppColors.darkSurface,
      dividerColor: AppColors.darkDivider,
      focusColor: AppColors.brandPrimary.withOpacity(0.24),
      hoverColor: AppColors.brandPrimary.withOpacity(0.08),
      highlightColor: AppColors.brandPrimary.withOpacity(0.12),
      splashColor: AppColors.brandPrimary.withOpacity(0.24),
      disabledColor: AppColors.darkTextDisabled,

      // 2. App Bar
      appBarTheme: _fixedAppBarTheme.copyWith(
        backgroundColor: AppColors.brandPrimary,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
        ),
      ),

      // 3. Card Theme
      cardTheme: _baseCardTheme(
        color: AppColors.darkSurface,
        borderColor: AppColors.darkBorder.withOpacity(0.5),
      ),

      // 4. Button Themes
      elevatedButtonTheme: _elevatedButtonTheme(AppColors.brandPrimary),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.brandPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: AppTextStyles.buttonMedium,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.brandPrimary,
          side: const BorderSide(color: AppColors.brandPrimary),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTextStyles.buttonMedium,
        ),
      ),

      // 5. Input Decoration Theme
      inputDecorationTheme: _inputDecorationTheme(
        fillColor: AppColors.darkSurfaceSecondary,
        borderColor: AppColors.darkBorder,
        focusedBorderColor: AppColors.brandPrimary,
        errorColor: AppColors.error,
      ),

      // 6. Text Theme
      textTheme: TextTheme(
        displayLarge: AppTextStyles.heading1.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        displayMedium: AppTextStyles.heading2.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        displaySmall: AppTextStyles.heading3.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        headlineMedium: AppTextStyles.heading4.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        headlineSmall: AppTextStyles.heading5.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        titleLarge: AppTextStyles.heading6.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.darkTextSecondary,
        ),
        bodySmall: AppTextStyles.bodySmall.copyWith(
          color: AppColors.darkTextTertiary,
        ),
        labelLarge: AppTextStyles.buttonLarge.copyWith(
          color: AppColors.brandPrimary,
        ),
        labelMedium: AppTextStyles.buttonMedium.copyWith(
          color: AppColors.brandPrimary,
        ),
        labelSmall: AppTextStyles.buttonSmall.copyWith(
          color: AppColors.brandPrimary,
        ),
      ),

      // 7. Icon Theme
      iconTheme: const IconThemeData(
        color: AppColors.darkIconPrimary,
        size: 24,
      ),

      primaryIconTheme: const IconThemeData(
        color: AppColors.brandPrimary,
        size: 24,
      ),

      // 8. Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.brandPrimary,
        unselectedItemColor: AppColors.darkIconSecondary,
        selectedIconTheme: const IconThemeData(color: AppColors.brandPrimary),
        unselectedIconTheme: IconThemeData(color: AppColors.darkIconSecondary),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // 9. Tab Bar Theme
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.brandPrimary,
        unselectedLabelColor: AppColors.darkTextSecondary,
        indicatorColor: AppColors.brandPrimary,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: AppColors.darkDivider,
      ),

      // 10. Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: AppTextStyles.heading5.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.darkTextSecondary,
        ),
      ),

      // 11. Color Scheme
      colorScheme: ColorScheme.dark(
        primary: AppColors.brandPrimary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.brandPrimary,
        onPrimaryContainer: Colors.white,
        secondary: AppColors.brandSecondary,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.brandSecondary,
        onSecondaryContainer: Colors.white,
        tertiary: AppColors.brandTertiary,
        onTertiary: Colors.white,
        error: AppColors.error,
        onError: Colors.white,
        errorContainer: AppColors.errorDark,
        onErrorContainer: AppColors.errorLight,
        background: AppColors.darkBackground,
        onBackground: AppColors.darkTextPrimary,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
        surfaceVariant: AppColors.darkSurfaceSecondary,
        onSurfaceVariant: AppColors.darkTextSecondary,
        outline: AppColors.darkBorder,
        outlineVariant: AppColors.darkDivider,
        shadow: AppColors.shadowDarkMedium,
        scrim: AppColors.shadowDarkHeavy,
        inverseSurface: AppColors.lightSurface,
        onInverseSurface: AppColors.lightTextPrimary,
        inversePrimary: AppColors.brandPrimary.withOpacity(0.8),
        surfaceTint: AppColors.brandPrimary,
      ),
    );
  }

  // --- HELPER METHOD TO GET THEME BASED ON BRIGHTNESS ---
  static ThemeData of(BuildContext context) {
    return Theme.of(context);
  }

  // --- HELPER METHOD TO CHECK IF DARK MODE IS ENABLED ---
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }
}
