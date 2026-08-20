#!/bin/bash
# Run from your project root (where lib/ lives). Commit your work first!
# Fixes broken/invented tokens found in the screens_zip audit.

TARGET="lib"   # change if your screens live elsewhere

# --- Broken AppColors.* refs that don't exist in colors.dart -> real tokens ---
grep -rl "AppColors.safeGreen"        --include="*.dart" "$TARGET" | xargs -r sed -i 's/AppColors\.safeGreen/AppColors.success/g'
grep -rl "AppColors.alertSuccess"     --include="*.dart" "$TARGET" | xargs -r sed -i 's/AppColors\.alertSuccess/AppColors.success/g'
grep -rl "AppColors.alertWarning"     --include="*.dart" "$TARGET" | xargs -r sed -i 's/AppColors\.alertWarning/AppColors.warning/g'
grep -rl "AppColors.backgroundContainer" --include="*.dart" "$TARGET" | xargs -r sed -i 's/AppColors\.backgroundContainer/AppColors.lightSurfaceVariant/g'

# --- Unambiguous status-color hardcodes -> semantic tokens ---
grep -rl "Colors.green"  --include="*.dart" "$TARGET" | xargs -r sed -i 's/Colors\.green\b/AppColors.success/g'
grep -rl "Colors.amber"  --include="*.dart" "$TARGET" | xargs -r sed -i 's/Colors\.amber\b/AppColors.warning/g'
grep -rl "Colors.orange" --include="*.dart" "$TARGET" | xargs -r sed -i 's/Colors\.orange\b/AppColors.warning/g'
grep -rl "Colors.red"    --include="*.dart" "$TARGET" | xargs -r sed -i 's/Colors\.red\b/AppColors.danger/g'

echo "Done. Now: flutter analyze  ->  fix any import errors (add colors.dart import where missing)."
echo "Review each fixed file's diff — a few of these may need Container/Success context, not the raw color."