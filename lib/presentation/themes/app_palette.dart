// lib/presentation/themes/app_palette.dart
import 'package:flutter/material.dart';

/// The 4 selectable themes. Dark is just another option in the dropdown.
enum AppThemeType {
  cleanCalm('Clean Calm', Color(0xFF0EA5E9)),
  aadyaBrand('AADYA Brand', Color(0xFF7C3AED)),
  natureCalm('Nature Calm', Color(0xFF10B981)),
  dark('Dark', Color(0xFF1A1424));

  const AppThemeType(this.label, this.swatch);

  final String label;

  /// Small dot shown next to the name in the theme dropdown.
  final Color swatch;

  /// Safe parse for persisted values. Old values like "light" fall back
  /// to cleanCalm; old "dark" still maps to dark.
  static AppThemeType fromName(String? name) =>
      AppThemeType.values.asNameMap()[name] ?? AppThemeType.cleanCalm;
}

/// Every color that CHANGES between themes lives here.
/// Semantic/safety colors (success, danger...) stay in AppColors as constants.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.brightness,
    required this.primary,
    required this.primaryHover,
    required this.primarySubtle,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.accent,
    required this.accentContainer,
    required this.background,
    required this.surface,
    this.onPrimary = Colors.white,
    // Shared neutrals (light defaults, dark overrides them)
    this.surfaceVariant = const Color(0xFFF3F3F8),
    this.outline = const Color(0xFFE5E5EA),
    this.outlineVariant = const Color(0xFFF0F0F4),
    this.textPrimary = const Color(0xFF17171C),
    this.textSecondary = const Color(0xFF5F6068),
    this.textTertiary = const Color(0xFF8A8B94),
    this.textDisabled = const Color(0xFFCBD5E1),
    this.iconPrimary = const Color(0xFF17171C),
    this.iconSecondary = const Color(0xFF8A8B94),
    this.shadow = const Color(0x14000000),
    this.scrim = const Color(0x52000000),
  });

  final Brightness brightness;
  final Color primary, onPrimary, primaryHover, primarySubtle;
  final Color primaryContainer, onPrimaryContainer;
  final Color accent, accentContainer;
  final Color background, surface, surfaceVariant;
  final Color outline, outlineVariant;
  final Color textPrimary, textSecondary, textTertiary, textDisabled;
  final Color iconPrimary, iconSecondary;
  final Color shadow, scrim;

  // ---------- 1. Clean Calm (sky blue) ----------
  static const cleanCalm = AppPalette(
    brightness: Brightness.light,
    primary: Color(0xFF0284C7),
    primaryHover: Color(0xFF0369A1),
    primarySubtle: Color(0xFF38BDF8),
    primaryContainer: Color(0xFFE0F2FE),
    onPrimaryContainer: Color(0xFF0369A1),
    accent: Color(0xFF0EA5E9),
    accentContainer: Color(0xFFE0F2FE),
    background: Color(0xFFF7F7F8),
    surface: Color(0xFFFFFFFF),
  );

  // ---------- 2. AADYA Brand ----------
  static const aadyaBrand = AppPalette(
    brightness: Brightness.light,
    primary: Color(0xFF312C6A),
    primaryHover: Color(0xFF3D3690), // Indigo 700
    primarySubtle: Color(0xFF4A4580), // Indigo 600
    primaryContainer: Color(0xFFE8E7F5),
    onPrimaryContainer: Color(0xFF312C6A),
    accent: Color(0xFF7C3AED),
    accentContainer: Color(0xFFEDE9FE), // derived
    background: Color(0xFFF8F7FF),
    surface: Color(0xFFFFFFFF),
  );

  // ---------- 3. Nature Calm (emerald) ----------
  static const natureCalm = AppPalette(
    brightness: Brightness.light,
    primary: Color(0xFF059669),
    primaryHover: Color(0xFF047857),
    primarySubtle: Color(0xFF34D399),
    primaryContainer: Color(0xFFD1FAE5),
    onPrimaryContainer: Color(0xFF047857),
    accent: Color(0xFF10B981),
    accentContainer: Color(0xFFD1FAE5),
    background: Color(0xFFF6FBF9),
    surface: Color(0xFFFFFFFF),
  );

  // ---------- 4. Dark (NOT in the design sheet: values are my proposal) ----------
  // #312C6A is too dark to read on a dark background, so primary is a lifted indigo.
  static const dark = AppPalette(
    brightness: Brightness.dark,
    primary: Color(0xFF9B96E8),
    onPrimary: Color(0xFF1A1740),
    primaryHover: Color(0xFFB3AFF0),
    primarySubtle: Color(0xFF6C67C4),
    primaryContainer: Color(0x339B96E8),
    onPrimaryContainer: Color(0xFFC9C6F7),
    accent: Color(0xFF38BDF8),
    accentContainer: Color(0x1F38BDF8),
    background: Color(0xFF0C0A12),
    surface: Color(0xFF1A1424),
    surfaceVariant: Color(0xFF1D1C2B),
    outline: Color(0xFF272538),
    outlineVariant: Color(0xFF1E1D2D),
    textPrimary: Color(0xFFF8FAFC),
    textSecondary: Color(0xFFCBD5E1),
    textTertiary: Color(0xFF64748B),
    textDisabled: Color(0xFF475569),
    iconPrimary: Color(0xFFF8FAFC),
    iconSecondary: Color(0xFF64748B),
    shadow: Color(0x33000000),
    scrim: Color(0x80000000),
  );

  static AppPalette fromType(AppThemeType type) => switch (type) {
    AppThemeType.cleanCalm => cleanCalm,
    AppThemeType.aadyaBrand => aadyaBrand,
    AppThemeType.natureCalm => natureCalm,
    AppThemeType.dark => dark,
  };

  static AppPalette of(BuildContext context) =>
      Theme.of(context).extension<AppPalette>() ?? cleanCalm;

  // Themes switch instantly, so no real interpolation is needed.
  @override
  AppPalette copyWith() => this;

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) =>
      other is AppPalette && t >= 0.5 ? other : this;
}
