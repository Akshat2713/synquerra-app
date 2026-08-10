import 'package:flutter/material.dart';

class StatusDot extends StatelessWidget {
  final bool state;
  final String onLabel;
  final String offLabel;
  final Color onColor;

  const StatusDot({
    super.key,
    required this.state,
    required this.onLabel,
    required this.offLabel,
    required this.onColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = state
        ? onColor
        : colors.onSurfaceVariant.withValues(alpha: 0.6);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          state ? onLabel : offLabel,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
            color: color,
          ),
        ),
      ],
    );
  }
}
