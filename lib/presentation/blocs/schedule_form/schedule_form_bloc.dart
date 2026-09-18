import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/schedule/schedule_entity.dart';
import '../../../domain/entities/geofence/geofence_entity.dart';
import '../../../domain/usecases/schedule/create_schedule_usecase.dart';
import '../../../domain/usecases/schedule/update_schedule_usecase.dart';
import '../../../domain/usecases/schedule/get_schedule_by_id_usecase.dart';
import '../../../domain/usecases/geofence/get_geofences_usecase.dart';

part 'schedule_form_event.dart';
part 'schedule_form_state.dart';

class ScheduleFormBloc extends Bloc<ScheduleFormEvent, ScheduleFormState> {
  final CreateScheduleUseCase _createScheduleUseCase;
  final UpdateScheduleUseCase _updateScheduleUseCase;
  final GetScheduleByIdUseCase _getScheduleByIdUseCase;
  final GetGeofencesUseCase _getGeofencesUseCase;

  ScheduleFormBloc({
    required CreateScheduleUseCase createScheduleUseCase,
    required UpdateScheduleUseCase updateScheduleUseCase,
    required GetScheduleByIdUseCase getScheduleByIdUseCase,
    required GetGeofencesUseCase getGeofencesUseCase,
  }) : _createScheduleUseCase = createScheduleUseCase,
       _updateScheduleUseCase = updateScheduleUseCase,
       _getScheduleByIdUseCase = getScheduleByIdUseCase,
       _getGeofencesUseCase = getGeofencesUseCase,
       super(const ScheduleFormState()) {
    on<ScheduleFormEditRequested>(_onEditRequested);
    on<ScheduleFormDeviceChanged>(_onDeviceChanged);
    on<ScheduleFormCreateSubmitted>(_onCreateSubmitted);
    on<ScheduleFormUpdateSubmitted>(_onUpdateSubmitted);
    on<ScheduleFormReset>(_onReset);
  }

  Future<void> _onEditRequested(
    ScheduleFormEditRequested event,
    Emitter<ScheduleFormState> emit,
  ) async {
    emit(
      state.copyWith(
        mode: ScheduleFormMode.edit,
        loadStatus: ScheduleFormLoadStatus.loading,
        errorMessage: null,
      ),
    );

    final result = await _getScheduleByIdUseCase(event.scheduleId);

    await result.fold(
      (failure) async {
        emit(
          state.copyWith(
            loadStatus: ScheduleFormLoadStatus.error,
            errorMessage: failure.userMessage,
          ),
        );
      },
      (schedule) async {
        emit(
          state.copyWith(
            loadStatus: ScheduleFormLoadStatus.loaded,
            schedule: schedule,
            selectedDeviceId: schedule.deviceId,
          ),
        );
        await _loadGeofences(schedule.deviceId, emit);
      },
    );
  }

  Future<void> _onDeviceChanged(
    ScheduleFormDeviceChanged event,
    Emitter<ScheduleFormState> emit,
  ) async {
    if (event.deviceId == null) {
      emit(
        state.copyWith(
          selectedDeviceId: null,
          geofences: const [],
          geofenceStatus: ScheduleFormGeofenceStatus.idle,
          geofenceError: null,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        selectedDeviceId: event.deviceId,
        geofences: const [],
        geofenceStatus: ScheduleFormGeofenceStatus.loading,
        geofenceError: null,
      ),
    );

    await _loadGeofences(event.deviceId!, emit);
  }

  Future<void> _loadGeofences(
    String deviceId,
    Emitter<ScheduleFormState> emit,
  ) async {
    final result = await _getGeofencesUseCase(deviceId);
    result.fold(
      (failure) => emit(
        state.copyWith(
          geofenceStatus: ScheduleFormGeofenceStatus.error,
          geofenceError: failure.userMessage,
        ),
      ),
      (geofences) => emit(
        state.copyWith(
          geofenceStatus: ScheduleFormGeofenceStatus.loaded,
          geofences: geofences,
        ),
      ),
    );
  }

  Future<void> _onCreateSubmitted(
    ScheduleFormCreateSubmitted event,
    Emitter<ScheduleFormState> emit,
  ) async {
    emit(
      state.copyWith(
        submitStatus: ScheduleFormSubmitStatus.submitting,
        submitError: null,
      ),
    );

    final result = await _createScheduleUseCase(event.body);

    result.fold(
      (failure) => emit(
        state.copyWith(
          submitStatus: ScheduleFormSubmitStatus.error,
          submitError: failure.userMessage,
        ),
      ),
      (schedule) => emit(
        state.copyWith(
          submitStatus: ScheduleFormSubmitStatus.success,
          schedule: schedule,
        ),
      ),
    );
  }

  Future<void> _onUpdateSubmitted(
    ScheduleFormUpdateSubmitted event,
    Emitter<ScheduleFormState> emit,
  ) async {
    emit(
      state.copyWith(
        submitStatus: ScheduleFormSubmitStatus.submitting,
        submitError: null,
      ),
    );

    final result = await _updateScheduleUseCase(
      scheduleId: event.scheduleId,
      updateBody: event.body,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          submitStatus: ScheduleFormSubmitStatus.error,
          submitError: failure.userMessage,
        ),
      ),
      (schedule) => emit(
        state.copyWith(
          submitStatus: ScheduleFormSubmitStatus.success,
          schedule: schedule,
        ),
      ),
    );
  }

  void _onReset(ScheduleFormReset event, Emitter<ScheduleFormState> emit) {
    emit(const ScheduleFormState());
  }
}
