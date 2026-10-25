import 'package:flutter/material.dart';
import '../themes/app_text_styles.dart';
import '../themes/app_tokens.dart';
import '../themes/colors.dart';
import 'app_button.dart';
import 'app_surfaces.dart';

class AsyncStateView extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final bool isEmpty;
  final Widget Function() builder;
  final VoidCallback? onRetry;
  final Widget? loadingWidget;
  final Widget? emptyWidget;
  final String emptyMessage;

  const AsyncStateView({
    super.key,
    required this.isLoading,
    required this.builder,
    this.errorMessage,
    this.isEmpty = false,
    this.onRetry,
    this.loadingWidget,
    this.emptyWidget,
    this.emptyMessage = 'No data available',
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return loadingWidget ??
          const Center(child: CircularProgressIndicator.adaptive());
    }

    if (errorMessage != null && errorMessage!.isNotEmpty) {
      return Center(
        child: Padding(
          padding: AppSpacing.lgAll,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: AppSpacing.md,
            children: [
              const IconTile(
                circle: true,
                size: AppSize.tapTarget,
                iconSize: AppSize.iconLg,
                icon: Icons.error_outline_rounded,
                background: AppColors.dangerContainer,
                foreground: AppColors.danger,
              ),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyWithColor(context),
              ),
              if (onRetry != null)
                AppButton(label: 'Retry', onPressed: onRetry, fullWidth: false),
            ],
          ),
        ),
      );
    }

    if (isEmpty) {
      return emptyWidget ??
          Center(
            child: Text(
              emptyMessage,
              style: AppTextStyles.bodyWithColor(
                context,
                color: AppColors.textTertiary(context),
              ),
            ),
          );
    }

    return builder();
  }
}
