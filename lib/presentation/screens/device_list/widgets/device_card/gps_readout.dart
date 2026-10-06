import 'package:flutter/material.dart';

import '../../../../themes/colors.dart';
import 'package:synquerra/presentation/themes/app_tokens.dart';

class GpsReadout extends StatelessWidget {
  final String? gpsStrength;

  const GpsReadout({super.key, required this.gpsStrength});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 42,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.satellite_alt_rounded,
            size: 16,
            color: AppColors.textSecondary(context),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            gpsStrength ?? '–',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              fontFamily: 'monospace',
              color: AppColors.textPrimary(context),
            ),
          ),
        ],
      ),
    );
  }
}
