import 'package:flutter/material.dart';
import '../../../themes/colors.dart';
import '../../../widgets/app_button.dart';

Future<bool?> showScheduleDeleteDialog(BuildContext context, String title) =>
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete schedule?'),
        content: Text('Are you sure you want to delete "$title"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          AppButton(
            label: 'Delete',
            fullWidth: false,
            backgroundColor: AppColors.danger,
            foregroundColor: AppColors.onDanger,
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );
