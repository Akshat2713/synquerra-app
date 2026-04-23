// lib/business/blocs/device_config_bloc/device_config_state.dart
part of 'device_config_bloc.dart';

abstract class DeviceConfigState extends Equatable {
  const DeviceConfigState();

  @override
  List<Object?> get props => [];
}

class DeviceConfigInitial extends DeviceConfigState {}

class DeviceConfigLoading extends DeviceConfigState {}

class DeviceConfigReady extends DeviceConfigState {
  final Map<String, String> settings;

  const DeviceConfigReady({required this.settings});

  @override
  List<Object?> get props => [settings];
}

class DeviceConfigError extends DeviceConfigState {
  final String message;

  const DeviceConfigError({required this.message});

  @override
  List<Object?> get props => [message];
}
