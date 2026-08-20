import 'package:flutter/material.dart';
import '../../../themes/colors.dart';

class AddDeviceFab extends StatelessWidget {
  final VoidCallback onTap;

  const AddDeviceFab({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onTap,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      tooltip: 'Add New Device',
      child: const Icon(Icons.add_rounded, size: 28),
    );
  }
}
