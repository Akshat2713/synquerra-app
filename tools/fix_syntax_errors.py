#!/usr/bin/env python3
"""
Fix syntax errors introduced by the codemod script.
"""

import re
from pathlib import Path

def find_and_fix_errors():
    """Find and fix common syntax errors."""
    project_root = Path(__file__).parent.parent
    screens_dir = project_root / 'lib' / 'presentation' / 'screens'
    widgets_dir = project_root / 'lib' / 'presentation' / 'widgets'

    fixed_files = 0

    for dart_file in list(screens_dir.rglob('*.dart')) + list(widgets_dir.rglob('*.dart')):
        try:
            with open(dart_file, 'r', encoding='utf-8') as f:
                content = f.read()
        except Exception as e:
            continue

        original = content

        # Fix 1: EdgeInsets.all(AppSpacing.lg, -> EdgeInsets.all(AppSpacing.lg),
        content = re.sub(r'EdgeInsets\.all\(AppSpacing\.(\w+),', r'EdgeInsets.all(AppSpacing.\1),', content)

        # Fix 2: EdgeInsets.symmetric(horizontal: AppSpacing.lg, -> EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        content = re.sub(r'EdgeInsets\.symmetric\((horizontal|vertical): AppSpacing\.(\w+),', r'EdgeInsets.symmetric(\1: AppSpacing.\2),', content)

        # Fix 3: EdgeInsets.only(bottom: AppSpacing.lg, -> EdgeInsets.only(bottom: AppSpacing.lg),
        content = re.sub(r'EdgeInsets\.only\((left|right|top|bottom|start|end): AppSpacing\.(\w+),', r'EdgeInsets.only(\1: AppSpacing.\2),', content)

        # Fix 4: SizedBox(height: AppSpacing.lg, -> SizedBox(height: AppSpacing.lg),
        content = re.sub(r'SizedBox\((width|height): AppSpacing\.(\w+),', r'SizedBox(\1: AppSpacing.\2),', content)

        # Fix 5: AppRadius.smAll, -> AppRadius.smAll),
        # Look for BorderRadius.circular( replaced but missing closing paren
        content = re.sub(r'BorderRadius\.(circular|all)\([^)]*AppRadius\.(\w+)(?!\))', lambda m: m.group(0) + ')', content)

        if content != original:
            try:
                with open(dart_file, 'w', encoding='utf-8') as f:
                    f.write(content)
                fixed_files += 1
                print(f"Fixed: {dart_file.relative_to(project_root)}")
            except Exception as e:
                print(f"Error writing {dart_file}: {e}")

    return fixed_files

def main():
    """Fix syntax errors."""
    print("Fixing syntax errors introduced by codemod...\n")
    fixed = find_and_fix_errors()
    print(f"\nFixed {fixed} files.")

if __name__ == '__main__':
    main()
