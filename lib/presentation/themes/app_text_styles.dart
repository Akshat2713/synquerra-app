// lib/presentation/themes/app_text_styles.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

/// Centralized text styles using Google Fonts (Inter as primary, Plus Jakarta Sans as fallback).
/// Role-based typography system for consistent text hierarchy.
class AppTextStyles {
  AppTextStyles._();

  // ===== FONT FAMILY CONFIGURATION =====
  // Use Inter as primary font, Plus Jakarta Sans as fallback
  static const String _fontFamily = 'Inter';
  static const String _fallbackFontFamily = 'Plus Jakarta Sans';

  // Helper to create TextStyle with proper font family
  static TextStyle _style({
    required double fontSize,
    required FontWeight fontWeight,
    double? height,
    double? letterSpacing,
    Color? color,
  }) => GoogleFonts.getFont(
    _fontFamily,
    fontSize: fontSize,
    fontWeight: fontWeight,
    height: height,
    letterSpacing: letterSpacing,
    color: color,
  ).copyWith(fontFamilyFallback: const [_fallbackFontFamily]);

  // ===== ROLE-BASED TYPOGRAPHY =====
  // display - Large, bold, high-emphasis text
  static TextStyle get display => _style(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
  );

  // title - Medium size, bold, section titles
  static TextStyle get title =>
      _style(fontSize: 20, fontWeight: FontWeight.w700, height: 1.3);

  // section - Smaller section headers
  static TextStyle get section =>
      _style(fontSize: 16, fontWeight: FontWeight.w600, height: 1.4);

  // body - Default text for paragraphs and content
  static TextStyle get body =>
      _style(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5);

  // meta - Supplementary information
  static TextStyle get meta => _style(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.2,
  );

  // micro - Very small text for labels, captions only
  static TextStyle get micro => _style(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.5,
  );

  // ===== DEPRECATED ALIASES (for backward compatibility) =====
  // Headings - mapped to new roles
  @Deprecated('Use AppTextStyles.display instead')
  static TextStyle get heading1 => display;

  @Deprecated('Use AppTextStyles.display instead')
  static TextStyle get heading2 => display.copyWith(fontSize: 28);

  @Deprecated('Use AppTextStyles.title instead')
  static TextStyle get heading3 =>
      title.copyWith(fontSize: 24, fontWeight: FontWeight.w600);

  @Deprecated('Use AppTextStyles.title instead')
  static TextStyle get heading4 => title;

  @Deprecated('Use AppTextStyles.section instead')
  static TextStyle get heading5 => section.copyWith(fontSize: 18);

  @Deprecated('Use AppTextStyles.section instead')
  static TextStyle get heading6 => section;

  // Body text - mapped to new roles
  @Deprecated('Use AppTextStyles.section instead')
  static TextStyle get bodyLarge => section;

  @Deprecated('Use AppTextStyles.body instead')
  static TextStyle get bodyMedium => body;

  @Deprecated('Use AppTextStyles.meta instead')
  static TextStyle get bodySmall => meta;

  // Captions & Labels
  @Deprecated('Use AppTextStyles.meta instead')
  static TextStyle get caption => meta;

  @Deprecated('Use AppTextStyles.micro instead')
  static TextStyle get overline => micro;

  @Deprecated('Use AppTextStyles.body instead')
  static TextStyle get label => body.copyWith(fontWeight: FontWeight.w500);

  @Deprecated('Use AppTextStyles.meta instead')
  static TextStyle get labelSmall => meta;

  // Button text - mapped to appropriate roles
  @Deprecated('Use AppTextStyles.section for large buttons')
  static TextStyle get buttonLarge =>
      section.copyWith(letterSpacing: 0.5, fontWeight: FontWeight.w600);

  @Deprecated('Use AppTextStyles.body for medium buttons')
  static TextStyle get buttonMedium =>
      body.copyWith(letterSpacing: 0.3, fontWeight: FontWeight.w600);

  @Deprecated('Use AppTextStyles.meta for small buttons')
  static TextStyle get buttonSmall =>
      meta.copyWith(letterSpacing: 0.2, fontWeight: FontWeight.w600);

  // Monospace (unchanged, still needed for technical data)
  static const TextStyle mono = TextStyle(
    fontFamily: 'monospace',
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.2,
  );

  // ===== THEME-AWARE HELPERS =====
  // Keep these for backward compatibility
  static TextStyle heading1WithColor(BuildContext context, {Color? color}) =>
      display.copyWith(color: color ?? _primary(context));
  static TextStyle bodyWithColor(BuildContext context, {Color? color}) =>
      body.copyWith(color: color ?? _secondary(context));
  static TextStyle captionWithColor(BuildContext context, {Color? color}) =>
      meta.copyWith(color: color ?? _tertiary(context));

  static Color _primary(BuildContext c) => AppColors.textPrimary(c);
  static Color _secondary(BuildContext c) => AppColors.textSecondary(c);
  static Color _tertiary(BuildContext c) => AppColors.textTertiary(c);

  // New theme-aware helpers for role-based system
  static TextStyle displayWithColor(BuildContext context, {Color? color}) =>
      display.copyWith(color: color ?? _primary(context));
  static TextStyle titleWithColor(BuildContext context, {Color? color}) =>
      title.copyWith(color: color ?? _primary(context));
  static TextStyle sectionWithColor(BuildContext context, {Color? color}) =>
      section.copyWith(color: color ?? _primary(context));
  static TextStyle metaWithColor(BuildContext context, {Color? color}) =>
      meta.copyWith(color: color ?? _secondary(context));
  static TextStyle microWithColor(BuildContext context, {Color? color}) =>
      micro.copyWith(color: color ?? _tertiary(context));
}
