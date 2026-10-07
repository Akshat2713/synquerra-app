// lib/presentation/themes/app_palette.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:synquerra/core/utils/app_logger.dart';

/// Helper to calculate contrast ratio between two colors (WCAG 2.1).
/// Returns ratio, with 4.5:1 being the minimum for normal text.
double _contrastRatio(Color foreground, Color background) {
  final double luminance1 = _relativeLuminance(foreground);
  final double luminance2 = _relativeLuminance(background);
  final double lighter = max(luminance1, luminance2);
  final double darker = min(luminance1, luminance2);
  return (lighter + 0.05) / (darker + 0.05);
}

/// Calculate relative luminance (WCAG 2.1).
double _relativeLuminance(Color color) {
  final double r = (color.r * 255.0).round().clamp(0, 255) / 255.0;
  final double g = (color.g * 255.0).round().clamp(0, 255) / 255.0;
  final double b = (color.b * 255.0).round().clamp(0, 255) / 255.0;

  final double rs = (r <= 0.03928)
      ? r / 12.92
      : pow((r + 0.055) / 1.055, 2.4).toDouble();
  final double gs = (g <= 0.03928)
      ? g / 12.92
      : pow((g + 0.055) / 1.055, 2.4).toDouble();
  final double bs = (b <= 0.03928)
      ? b / 12.92
      : pow((b + 0.055) / 1.055, 2.4).toDouble();

  return 0.2126 * rs + 0.7152 * gs + 0.0722 * bs;
}

/// Validate contrast ratios for a palette and print results.
void _validatePalette(String name, AppPalette palette) {
  AppLogger.d('AppPalette', '\n===== CONTRAST VALIDATION: $name =====');

  // Text-on-background pairs
  final textPairs = [
    ['textPrimary', palette.textPrimary, 'background', palette.background],
    ['textSecondary', palette.textSecondary, 'background', palette.background],
    ['textTertiary', palette.textTertiary, 'background', palette.background],
    ['textPrimary', palette.textPrimary, 'surface', palette.surface],
    ['textSecondary', palette.textSecondary, 'surface', palette.surface],
    ['textTertiary', palette.textTertiary, 'surface', palette.surface],
    [
      'textPrimary',
      palette.textPrimary,
      'surfaceVariant',
      palette.surfaceVariant,
    ],
    [
      'textSecondary',
      palette.textSecondary,
      'surfaceVariant',
      palette.surfaceVariant,
    ],
    ['onPrimary', palette.onPrimary, 'primary', palette.primary],
    [
      'onPrimaryContainer',
      palette.onPrimaryContainer,
      'primaryContainer',
      palette.primaryContainer,
    ],
  ];

  bool allValid = true;

  for (final pair in textPairs) {
    final ratio = _contrastRatio(pair[1] as Color, pair[3] as Color);
    final minRequired = 4.5; // WCAG AA for normal text
    final valid = ratio >= minRequired;

    AppLogger.d(
      'AppPalette',
      '${pair[0]} on ${pair[2]}: ${ratio.toStringAsFixed(2)}:1 ${valid ? "✅ PASS" : "❌ FAIL"} (needs ≥$minRequired:1)',
    );

    if (!valid) {
      allValid = false;
    }
  }

  // UI component pairs (minimum 3:1)
  final uiPairs = [
    ['outline', palette.outline, 'surface', palette.surface],
    ['outline', palette.outline, 'background', palette.background],
    ['outlineVariant', palette.outlineVariant, 'surface', palette.surface],
    [
      'outlineVariant',
      palette.outlineVariant,
      'background',
      palette.background,
    ],
  ];

  AppLogger.d('AppPalette', '\nUI Component Contrast:');
  for (final pair in uiPairs) {
    final ratio = _contrastRatio(pair[1] as Color, pair[3] as Color);
    final minRequired = 3.0; // WCAG for UI components
    final valid = ratio >= minRequired;

    AppLogger.d(
      'AppPalette',
      '${pair[0]} on ${pair[2]}: ${ratio.toStringAsFixed(2)}:1 ${valid ? "✅ PASS" : "❌ FAIL"} (needs ≥$minRequired:1)',
    );

    if (!valid) {
      allValid = false;
    }
  }

  if (allValid) {
    AppLogger.d(
      'AppPalette',
      '\n✅ All contrast ratios meet WCAG AA requirements!',
    );
  } else {
    AppLogger.d('AppPalette', '\n❌ Some contrast ratios need adjustment!');
  }
}

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
    textTertiary: Color(0xFF6B6C75),
    outline: Color(0xFFD9DAE0),
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
    textTertiary: Color(0xFF6B6C75),
    outline: Color(0xFFD9DAE0),
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
    textTertiary: Color(0xFF6B6C75),
    outline: Color(0xFFD9DAE0),
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
    outline: Color(0xFF34324A),
    outlineVariant: Color(0xFF1E1D2D),
    textPrimary: Color(0xFFF8FAFC),
    textSecondary: Color(0xFFCBD5E1),
    textTertiary: Color(0xFF94A3B8),
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

  // Validation method that can be called during development
  static void validateAllPalettes() {
    _validatePalette('Clean Calm', cleanCalm);
    _validatePalette('AADYA Brand', aadyaBrand);
    _validatePalette('Nature Calm', natureCalm);
    _validatePalette('Dark', dark);
  }
}
