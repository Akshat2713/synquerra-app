import 'package:flutter/material.dart';
import '../themes/app_text_styles.dart';
import '../themes/app_tokens.dart';
import '../themes/colors.dart';
import 'app_surfaces.dart';

class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.lgAll,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: AppSpacing.smd,
        children: [
          IconTile(
            circle: true,
            size: AppSize.avatarLg,
            iconSize: AppSize.iconLg,
            icon: icon,
            background: AppColors.primaryContainer(context),
            foreground: AppColors.onPrimaryContainer(context),
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.sectionWithColor(context),
          ),
          if (message != null)
            Text(
              message!,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyWithColor(context),
            ),
        ],
      ),
    );
  }
}
