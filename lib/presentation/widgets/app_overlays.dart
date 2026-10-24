import 'package:flutter/material.dart';
import '../themes/app_text_styles.dart';
import '../themes/app_tokens.dart';
import '../themes/colors.dart';

class AppSnackBar {
  AppSnackBar._();

  static void success(BuildContext c, String message) =>
      _show(c, message, isError: false);

  static void error(BuildContext c, String message) =>
      _show(c, message, isError: true);

  static void _show(
    BuildContext context,
    String message, {
    required bool isError,
  }) {
    final fg = isError ? AppColors.onDanger : AppColors.onSuccess;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: isError ? AppColors.danger : AppColors.success,
          margin: AppSpacing.mdAll,
          duration: isError ? AppMotion.snackLong : AppMotion.snack,
          content: Row(
            children: [
              Icon(
                isError
                    ? Icons.error_outline_rounded
                    : Icons.check_circle_rounded,
                color: fg,
                size: AppSize.icon,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  message,
                  style: AppTextStyles.body.copyWith(color: fg),
                ),
              ),
            ],
          ),
        ),
      );
  }
}

Future<T?> showAppBottomSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) => showModalBottomSheet<T>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: builder,
);
