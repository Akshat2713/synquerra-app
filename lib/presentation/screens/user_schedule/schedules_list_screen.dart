import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:synquerra/presentation/app/app_router.dart';
import 'package:synquerra/presentation/themes/colors.dart';

import '../../../domain/entities/schedule/schedule_entity.dart';
import '../../blocs/schedule_list/schedule_list_bloc.dart';
import 'widgets/schedule_card.dart';
import 'widgets/schedule_delete_dialog.dart';
import 'widgets/schedule_empty_view.dart';
import 'widgets/schedule_error_view.dart';

class SchedulesListScreen extends StatefulWidget {
  const SchedulesListScreen({super.key});

  @override
  State<SchedulesListScreen> createState() => _SchedulesListScreenState();
}

class _SchedulesListScreenState extends State<SchedulesListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ScheduleListBloc>().add(const ScheduleListLoadRequested());
  }

  Future<void> _onRefresh() async {
    final bloc = context.read<ScheduleListBloc>();
    bloc.add(const ScheduleListRefreshRequested());
    await bloc.stream.firstWhere((s) => !s.isLoading);
  }

  void _onEdit(ScheduleEntity schedule) {
    AppRouter.pushEditSchedule(context, scheduleId: schedule.id).then((_) {
      if (mounted) {
        context.read<ScheduleListBloc>().add(
          const ScheduleListRefreshRequested(),
        );
      }
    });
  }

  void _onAdd() {
    AppRouter.pushCreateSchedule(context).then((_) {
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
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Schedule Rules'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocConsumer<ScheduleListBloc, ScheduleListState>(
        listenWhen: (p, c) =>
            c.actionError != null && p.actionError != c.actionError,
        listener: (context, state) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.actionError!),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        },
        builder: (context, state) {
          if (state.isLoading && state.schedules.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.isError && state.schedules.isEmpty) {
            return ScheduleErrorView(
              message: state.errorMessage ?? 'Something went wrong',
              onRetry: () => context.read<ScheduleListBloc>().add(
                const ScheduleListLoadRequested(),
              ),
            );
          }

          if (state.schedules.isEmpty) {
            return const ScheduleEmptyView();
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            color: AppColors.primary,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.schedules.length,
              itemBuilder: (context, index) {
                final schedule = state.schedules[index];
                return ScheduleCard(
                  schedule: schedule,
                  isProcessing: state.isProcessing(schedule.id),
                  onTap: () {
                    AppRouter.pushScheduleView(context, schedule: schedule);
                  },
                  onToggle: (val) => context.read<ScheduleListBloc>().add(
                    ScheduleListItemStatusToggled(
                      scheduleId: schedule.id,
                      isActive: val,
                    ),
                  ),
                  onEdit: () => _onEdit(schedule),
                  // onAddException: () => _onAddException(schedule),
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
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        onPressed: _onAdd,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Schedule',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
