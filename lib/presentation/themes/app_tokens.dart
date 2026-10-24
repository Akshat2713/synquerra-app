// lib/presentation/themes/app_tokens.dart
import 'package:flutter/material.dart';

/// Design tokens for consistent spacing and radii across the app.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;

  /// Convenience getters for EdgeInsets
  static EdgeInsets get xsAll => const EdgeInsets.all(xs);
  static EdgeInsets get smAll => const EdgeInsets.all(sm);
  static EdgeInsets get mdAll => const EdgeInsets.all(md);
  static EdgeInsets get lgAll => const EdgeInsets.all(lg);
  static EdgeInsets get xlAll => const EdgeInsets.all(xl);

  static EdgeInsets xsHorizontal = const EdgeInsets.symmetric(horizontal: xs);
  static EdgeInsets smHorizontal = const EdgeInsets.symmetric(horizontal: sm);
  static EdgeInsets mdHorizontal = const EdgeInsets.symmetric(horizontal: md);
  static EdgeInsets lgHorizontal = const EdgeInsets.symmetric(horizontal: lg);

  static EdgeInsets xsVertical = const EdgeInsets.symmetric(vertical: xs);
  static EdgeInsets smVertical = const EdgeInsets.symmetric(vertical: sm);
  static EdgeInsets mdVertical = const EdgeInsets.symmetric(vertical: md);
  static EdgeInsets lgVertical = const EdgeInsets.symmetric(vertical: lg);

  static EdgeInsets xsSymmetric = const EdgeInsets.symmetric(
    horizontal: xs,
    vertical: xs,
  );
  static EdgeInsets smSymmetric = const EdgeInsets.symmetric(
    horizontal: sm,
    vertical: sm,
  );
  static EdgeInsets mdSymmetric = const EdgeInsets.symmetric(
    horizontal: md,
    vertical: md,
  );
}

/// Design tokens for consistent border radii across the app.
class AppRadius {
  AppRadius._();

  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 20.0;
  static const double pill = 999.0;

  static BorderRadius smAll = const BorderRadius.all(Radius.circular(sm));
  static BorderRadius mdAll = const BorderRadius.all(Radius.circular(md));
  static BorderRadius lgAll = const BorderRadius.all(Radius.circular(lg));
  static BorderRadius pillAll = const BorderRadius.all(Radius.circular(pill));
}

/// Design tokens for alpha (transparency) values.
class AppAlpha {
  AppAlpha._();

  static const double tint = 0.08; // 8% opacity for tint overlays
  static const double border = 0.25; // 25% opacity for subtle borders
  static const double overlay = 0.5; // 50% opacity for overlays/scrims
  static const double fill = 0.2; // translucent fill on a colored surface
  static const double strong = 0.85; // secondary text on a colored surface
  static const double disabled = 0.4;

  /// Helper to create color with alpha applied
  static Color withAlpha(Color color, double alpha) =>
      color.withValues(alpha: alpha);

  static Color withTint(Color color) => color.withValues(alpha: tint);
  static Color withBorderAlpha(Color color) => color.withValues(alpha: border);
  static Color withOverlayAlpha(Color color) =>
      color.withValues(alpha: overlay);
}

/// Component sizes.
class AppSize {
  AppSize._();
  static const double iconSm = 16;
  static const double icon = 20;
  static const double iconLg = 24;
  static const double tile = 40; // icon tile / avatar
  static const double tapTarget = 48;
  static const double stroke = 2; // borders and spinners
  static const double carouselCard = 128;
}

/// Durations, curves and motion amounts.
class AppMotion {
  AppMotion._();
  static const Duration fast = Duration(milliseconds: 120);
  static const Duration base = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 420);
  static const Duration stagger = Duration(milliseconds: 80);
  static const Duration snack = Duration(seconds: 2);
  static const Duration snackLong = Duration(seconds: 4);
  static const Curve curve = Curves.easeOutCubic;
  static const double pressScale = 0.96;
  static const double slideOffset = 0.06;
}

/// Elevation. Pass AppColors.shadow(context) so it follows the theme.
class AppShadow {
  AppShadow._();
  static List<BoxShadow> card(Color shadow) => [
    BoxShadow(color: shadow, blurRadius: 24, offset: const Offset(0, 8)),
    BoxShadow(color: shadow, blurRadius: 4, offset: const Offset(0, 1)),
  ];
  static List<BoxShadow> soft(Color shadow) => [
    BoxShadow(color: shadow, blurRadius: 8, offset: const Offset(0, 2)),
  ];
  static List<BoxShadow> glow(Color color) => [
    BoxShadow(
      color: AppAlpha.withBorderAlpha(color),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}
