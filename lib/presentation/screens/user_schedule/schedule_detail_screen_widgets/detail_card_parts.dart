import 'package:flutter/material.dart';
import '../../../themes/app_text_styles.dart';
import '../../../themes/app_tokens.dart';
import '../../../themes/colors.dart';
import '../../../widgets/app_surfaces.dart';

class DetailCardHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color background;
  final Color foreground;
  final Widget? trailing;

  const DetailCardHeader({
    super.key,
    required this.title,
    required this.icon,
    required this.background,
    required this.foreground,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) => Row(
    spacing: AppSpacing.smd,
    children: [
      IconTile(icon: icon, background: background, foreground: foreground),
      Expanded(
        child: Text(title, style: AppTextStyles.sectionWithColor(context)),
      ),
      if (trailing != null) trailing!,
    ],
  );
}

class DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const DetailRow({
    super.key,
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) => InsetRow(
    child: Row(
      spacing: AppSpacing.md,
      children: [
        Text(label, style: AppTextStyles.bodyWithColor(context)),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style:
                AppTextStyles.bodyWithColor(
                  context,
                  color: highlight
                      ? AppColors.primary(context)
                      : AppColors.textPrimary(context),
                ).copyWith(
                  fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
                ),
          ),
        ),
      ],
    ),
  );
}
