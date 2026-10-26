import 'package:flutter/material.dart';
import '../themes/app_text_styles.dart';
import '../themes/app_tokens.dart';
import '../themes/colors.dart';
import '../utils/app_icons.dart';

enum _SnackKind { success, error, info }

class AppSnackBar {
  AppSnackBar._();

  static void success(BuildContext c, String message) =>
      _show(c, message, _SnackKind.success);

  static void error(BuildContext c, String message) =>
      _show(c, message, _SnackKind.error);

  /// Neutral heads-up (empty results, notices). Not an error.
  static void info(BuildContext c, String message) =>
      _show(c, message, _SnackKind.info);

  static void _show(BuildContext context, String message, _SnackKind kind) {
    final (bg, fg, icon) = switch (kind) {
      _SnackKind.success => (
        AppColors.success,
        AppColors.onSuccess,
        AppIcons.success,
      ),
      _SnackKind.error => (
        AppColors.danger,
        AppColors.onDanger,
        AppIcons.error,
      ),
      _SnackKind.info => (AppColors.info, AppColors.onInfo, AppIcons.info),
    };

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: bg,
          margin: AppSpacing.mdAll,
          duration: kind == _SnackKind.success
              ? AppMotion.snack
              : AppMotion.snackLong,
          content: Row(
            spacing: AppSpacing.sm,
            children: [
              Icon(icon, color: fg, size: AppSize.icon),
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
