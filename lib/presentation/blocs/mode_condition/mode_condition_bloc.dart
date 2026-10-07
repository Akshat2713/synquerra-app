import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/app_logger.dart';
import '../../../data/datasources/graphql/mode_conditions_query.dart';
import '../../../domain/entities/geofence_mode/geofence_mode_entity.dart';
import '../../../domain/entities/geofence_mode/mode_condition_entity.dart';
import '../../../domain/failures/failure.dart';
import '../../../domain/usecases/mode_conditions/create_mode_condition_usecase.dart';
import '../../../domain/usecases/mode_conditions/delete_mode_condition_usecase.dart';
import '../../../domain/usecases/mode_conditions/get_geofence_modes_usecase.dart';
import '../../../domain/usecases/mode_conditions/get_mode_conditions_usecase.dart';
import '../../../domain/usecases/mode_conditions/update_mode_condition_usecase.dart';
import '../base/base_state.dart';

part 'mode_condition_event.dart';
part 'mode_condition_state.dart';

class ModeConditionBloc extends Bloc<ModeConditionEvent, ModeConditionState> {
  static const _tag = 'ModeConditionBloc';

  final GetModeConditionsUseCase _getModeConditionsUseCase;
  final CreateModeConditionUseCase _createModeConditionUseCase;
  final UpdateModeConditionUseCase _updateModeConditionUseCase;
  final DeleteModeConditionUseCase _deleteModeConditionUseCase;
  final GetGeofenceModesUseCase _getGeofenceModesUseCase;

  // Kept here so loading modes doesn't wipe conditions (and vice versa).
  List<ModeConditionEntity> _conditions = const [];
  List<GeofenceModeEntity> _modes = const [];
  String? _modesCategory;

  ModeConditionBloc({
    required GetModeConditionsUseCase getModeConditionsUseCase,
    required CreateModeConditionUseCase createModeConditionUseCase,
    required UpdateModeConditionUseCase updateModeConditionUseCase,
    required DeleteModeConditionUseCase deleteModeConditionUseCase,
    required GetGeofenceModesUseCase getGeofenceModesUseCase,
  }) : _getModeConditionsUseCase = getModeConditionsUseCase,
       _createModeConditionUseCase = createModeConditionUseCase,
       _updateModeConditionUseCase = updateModeConditionUseCase,
       _deleteModeConditionUseCase = deleteModeConditionUseCase,
       _getGeofenceModesUseCase = getGeofenceModesUseCase,
       super(const ModeConditionInitial()) {
    on<ModeConditionLoad>(_onLoad);
    on<ModeConditionLoadModes>(_onLoadModes);
    on<ModeConditionCreate>(_onCreate);
    on<ModeConditionUpdate>(_onUpdate);
    on<ModeConditionDelete>(_onDelete);
  }

  /// Loads conditions for BOTH types (cloud geofence + device geofence).
  Future<void> _onLoad(
    ModeConditionLoad event,
    Emitter<ModeConditionState> emit,
  ) async {
    AppLogger.d(_tag, 'Load → deviceId: ${event.deviceId}');
    emit(const ModeConditionLoading());

    final results = await Future.wait([
      _getModeConditionsUseCase(
        GetModeConditionsParams(
          deviceId: event.deviceId,
          conditionType: ModeConditionType.geofence,
        ),
      ),
      _getModeConditionsUseCase(
        GetModeConditionsParams(
          deviceId: event.deviceId,
          conditionType: ModeConditionType.deviceGeofence,
        ),
      ),
    ]);

    Failure? failure;
    final all = <ModeConditionEntity>[];
    for (final r in results) {
      r.fold((f) => failure ??= f, all.addAll);
    }

    if (failure != null) {
      AppLogger.d(_tag, 'Load failed: ${failure!.message}');
      emit(ModeConditionError(failure!.userMessage));
      return;
    }

    _conditions = all;
    AppLogger.d(_tag, 'Loaded ${all.length} mode conditions');
    emit(
      ModeConditionLoaded(
        conditions: _conditions,
        modes: _modes,
        modesCategory: _modesCategory,
      ),
    );
  }

  /// Loads modes for the dropdown. [category] decides which modes come back
  /// (cloud geofence vs device geofence).
  Future<void> _onLoadModes(
    ModeConditionLoadModes event,
    Emitter<ModeConditionState> emit,
  ) async {
    AppLogger.d(_tag, 'LoadModes → category: ${event.category}');
    _modes = const [];
    _modesCategory = null;
    emit(ModeConditionLoaded(conditions: _conditions)); // clears stale modes
    final result = await _getGeofenceModesUseCase(
      GetGeofenceModesParams(category: event.category),
    );
    result.fold(
      (failure) => emit(ModeConditionOperationError(failure.userMessage)),
      (modes) {
        _modes = modes;
        _modesCategory = event.category;
        emit(
          ModeConditionLoaded(
            conditions: _conditions,
            modes: _modes,
            modesCategory: _modesCategory,
          ),
        );
      },
    );
  }

  Future<void> _onCreate(
    ModeConditionCreate event,
    Emitter<ModeConditionState> emit,
  ) async {
    AppLogger.d(_tag, 'Create → deviceId: ${event.deviceId}');
    emit(const ModeConditionOperationLoading());
    final result = await _createModeConditionUseCase(
      CreateModeConditionParams(
        modeId: event.modeId,
        deviceId: event.deviceId,
        conditionType: event.conditionType,
        enabled: event.enabled,
        config: event.config,
      ),
    );
    result.fold(
      (failure) => emit(ModeConditionOperationError(failure.userMessage)),
      (_) {
        emit(const ModeConditionCreated());
        add(ModeConditionLoad(event.deviceId));
      },
    );
  }

  Future<void> _onUpdate(
    ModeConditionUpdate event,
    Emitter<ModeConditionState> emit,
  ) async {
    AppLogger.d(_tag, 'Update → conditionId: ${event.conditionId}');
    emit(const ModeConditionOperationLoading());
    final result = await _updateModeConditionUseCase(
      UpdateModeConditionParams(
        conditionId: event.conditionId,
        modeId: event.modeId,
        deviceId: event.deviceId,
        conditionType: event.conditionType,
        enabled: event.enabled,
        config: event.config,
      ),
    );
    result.fold(
      (failure) => emit(ModeConditionOperationError(failure.userMessage)),
      (_) {
        emit(const ModeConditionUpdated());
        add(ModeConditionLoad(event.deviceId));
      },
    );
  }

  Future<void> _onDelete(
    ModeConditionDelete event,
    Emitter<ModeConditionState> emit,
  ) async {
    AppLogger.d(_tag, 'Delete → conditionId: ${event.conditionId}');
    emit(const ModeConditionOperationLoading());
    final result = await _deleteModeConditionUseCase(event.conditionId);
    result.fold(
      (failure) => emit(ModeConditionOperationError(failure.userMessage)),
      (_) {
        emit(const ModeConditionDeleted());
        add(ModeConditionLoad(event.deviceId));
      },
    );
  }
}
