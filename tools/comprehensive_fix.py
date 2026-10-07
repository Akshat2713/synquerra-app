#!/usr/bin/env python3
"""
Comprehensive fix for broken syntax from codemod.
"""

import re
from pathlib import Path

def fix_broken_edgeinsets(content):
    """Fix broken EdgeInsets syntax."""
    # Pattern for broken EdgeInsets.symmetric with comma issue
    # padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl), vertical: 32),
    pattern1 = r'(padding|margin):\s*const\s+EdgeInsets\.symmetric\(([^)]+)\)\s*,\s*(horizontal|vertical):\s*(\d+(?:\.\d+)?)\)'

    def fix_match1(match):
        param1 = match.group(2)  # e.g., "horizontal: AppSpacing.xl"
        param2_name = match.group(3)  # "vertical" or "horizontal"
        param2_value = match.group(4)  # e.g., "32"
        prefix = match.group(1)  # "padding" or "margin"

        # Check if param2_value should be a token
        spacing_map = {
            '2': 'AppSpacing.xs', '3': 'AppSpacing.xs', '5': 'AppSpacing.xs', '6': 'AppSpacing.xs',
            '10': 'AppSpacing.sm', '14': 'AppSpacing.md', '18': 'AppSpacing.md',
            '20': 'AppSpacing.lg', '28': 'AppSpacing.xl', '36': 'AppSpacing.xl'
        }

        param2_token = spacing_map.get(param2_value, param2_value)

        return f'{prefix}: const EdgeInsets.symmetric({param1}, {param2_name}: {param2_token})'

    content = re.sub(pattern1, fix_match1, content)

    # Also look for general broken syntax with extra closing parens
    # EdgeInsets.symmetric(horizontal: AppSpacing.xl), something)
    pattern2 = r'EdgeInsets\.symmetric\(([^)]+)\)\s*,\s*([^)]+)\)'
    def fix_match2(match):
        param1 = match.group(1)  # e.g., "horizontal: AppSpacing.xl"
        param2 = match.group(2)  # e.g., "vertical: 32"

        # Parse param2 to get the actual value
        param2_match = re.match(r'(\w+):\s*(\d+(?:\.\d+)?)', param2)
        if param2_match:
            param2_name = param2_match.group(1)
            param2_value = param2_match.group(2)

            spacing_map = {
                '2': 'AppSpacing.xs', '3': 'AppSpacing.xs', '5': 'AppSpacing.xs', '6': 'AppSpacing.xs',
                '10': 'AppSpacing.sm', '14': 'AppSpacing.md', '18': 'AppSpacing.md',
                '20': 'AppSpacing.lg', '28': 'AppSpacing.xl', '36': 'AppSpacing.xl'
            }

            param2_token = spacing_map.get(param2_value, param2_value)
            return f'EdgeInsets.symmetric({param1}, {param2_name}: {param2_token})'

        return match.group(0)

    content = re.sub(pattern2, fix_match2, content)

    return content

def fix_broken_sizedbox(content):
    """Fix broken SizedBox syntax."""
    # SizedBox(height: AppSpacing.xl), something)
    pattern = r'SizedBox\(([^)]+)\)\s*,\s*([^)]+)\)'

    def fix_match(match):
        param1 = match.group(1)  # e.g., "height: AppSpacing.xl"
        param2 = match.group(2)  # e.g., "width: 200"

        # Check if this is actually a broken SizedBox with extra params
        if ':' in param2:
            param2_match = re.match(r'(\w+):\s*([^,]+)', param2)
            if param2_match:
                param2_name = param2_match.group(1)
                param2_value = param2_match.group(2)
                return f'SizedBox({param1}, {param2_name}: {param2_value})'

        return match.group(0)

    return re.sub(pattern, fix_match, content)

def main():
    """Fix all broken syntax."""
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

        # Apply fixes
        content = fix_broken_edgeinsets(content)
        content = fix_broken_sizedbox(content)

        if content != original:
            try:
                with open(dart_file, 'w', encoding='utf-8') as f:
                    f.write(content)
                fixed_files += 1
                print(f"Fixed: {dart_file.relative_to(project_root)}")
            except Exception as e:
                print(f"Error writing {dart_file}: {e}")

    print(f"\nFixed {fixed_files} files.")

if __name__ == '__main__':
    main()
