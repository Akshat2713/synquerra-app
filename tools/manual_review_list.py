#!/usr/bin/env python3
"""
Extract manual review items from codemod output.
"""

import re
import os
from pathlib import Path

def extract_manual_review():
    """Extract manual review items from codemod output."""
    project_root = Path(__file__).parent.parent
    screens_dir = project_root / 'lib' / 'presentation' / 'screens'
    widgets_dir = project_root / 'lib' / 'presentation' / 'widgets'

    manual_review = []

    # Look for spacing values 18 and 20 in Dart files
    for dart_file in list(screens_dir.rglob('*.dart')) + list(widgets_dir.rglob('*.dart')):
        try:
            with open(dart_file, 'r', encoding='utf-8') as f:
                lines = f.readlines()
        except Exception as e:
            continue

        for line_num, line in enumerate(lines, 1):
            line = line.rstrip()

            # Look for spacing patterns with 18 or 20
            patterns = [
                (r'SizedBox\((?:width|height):\s*(18|20)', 'SizedBox'),
                (r'EdgeInsets\.all\((\d+(?:\.\d+)?)\)', 'EdgeInsets.all'),
                (r'EdgeInsets\.symmetric\((?:horizontal|vertical):\s*(\d+(?:\.\d+)?)', 'EdgeInsets.symmetric'),
                (r'EdgeInsets\.only\([^)]*(?:left|right|top|bottom|start|end):\s*(\d+(?:\.\d+)?)', 'EdgeInsets.only'),
            ]

            for pattern, context_type in patterns:
                match = re.search(pattern, line)
                if match:
                    value = match.group(1)
                    if value in ('18', '20'):
                        # Extract a snippet for context
                        context = line[:100] + ('...' if len(line) > 100 else '')
                        manual_review.append({
                            'file': str(dart_file.relative_to(project_root)),
                            'line': line_num,
                            'context': context,
                            'value': value,
                            'type': context_type
                        })

    return manual_review

def main():
    """Print manual review items."""
    manual_items = extract_manual_review()

    if not manual_items:
        print("No manual review items found.")
        return

    print(f"Found {len(manual_items)} manual review items:\n")
    print("=" * 100)

    # Group by file
    items_by_file = {}
    for item in manual_items:
        file = item['file']
        if file not in items_by_file:
            items_by_file[file] = []
        items_by_file[file].append(item)

    for file in sorted(items_by_file.keys()):
        print(f"\n[FILE] {file}")
        print("-" * 80)

        for item in items_by_file[file]:
            value = item['value']
            suggestion = "AppSpacing.lg (24)" if value == "20" else "AppSpacing.md (16) or AppSpacing.lg (24)"

            print(f"  Line {item['line']}:")
            print(f"    Context: {item['context']}")
            print(f"    Value: {value} -> Needs decision: {suggestion}")
            print()

if __name__ == '__main__':
    main()
