import 'package:flutter/material.dart';

import '../../../themes/app_text_styles.dart';
import '../../../themes/app_tokens.dart';
import '../../../themes/colors.dart';

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.xs,
        top: AppSpacing.smd,
        bottom: AppSpacing.sm,
      ),
      child: Text(
        title,
        style: AppTextStyles.sectionWithColor(
          context,
          color: AppColors.primary(context),
        ),
      ),
    );
  }
}
