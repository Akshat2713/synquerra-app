import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/schedule/schedule_entity.dart';
import '../../../domain/usecases/schedule/get_my_schedules_usecase.dart';
import '../../../domain/usecases/schedule/delete_schedule_usecase.dart';
import '../../../domain/usecases/schedule/toggle_schedule_status_usecase.dart';

part 'schedule_list_event.dart';
part 'schedule_list_state.dart';

class ScheduleListBloc extends Bloc<ScheduleListEvent, ScheduleListState> {
  final GetMySchedulesUseCase _getMySchedulesUseCase;
  final DeleteScheduleUseCase _deleteScheduleUseCase;
  final ToggleScheduleStatusUseCase _toggleScheduleStatusUseCase;

  ScheduleListBloc({
    required GetMySchedulesUseCase getMySchedulesUseCase,
    required DeleteScheduleUseCase deleteScheduleUseCase,
    required ToggleScheduleStatusUseCase toggleScheduleStatusUseCase,
  }) : _getMySchedulesUseCase = getMySchedulesUseCase,
       _deleteScheduleUseCase = deleteScheduleUseCase,
       _toggleScheduleStatusUseCase = toggleScheduleStatusUseCase,
       super(const ScheduleListState()) {
    on<ScheduleListLoadRequested>(_onLoad);
    on<ScheduleListRefreshRequested>(_onRefresh);
    on<ScheduleListItemDeleted>(_onItemDeleted);
    on<ScheduleListItemStatusToggled>(_onItemStatusToggled);
  }

  Future<void> _onLoad(
    ScheduleListLoadRequested event,
    Emitter<ScheduleListState> emit,
  ) async {
    emit(
      state.copyWith(status: ScheduleListStatus.loading, errorMessage: null),
    );
    await _fetch(event.isActive, emit);
  }

  Future<void> _onRefresh(
    ScheduleListRefreshRequested event,
    Emitter<ScheduleListState> emit,
  ) async {
    emit(
      state.copyWith(status: ScheduleListStatus.loading, errorMessage: null),
    );
    await _fetch(event.isActive, emit);
  }

  Future<void> _fetch(bool? isActive, Emitter<ScheduleListState> emit) async {
    final result = await _getMySchedulesUseCase(isActive: isActive);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ScheduleListStatus.error,
          errorMessage: failure.userMessage,
        ),
      ),
      (schedules) => emit(
        state.copyWith(
          status: ScheduleListStatus.loaded,
          schedules: schedules,
          errorMessage: null,
        ),
      ),
    );
  }

  Future<void> _onItemDeleted(
    ScheduleListItemDeleted event,
    Emitter<ScheduleListState> emit,
  ) async {
    emit(
      state.copyWith(
        processingIds: {...state.processingIds, event.scheduleId},
        actionError: null,
      ),
    );

    final result = await _deleteScheduleUseCase(event.scheduleId);

    result.fold(
      (failure) {
        final processing = {...state.processingIds}..remove(event.scheduleId);
        emit(
          state.copyWith(
            processingIds: processing,
            actionError: failure.userMessage,
          ),
        );
      },
      (_) {
        final processing = {...state.processingIds}..remove(event.scheduleId);
        final schedules = state.schedules
            .where((s) => s.id != event.scheduleId)
            .toList(growable: false);
        emit(state.copyWith(processingIds: processing, schedules: schedules));
      },
    );
  }

  Future<void> _onItemStatusToggled(
    ScheduleListItemStatusToggled event,
    Emitter<ScheduleListState> emit,
  ) async {
    emit(
      state.copyWith(
        processingIds: {...state.processingIds, event.scheduleId},
        actionError: null,
      ),
    );

    final result = await _toggleScheduleStatusUseCase(
      ToggleScheduleStatusParams(
        scheduleId: event.scheduleId,
        isActive: event.isActive,
      ),
    );

    result.fold(
      (failure) {
        final processing = {...state.processingIds}..remove(event.scheduleId);
        emit(
          state.copyWith(
            processingIds: processing,
            actionError: failure.userMessage,
          ),
        );
      },
      (_) {
        final processing = {...state.processingIds}..remove(event.scheduleId);
        final schedules = state.schedules
            .map((s) {
              if (s.id != event.scheduleId) return s;
              return ScheduleEntity(
                id: s.id,
                targetUserId: s.targetUserId,
                deviceId: s.deviceId,
                geofenceId: s.geofenceId,
                title: s.title,
                description: s.description,
                startTime: s.startTime,
                endTime: s.endTime,
                timezone: s.timezone,
                recurrenceType: s.recurrenceType,
                daysOfWeek: s.daysOfWeek,
                customDates: s.customDates,
                startDate: s.startDate,
                endDate: s.endDate,
                crossesMidnight: s.crossesMidnight,
                priority: s.priority,
                isActive: event.isActive,
                arrivalGraceMins: s.arrivalGraceMins,
                departureBufferMins: s.departureBufferMins,
                minimumStayMins: s.minimumStayMins,
                alertOnAbsence: s.alertOnAbsence,
                alertOnLateArrival: s.alertOnLateArrival,
                alertOnEarlyDeparture: s.alertOnEarlyDeparture,
                alertOnEarlyEntry: s.alertOnEarlyEntry,
                alertOnReentry: s.alertOnReentry,
                sendPushNotification: s.sendPushNotification,
                createdAt: s.createdAt,
                updatedAt: s.updatedAt,
              );
            })
            .toList(growable: false);
        emit(state.copyWith(processingIds: processing, schedules: schedules));
      },
    );
  }
}
