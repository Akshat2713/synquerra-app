// lib/presentation/screens/device_list/widgets/device_card/signal_meter.dart

import 'package:flutter/material.dart';
import 'package:synquerra/presentation/utils/unit_formatter.dart';
import '../../../../themes/colors.dart';

class SignalMeter extends StatelessWidget {
  final int? signal;

  const SignalMeter({super.key, required this.signal});

  @override
  Widget build(BuildContext context) {
    final filled = UnitFormatter.signalBarsFilled(signal);
    const heights = [7.0, 11.0, 15.0, 19.0];

    return SizedBox(
      width: 42,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(4, (i) {
              final isFilled = i < filled;
              return Container(
                width: 4,
                height: heights[i],
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                decoration: BoxDecoration(
                  color: isFilled
                      ? AppColors.info
                      : AppColors.textSecondary(context).withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(1.5),
                ),
              );
            }),
          ),
          const SizedBox(height: 4),
          Text(
            signal != null ? '$signal%' : '–',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(context),
            ),
          ),
        ],
      ),
    );
  }
}
