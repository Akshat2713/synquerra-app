import 'package:flutter/material.dart';
import 'package:synquerra/old/theme/colors.dart';

class AuthFooter extends StatelessWidget {
  final String question;
  final String actionLabel;
  final VoidCallback onActionTap;

  const AuthFooter({
    super.key,
    required this.question,
    required this.actionLabel,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          question,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: onActionTap,
          child: Text(
            actionLabel,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.navBlue,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.navBlue,
            ),
          ),
        ),
      ],
    );
  }
}
