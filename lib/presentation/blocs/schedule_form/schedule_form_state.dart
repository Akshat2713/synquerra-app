part of 'schedule_form_bloc.dart';

enum ScheduleFormMode { create, edit }

enum ScheduleFormLoadStatus { idle, loading, loaded, error }

enum ScheduleFormGeofenceStatus { idle, loading, loaded, error }

enum ScheduleFormSubmitStatus { idle, submitting, success, error }

class ScheduleFormState extends Equatable {
  final ScheduleFormMode mode;

  // Loading an existing schedule (edit mode prefill)
  final ScheduleFormLoadStatus loadStatus;
  final ScheduleEntity? schedule;
  final String? errorMessage;

  // Device -> geofence cascade
  final String? selectedDeviceId;
  final ScheduleFormGeofenceStatus geofenceStatus;
  final List<GeofenceEntity> geofences;
  final String? geofenceError;

  // Create/update submission
  final ScheduleFormSubmitStatus submitStatus;
  final String? submitError;

  const ScheduleFormState({
    this.mode = ScheduleFormMode.create,
    this.loadStatus = ScheduleFormLoadStatus.idle,
    this.schedule,
    this.errorMessage,
    this.selectedDeviceId,
    this.geofenceStatus = ScheduleFormGeofenceStatus.idle,
    this.geofences = const [],
    this.geofenceError,
    this.submitStatus = ScheduleFormSubmitStatus.idle,
    this.submitError,
  });

  bool get isEdit => mode == ScheduleFormMode.edit;
  bool get isLoadingSchedule => loadStatus == ScheduleFormLoadStatus.loading;
  bool get isLoadingGeofences =>
      geofenceStatus == ScheduleFormGeofenceStatus.loading;
  bool get isSubmitting => submitStatus == ScheduleFormSubmitStatus.submitting;
  bool get isSubmitSuccess => submitStatus == ScheduleFormSubmitStatus.success;

  ScheduleFormState copyWith({
    ScheduleFormMode? mode,
    ScheduleFormLoadStatus? loadStatus,
    ScheduleEntity? schedule,
    String? errorMessage,
    String? selectedDeviceId,
    ScheduleFormGeofenceStatus? geofenceStatus,
    List<GeofenceEntity>? geofences,
    String? geofenceError,
    ScheduleFormSubmitStatus? submitStatus,
    String? submitError,
  }) {
    return ScheduleFormState(
      mode: mode ?? this.mode,
      loadStatus: loadStatus ?? this.loadStatus,
      schedule: schedule ?? this.schedule,
      errorMessage: errorMessage,
      selectedDeviceId: selectedDeviceId ?? this.selectedDeviceId,
      geofenceStatus: geofenceStatus ?? this.geofenceStatus,
      geofences: geofences ?? this.geofences,
      geofenceError: geofenceError,
      submitStatus: submitStatus ?? this.submitStatus,
      submitError: submitError,
    );
  }

  @override
  List<Object?> get props => [
    mode,
    loadStatus,
    schedule,
    errorMessage,
    selectedDeviceId,
    geofenceStatus,
    geofences,
    geofenceError,
    submitStatus,
    submitError,
  ];
}
