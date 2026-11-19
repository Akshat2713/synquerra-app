import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/entities/device/device_entity.dart';
import '../../../../domain/utils/schedule_resolver.dart';
import '../../../blocs/schedule_list/schedule_list_bloc.dart';
import '../../../themes/app_text_styles.dart';
import '../../../themes/app_tokens.dart';
import '../../../themes/colors.dart';
import '../../../widgets/app_surfaces.dart';
import '../../../widgets/expandable_card.dart';

import 'schedule_row_skeleton.dart';

class TodayScheduleCard extends StatefulWidget {
  final DeviceEntity device;

  const TodayScheduleCard({super.key, required this.device});

  @override
  State<TodayScheduleCard> createState() => _TodayScheduleCardState();
}

class _TodayScheduleCardState extends State<TodayScheduleCard> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    // Re-evaluate upcoming / ongoing / completed every minute.
    _ticker = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _load() => context.read<ScheduleListBloc>().add(
    ScheduleListLoadRequested(
      userId: widget.device.displayRealUserId,
      deviceId: widget.device.id,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return ExpandableCard(
      leading: IconTile(
        icon: Icons.event_rounded,
        background: AppColors.primary(context),
        foreground: AppColors.onPrimary(context),
      ),
      title: "Today's Schedule",
      onExpanded: _load,
      child: BlocBuilder<ScheduleListBloc, ScheduleListState>(
        builder: (context, state) {
          if ((state.isLoading || state.status == ScheduleListStatus.initial) &&
              state.schedules.isEmpty) {
            return const ScheduleRowSkeleton();
          }

          if (state.isError && state.schedules.isEmpty) {
            return ExpandableCardEmpty(
              state.errorMessage ?? 'Could not load schedules.',
            );
          }

          final today = ScheduleResolver.forDay(
            state.schedules,
            DateTime.now(),
          );

          if (today.isEmpty) {
            return const ExpandableCardEmpty('No scheduled events today.');
          }

          return Column(
            children: [for (final r in today) _ScheduleRow(resolved: r)],
          );
        },
      ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  final ResolvedSchedule resolved;
  const _ScheduleRow({required this.resolved});

  static String _label(ScheduleStatus s) => switch (s) {
    ScheduleStatus.upcoming => 'Upcoming',
    ScheduleStatus.ongoing => 'Ongoing',
    ScheduleStatus.completed => 'Completed',
  };

  @override
  Widget build(BuildContext context) {
    final schedule = resolved.schedule;

    return InsetRow(
      onTap: () {}, // TODO(logic): wire destination
      child: Row(
        children: [
          InfoPill(
            label: schedule.startTime,
            background: AppColors.primaryContainer(context),
            foreground: AppColors.primary(context),
          ),
          const SizedBox(width: AppSpacing.smd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  schedule.title,
                  style: AppTextStyles.bodyWithColor(
                    context,
                    color: AppColors.textPrimary(context),
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  _label(resolved.status),
                  style: AppTextStyles.metaWithColor(context),
                ),
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
}
