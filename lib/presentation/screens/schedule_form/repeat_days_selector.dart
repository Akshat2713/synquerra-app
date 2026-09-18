// lib/presentation/screens/create_schedule/widgets/repeat_days_selector.dart
import 'package:flutter/material.dart';
import '../../themes/colors.dart';

class RepeatDaysSelector extends StatelessWidget {
  final List<int> selectedDays;
  final ValueChanged<int> onDayToggled;

  const RepeatDaysSelector({
    super.key,
    required this.selectedDays,
    required this.onDayToggled,
  });

  static const List<String> _dayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final isSelected = selectedDays.contains(index);
        return InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => onDayToggled(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.surfaceVariant(context),
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.outline(context),
              ),
            ),
            child: Text(
              _dayNames[index],
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? Colors.white
                    : AppColors.textSecondary(context),
              ),
            ),
          ),
        );
      }),
    );
  }
}
