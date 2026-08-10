import 'package:flutter/material.dart';
import '../../../../themes/colors.dart';

class SignalMeter extends StatelessWidget {
  final int? signal;

  const SignalMeter({super.key, required this.signal});

  int _signalBarsFilled(int? s) {
    final sig = s ?? 0;
    if (sig >= 75) return 4;
    if (sig >= 50) return 3;
    if (sig >= 25) return 2;
    if (sig > 0) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final filled = _signalBarsFilled(signal);
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
                      : colors.onSurfaceVariant.withValues(alpha: 0.18),
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
              color: colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
