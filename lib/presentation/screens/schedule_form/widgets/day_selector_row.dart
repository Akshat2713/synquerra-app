import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../themes/app_text_styles.dart';
import '../../../themes/app_tokens.dart';
import '../../../themes/colors.dart';

class DaySelectorRow extends StatelessWidget {
  final List<int> selectedDays;
  // final ValueChanged<int> onDayToggled;

  // Index 0 (Sun) to 6 (Sat).
  static const List<String> _dayInitials = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  static const List<String> _dayNames = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  final ValueChanged<int>? onDayToggled; // was non-null
  const DaySelectorRow({
    super.key,
    required this.selectedDays,
    this.onDayToggled,
  });

  @override
  Widget build(BuildContext context) {
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : AppMotion.base;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(_dayInitials.length, (index) {
        final isSelected = selectedDays.contains(index);
        final background = isSelected
            ? AppColors.primary(context)
            : AppColors.surfaceVariant(context);
        final foreground = isSelected
            ? AppColors.onPrimary(context)
            : AppColors.textSecondary(context);

        return Semantics(
          button: onDayToggled != null,
          selected: isSelected,
          label: _dayNames[index],
          excludeSemantics: true,
          child: AnimatedContainer(
            duration: duration,
            curve: AppMotion.curve,
            width: AppSize.tile,
            height: AppSize.tile,
            decoration: BoxDecoration(
              color: background,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? AppColors.primary(context)
                    : AppColors.outline(context),
              ),
            ),
            child: Material(
              type: MaterialType.transparency,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onDayToggled == null
                    ? null
                    : () {
                        HapticFeedback.selectionClick();
                        onDayToggled!(index);
                      },
                child: Center(
                  child: Text(
                    _dayInitials[index],
                    style: AppTextStyles.bodyWithColor(
                      context,
                      color: foreground,
                    ).copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
