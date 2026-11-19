import 'package:flutter/material.dart';

import '../themes/app_text_styles.dart';
import '../themes/app_tokens.dart';
import '../themes/colors.dart';
import '../utils/app_icons.dart';

class AppTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final bool isPassword;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;
  final bool enabled;
  final bool readOnly;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final VoidCallback? onTap;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.validator,
    this.enabled = true,
    this.onChanged,
    this.onSubmitted,
    this.readOnly = false,
    this.onTap,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword && _obscure,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      readOnly: widget.readOnly,
      enabled: widget.enabled,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      style: AppTextStyles.bodyWithColor(
        context,
        color: AppColors.textPrimary(context),
      ),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        prefixIcon: widget.prefixIcon != null
            ? Icon(
                widget.prefixIcon,
                size: AppSize.icon,
                color: AppColors.textSecondary(context),
              )
            : null,
        suffixIcon: widget.isPassword
            ? IconButton(
                tooltip: _obscure ? 'Show password' : 'Hide password',
                icon: Icon(
                  _obscure ? AppIcons.visibilityOff : AppIcons.visibility,
                  size: AppSize.icon,
                  color: AppColors.textSecondary(context),
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
            : null,
      ),
      onTap: widget.onTap,
    );
  }
}
