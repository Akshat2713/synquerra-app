// lib/presentation/widgets/core/app_info_row.dart
import 'package:flutter/material.dart';

class AppInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;
  final Color? valueColor;
  final bool compact;
  final Widget? customValue;

  const AppInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
    this.valueColor,
    this.compact = false,
    this.customValue,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconBgColor = (iconColor ?? colorScheme.primary).withValues(alpha: 0.1);

    return Padding(
      padding: EdgeInsets.only(bottom: compact ? 8 : 12),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 16, color: iconColor ?? colorScheme.primary)),
          const SizedBox(width: 12),
          SizedBox(width: compact ? 100 : 120, child: Text(label, style: TextStyle(fontSize: compact ? 13 : 14, color: colorScheme.onSurfaceVariant))),
          const SizedBox(width: 8),
          Expanded(
            child: customValue ??
                Container(
                  padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 12, vertical: compact ? 4 : 6),
                  decoration: BoxDecoration(color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(30)),
                  child: Text(value, style: TextStyle(fontSize: compact ? 13 : 14, fontWeight: FontWeight.w600, color: valueColor ?? colorScheme.onSurface), textAlign: TextAlign.center),
                ),
          ),
        ],
      ),
    );
  }
}