import 'package:flutter/material.dart';

class PacketBadge extends StatelessWidget {
  final bool isAlert;
  final ColorScheme colors;
  const PacketBadge({super.key, required this.isAlert, required this.colors});

  @override
  Widget build(BuildContext context) {
    final bg = isAlert ? colors.error : colors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAlert ? Icons.warning_rounded : Icons.check_circle_rounded,
            size: 12,
            color: isAlert ? colors.onError : colors.onPrimary,
          ),
          const SizedBox(width: 4),
          Text(
            isAlert ? 'Alert' : 'Normal',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isAlert ? colors.onError : colors.onPrimary,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
