import 'package:flutter/material.dart';
import '../themes/app_text_styles.dart';
import '../themes/app_tokens.dart';
import 'app_surfaces.dart';

/// Card with a solid colored icon tile + title header, then [children].
class AppSectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color background;
  final Color foreground;
  final List<Widget> children;

  /// Gap between children. Pass null for InsetRows (they carry their own gap).
  final double? spacing;

  const AppSectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.children,
    this.spacing = AppSpacing.md,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            spacing: AppSpacing.smd,
            children: [
              IconTile(
                icon: icon,
                background: background,
                foreground: foreground,
              ),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.sectionWithColor(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: spacing ?? 0,
            children: children,
          ),
        ],
      ),
    );
  }
}
