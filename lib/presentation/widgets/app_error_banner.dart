import 'package:flutter/material.dart';
import '../themes/app_text_styles.dart';
import '../themes/app_tokens.dart';
import '../themes/colors.dart';
import '../utils/app_icons.dart';
import 'app_surfaces.dart';

/// Inline error message for forms and sheets. Stays in the layout until the
/// caller stops rendering it. For transient notices, use [AppSnackBar].
class AppErrorBanner extends StatelessWidget {
  final String message;
  const AppErrorBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      tint: AppColors.dangerContainer,
      padding: AppSpacing.smAll,
      child: Row(
        spacing: AppSpacing.sm,
        children: [
          Icon(AppIcons.error, size: AppSize.icon, color: AppColors.danger),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyWithColor(
                context,
                color: AppColors.textPrimary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
