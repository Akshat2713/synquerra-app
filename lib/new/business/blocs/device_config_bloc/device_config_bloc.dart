// lib/business/blocs/device_config_bloc/device_config_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import '../../repositories/device_config_repository.dart';
import '../../failures/failure.dart';

part 'device_config_event.dart';
part 'device_config_state.dart';

class DeviceConfigBloc extends Bloc<DeviceConfigEvent, DeviceConfigState> {
  final DeviceConfigRepository _repository;

  DeviceConfigBloc({required DeviceConfigRepository repository})
    : _repository = repository,
      super(DeviceConfigInitial()) {
    on<DeviceConfigLoaded>(_onLoaded);
    on<DeviceConfigIntervalUpdated>(_onIntervalUpdated);
  }

  Future<void> _onLoaded(
    DeviceConfigLoaded event,
    Emitter<DeviceConfigState> emit,
  ) async {
    emit(DeviceConfigLoading());

    final result = await _repository.getAllSettings();

    result.fold(
      (failure) =>
          emit(DeviceConfigError(message: _mapFailureToMessage(failure))),
      (settings) => emit(DeviceConfigReady(settings: settings)),
    );
  }

  Future<void> _onIntervalUpdated(
    DeviceConfigIntervalUpdated event,
    Emitter<DeviceConfigState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DeviceConfigReady) return;

    final result = await _repository.saveSetting(event.key, event.value);

    result.fold(
      (failure) =>
          emit(DeviceConfigError(message: _mapFailureToMessage(failure))),
      (_) {
        final updatedSettings = Map<String, String>.from(currentState.settings);
        updatedSettings[event.key] = event.value;
        emit(DeviceConfigReady(settings: updatedSettings));
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is NetworkFailure) {
      return 'No internet connection.';
    } else if (failure is CacheFailure) {
      return 'Unable to save settings.';
    } else {
      return 'Something went wrong.';
    }
  }
}
