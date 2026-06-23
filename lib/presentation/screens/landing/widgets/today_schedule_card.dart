import 'package:flutter/material.dart';
import '../../../blocs/landing/landing_bloc.dart'; // Holds your ScheduleEntry model

class TodayScheduleCard extends StatelessWidget {
  final List<ScheduleEntry> schedule;

  const TodayScheduleCard({super.key, required this.schedule});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    const kBlue = Color(0xFF5B8DEF);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.outlineVariant, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title Header
          Text(
            "TODAY'S SCHEDULE",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: colors.onSurfaceVariant.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),

          // Schedule Timeline Items
          if (schedule.isNotEmpty)
            ...schedule.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 56,
                      child: Text(
                        item.time,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color:
                              kBlue, // Distinct time accent color from layout image
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Text(
              'No scheduled events today.',
              style: TextStyle(fontSize: 14, color: colors.onSurfaceVariant),
            ),
        ],
      ),
    );
  }
}
