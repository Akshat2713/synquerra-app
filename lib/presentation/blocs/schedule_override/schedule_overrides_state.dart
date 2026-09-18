part of 'schedule_overrides_bloc.dart';

enum ScheduleOverridesStatus { initial, loading, loaded, error }

enum ScheduleOverrideAction { none, created, updated, deleted }

class ScheduleOverridesState extends Equatable {
  final ScheduleOverridesStatus status;
  final List<ScheduleOverrideEntity> overrides;
  final Set<String> processingIds;
  final bool isSubmitting;
  final String? errorMessage;
  final String? actionError;
  final ScheduleOverrideAction lastAction;

  const ScheduleOverridesState({
    this.status = ScheduleOverridesStatus.initial,
    this.overrides = const [],
    this.processingIds = const {},
    this.isSubmitting = false,
    this.errorMessage,
    this.actionError,
    this.lastAction = ScheduleOverrideAction.none,
  });

  ScheduleOverridesState copyWith({
    ScheduleOverridesStatus? status,
    List<ScheduleOverrideEntity>? overrides,
    Set<String>? processingIds,
    bool? isSubmitting,
    String? errorMessage,
    String? actionError,
    ScheduleOverrideAction? lastAction,
  }) {
    return ScheduleOverridesState(
      status: status ?? this.status,
      overrides: overrides ?? this.overrides,
      processingIds: processingIds ?? this.processingIds,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
      actionError: actionError,
      lastAction: lastAction ?? ScheduleOverrideAction.none,
    );
  }

  @override
  List<Object?> get props => [
    status,
    overrides,
    processingIds,
    isSubmitting,
    errorMessage,
    actionError,
    lastAction,
  ];
}
