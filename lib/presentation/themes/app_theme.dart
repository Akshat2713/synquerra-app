// lib/presentation/themes/app_theme.dart
import 'package:flutter/material.dart';
import 'package:synquerra/presentation/themes/colors.dart';
import 'app_palette.dart';
import 'app_text_styles.dart';
import 'app_tokens.dart';

/// Builds ThemeData for ANY AppThemeType from its AppPalette.
/// One builder instead of separate light/dark copies.
class AppTheme {
  AppTheme._();

  static ThemeData fromType(AppThemeType type) =>
      _build(AppPalette.fromType(type));

  static ThemeData _build(AppPalette p) {
    final isDark = p.brightness == Brightness.dark;
    final shape12 = RoundedRectangleBorder(
      borderRadius: AppRadius.mdAll,
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
        backgroundColor: p.background,
        foregroundColor: p.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: true,
        iconTheme: IconThemeData(color: p.textPrimary),
        actionsIconTheme: IconThemeData(color: p.textPrimary),
        titleTextStyle: AppTextStyles.title.copyWith(color: p.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: p.surface,
        elevation: 2,
        shadowColor: p.shadow,
        margin: EdgeInsets.only(bottom: AppSpacing.md),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.mdAll,
        ),
        clipBehavior: Clip.antiAlias,
      ),
      // Elevated button (for secondary actions)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: p.surface,
          foregroundColor: p.primary,
          minimumSize: const Size(88, 48),
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          shape: shape12,
          elevation: 0,
          textStyle: AppTextStyles.buttonMedium,
        ),
      ),
      // FilledButton for primary actions (uses primary color)
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.primary,
          foregroundColor: p.onPrimary,
          minimumSize: const Size(88, 48),
          shape: shape12,
          textStyle: AppTextStyles.buttonMedium,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.primary,
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
          textStyle: AppTextStyles.buttonMedium,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.primary,
          side: BorderSide(color: p.primary),
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
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
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.smAll,
          borderSide: BorderSide.none,
        ),
        enabledBorder: _inputBorder(p.outline, 1),
        focusedBorder: _inputBorder(p.primary, 2),
        errorBorder: _inputBorder(AppColors.danger, 1),
        focusedErrorBorder: _inputBorder(AppColors.danger, 2),
        labelStyle: AppTextStyles.label,
        hintStyle: AppTextStyles.body.copyWith(color: p.textTertiary),
        errorStyle: AppTextStyles.meta.copyWith(color: AppColors.danger),
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.display.copyWith(color: p.textPrimary),
        displayMedium: AppTextStyles.display.copyWith(fontSize: 28, color: p.textPrimary),
        displaySmall: AppTextStyles.title.copyWith(fontSize: 24, color: p.textPrimary),
        headlineMedium: AppTextStyles.title.copyWith(color: p.textPrimary),
        headlineSmall: AppTextStyles.section.copyWith(fontSize: 18, color: p.textPrimary),
        titleLarge: AppTextStyles.section.copyWith(color: p.textPrimary),
        bodyLarge: AppTextStyles.section.copyWith(color: p.textPrimary),
        bodyMedium: AppTextStyles.body.copyWith(color: p.textSecondary),
        bodySmall: AppTextStyles.meta.copyWith(color: p.textTertiary),
        labelLarge: AppTextStyles.section.copyWith(color: p.primary, fontWeight: FontWeight.w600),
        labelMedium: AppTextStyles.body.copyWith(color: p.primary, fontWeight: FontWeight.w600),
        labelSmall: AppTextStyles.meta.copyWith(color: p.primary, fontWeight: FontWeight.w600),
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
