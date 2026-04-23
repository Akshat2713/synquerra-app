// lib/presentation/widgets/core/app_progress_indicator.dart
import 'package:flutter/material.dart';

class AppProgressIndicator extends StatelessWidget {
  final double value;
  final double height;
  final Color? backgroundColor;
  final Color? valueColor;
  final String? label;
  final String? suffix;

  const AppProgressIndicator({
    super.key,
    required this.value,
    this.height = 8,
    this.backgroundColor,
    this.valueColor,
    this.label,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label!, style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
              Text("${value.toStringAsFixed(0)}${suffix ?? ''}", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 4),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: LinearProgressIndicator(
            value: value / 100,
            backgroundColor: backgroundColor ?? colorScheme.surfaceContainerHighest,
            color: valueColor ?? (value > 70 ? Colors.green : (value > 30 ? Colors.orange : Colors.red)),
            minHeight: height,
          ),
        ),
      ],
    );
  }
}