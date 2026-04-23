// lib/presentation/widgets/core/app_button.dart
import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final IconData? icon;
  final bool isLoading;
  final bool isOutlined;
  final bool isText;
  final bool isDanger;
  final Color? backgroundColor;
  final Color? textColor;
  final double width;
  final double height;
  final double borderRadius;

  const AppButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.isLoading = false,
    this.isOutlined = false,
    this.isText = false,
    this.isDanger = false,
    this.backgroundColor,
    this.textColor,
    this.width = double.infinity,
    this.height = 48,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isEnabled = onPressed != null && !isLoading;
    
    Color? bgColor = backgroundColor;
    Color? fgColor = textColor;
    
    if (isDanger && !isOutlined && !isText) {
      bgColor = Colors.red;
      fgColor = Colors.white;
    } else if (isDanger && isOutlined) {
      bgColor = Colors.transparent;
      fgColor = Colors.red;
    }

    if (isText) {
      return TextButton(
        onPressed: isEnabled ? onPressed : null,
        style: TextButton.styleFrom(
          minimumSize: Size(width, height),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
          foregroundColor: fgColor ?? colorScheme.primary,
        ),
        child: _buildChild(),
      );
    }

    if (isOutlined) {
      return OutlinedButton(
        onPressed: isEnabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          minimumSize: Size(width, height),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
          side: BorderSide(color: bgColor ?? colorScheme.primary),
          foregroundColor: fgColor ?? colorScheme.primary,
        ),
        child: _buildChild(),
      );
    }

    return ElevatedButton(
      onPressed: isEnabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor ?? colorScheme.primary,
        foregroundColor: fgColor ?? Colors.white,
        minimumSize: Size(width, height),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
        elevation: isEnabled ? 2 : 0,
      ),
      child: _buildChild(),
    );
  }

  Widget _buildChild() {
    if (isLoading) {
      return const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2));
    }
    if (icon != null) {
      return Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 20), const SizedBox(width: 8), Text(label)]);
    }
    return Text(label);
  }
}