import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../themes/app_text_styles.dart';
import '../themes/app_tokens.dart';
import '../themes/colors.dart';

/// Read-only field that opens a picker. Looks like [AppTextField].
class AppPickerField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final FormFieldValidator<String>? validator;
  final VoidCallback onTap;

  const AppPickerField({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.validator,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      key: ValueKey(value),
      initialValue: value,
      validator: validator,
      builder: (state) => Stack(
        children: [
          InputDecorator(
            isEmpty: value.isEmpty,
            decoration: InputDecoration(
              labelText: label,
              errorText: state.errorText,
              prefixIcon: Icon(
                icon,
                size: AppSize.icon,
                color: AppColors.textSecondary(context),
              ),
            ),
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyWithColor(
                context,
                color: AppColors.textPrimary(context),
              ),
            ),
          ),
          Positioned.fill(
            child: Material(
              type: MaterialType.transparency,
              borderRadius: AppRadius.mdAll,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onTap();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
