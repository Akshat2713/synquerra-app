import 'package:flutter/material.dart';
import '../../../themes/app_text_styles.dart';
import '../../../themes/app_tokens.dart';
import '../../../themes/colors.dart';
import '../../../utils/app_icons.dart';
import '../../../widgets/app_surfaces.dart';

class ScheduleEmptyView extends StatelessWidget {
  const ScheduleEmptyView({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: AppSpacing.lgAll,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: AppSpacing.md,
        children: [
          IconTile(
            circle: true,
            size: AppSize.tapTarget,
            iconSize: AppSize.iconLg,
            icon: AppIcons.schedule,
            background: AppColors.primaryContainer(context),
            foreground: AppColors.onPrimaryContainer(context),
          ),
          Text(
            'No schedules yet',
            style: AppTextStyles.sectionWithColor(context),
          ),
          Text(
            'Add a rule to set when this device should be at a place.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyWithColor(context),
          ),
        ],
      ),
    ),
  );
}
