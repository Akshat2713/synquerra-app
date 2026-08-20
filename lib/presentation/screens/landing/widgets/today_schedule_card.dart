import 'package:flutter/material.dart';

import '../../../themes/colors.dart';

class TodayScheduleCard extends StatefulWidget {
  final List<ScheduleEntry> schedule;

  const TodayScheduleCard({super.key, required this.schedule});

  @override
  State<TodayScheduleCard> createState() => _TodayScheduleCardState();
}

class _TodayScheduleCardState extends State<TodayScheduleCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.outlineVariant(context).withValues(alpha: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Dropdown Header ──────────────────────────────────────
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textSecondary(context),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Today's Schedule",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Expandable List ──────────────────────────────────────
          if (_isExpanded) ...[
            Divider(
              height: 1,
              color: AppColors.outlineVariant(context).withValues(alpha: 0.3),
            ),
            if (widget.schedule.isNotEmpty)
              ...widget.schedule.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 50,
                        child: Text(
                          item.time,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.label,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Safe environment',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          side: BorderSide(
                            color: AppColors.outlineVariant(
                              context,
                            ).withValues(alpha: 0.5),
                          ),
                        ),
                        child: const Text(
                          'Skip',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No scheduled events today.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class ScheduleEntry {
  final String id;
  final String time;
  final String label;
  final String subtitle;
  final bool isSkipped;

  const ScheduleEntry({
    required this.id,
    required this.time,
    required this.label,
    this.subtitle = 'Safe environment',
    this.isSkipped = false,
  });
}

final List<ScheduleEntry> mockSchedule = [
  const ScheduleEntry(
    id: '1',
    time: '08:00',
    label: 'School day',
    subtitle: 'Safe environment',
  ),
  const ScheduleEntry(
    id: '2',
    time: '12:30',
    label: 'Lunch Break',
    subtitle: 'Cafeteria',
  ),
  const ScheduleEntry(
    id: '3',
    time: '15:00',
    label: 'After-school Activity',
    subtitle: 'Sports Complex',
  ),
  const ScheduleEntry(
    id: '4',
    time: '18:00',
    label: 'Evening Study',
    subtitle: 'Home / Library',
  ),
];
