part of 'schedule_list_bloc.dart';

abstract class ScheduleListEvent extends Equatable {
  const ScheduleListEvent();
  @override
  List<Object?> get props => [];
}

class ScheduleListLoadRequested extends ScheduleListEvent {
  final String userId;
  final String deviceId;

  const ScheduleListLoadRequested({
    required this.userId,
    required this.deviceId,
  });

  @override
  List<Object?> get props => [userId, deviceId];
}

class ScheduleListRefreshRequested extends ScheduleListEvent {
  const ScheduleListRefreshRequested();
}

class ScheduleListItemDeleted extends ScheduleListEvent {
  final String scheduleId;
  const ScheduleListItemDeleted(this.scheduleId);
  @override
  List<Object?> get props => [scheduleId];
}

class ScheduleListItemStatusToggled extends ScheduleListEvent {
  final String scheduleId;
  final bool isActive;
  const ScheduleListItemStatusToggled({
    required this.scheduleId,
    required this.isActive,
  });
  @override
  List<Object?> get props => [scheduleId, isActive];
}
