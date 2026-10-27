part of 'schedule_list_bloc.dart';

enum ScheduleListStatus { initial, loading, loaded, error }

class ScheduleListState extends Equatable {
  final ScheduleListStatus status;
  final List<ScheduleEntity> schedules;
  final String? errorMessage;
  final Set<String> processingIds;
  final String? actionError;
  final String? userId;
  final String? deviceId;

  const ScheduleListState({
    this.status = ScheduleListStatus.initial,
    this.schedules = const [],
    this.errorMessage,
    this.processingIds = const {},
    this.actionError,
    this.userId,
    this.deviceId,
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
    String? userId,
    String? deviceId,
  }) {
    return ScheduleListState(
      status: status ?? this.status,
      schedules: schedules ?? this.schedules,
      errorMessage: errorMessage,
      processingIds: processingIds ?? this.processingIds,
      actionError: actionError,
      userId: userId ?? this.userId,
      deviceId: deviceId ?? this.deviceId,
    );
  }

  @override
  List<Object?> get props => [
    status,
    schedules,
    errorMessage,
    processingIds,
    actionError,
    userId,
    deviceId,
  ];
}
