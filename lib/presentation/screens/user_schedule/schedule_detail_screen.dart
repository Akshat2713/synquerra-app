import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection_container.dart';
import '../../../domain/entities/schedule/schedule_entity.dart';
import '../../../domain/entities/schedule/schedule_override_entity.dart';
// import '../../blocs/schedule_overrides/schedule_overrides_bloc.dart';
import '../../app/app_router.dart';
import '../../blocs/schedule_override/schedule_overrides_bloc.dart';
import '../../themes/app_tokens.dart';
import '../../themes/colors.dart';
import '../../utils/app_icons.dart';
import '../../widgets/app_motion_widgets.dart';
import '../../widgets/app_overlays.dart';
import 'schedule_detail_screen_widgets/schedule_exceptions_card.dart';
import 'schedule_detail_screen_widgets/schedule_header_card.dart';
import 'schedule_detail_screen_widgets/schedule_rules_card.dart';
import 'schedule_detail_screen_widgets/schedule_timing_card.dart';
// import 'schedule_detail_screen_widgets/schedule_override_form_sheet.dart';

class ScheduleDetailsScreen extends StatefulWidget {
  final ScheduleEntity schedule;

  const ScheduleDetailsScreen({super.key, required this.schedule});

  @override
  State<ScheduleDetailsScreen> createState() => _ScheduleDetailsScreenState();
}

class _ScheduleDetailsScreenState extends State<ScheduleDetailsScreen> {
  late final ScheduleOverridesBloc _bloc;

  @override
  void initState() {
    super.initState();
    // Adjust to your DI setup (get_it/injectable shown as `sl<T>()`)
    _bloc = sl<ScheduleOverridesBloc>()
      ..add(ScheduleOverridesLoadRequested(scheduleId: widget.schedule.id));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  void _openForm({ScheduleOverrideEntity? existing}) {
    AppRouter.pushScheduleOverride(
      context,
      scheduleId: widget.schedule.id,
      bloc: _bloc,
      existingOverride: existing,
    );
  }

  void _confirmDelete(ScheduleOverrideEntity override) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete exception?'),
        content: Text('This will remove the exception for ${override.date}.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _bloc.add(
                ScheduleOverrideDeleted(
                  scheduleId: widget.schedule.id,
                  overrideId: override.id,
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        appBar: AppBar(
          title: const Text('Schedule Details'),
          leading: IconButton(
            tooltip: 'Back',
            icon: const Icon(AppIcons.back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: BlocConsumer<ScheduleOverridesBloc, ScheduleOverridesState>(
          listener: (context, state) {
            if (state.actionError != null) {
              AppSnackBar.error(context, state.actionError!);
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: AppSpacing.mdAll,
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: AppSpacing.md,
                children: [
                  ScheduleHeaderCard(
                    schedule: widget.schedule,
                  ).entrance(context, index: 0),
                  ScheduleTimingCard(
                    schedule: widget.schedule,
                  ).entrance(context, index: 1),
                  ScheduleRulesCard(
                    schedule: widget.schedule,
                  ).entrance(context, index: 2),
                  if (state.status == ScheduleOverridesStatus.loading &&
                      state.overrides.isEmpty)
                    const Center(child: CircularProgressIndicator()) // pending
                  else if (state.status == ScheduleOverridesStatus.error)
                    Text(
                      state.errorMessage ?? 'Failed to load exceptions.',
                      style: TextStyle(color: AppColors.danger), // pending
                    )
                  else
                    ScheduleExceptionsCard(
                      overrides: state.overrides,
                      processingIds: state.processingIds,
                      onAddException: () => _openForm(),
                      onEditException: (o) => _openForm(existing: o),
                      onDeleteException: _confirmDelete,
                    ).entrance(context, index: 3),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
