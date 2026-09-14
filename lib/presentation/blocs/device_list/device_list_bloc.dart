import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection_container.dart';
import '../../../domain/entities/device/device_entity.dart';
import '../../../domain/usecases/device/get_device_list_usecase.dart';
import '../../../core/utils/app_logger.dart';
import '../../../domain/usecases/device/invalidate_device_cache_usecase.dart';
import '../base/base_state.dart';

part 'device_list_event.dart';
part 'device_list_state.dart';

class DeviceListBloc extends Bloc<DeviceListEvent, DeviceListState> {
  final GetDeviceListUseCase _getDeviceListUseCase;
  final InvalidateDeviceCacheUseCase _invalidateDeviceCacheUseCase;
  final UserHolder _userHolder;

  DeviceListBloc({
    required GetDeviceListUseCase getDeviceListUseCase,
    required InvalidateDeviceCacheUseCase invalidateDeviceCacheUseCase, // 👈
    required UserHolder userHolder,
  }) : _getDeviceListUseCase = getDeviceListUseCase,
       _invalidateDeviceCacheUseCase = invalidateDeviceCacheUseCase,
       _userHolder = userHolder,
       super(const DeviceListInitial()) {
    on<DeviceListLoadRequested>(_onLoad);
    on<DeviceListRefreshRequested>(_onRefresh);
    on<DeviceListDeviceToggled>(_onDeviceToggled);
  }

  Future<void> _onLoad(
    DeviceListLoadRequested event,
    Emitter<DeviceListState> emit,
  ) async {
    emit(const DeviceListLoading());
    await _fetchData(emit);
  }

  Future<void> _onRefresh(
    DeviceListRefreshRequested event,
    Emitter<DeviceListState> emit,
  ) async {
    _invalidateDeviceCacheUseCase();
    await _fetchData(emit);
  }

  Future<void> _fetchData(Emitter<DeviceListState> emit) async {
    final personId = _userHolder.user?.personId;
    if (personId == null) {
      AppLogger.d('DeviceListBloc', 'No logged-in user found');
      emit(const DeviceListError('User not found. Please log in again.'));
      return;
    }
    AppLogger.d('DeviceListBloc', 'Fetching devices');
    final devicesResult = await _getDeviceListUseCase(personId);
    if (devicesResult.isLeft()) {
      final failure = devicesResult.fold((f) => f, (_) => null)!;
      AppLogger.d('DeviceListBloc', 'Devices fetch failed: ${failure.message}');
      emit(DeviceListError(failure.userMessage));
      return;
    }
    final devices = devicesResult.fold((_) => <DeviceEntity>[], (d) => d);
    AppLogger.d('DeviceListBloc', 'Loaded ${devices.length} devices');
    emit(DeviceListLoaded(devices: devices));
  }

  void _onDeviceToggled(
    DeviceListDeviceToggled event,
    Emitter<DeviceListState> emit,
  ) {
    if (state is! DeviceListLoaded) return;
    final current = state as DeviceListLoaded;

    final toggled = Set<String>.from(current.toggledImeis);
    if (toggled.contains(event.imei)) {
      toggled.remove(event.imei);
    } else {
      toggled.add(event.imei);
    }

    AppLogger.d(
      'DeviceListBloc',
      'Device ${event.imei} toggled → active: ${current.isDeviceActive(current.devices.firstWhere((d) => d.imei == event.imei))}',
    );

    emit(current.copyWith(toggledImeis: toggled));
  }
}
