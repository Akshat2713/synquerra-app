import 'package:flutter/material.dart';

class GpsReadout extends StatelessWidget {
  final String? gpsStrength;

  const GpsReadout({super.key, required this.gpsStrength});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      width: 42,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.satellite_alt_rounded,
            size: 16,
            color: colors.onSurfaceVariant,
          ),
          const SizedBox(height: 6),
          Text(
            gpsStrength ?? '–',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              fontFamily: 'monospace',
              color: colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
