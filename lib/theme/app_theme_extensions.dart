import 'package:flutter/material.dart';
import 'colors.dart';

/// Extensions on BuildContext for easy theme access
/// This file handles ONLY context extensions - no color definitions
extension ThemeExtensions on BuildContext {
  // ===== THEME DATA =====
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  bool get isDarkMode => theme.brightness == Brightness.dark;

  // ===== SURFACE COLORS =====
  Color get surfaceColor =>
      isDarkMode ? AppColors.darkSurface : AppColors.lightSurface;

  Color get surfaceSecondaryColor => isDarkMode
      ? AppColors.darkSurfaceSecondary
      : AppColors.lightSurfaceSecondary;

  Color get surfaceTertiaryColor => isDarkMode
      ? AppColors.darkSurfaceTertiary
      : AppColors.lightSurfaceTertiary;

  // ===== TEXT COLORS =====
  Color get primaryTextColor =>
      isDarkMode ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

  Color get secondaryTextColor =>
      isDarkMode ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

  Color get tertiaryTextColor =>
      isDarkMode ? AppColors.darkTextTertiary : AppColors.lightTextTertiary;

  Color get disabledTextColor =>
      isDarkMode ? AppColors.darkTextDisabled : AppColors.lightTextDisabled;

  // ===== ICON COLORS =====
  Color get primaryIconColor =>
      isDarkMode ? AppColors.darkIconPrimary : AppColors.lightIconPrimary;

  Color get secondaryIconColor =>
      isDarkMode ? AppColors.darkIconSecondary : AppColors.lightIconSecondary;

  Color get disabledIconColor =>
      isDarkMode ? AppColors.darkIconDisabled : AppColors.lightIconDisabled;

  // ===== BORDER & DIVIDER COLORS =====
  Color get borderColor =>
      isDarkMode ? AppColors.darkBorder : AppColors.lightBorder;

  Color get dividerColor =>
      isDarkMode ? AppColors.darkDivider : AppColors.lightDivider;

  // ===== BACKGROUND COLORS =====
  Color get backgroundColor =>
      isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;
}

/// Extension on TextStyle for easy color theming
extension TextStyleExtensions on TextStyle {
  TextStyle withPrimaryColor(BuildContext context) {
    return copyWith(color: context.primaryTextColor);
  }

  TextStyle withSecondaryColor(BuildContext context) {
    return copyWith(color: context.secondaryTextColor);
  }

  TextStyle withTertiaryColor(BuildContext context) {
    return copyWith(color: context.tertiaryTextColor);
  }

  TextStyle withColor(Color color) {
    return copyWith(color: color);
  }
}
