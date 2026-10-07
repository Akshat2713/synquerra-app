import 'package:flutter/material.dart';
import '../../../../presentation/themes/colors.dart';
import 'package:synquerra/presentation/themes/app_tokens.dart';

Future<bool?> showScheduleDeleteDialog(BuildContext context, String title) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
      title: const Text('Delete Schedule'),
      content: Text('Are you sure you want to delete "$title"?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(
            'Cancel',
            style: TextStyle(color: AppColors.textSecondary(context)),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.danger,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.smAll,
            ),
          ),
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}
