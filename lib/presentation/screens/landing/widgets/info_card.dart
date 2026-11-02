import 'package:flutter/material.dart';
import '../../../themes/app_text_styles.dart';
import '../../../themes/app_tokens.dart';
import '../../../themes/colors.dart';
import '../../../widgets/app_motion_widgets.dart';
import '../../../widgets/app_surfaces.dart';

class InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;

  const InfoCard({
    super.key,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          IconTile(icon: icon, background: iconBg, foreground: iconColor),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedText(
                  title,
                  style: AppTextStyles.bodyWithColor(
                    context,
                    color: AppColors.textPrimary(context),
                  ).copyWith(fontWeight: FontWeight.w600),
                  maxLines: 2,
                ),
                const SizedBox(height: AppSpacing.xs),
                AnimatedText(
                  subtitle,
                  style: AppTextStyles.metaWithColor(context),
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
