#!/usr/bin/env python3
"""
UI Codemod: Migrate Dart UI code to use AppTokens (AppRadius, AppSpacing, AppAlpha).

Processes all .dart files under lib/presentation/screens and lib/presentation/widgets.
Maps legacy spacing/radius values to design tokens.

Usage:
  python tools/ui_codemod.py              # Dry-run mode (prints diff summary)
  python tools/ui_codemod.py --apply      # Real mode (modifies files)
"""

import re
import sys
import os
from pathlib import Path
from dataclasses import dataclass
from typing import List, Tuple, Optional, Set
from collections import defaultdict

@dataclass
class FileChange:
    path: str
    original: str
    modified: str
    changes: List[str]

class DartTokenMigrator:
    def __init__(self, dry_run: bool = True):
        self.dry_run = dry_run
        self.changes: List[FileChange] = []
        self.manual_review: List[Tuple[str, str, str]] = []  # (file, line_context, reason)
        self.needs_import: Set[str] = set()

    def run(self, root_dir: str = '.'):
        """Process all Dart files in presentation/screens and presentation/widgets."""
        root_path = Path(root_dir)
        screens_dir = root_path / 'lib' / 'presentation' / 'screens'
        widgets_dir = root_path / 'lib' / 'presentation' / 'widgets'

        dart_files = []

        # Find all .dart files in screens directory and subdirectories
        if screens_dir.exists():
            dart_files.extend(screens_dir.rglob('*.dart'))

        # Find all .dart files in widgets directory and subdirectories
        if widgets_dir.exists():
            dart_files.extend(widgets_dir.rglob('*.dart'))

        dart_files = list(set(dart_files))
        dart_files = [f for f in dart_files if f.exists()]

        if not dart_files:
            print(f"No Dart files found matching patterns.")
            return

        print(f"Found {len(dart_files)} Dart files to process.\n")

        for dart_file in sorted(dart_files):
            self._process_file(str(dart_file))

        self._print_summary()

    def _process_file(self, filepath: str):
        """Process a single Dart file."""
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                original = f.read()
        except Exception as e:
            print(f"⚠️  Error reading {filepath}: {e}")
            return

        modified = original
        changes = []

        # Apply transformations in order
        modified, radius_changes = self._migrate_border_radius(modified, filepath)
        changes.extend(radius_changes)

        modified, spacing_changes = self._migrate_spacing(modified, filepath)
        changes.extend(spacing_changes)

        modified, alpha_changes = self._migrate_alpha(modified, filepath)
        changes.extend(alpha_changes)

        # If changes were made, track them
        if modified != original:
            if self._needs_tokens_import(original) and not self._has_tokens_import(original):
                self.needs_import.add(filepath)
                modified = self._add_tokens_import(modified)
                changes.append("Added 'import app_tokens.dart'")

            self.changes.append(FileChange(
                path=filepath,
                original=original,
                modified=modified,
                changes=changes
            ))

            if not self.dry_run:
                with open(filepath, 'w', encoding='utf-8') as f:
                    f.write(modified)

    def _migrate_border_radius(self, content: str, filepath: str) -> Tuple[str, List[str]]:
        """
        Map BorderRadius.circular(n) to AppRadius tokens.
        1.5-8 -> AppRadius.sm
        10-14 -> AppRadius.md
        16-30 -> AppRadius.lg
        """
        changes = []

        # Pattern: BorderRadius.circular(number)
        def replace_border_radius(match):
            value_str = match.group(1)
            try:
                value = float(value_str)
            except ValueError:
                return match.group(0)

            if 1.5 <= value <= 8:
                changes.append(f"BorderRadius.circular({value}) -> AppRadius.smAll")
                return "AppRadius.smAll"
            elif 10 <= value <= 14:
                changes.append(f"BorderRadius.circular({value}) -> AppRadius.mdAll")
                return "AppRadius.mdAll"
            elif 16 <= value <= 30:
                changes.append(f"BorderRadius.circular({value}) -> AppRadius.lgAll")
                return "AppRadius.lgAll"
            else:
                self.manual_review.append((filepath, f"BorderRadius.circular({value})", f"Radius {value} doesn't match standard tokens"))
                return match.group(0)

        content = re.sub(r'BorderRadius\.circular\((\d+(?:\.\d+)?)\)', replace_border_radius, content)

        # Also handle BorderRadius.all(Radius.circular(n))
        def replace_border_radius_all(match):
            value_str = match.group(1)
            try:
                value = float(value_str)
            except ValueError:
                return match.group(0)

            if 1.5 <= value <= 8:
                changes.append(f"BorderRadius.all(Radius.circular({value})) -> AppRadius.smAll")
                return "AppRadius.smAll"
            elif 10 <= value <= 14:
                changes.append(f"BorderRadius.all(Radius.circular({value})) -> AppRadius.mdAll")
                return "AppRadius.mdAll"
            elif 16 <= value <= 30:
                changes.append(f"BorderRadius.all(Radius.circular({value})) -> AppRadius.lgAll")
                return "AppRadius.lgAll"
            else:
                return match.group(0)

        content = re.sub(r'BorderRadius\.all\(Radius\.circular\((\d+(?:\.\d+)?)\)\)', replace_border_radius_all, content)

        return content, changes

    def _migrate_spacing(self, content: str, filepath: str) -> Tuple[str, List[str]]:
        """
        Map spacing values in SizedBox and EdgeInsets to AppSpacing tokens.
        2,3,5,6 -> 4 (xs)
        10 -> 8 (sm)
        14 -> 16 (md)
        18,20 -> manual review
        28,36 -> 32 (xl)
        """
        changes = []
        spacing_map = {
            '2': ('AppSpacing.xs', 'xs (4)'),
            '3': ('AppSpacing.xs', 'xs (4)'),
            '5': ('AppSpacing.xs', 'xs (4)'),
            '6': ('AppSpacing.xs', 'xs (4)'),
            '10': ('AppSpacing.sm', 'sm (8)'),
            '14': ('AppSpacing.md', 'md (16)'),
            '18': ('AppSpacing.md', 'md (16)'),  # 18 maps to md (16)
            '20': ('AppSpacing.lg', 'lg (24)'),  # 20 maps to lg (24)
            '28': ('AppSpacing.xl', 'xl (32)'),
            '36': ('AppSpacing.xl', 'xl (32)'),
        }

        # SizedBox(width: value) and SizedBox(height: value)
        def replace_sizedbox(match):
            key = match.group(1)  # "width" or "height"
            value = match.group(2)

            if value in spacing_map:
                token, desc = spacing_map[value]
                changes.append(f"SizedBox({key}: {value}) -> SizedBox({key}: {token})")
                return f"SizedBox({key}: {token}"
            elif value == '20':
                changes.append(f"SizedBox({key}: {value}) -> SizedBox({key}: AppSpacing.lg)")
                return f"SizedBox({key}: AppSpacing.lg"
            elif value == '18':
                changes.append(f"SizedBox({key}: {value}) -> SizedBox({key}: AppSpacing.md)")
                return f"SizedBox({key}: AppSpacing.md"

            return match.group(0)

        content = re.sub(r'SizedBox\((width|height):\s*(\d+(?:\.\d+)?)', replace_sizedbox, content)

        # EdgeInsets migrations
        # EdgeInsets.symmetric(horizontal: value) and vertical
        def replace_edge_insets_symmetric(match):
            direction = match.group(1)  # "horizontal" or "vertical"
            value = match.group(2)

            if value in spacing_map:
                token, _ = spacing_map[value]
                changes.append(f"EdgeInsets.symmetric({direction}: {value}) -> EdgeInsets.symmetric({direction}: {token})")
                return f"EdgeInsets.symmetric({direction}: {token}"
            elif value == '20':
                changes.append(f"EdgeInsets.symmetric({direction}: {value}) -> EdgeInsets.symmetric({direction}: AppSpacing.lg)")
                return f"EdgeInsets.symmetric({direction}: AppSpacing.lg"
            elif value == '18':
                changes.append(f"EdgeInsets.symmetric({direction}: {value}) -> EdgeInsets.symmetric({direction}: AppSpacing.md)")
                return f"EdgeInsets.symmetric({direction}: AppSpacing.md"

            return match.group(0)

        content = re.sub(r'EdgeInsets\.symmetric\((horizontal|vertical):\s*(\d+(?:\.\d+)?)', replace_edge_insets_symmetric, content)

        # EdgeInsets.all(value)
        def replace_edge_insets_all(match):
            value = match.group(1)

            if value in spacing_map:
                token, _ = spacing_map[value]
                changes.append(f"EdgeInsets.all({value}) -> EdgeInsets.all({token})")
                return f"EdgeInsets.all({token}"
            elif value == '20':
                changes.append(f"EdgeInsets.all({value}) -> EdgeInsets.all(AppSpacing.lg)")
                return f"EdgeInsets.all(AppSpacing.lg"
            elif value == '18':
                changes.append(f"EdgeInsets.all({value}) -> EdgeInsets.all(AppSpacing.md)")
                return f"EdgeInsets.all(AppSpacing.md"

            return match.group(0)

        content = re.sub(r'EdgeInsets\.all\((\d+(?:\.\d+)?)\)', replace_edge_insets_all, content)

        # EdgeInsets.only(left/right/top/bottom: value)
        def replace_edge_insets_only(match):
            direction = match.group(1)
            value = match.group(2)

            if value in spacing_map:
                token, _ = spacing_map[value]
                changes.append(f"EdgeInsets.only({direction}: {value}) -> EdgeInsets.only({direction}: {token})")
                return f".only({direction}: {token}"
            elif value == '20':
                changes.append(f"EdgeInsets.only({direction}: {value}) -> EdgeInsets.only({direction}: AppSpacing.lg)")
                return f".only({direction}: AppSpacing.lg"
            elif value == '18':
                changes.append(f"EdgeInsets.only({direction}: {value}) -> EdgeInsets.only({direction}: AppSpacing.md)")
                return f".only({direction}: AppSpacing.md"

            return match.group(0)

        content = re.sub(r'\.only\((left|right|top|bottom|start|end):\s*(\d+(?:\.\d+)?)', replace_edge_insets_only, content)

        return content, changes

    def _migrate_alpha(self, content: str, filepath: str) -> Tuple[str, List[str]]:
        """
        Map withValues(alpha: x) to AppAlpha tokens.
        x <= 0.15 -> AppAlpha.tint
        0.2 <= x <= 0.5 -> AppAlpha.border
        x > 0.5 -> AppAlpha.overlay
        """
        changes = []

        def replace_with_values_alpha(match):
            value_str = match.group(1)
            try:
                value = float(value_str)
            except ValueError:
                return match.group(0)

            if value <= 0.15:
                changes.append(f"withValues(alpha: {value}) -> withValues(alpha: AppAlpha.tint)")
                return f".withValues(alpha: AppAlpha.tint)"
            elif 0.2 <= value <= 0.5:
                changes.append(f"withValues(alpha: {value}) -> withValues(alpha: AppAlpha.border)")
                return f".withValues(alpha: AppAlpha.border)"
            elif value > 0.5:
                changes.append(f"withValues(alpha: {value}) -> withValues(alpha: AppAlpha.overlay)")
                return f".withValues(alpha: AppAlpha.overlay)"

            return match.group(0)

        content = re.sub(r'\.withValues\(alpha:\s*(0?\.\d+)\)', replace_with_values_alpha, content)

        return content, changes

    def _needs_tokens_import(self, content: str) -> bool:
        """Check if content uses AppRadius, AppSpacing, or AppAlpha."""
        return any(token in content for token in ['AppRadius', 'AppSpacing', 'AppAlpha'])

    def _has_tokens_import(self, content: str) -> bool:
        """Check if file already imports app_tokens."""
        patterns = [
            "import 'package:synquerra/presentation/themes/app_tokens.dart'",
            "import \"package:synquerra/presentation/themes/app_tokens.dart\"",
            "import '../../themes/app_tokens.dart'",
            "import \"../../themes/app_tokens.dart\"",
            "import '../themes/app_tokens.dart'",
            "import \"../themes/app_tokens.dart\"",
            "import 'app_tokens.dart'",
            'import "app_tokens.dart"',
        ]
        return any(pattern in content for pattern in patterns)

    def _add_tokens_import(self, content: str) -> str:
        """Add the app_tokens import after other app theme imports."""
        lines = content.split('\n')

        # Find the last import line
        last_import_idx = -1
        for i, line in enumerate(lines):
            if line.strip().startswith('import '):
                last_import_idx = i

        # Insert after the last import
        if last_import_idx >= 0:
            # Check if we already have a themes import
            for i in range(last_import_idx, -1, -1):
                if 'themes/' in lines[i]:
                    insert_idx = i + 1
                    break
            else:
                insert_idx = last_import_idx + 1
        else:
            # No imports found, add at the beginning
            insert_idx = 0

        # Add the import
        import_line = "import 'package:synquerra/presentation/themes/app_tokens.dart';"
        lines.insert(insert_idx, import_line)
        return '\n'.join(lines)

    def _print_summary(self):
        """Print summary of changes."""
        if self.dry_run:
            print("\n" + "="*70)
            print("DRY-RUN MODE: Changes that would be made:")
            print("="*70 + "\n")
        else:
            print("\n" + "="*70)
            print("REAL MODE: Changes applied:")
            print("="*70 + "\n")

        if not self.changes:
            print("[OK] No changes needed.\n")
            return

        print(f"[NOTE] {len(self.changes)} file(s) would be modified:\n")

        all_changes = defaultdict(int)

        for change in self.changes:
            print(f"[FILE] {change.path}")
            for desc in change.changes:
                # Replace Unicode arrow with ASCII arrow for Windows compatibility
                safe_desc = desc.replace('→', '->')
                print(f"   • {safe_desc}")
                all_changes[desc.split('->')[0].strip()] += 1
            print()

        if self.needs_import:
            print(f"\n[IMPORT] Imports to add: {len(self.needs_import)} file(s)")
            for filepath in sorted(self.needs_import):
                print(f"   • {filepath}")

        if self.manual_review:
            print(f"\n[WARN] {len(self.manual_review)} item(s) need manual review:\n")
            for filepath, context, reason in self.manual_review:
                print(f"   [LINE] {filepath}")
                print(f"      Context: {context}")
                print(f"      Reason: {reason}\n")

        print("\n" + "="*70)
        print(f"Summary: {len(self.changes)} file(s) modified, {len(self.manual_review)} item(s) for review")
        print("="*70 + "\n")

        if self.dry_run:
            print("To apply these changes, run: python tools/ui_codemod.py --apply\n")

def main():
    """Main entry point."""
    dry_run = '--apply' not in sys.argv

    # Resolve to project root
    script_dir = Path(__file__).parent
    project_root = script_dir.parent

    os.chdir(project_root)

    migrator = DartTokenMigrator(dry_run=dry_run)
    migrator.run(str(project_root))

if __name__ == '__main__':
    main()
