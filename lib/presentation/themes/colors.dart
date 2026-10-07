// lib/presentation/themes/colors.dart
import 'package:flutter/material.dart';
import 'app_palette.dart';

/// Two kinds of colors:
///  1. static const  -> semantic/safety colors, identical in ALL themes
///  2. static fn(c)  -> theme-dependent colors, read from the active AppPalette
///
/// BREAKING CHANGE: `AppColors.primary` (const) is now `AppColors.primary(context)`.
/// All lightXxx / darkXxx tokens moved into AppPalette.
class AppColors {
  AppColors._();

  // ==========================================
  // ===== SEMANTIC / SAFETY (same in all themes)
  // ==========================================
  // Containers stay as 12% tints (not the solid hexes in the design sheet)
  // so they look right on both light and dark surfaces.
  static const Color success = Color(0xFF16A34A);
  static const Color activeLocation = Color(0xFF287444);
  static const Color successContainer = Color(0x1F16A34A); // sheet: #ECFDF3
  static const Color onSuccess = Colors.white;

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningContainer = Color(0x1FF59E0B); // sheet: #FFF7E6
  static const Color onWarning = Colors.white;

  static const Color danger = Color(0xFFDC2626);
  static const Color dangerContainer = Color(0x1FDC2626); // sheet: #FEF2F2
  static const Color onDanger = Colors.white;

  static const Color info = Color(0xFF0EA5E9);
  static const Color infoContainer = Color(0x1F0EA5E9); // sheet: #EFF8FF

  // NEW: "Offline" state from the design sheet
  static const Color offline = Color(0xFF64748B);
  static const Color offlineContainer = Color(0x1F64748B); // sheet: #F1F5F9

  // ==========================================
  // ===== MAP / SPECIAL ENVIRONMENT (unchanged)
  // ==========================================
  static const Color environmentCategory1 = Color(0xFFF59E0B);
  static const Color environmentCategory2 = Color(0xFFA855F7);
  static const Color environmentCategory3 = Color(0xFF10B981);

  static const Color lightMapPath = Color(0xFFFFFFFF);
  static const Color lightMapZonePrimary = Color(0xFFD1FAE5);
  static const Color lightMapZoneSecondary = Color(0xFFDBEAFE);

  static const Color darkMapPath = Color(0xFF1E1D2D);
  static const Color darkMapZonePrimary = Color(0xFF064E3B);
  static const Color darkMapZoneSecondary = Color(0xFF1E3A8A);

  // ==========================================
  // ===== THEME-AWARE (read from AppPalette)
  // ==========================================
  static AppPalette _p(BuildContext c) => AppPalette.of(c);

  // Brand
  static Color primary(BuildContext c) => _p(c).primary;
  static Color onPrimary(BuildContext c) => _p(c).onPrimary;
  static Color primaryHover(BuildContext c) => _p(c).primaryHover;
  static Color primarySubtle(BuildContext c) => _p(c).primarySubtle;
  static Color primaryContainer(BuildContext c) => _p(c).primaryContainer;
  static Color onPrimaryContainer(BuildContext c) => _p(c).onPrimaryContainer;
  static Color primaryBorder(BuildContext c) =>
      _p(c).primary.withValues(alpha: 0.4);
  static Color accent(BuildContext c) => _p(c).accent;
  static Color accentContainer(BuildContext c) => _p(c).accentContainer;

  static LinearGradient primaryGradient(BuildContext c) => LinearGradient(
    colors: [_p(c).primary, _p(c).primaryHover],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Surfaces / borders / text / icons
  static Color background(BuildContext c) => _p(c).background;
  static Color surface(BuildContext c) => _p(c).surface;
  static Color surfaceVariant(BuildContext c) => _p(c).surfaceVariant;
  static Color outline(BuildContext c) => _p(c).outline;
  static Color outlineVariant(BuildContext c) => _p(c).outlineVariant;
  static Color textPrimary(BuildContext c) => _p(c).textPrimary;
  static Color textSecondary(BuildContext c) => _p(c).textSecondary;
  static Color textTertiary(BuildContext c) => _p(c).textTertiary;
  static Color iconPrimary(BuildContext c) => _p(c).iconPrimary;
  static Color iconSecondary(BuildContext c) => _p(c).iconSecondary;
  static Color shadow(BuildContext c) => _p(c).shadow;
  static Color scrim(BuildContext c) => _p(c).scrim;
}
