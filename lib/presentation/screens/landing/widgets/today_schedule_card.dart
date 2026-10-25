import 'package:flutter/material.dart';
import 'package:synquerra/presentation/themes/app_text_styles.dart';
import 'package:synquerra/presentation/themes/app_tokens.dart';
import 'package:synquerra/presentation/themes/colors.dart';
import 'package:synquerra/presentation/widgets/app_surfaces.dart';
import 'package:synquerra/presentation/widgets/expandable_card.dart';

class TodayScheduleCard extends StatelessWidget {
  final List<ScheduleEntry> schedule;

  const TodayScheduleCard({super.key, required this.schedule});

  @override
  Widget build(BuildContext context) {
    return ExpandableCard(
      leading: IconTile(
        icon: Icons.event_rounded,
        background: AppColors.primary(context),
        foreground: AppColors.onPrimary(context),
      ),
      title: "Today's Schedule",
      child: schedule.isEmpty
          ? const ExpandableCardEmpty('No scheduled events today.')
          : Column(
              children: [for (final e in schedule) _ScheduleRow(entry: e)],
            ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  final ScheduleEntry entry;
  const _ScheduleRow({required this.entry});

  @override
  Widget build(BuildContext context) => InsetRow(
    onTap: () {}, // TODO(logic): wire destination
    child: Row(
      children: [
        InfoPill(
          label: entry.time,
          background: AppColors.primaryContainer(context),
          foreground: AppColors.primary(context),
        ),
        const SizedBox(width: AppSpacing.smd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.label,
                style: AppTextStyles.bodyWithColor(
                  context,
                  color: AppColors.textPrimary(context),
                ).copyWith(fontWeight: FontWeight.w600),
              ),
              Text(entry.subtitle, style: AppTextStyles.metaWithColor(context)),
            ],
          ),
        ),
        // TODO(logic): wire skip action.
        FilledButton.tonal(
          onPressed: () {},
          style: FilledButton.styleFrom(
            visualDensity: VisualDensity.compact,
            minimumSize: Size.zero,
          ),
          child: const Text('Skip'),
        ),
      ],
    ),
  );
}

// TODO(logic): move ScheduleEntry + mockSchedule to domain/entities, fed by a bloc.
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
  const ScheduleEntry(id: '1', time: '08:00', label: 'School day'),
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
