#!/usr/bin/env bash
set -euo pipefail
[ -d lib ] || { echo "Run this from the project root (where lib/ is)"; exit 1; }

find lib -name '*.dart' \
  ! -path '*/themes/colors.dart' \
  ! -path '*/themes/app_palette.dart' \
  ! -path '*/themes/app_theme.dart' \
  -exec perl -pi -e '
    # 1. brand/accent consts -> context functions
    s/\bAppColors\.(primary|primaryHover|primarySubtle|primaryContainer|onPrimaryContainer|onPrimary|primaryBorder|primaryGradient|accent|accentContainer)\b(?!\()/AppColors.$1(context)/g;

    # 2. lightXxx / darkXxx -> brightness-aware helpers
    s/\bAppColors\.(?:light|dark)(TextPrimary|TextSecondary|TextTertiary|SurfaceVariant|Surface|Background|OutlineVariant|Outline|IconPrimary|IconSecondary|Shadow|Scrim)\b(?!\()/"AppColors.".lcfirst($1)."(context)"/ge;

    # 3. drop `const` on a widget that now contains a (context) call (same line only)
    s/\bconst\s+(?=[A-Z]\w*\([^;]*AppColors\.\w+\(context\))//;
  ' {} +

echo "Done. Now run: flutter analyze"