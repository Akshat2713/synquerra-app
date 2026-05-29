import 'package:flutter/material.dart';

class DataChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ColorScheme colors;
  final Color? accent;

  const DataChip({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.colors,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final fg = accent ?? colors.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surface.withOpacity(0.7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  color: colors.onSurfaceVariant.withOpacity(0.7),
                  letterSpacing: 0.3,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
