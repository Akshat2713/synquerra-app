import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/schedule/schedule_override_entity.dart';
import '../../../domain/usecases/schedule/get_schedule_overrides_usecase.dart';
import '../../../domain/usecases/schedule/create_schedule_override_usecase.dart';
import '../../../domain/usecases/schedule/update_schedule_override_usecase.dart';
import '../../../domain/usecases/schedule/delete_schedule_override_usecase.dart';

part 'schedule_overrides_event.dart';
part 'schedule_overrides_state.dart';

class ScheduleOverridesBloc
    extends Bloc<ScheduleOverridesEvent, ScheduleOverridesState> {
  final GetScheduleOverridesUseCase _getScheduleOverridesUseCase;
  final CreateScheduleOverrideUseCase _createScheduleOverrideUseCase;
  final UpdateScheduleOverrideUseCase _updateScheduleOverrideUseCase;
  final DeleteScheduleOverrideUseCase _deleteScheduleOverrideUseCase;

  ScheduleOverridesBloc({
    required GetScheduleOverridesUseCase getScheduleOverridesUseCase,
    required CreateScheduleOverrideUseCase createScheduleOverrideUseCase,
    required UpdateScheduleOverrideUseCase updateScheduleOverrideUseCase,
    required DeleteScheduleOverrideUseCase deleteScheduleOverrideUseCase,
  }) : _getScheduleOverridesUseCase = getScheduleOverridesUseCase,
       _createScheduleOverrideUseCase = createScheduleOverrideUseCase,
       _updateScheduleOverrideUseCase = updateScheduleOverrideUseCase,
       _deleteScheduleOverrideUseCase = deleteScheduleOverrideUseCase,
       super(const ScheduleOverridesState()) {
    on<ScheduleOverridesLoadRequested>(_onLoad);
    on<ScheduleOverrideCreated>(_onCreate);
    on<ScheduleOverrideUpdated>(_onUpdate);
    on<ScheduleOverrideDeleted>(_onDelete);
  }

  Future<void> _onLoad(
    ScheduleOverridesLoadRequested event,
    Emitter<ScheduleOverridesState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ScheduleOverridesStatus.loading,
        errorMessage: null,
      ),
    );

    final result = await _getScheduleOverridesUseCase(
      scheduleId: event.scheduleId,
      startDate: event.startDate,
      endDate: event.endDate,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ScheduleOverridesStatus.error,
          errorMessage: failure.userMessage,
        ),
      ),
      (overrides) => emit(
        state.copyWith(
          status: ScheduleOverridesStatus.loaded,
          overrides: overrides,
          errorMessage: null,
        ),
      ),
    );
  }

  Future<void> _onCreate(
    ScheduleOverrideCreated event,
    Emitter<ScheduleOverridesState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, actionError: null));

    final result = await _createScheduleOverrideUseCase(
      CreateScheduleOverrideParams(
        scheduleId: event.scheduleId,
        overrideBody: event.overrideBody,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(isSubmitting: false, actionError: failure.userMessage),
      ),
      (override) => emit(
        state.copyWith(
          isSubmitting: false,
          overrides: [...state.overrides, override],
          actionError: null,
          lastAction: ScheduleOverrideAction.created,
        ),
      ),
    );
  }

  Future<void> _onUpdate(
    ScheduleOverrideUpdated event,
    Emitter<ScheduleOverridesState> emit,
  ) async {
    emit(
      state.copyWith(
        processingIds: {...state.processingIds, event.overrideId},
        actionError: null,
      ),
    );

    final result = await _updateScheduleOverrideUseCase(
      scheduleId: event.scheduleId,
      overrideId: event.overrideId,
      updateBody: event.updateBody,
    );

    result.fold(
      (failure) {
        final processing = {...state.processingIds}..remove(event.overrideId);
        emit(
          state.copyWith(
            processingIds: processing,
            actionError: failure.userMessage,
          ),
        );
      },
      (updated) {
        final processing = {...state.processingIds}..remove(event.overrideId);
        final overrides = state.overrides
            .map((o) => o.id == updated.id ? updated : o)
            .toList(growable: false);
        emit(
          state.copyWith(
            processingIds: processing,
            overrides: overrides,
            lastAction: ScheduleOverrideAction.updated,
          ),
        );
      },
    );
  }

  Future<void> _onDelete(
    ScheduleOverrideDeleted event,
    Emitter<ScheduleOverridesState> emit,
  ) async {
    emit(
      state.copyWith(
        processingIds: {...state.processingIds, event.overrideId},
        actionError: null,
      ),
    );

    final result = await _deleteScheduleOverrideUseCase(
      scheduleId: event.scheduleId,
      overrideId: event.overrideId,
    );

    result.fold(
      (failure) {
        final processing = {...state.processingIds}..remove(event.overrideId);
        emit(
          state.copyWith(
            processingIds: processing,
            actionError: failure.userMessage,
          ),
        );
      },
      (_) {
        final processing = {...state.processingIds}..remove(event.overrideId);
        final overrides = state.overrides
            .where((o) => o.id != event.overrideId)
            .toList(growable: false);
        emit(
          state.copyWith(
            processingIds: processing,
            overrides: overrides,
            lastAction: ScheduleOverrideAction.deleted,
          ),
        );
      },
    );
  }
}
