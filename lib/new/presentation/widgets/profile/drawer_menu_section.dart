// lib/presentation/widgets/profile/drawer_menu_section.dart
import 'package:flutter/material.dart';

class DrawerMenuSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const DrawerMenuSection({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              fontSize: 11,
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}
