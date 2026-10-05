// lib/presentation/themes/app_theme.dart
import 'package:flutter/material.dart';
import 'package:synquerra/presentation/themes/colors.dart';
import 'app_palette.dart';
import 'app_text_styles.dart';

/// Builds ThemeData for ANY AppThemeType from its AppPalette.
/// One builder instead of separate light/dark copies.
class AppTheme {
  AppTheme._();

  static ThemeData fromType(AppThemeType type) =>
      _build(AppPalette.fromType(type));

  static ThemeData _build(AppPalette p) {
    final isDark = p.brightness == Brightness.dark;
    final shape12 = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    );

    final scheme = ColorScheme(
      brightness: p.brightness,
      primary: p.primary,
      onPrimary: p.onPrimary,
      primaryContainer: p.primaryContainer,
      onPrimaryContainer: p.onPrimaryContainer,
      secondary: p.accent,
      onSecondary: isDark ? p.background : Colors.white,
      secondaryContainer: p.accentContainer,
      onSecondaryContainer: isDark ? p.accent : p.primary,
      tertiary: p.primarySubtle,
      onTertiary: Colors.white,
      error: AppColors.danger,
      onError: AppColors.onDanger,
      errorContainer: AppColors.dangerContainer,
      onErrorContainer: AppColors.danger,
      surface: p.surface,
      onSurface: p.textPrimary,
      surfaceContainerHighest: p.surfaceVariant,
      onSurfaceVariant: p.textSecondary,
      outline: p.outline,
      outlineVariant: p.outlineVariant,
      shadow: p.shadow,
      scrim: p.scrim,
      inverseSurface: p.textPrimary,
      onInverseSurface: p.surface,
      inversePrimary: p.primarySubtle,
      surfaceTint: p.primary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: p.brightness,
      colorScheme: scheme,
      extensions: <ThemeExtension<dynamic>>[
        p,
      ], // <- AppColors.xxx(context) reads this
      primaryColor: p.primary,
      scaffoldBackgroundColor: p.background,
      cardColor: p.surface,
      dividerColor: p.outlineVariant,
      focusColor: p.primary.withValues(alpha: isDark ? 0.24 : 0.12),
      hoverColor: p.primary.withValues(alpha: isDark ? 0.08 : 0.04),
      highlightColor: p.primary.withValues(alpha: isDark ? 0.12 : 0.08),
      splashColor: p.primary.withValues(alpha: isDark ? 0.24 : 0.12),
      disabledColor: p.textDisabled,
      appBarTheme: AppBarTheme(
        backgroundColor: p.surfaceVariant,
        foregroundColor: p.textPrimary,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: p.textPrimary),
        actionsIconTheme: IconThemeData(color: p.textPrimary),
        titleTextStyle: AppTextStyles.heading4.copyWith(color: p.textPrimary),
        shape: Border(bottom: BorderSide(color: p.outline, width: 1)),
      ),
      cardTheme: CardThemeData(
        color: p.surface,
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: p.outline, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      // "Primary Button" in the design sheet
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: p.primary,
          foregroundColor: p.onPrimary,
          minimumSize: const Size(88, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: shape12,
          elevation: 0,
          textStyle: AppTextStyles.buttonMedium,
        ),
      ),
      // "Secondary Button" in the design sheet = accent color
      // (use FilledButton for secondary actions)
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.accent,
          foregroundColor: isDark ? p.background : Colors.white,
          minimumSize: const Size(88, 48),
          shape: shape12,
          textStyle: AppTextStyles.buttonMedium,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: AppTextStyles.buttonMedium,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.primary,
          side: BorderSide(color: p.primary),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: shape12,
          textStyle: AppTextStyles.buttonMedium,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? p.primary : null,
        ),
        checkColor: WidgetStatePropertyAll(p.onPrimary),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? p.onPrimary : null,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? p.primary : null,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: _inputBorder(p.outline, 1),
        focusedBorder: _inputBorder(p.primary, 2),
        errorBorder: _inputBorder(AppColors.danger, 1),
        focusedErrorBorder: _inputBorder(AppColors.danger, 2),
        labelStyle: AppTextStyles.label,
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: p.textTertiary),
        errorStyle: AppTextStyles.caption.copyWith(color: AppColors.danger),
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.heading1.copyWith(color: p.textPrimary),
        displayMedium: AppTextStyles.heading2.copyWith(color: p.textPrimary),
        displaySmall: AppTextStyles.heading3.copyWith(color: p.textPrimary),
        headlineMedium: AppTextStyles.heading4.copyWith(color: p.textPrimary),
        headlineSmall: AppTextStyles.heading5.copyWith(color: p.textPrimary),
        titleLarge: AppTextStyles.heading6.copyWith(color: p.textPrimary),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: p.textPrimary),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: p.textSecondary),
        bodySmall: AppTextStyles.bodySmall.copyWith(color: p.textTertiary),
        labelLarge: AppTextStyles.buttonLarge.copyWith(color: p.primary),
        labelMedium: AppTextStyles.buttonMedium.copyWith(color: p.primary),
        labelSmall: AppTextStyles.buttonSmall.copyWith(color: p.primary),
      ),
      iconTheme: IconThemeData(color: p.iconPrimary, size: 24),
      primaryIconTheme: IconThemeData(color: p.primary, size: 24),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: p.surface,
        selectedItemColor: p.primary,
        unselectedItemColor: p.iconSecondary,
        selectedIconTheme: IconThemeData(color: p.primary),
        unselectedIconTheme: IconThemeData(color: p.iconSecondary),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: p.primary,
        unselectedLabelColor: p.textSecondary,
        indicatorColor: p.primary,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: p.outlineVariant,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: AppTextStyles.heading5.copyWith(color: p.textPrimary),
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: p.textSecondary,
        ),
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, double width) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width),
      );

  static ThemeData of(BuildContext context) => Theme.of(context);
  static bool isDarkMode(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;
}
