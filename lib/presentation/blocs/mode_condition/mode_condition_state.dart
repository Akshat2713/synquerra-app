part of 'mode_condition_bloc.dart';

abstract class ModeConditionState extends BaseState {
  const ModeConditionState();
}

class ModeConditionInitial extends ModeConditionState {
  const ModeConditionInitial();
}

class ModeConditionLoading extends ModeConditionState with LoadingState {
  const ModeConditionLoading();
}

class ModeConditionLoaded extends ModeConditionState {
  final List<ModeConditionEntity> conditions;
  final List<GeofenceModeEntity> modes;
  final String? modesCategory; // category the current [modes] were loaded for

  const ModeConditionLoaded({
    this.conditions = const [],
    this.modes = const [],
    this.modesCategory,
  });

  /// Finds the condition attached to a geofence, or null if it has none.
  /// [geofenceKey] is what is stored in config['geofence_id'].
  ModeConditionEntity? conditionFor({
    required String geofenceKey,
    required String conditionType,
  }) {
    for (final c in conditions) {
      if (c.conditionType == conditionType && c.geofenceId == geofenceKey) {
        return c;
      }
    }
    return null;
  }

  @override
  List<Object?> get props => [conditions, modes, modesCategory];
}

class ModeConditionError extends ModeConditionState with ErrorState {
  @override
  final String message;
  const ModeConditionError(this.message);
  @override
  List<Object?> get props => [message];
}

class ModeConditionOperationLoading extends ModeConditionState
    with LoadingState {
  const ModeConditionOperationLoading();
}

class ModeConditionCreated extends ModeConditionState {
  const ModeConditionCreated();
}

class ModeConditionUpdated extends ModeConditionState {
  const ModeConditionUpdated();
}

class ModeConditionDeleted extends ModeConditionState {
  const ModeConditionDeleted();
}

class ModeConditionOperationError extends ModeConditionState with ErrorState {
  @override
  final String message;
  const ModeConditionOperationError(this.message);
  @override
  List<Object?> get props => [message];
}
