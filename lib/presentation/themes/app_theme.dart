import 'package:flutter/material.dart';
import 'package:synquerra/presentation/themes/colors.dart';
import 'app_text_styles.dart';

/// Theme data configuration for the entire app.
/// This file handles ONLY theme creation and configuration.
class AppTheme {
  AppTheme._();

  // --- SHARED APP BAR CONFIG ---
  static const AppBarTheme _fixedAppBarTheme = AppBarTheme(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    iconTheme: IconThemeData(color: Colors.white),
    actionsIconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: AppTextStyles.heading4,
  );

  // --- SHARED CARD THEME ---
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
    required Color hintColor,
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
      labelStyle: AppTextStyles.label,
      hintStyle: AppTextStyles.bodyMedium.copyWith(color: hintColor),
      errorStyle: AppTextStyles.caption.copyWith(color: errorColor),
    );
  }

  // --- LIGHT THEME ---
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.lightBackground,
      cardColor: AppColors.lightSurface,
      dividerColor: AppColors.lightOutlineVariant,
      focusColor: AppColors.primary.withValues(alpha: 0.12),
      hoverColor: AppColors.primary.withValues(alpha: 0.04),
      highlightColor: AppColors.primary.withValues(alpha: 0.08),
      splashColor: AppColors.primary.withValues(alpha: 0.12),
      disabledColor: AppColors.lightTextDisabled,
      appBarTheme: _fixedAppBarTheme,
      cardTheme: _baseCardTheme(
        color: AppColors.lightSurface,
        borderColor: AppColors.lightOutline,
      ),
      elevatedButtonTheme: _elevatedButtonTheme(AppColors.primary),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: AppTextStyles.buttonMedium,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTextStyles.buttonMedium,
        ),
      ),
      inputDecorationTheme: _inputDecorationTheme(
        fillColor: AppColors.lightSurfaceVariant,
        borderColor: AppColors.lightOutline,
        focusedBorderColor: AppColors.primary,
        errorColor: AppColors.danger,
        hintColor: AppColors.lightTextTertiary,
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
          color: AppColors.primary,
        ),
        labelMedium: AppTextStyles.buttonMedium.copyWith(
          color: AppColors.primary,
        ),
        labelSmall: AppTextStyles.buttonSmall.copyWith(
          color: AppColors.primary,
        ),
      ),
      iconTheme: const IconThemeData(
        color: AppColors.lightIconPrimary,
        size: 24,
      ),
      primaryIconTheme: const IconThemeData(color: AppColors.primary, size: 24),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.lightIconSecondary,
        selectedIconTheme: IconThemeData(color: AppColors.primary),
        unselectedIconTheme: IconThemeData(color: AppColors.lightIconSecondary),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.lightTextSecondary,
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: AppColors.lightOutlineVariant,
      ),
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
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.primaryHover,
        secondary: AppColors.info,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.infoContainer,
        onSecondaryContainer: AppColors.info,
        tertiary: AppColors.primarySubtle,
        onTertiary: Colors.white,
        error: AppColors.danger,
        onError: AppColors.onDanger,
        errorContainer: AppColors.dangerContainer,
        onErrorContainer: AppColors.danger,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightTextPrimary,
        surfaceContainerHighest: AppColors.lightSurfaceVariant,
        onSurfaceVariant: AppColors.lightTextSecondary,
        outline: AppColors.lightOutline,
        outlineVariant: AppColors.lightOutlineVariant,
        shadow: AppColors.lightShadow,
        scrim: AppColors.lightScrim,
        inverseSurface: AppColors.darkSurface,
        onInverseSurface: AppColors.darkTextPrimary,
        inversePrimary: AppColors.primarySubtle,
        surfaceTint: AppColors.primary,
      ),
    );
  }

  // --- DARK THEME ---
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.darkBackground,
      cardColor: AppColors.darkSurface,
      dividerColor: AppColors.darkOutlineVariant,
      focusColor: AppColors.primary.withValues(alpha: 0.24),
      hoverColor: AppColors.primary.withValues(alpha: 0.08),
      highlightColor: AppColors.primary.withValues(alpha: 0.12),
      splashColor: AppColors.primary.withValues(alpha: 0.24),
      disabledColor: AppColors.darkTextDisabled,
      appBarTheme: _fixedAppBarTheme,
      cardTheme: _baseCardTheme(
        color: AppColors.darkSurface,
        borderColor: AppColors.darkOutline,
      ),
      elevatedButtonTheme: _elevatedButtonTheme(AppColors.primary),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: AppTextStyles.buttonMedium,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTextStyles.buttonMedium,
        ),
      ),
      inputDecorationTheme: _inputDecorationTheme(
        fillColor: AppColors.darkSurfaceVariant,
        borderColor: AppColors.darkOutline,
        focusedBorderColor: AppColors.primary,
        errorColor: AppColors.danger,
        hintColor: AppColors.darkTextTertiary,
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
          color: AppColors.primary,
        ),
        labelMedium: AppTextStyles.buttonMedium.copyWith(
          color: AppColors.primary,
        ),
        labelSmall: AppTextStyles.buttonSmall.copyWith(
          color: AppColors.primary,
        ),
      ),
      iconTheme: const IconThemeData(
        color: AppColors.darkIconPrimary,
        size: 24,
      ),
      primaryIconTheme: const IconThemeData(color: AppColors.primary, size: 24),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.darkIconSecondary,
        selectedIconTheme: const IconThemeData(color: AppColors.primary),
        unselectedIconTheme: IconThemeData(color: AppColors.darkIconSecondary),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.darkTextSecondary,
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: AppColors.darkOutlineVariant,
      ),
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
      colorScheme: ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.primarySubtle,
        secondary: AppColors.info,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.infoContainer,
        onSecondaryContainer: AppColors.info,
        tertiary: AppColors.primarySubtle,
        onTertiary: Colors.white,
        error: AppColors.danger,
        onError: AppColors.onDanger,
        errorContainer: AppColors.dangerContainer,
        onErrorContainer: AppColors.danger,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
        surfaceContainerHighest: AppColors.darkSurfaceVariant,
        onSurfaceVariant: AppColors.darkTextSecondary,
        outline: AppColors.darkOutline,
        outlineVariant: AppColors.darkOutlineVariant,
        shadow: AppColors.darkShadow,
        scrim: AppColors.darkScrim,
        inverseSurface: AppColors.lightSurface,
        onInverseSurface: AppColors.lightTextPrimary,
        inversePrimary: AppColors.primarySubtle,
        surfaceTint: AppColors.primary,
      ),
    );
  }

  static ThemeData of(BuildContext context) => Theme.of(context);
  static bool isDarkMode(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;
}
