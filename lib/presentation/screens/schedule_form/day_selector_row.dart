import 'package:flutter/material.dart';
import 'package:synquerra/presentation/themes/colors.dart';

class DaySelectorRow extends StatelessWidget {
  final List<int> selectedDays;
  final ValueChanged<int> onDayToggled;

  static const List<String> _dayNames = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  const DaySelectorRow({
    super.key,
    required this.selectedDays,
    required this.onDayToggled,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        // index directly corresponds to 0 (Sun) -> 6 (Sat)
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
