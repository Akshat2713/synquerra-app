// lib/presentation/blocs/manage_devices/manage_devices_state.dart

part of 'manage_devices_bloc.dart';

abstract class ManageDevicesState extends BaseState {
  const ManageDevicesState();
}

class ManageDevicesInitial extends ManageDevicesState {
  const ManageDevicesInitial();
}

class ManageDevicesLoading extends ManageDevicesState with LoadingState {
  const ManageDevicesLoading();
}

class ManageDevicesLoaded extends ManageDevicesState {
  final List<RelationshipEntity> relationships;
  final String? processingDeviceId;
  final String? errorMessage;

  const ManageDevicesLoaded({
    required this.relationships,
    this.processingDeviceId,
    this.errorMessage,
  });

  ManageDevicesLoaded copyWith({
    List<RelationshipEntity>? relationships,
    String? processingDeviceId,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ManageDevicesLoaded(
      relationships: relationships ?? this.relationships,
      processingDeviceId: processingDeviceId,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [relationships, processingDeviceId, errorMessage];
}

class ManageDevicesError extends ManageDevicesState with ErrorState {
  @override
  final String message;

  const ManageDevicesError(this.message);

  @override
  List<Object?> get props => [message];
}
