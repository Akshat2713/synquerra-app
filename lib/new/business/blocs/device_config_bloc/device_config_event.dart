// lib/business/blocs/device_config_bloc/device_config_event.dart
part of 'device_config_bloc.dart';

abstract class DeviceConfigEvent extends Equatable {
  const DeviceConfigEvent();

  @override
  List<Object?> get props => [];
}

class DeviceConfigLoaded extends DeviceConfigEvent {}

class DeviceConfigIntervalUpdated extends DeviceConfigEvent {
  final String key;
  final String value;

  const DeviceConfigIntervalUpdated({required this.key, required this.value});

  @override
  List<Object?> get props => [key, value];
}
