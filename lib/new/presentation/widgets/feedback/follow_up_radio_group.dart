// lib/presentation/widgets/feedback/follow_up_radio_group.dart
import 'package:flutter/material.dart';

enum FollowUpPermission { yes, no, none }

class FollowUpRadioGroup extends StatelessWidget {
  final FollowUpPermission value;
  final ValueChanged<FollowUpPermission> onChanged;

  const FollowUpRadioGroup({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Radio<FollowUpPermission>(
          value: FollowUpPermission.yes,
          groupValue: value,
          onChanged: (val) => onChanged(val ?? FollowUpPermission.none),
          activeColor: colorScheme.primary,
        ),
        Text(
          'Yes',
          style: TextStyle(color: colorScheme.onSurface, fontSize: 16),
        ),
        const SizedBox(width: 20),
        Radio<FollowUpPermission>(
          value: FollowUpPermission.no,
          groupValue: value,
          onChanged: (val) => onChanged(val ?? FollowUpPermission.none),
          activeColor: colorScheme.primary,
        ),
        Text(
          'No',
          style: TextStyle(color: colorScheme.onSurface, fontSize: 16),
        ),
      ],
    );
  }
}
