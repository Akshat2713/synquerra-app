part of 'schedule_list_bloc.dart';

enum ScheduleListStatus { initial, loading, loaded, error }

class ScheduleListState extends Equatable {
  final ScheduleListStatus status;
  final List<ScheduleEntity> schedules;
  final String? errorMessage;
  final Set<String> processingIds; // schedule ids currently deleting/toggling
  final String? actionError; // transient error from a delete/toggle action

  const ScheduleListState({
    this.status = ScheduleListStatus.initial,
    this.schedules = const [],
    this.errorMessage,
    this.processingIds = const {},
    this.actionError,
  });

  bool get isLoading => status == ScheduleListStatus.loading;
  bool get isError => status == ScheduleListStatus.error;
  bool isProcessing(String scheduleId) => processingIds.contains(scheduleId);

  ScheduleListState copyWith({
    ScheduleListStatus? status,
    List<ScheduleEntity>? schedules,
    String? errorMessage,
    Set<String>? processingIds,
    String? actionError,
  }) {
    return ScheduleListState(
      status: status ?? this.status,
      schedules: schedules ?? this.schedules,
      errorMessage: errorMessage,
      processingIds: processingIds ?? this.processingIds,
      actionError: actionError,
    );
  }

  @override
  List<Object?> get props => [
    status,
    schedules,
    errorMessage,
    processingIds,
    actionError,
  ];
}
