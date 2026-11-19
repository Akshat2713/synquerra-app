import 'package:flutter/material.dart';

import '../themes/app_text_styles.dart';
import '../themes/app_tokens.dart';
import '../themes/colors.dart';
import '../utils/app_icons.dart';

class AppDropdownField<T> extends StatelessWidget {
  final String label;
  final IconData? prefixIcon;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;
  final FormFieldValidator<T>? validator;

  const AppDropdownField({
    super.key,
    required this.label,
    this.prefixIcon,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = AppTextStyles.bodyWithColor(
      context,
      color: AppColors.textPrimary(context),
    ).copyWith(fontWeight: FontWeight.w500);

    return DropdownButtonFormField<T>(
      key: ValueKey(value),
      initialValue: items.contains(value) ? value : null,
      isExpanded: true,
      style: textStyle,
      dropdownColor: AppColors.surface(context),
      icon: Icon(
        AppIcons.keyboardArrowDown,
        color: AppColors.textSecondary(context),
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: prefixIcon == null
            ? null
            : Icon(
                prefixIcon,
                size: AppSize.icon,
                color: AppColors.textSecondary(context),
              ),
      ),
      items: [
        for (final i in items)
          DropdownMenuItem<T>(
            value: i,
            child: Text(
              itemLabel(i),
              overflow: TextOverflow.ellipsis,
              style: textStyle,
            ),
          ),
      ],
      onChanged: onChanged,
      validator: validator,
    );
  }
}
