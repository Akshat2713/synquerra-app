import 'package:flutter/material.dart';
import '../themes/app_tokens.dart';
import '../themes/colors.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool fullWidth;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.fullWidth = true,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final spinner = foregroundColor ?? AppColors.onPrimary(context);
    return FilledButton(
      // Keep the enabled look while loading, but ignore taps.
      onPressed: onPressed == null ? null : (isLoading ? () {} : onPressed),
      style: FilledButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        minimumSize: fullWidth
            ? const Size.fromHeight(AppSize.tapTarget)
            : null,
      ),
      child: isLoading
          ? SizedBox.square(
              dimension: AppSize.icon,
              child: CircularProgressIndicator(
                strokeWidth: AppSize.stroke,
                color: spinner,
              ),
            )
          : Text(label),
    );
  }
}
