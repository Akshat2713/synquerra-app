#!/usr/bin/env python3
"""
Fix missing app_tokens imports in files that use AppRadius/AppSpacing/AppAlpha.
"""

import re
from pathlib import Path

def find_files_needing_import():
    """Find files that use tokens but don't import them."""
    project_root = Path(__file__).parent.parent
    screens_dir = project_root / 'lib' / 'presentation' / 'screens'
    widgets_dir = project_root / 'lib' / 'presentation' / 'widgets'

    files_to_fix = []

    for dart_file in list(screens_dir.rglob('*.dart')) + list(widgets_dir.rglob('*.dart')):
        try:
            with open(dart_file, 'r', encoding='utf-8') as f:
                content = f.read()
        except Exception as e:
            continue

        # Check if file uses tokens
        uses_tokens = any(token in content for token in ['AppRadius', 'AppSpacing', 'AppAlpha'])

        # Check if already has import
        has_import = any(pattern in content for pattern in [
            "import 'package:synquerra/presentation/themes/app_tokens.dart'",
            "import \"package:synquerra/presentation/themes/app_tokens.dart\"",
            "import '../../themes/app_tokens.dart'",
            "import \"../../themes/app_tokens.dart\"",
            "import '../themes/app_tokens.dart'",
            "import \"../themes/app_tokens.dart\"",
            "import 'app_tokens.dart'",
            'import "app_tokens.dart"',
        ])

        if uses_tokens and not has_import:
            files_to_fix.append(dart_file)

    return files_to_fix

def add_import_to_file(filepath):
    """Add app_tokens import to a file."""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            lines = f.readlines()
    except Exception as e:
        print(f"  Error reading {filepath}: {e}")
        return False

    # Find the last import line
    last_import_idx = -1
    for i, line in enumerate(lines):
        if line.strip().startswith('import '):
            last_import_idx = i

    # Insert after the last import
    if last_import_idx >= 0:
        insert_idx = last_import_idx + 1
    else:
        # No imports found, add at the beginning
        insert_idx = 0

    # Add the import
    import_line = "import 'package:synquerra/presentation/themes/app_tokens.dart';\n"
    lines.insert(insert_idx, import_line)

    try:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.writelines(lines)
        return True
    except Exception as e:
        print(f"  Error writing {filepath}: {e}")
        return False

def main():
    """Fix imports in all files."""
    files_to_fix = find_files_needing_import()

    if not files_to_fix:
        print("No files need import fixes.")
        return

    print(f"Found {len(files_to_fix)} files needing app_tokens import:\n")

    fixed_count = 0
    for filepath in sorted(files_to_fix):
        print(f"Fixing: {filepath.relative_to(Path(__file__).parent.parent)}")
        if add_import_to_file(filepath):
            fixed_count += 1
            print(f"  -> Import added")
        else:
            print(f"  -> Failed to add import")
        print()

    print(f"\nFixed imports in {fixed_count}/{len(files_to_fix)} files.")

if __name__ == '__main__':
    main()
