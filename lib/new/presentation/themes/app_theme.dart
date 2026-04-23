// lib/presentation/themes/app_theme.dart
import 'package:flutter/material.dart';
import 'colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  // Shared App Bar Theme
  static const AppBarTheme _fixedAppBarTheme = AppBarTheme(
    backgroundColor: AppColors.brandPrimary,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    iconTheme: IconThemeData(color: Colors.white),
    actionsIconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
  );

  // Base Card Theme
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

  // Input Decoration Theme
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
    );
  }

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.brandPrimary,
      scaffoldBackgroundColor: AppColors.lightBackground,
      cardColor: AppColors.lightSurface,
      dividerColor: AppColors.lightDivider,

      appBarTheme: _fixedAppBarTheme.copyWith(
        backgroundColor: AppColors.brandPrimary,
      ),
      cardTheme: _baseCardTheme(
        color: AppColors.lightSurface,
        borderColor: AppColors.lightBorder.withOpacity(0.5),
      ),
      inputDecorationTheme: _inputDecorationTheme(
        fillColor: AppColors.lightSurfaceSecondary,
        borderColor: AppColors.lightBorder,
        focusedBorderColor: AppColors.brandPrimary,
        errorColor: AppColors.error,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brandPrimary,
          foregroundColor: Colors.white,
          minimumSize: const Size(88, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTextStyles.buttonMedium,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.brandPrimary,
          textStyle: AppTextStyles.buttonMedium,
        ),
      ),

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
      ),

      iconTheme: const IconThemeData(
        color: AppColors.lightIconPrimary,
        size: 24,
      ),
      colorScheme: ColorScheme.light(
        primary: AppColors.brandPrimary,
        onPrimary: Colors.white,
        secondary: AppColors.brandSecondary,
        onSecondary: Colors.white,
        error: AppColors.error,
        onError: Colors.white,
        background: AppColors.lightBackground,
        onBackground: AppColors.lightTextPrimary,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightTextPrimary,
        surfaceVariant: AppColors.lightSurfaceSecondary,
        onSurfaceVariant: AppColors.lightTextSecondary,
        outline: AppColors.lightBorder,
        outlineVariant: AppColors.lightDivider,
      ),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.brandPrimary,
      scaffoldBackgroundColor: AppColors.darkBackground,
      cardColor: AppColors.darkSurface,
      dividerColor: AppColors.darkDivider,

      appBarTheme: _fixedAppBarTheme.copyWith(
        backgroundColor: AppColors.brandPrimary,
      ),
      cardTheme: _baseCardTheme(
        color: AppColors.darkSurface,
        borderColor: AppColors.darkBorder.withOpacity(0.5),
      ),
      inputDecorationTheme: _inputDecorationTheme(
        fillColor: AppColors.darkSurfaceSecondary,
        borderColor: AppColors.darkBorder,
        focusedBorderColor: AppColors.brandPrimary,
        errorColor: AppColors.error,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brandPrimary,
          foregroundColor: Colors.white,
          minimumSize: const Size(88, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTextStyles.buttonMedium,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.brandPrimary,
          textStyle: AppTextStyles.buttonMedium,
        ),
      ),

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
      ),

      iconTheme: const IconThemeData(
        color: AppColors.darkIconPrimary,
        size: 24,
      ),
      colorScheme: ColorScheme.dark(
        primary: AppColors.brandPrimary,
        onPrimary: Colors.white,
        secondary: AppColors.brandSecondary,
        onSecondary: Colors.white,
        error: AppColors.error,
        onError: Colors.white,
        background: AppColors.darkBackground,
        onBackground: AppColors.darkTextPrimary,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
        surfaceVariant: AppColors.darkSurfaceSecondary,
        onSurfaceVariant: AppColors.darkTextSecondary,
        outline: AppColors.darkBorder,
        outlineVariant: AppColors.darkDivider,
      ),
    );
  }
}
