import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection_container.dart';
import '../../../domain/entities/device/device_entity.dart';
import '../../../domain/repositories/device_repository.dart';
import '../../../domain/usecases/device/get_device_list_usecase.dart';

part 'device_list_event.dart';
part 'device_list_state.dart';

class DeviceListBloc extends Bloc<DeviceListEvent, DeviceListState> {
  final GetDeviceListUseCase _getDeviceListUseCase;
  final DeviceRepository _deviceRepository;

  DeviceListBloc({
    required GetDeviceListUseCase getDeviceListUseCase,
    required DeviceRepository deviceRepository,
  }) : _getDeviceListUseCase = getDeviceListUseCase,
       _deviceRepository = deviceRepository,

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
    _deviceRepository.invalidateCache(); // Clean call via domain interface
    await _fetchData(emit);
  }

  Future<void> _fetchData(Emitter<DeviceListState> emit) async {
    final personId = sl<UserHolder>().user?.personId;
    if (personId == null) {
      debugPrint('[DeviceListBloc] No logged-in user found');
      emit(const DeviceListError('User not found. Please log in again.'));
      return;
    }
    debugPrint('[DeviceListBloc] Fetching devices');
    final devicesResult = await _getDeviceListUseCase(personId);
    if (devicesResult.isLeft()) {
      final failure = devicesResult.fold((f) => f, (_) => null)!;
      debugPrint('[DeviceListBloc] Devices fetch failed: ${failure.message}');
      emit(DeviceListError(failure.userMessage));
      return;
    }
    final devices = devicesResult.fold((_) => <DeviceEntity>[], (d) => d);
    debugPrint('[DeviceListBloc] Loaded ${devices.length} devices');
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

    debugPrint(
      '[DeviceListBloc] Device ${event.imei} toggled → active: ${current.isDeviceActive(current.devices.firstWhere((d) => d.imei == event.imei))}',
    );

    emit(current.copyWith(toggledImeis: toggled));
  }
}
