import 'package:flutter/material.dart';

/// Separate stateless widget for the dot to prevent re-building the whole Marker
class HistoryDot extends StatelessWidget {
  final double rotation;
  const HistoryDot({super.key, required this.rotation});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.8),
        shape: BoxShape.circle,
      ),
      child: Transform.rotate(
        angle: rotation,
        child: const Icon(Icons.navigation, color: Colors.white, size: 14),
      ),
    );
  }
}
