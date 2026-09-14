#!/bin/bash
# Run from project root. Scans the ENTIRE lib/ folder (not just screens/),
# which is what was missed last time.
TARGET="lib"

echo "=== 1) 'colors: colors' or 'colors,' passed as bare arg ==="
grep -rn "colors: colors\|(colors,\| colors,$" --include="*.dart" "$TARGET"

echo ""
echo "=== 2) Method/constructor params or fields still typed ColorScheme ==="
grep -rn "ColorScheme colors" --include="*.dart" "$TARGET"

echo ""
echo "=== 3) Any bare 'colors.' member access left ==="
grep -rn "colors\.[a-zA-Z]" --include="*.dart" "$TARGET" | grep -v "AppColors\."

echo ""
echo "=== 4) Any remaining Theme.of(context).colorScheme (not yet migrated) ==="
grep -rn "colorScheme" --include="*.dart" "$TARGET"

echo ""
echo "=== 5) Files with 'colors' as identifier where surrounding method has no BuildContext param ==="
echo "(manual check needed for any hits above — same fix pattern: swap ColorScheme colors -> BuildContext context, remove colors: colors call args)"