// lib/presentation/widgets/core/app_section.dart
import 'package:flutter/material.dart';

class AppSection extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Color? color;
  final List<Widget> children;
  final EdgeInsets padding;
  final bool showDivider;

  const AppSection({
    super.key,
    required this.title,
    this.icon,
    this.color,
    required this.children,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final headerColor = color ?? colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Row(
            children: [
              if (icon != null) ...[
                Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: headerColor.withValues(alpha: 0.15), shape: BoxShape.circle), child: Icon(icon, size: 16, color: headerColor)),
                const SizedBox(width: 10),
              ],
              Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: headerColor, letterSpacing: 0.5)),
            ],
          ),
        ),
        Padding(padding: padding, child: Column(children: children)),
        if (showDivider) ...[
          const SizedBox(height: 16),
          Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.3), indent: 20, endIndent: 20),
        ],
      ],
    );
  }
}