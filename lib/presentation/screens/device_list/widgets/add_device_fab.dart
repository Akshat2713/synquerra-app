import 'package:flutter/material.dart';

class AddDeviceFab extends StatelessWidget {
  final VoidCallback onTap;

  const AddDeviceFab({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FloatingActionButton(
      onPressed: onTap,
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      tooltip: 'Add New Device',
      child: const Icon(Icons.add_rounded, size: 28),
    );
  }
}
