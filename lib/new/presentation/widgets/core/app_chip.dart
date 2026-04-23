// lib/presentation/widgets/core/app_chip.dart
import 'package:flutter/material.dart';

class AppChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;
  final bool compact;
  final VoidCallback? onTap;

  const AppChip({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.color,
    this.compact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final chipColor = color ?? colorScheme.primary;

    Widget chip = Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 12, vertical: compact ? 6 : 10),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(compact ? 12 : 16),
        border: Border.all(color: chipColor.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 14 : 16, color: chipColor),
          const SizedBox(width: 6),
          Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text(label, style: TextStyle(fontSize: compact ? 9 : 10, color: colorScheme.onSurfaceVariant)),
            Text(value, style: TextStyle(fontSize: compact ? 12 : 14, fontWeight: FontWeight.w600)),
          ]),
        ],
      ),
    );

    if (onTap != null) {
      chip = InkWell(onTap: onTap, borderRadius: BorderRadius.circular(compact ? 12 : 16), child: chip);
    }

    return chip;
  }
}