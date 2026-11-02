import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../app/app_router.dart';
import '../../../domain/entities/device/device_entity.dart';
import '../../../domain/entities/schedule/schedule_entity.dart';
import '../../blocs/schedule_list/schedule_list_bloc.dart';
import '../../utils/app_icons.dart';
import '../../widgets/app_motion_widgets.dart';
import '../../widgets/app_overlays.dart';
import '../../widgets/async_state_view.dart';
import 'widgets/schedule_card.dart';
import 'widgets/schedule_delete_dialog.dart';
import 'widgets/schedule_empty_view.dart';
import '../../themes/app_tokens.dart';

import 'widgets/schedule_list_skeleton.dart';

class SchedulesListScreen extends StatefulWidget {
  final DeviceEntity device;
  const SchedulesListScreen({super.key, required this.device});

  @override
  State<SchedulesListScreen> createState() => _SchedulesListScreenState();
}

class _SchedulesListScreenState extends State<SchedulesListScreen> {
  // Keeps the last card clear of the extended FAB.
  static const double _fabClearance =
      AppSize.tapTarget + AppSpacing.xl + AppSpacing.md;

  void _load() {
    context.read<ScheduleListBloc>().add(
      ScheduleListLoadRequested(
        userId: widget.device.displayRealUserId,
        deviceId: widget.device.id,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _onRefresh() async {
    final bloc = context.read<ScheduleListBloc>();
    bloc.add(const ScheduleListRefreshRequested());
    await bloc.stream.firstWhere((s) => !s.isLoading);
  }

  void _onEdit(ScheduleEntity schedule) {
    AppRouter.pushEditSchedule(
      context,
      scheduleId: schedule.id,
      device: widget.device,
    ).then((_) {
      if (mounted) {
        context.read<ScheduleListBloc>().add(
          const ScheduleListRefreshRequested(),
        );
      }
    });
  }

  void _onAdd() {
    AppRouter.pushCreateSchedule(context, device: widget.device).then((_) {
      if (mounted) {
        context.read<ScheduleListBloc>().add(
          const ScheduleListRefreshRequested(),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Rules'),
        actions: [
          // TODO(logic): schedule filtering is not implemented yet.
          IconButton(
            tooltip: 'Filter (coming soon)',
            icon: Icon(AppIcons.filter),
            onPressed: null,
          ),
        ],
      ),
      body: BlocConsumer<ScheduleListBloc, ScheduleListState>(
        listenWhen: (p, c) =>
            c.actionError != null && p.actionError != c.actionError,
        listener: (context, state) =>
            AppSnackBar.error(context, state.actionError!),
        builder: (context, state) {
          final noData = state.schedules.isEmpty;
          return AsyncStateView(
            isLoading: state.isLoading && noData,
            loadingWidget: const ScheduleListSkeleton(),
            errorMessage: state.isError && noData
                ? (state.errorMessage ?? 'Something went wrong')
                : null,
            onRetry: _load,
            isEmpty: noData,
            emptyWidget: const ScheduleEmptyView(),
            builder: () => RefreshIndicator(
              onRefresh: _onRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  _fabClearance,
                ),
                child: Column(
                  spacing: AppSpacing.md,
                  children: [
                    for (final (i, schedule) in state.schedules.indexed)
                      KeyedSubtree(
                        key: ValueKey(schedule.id),
                        child: ScheduleCard(
                          schedule: schedule,
                          isProcessing: state.isProcessing(schedule.id),
                          onTap: () => AppRouter.pushScheduleView(
                            context,
                            schedule: schedule,
                          ),
                          onToggle: (val) =>
                              context.read<ScheduleListBloc>().add(
                                ScheduleListItemStatusToggled(
                                  scheduleId: schedule.id,
                                  isActive: val,
                                ),
                              ),
                          onEdit: () => _onEdit(schedule),
                          onDelete: () async {
                            final confirmed = await showScheduleDeleteDialog(
                              context,
                              schedule.title,
                            );
                            if (confirmed == true && context.mounted) {
                              context.read<ScheduleListBloc>().add(
                                ScheduleListItemDeleted(schedule.id),
                              );
                            }
                          },
                        ).entrance(context, index: i),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onAdd,
        icon: Icon(AppIcons.add),
        label: const Text('Add Schedule'),
      ),
    );
  }
}
