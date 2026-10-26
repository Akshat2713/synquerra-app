// lib/presentation/themes/app_theme.dart
import 'package:flutter/material.dart';
import 'package:synquerra/presentation/themes/colors.dart';
import 'app_palette.dart';
import 'app_text_styles.dart';
import 'app_tokens.dart';

/// Builds ThemeData for ANY AppThemeType from its AppPalette.
class AppTheme {
  AppTheme._();

  static ThemeData fromType(AppThemeType type) =>
      _build(AppPalette.fromType(type));

  static ThemeData _build(AppPalette p) {
    final isDark = p.brightness == Brightness.dark;
    final shapeMd = RoundedRectangleBorder(borderRadius: AppRadius.mdAll);
    final shapeLg = RoundedRectangleBorder(borderRadius: AppRadius.lgAll);
    const buttonMin = Size(AppSize.buttonMinWidth, AppSize.tapTarget);

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
      extensions: <ThemeExtension<dynamic>>[p], // AppColors.xxx(context)
      primaryColor: p.primary,
      scaffoldBackgroundColor: p.background,
      cardColor: p.surface,
      dividerColor: p.outlineVariant,
      focusColor: AppAlpha.withAlpha(p.primary, AppAlpha.pressed),
      hoverColor: AppAlpha.withAlpha(p.primary, AppAlpha.hover),
      highlightColor: AppAlpha.withTint(p.primary),
      splashColor: AppAlpha.withAlpha(p.primary, AppAlpha.pressed),
      disabledColor: p.textDisabled,

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: shapeMd,
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surface,
        modalBackgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.lg),
          ),
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: p.background,
        foregroundColor: p.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: AppSize.elevationLow,
        centerTitle: true,
        iconTheme: IconThemeData(color: p.textPrimary),
        actionsIconTheme: IconThemeData(color: p.textPrimary),
        titleTextStyle: AppTextStyles.title.copyWith(color: p.textPrimary),
      ),

      // Matches AppCard: lg radius + outline border. No elevation, so raw
      // Card() looks like AppCard minus the layered shadow.
      cardTheme: CardThemeData(
        color: p.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.only(bottom: AppSpacing.md),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.lgAll,
          side: BorderSide(color: AppAlpha.withOverlayAlpha(p.outline)),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // Secondary action
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: p.surface,
          foregroundColor: p.primary,
          minimumSize: buttonMin,
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          shape: shapeMd,
          elevation: 0,
          textStyle: AppTextStyles.button,
        ),
      ),
      // Primary action
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.primary,
          foregroundColor: p.onPrimary,
          minimumSize: buttonMin,
          shape: shapeMd,
          textStyle: AppTextStyles.button,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.primary,
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          textStyle: AppTextStyles.button,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.primary,
          side: BorderSide(color: p.primary),
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          shape: shapeMd,
          textStyle: AppTextStyles.button,
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
          vertical: AppSpacing.smd,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide.none,
        ),
        enabledBorder: _inputBorder(p.outline, AppSize.hairline),
        focusedBorder: _inputBorder(p.primary, AppSize.stroke),
        errorBorder: _inputBorder(AppColors.danger, AppSize.hairline),
        focusedErrorBorder: _inputBorder(AppColors.danger, AppSize.stroke),
        labelStyle: AppTextStyles.body,
        hintStyle: AppTextStyles.body.copyWith(color: p.textTertiary),
        errorStyle: AppTextStyles.meta.copyWith(color: AppColors.danger),
      ),

      // Mapped to roles only (no size overrides).
      textTheme: TextTheme(
        displayLarge: AppTextStyles.display.copyWith(color: p.textPrimary),
        displayMedium: AppTextStyles.display.copyWith(color: p.textPrimary),
        displaySmall: AppTextStyles.title.copyWith(color: p.textPrimary),
        headlineMedium: AppTextStyles.title.copyWith(color: p.textPrimary),
        headlineSmall: AppTextStyles.section.copyWith(color: p.textPrimary),
        titleLarge: AppTextStyles.section.copyWith(color: p.textPrimary),
        bodyLarge: AppTextStyles.section.copyWith(color: p.textPrimary),
        bodyMedium: AppTextStyles.body.copyWith(color: p.textSecondary),
        bodySmall: AppTextStyles.meta.copyWith(color: p.textTertiary),
        labelLarge: AppTextStyles.section.copyWith(color: p.primary),
        labelMedium: AppTextStyles.button.copyWith(color: p.primary),
        labelSmall: AppTextStyles.meta.copyWith(color: p.primary),
      ),

      iconTheme: IconThemeData(color: p.iconPrimary, size: AppSize.iconLg),
      primaryIconTheme: IconThemeData(color: p.primary, size: AppSize.iconLg),

      // NEW: this is what DeviceShellScreen's NavigationBar actually reads.
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        indicatorColor: p.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => AppTextStyles.meta.copyWith(
            color: s.contains(WidgetState.selected)
                ? p.primary
                : p.textSecondary,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(
            color: s.contains(WidgetState.selected)
                ? p.onPrimaryContainer
                : p.iconSecondary,
          ),
        ),
      ),

      // Old-style bar, kept in case main_shell/bottom_bar.dart uses it.
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: p.surface,
        selectedItemColor: p.primary,
        unselectedItemColor: p.iconSecondary,
        selectedIconTheme: IconThemeData(color: p.primary),
        unselectedIconTheme: IconThemeData(color: p.iconSecondary),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: AppSize.elevationHigh,
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: p.primary,
        unselectedLabelColor: p.textSecondary,
        indicatorColor: p.primary,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: p.outlineVariant,
      ),

      sliderTheme: SliderThemeData(
        trackHeight: AppSize.sliderTrack,
        activeTrackColor: p.primary,
        inactiveTrackColor: AppAlpha.withBorderAlpha(p.outlineVariant),
        thumbColor: p.primary,
        overlayColor: AppAlpha.withAlpha(p.primary, AppAlpha.pressed),
        thumbShape: const RoundSliderThumbShape(
          enabledThumbRadius: AppSize.sliderThumb,
        ),
        overlayShape: const RoundSliderOverlayShape(
          overlayRadius: AppSize.sliderOverlay,
        ),
      ),

      popupMenuTheme: PopupMenuThemeData(
        color: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: shapeMd,
        textStyle: AppTextStyles.body.copyWith(color: p.textPrimary),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: shapeLg,
        titleTextStyle: AppTextStyles.section.copyWith(color: p.textPrimary),
        contentTextStyle: AppTextStyles.body.copyWith(color: p.textSecondary),
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, double width) =>
      OutlineInputBorder(
        borderRadius: AppRadius.mdAll,
        borderSide: BorderSide(color: color, width: width),
      );

  static ThemeData of(BuildContext context) => Theme.of(context);
  static bool isDarkMode(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;
}
