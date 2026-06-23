import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories_impl/device_repository_impl.dart';
import '../../../domain/entities/alerts/alert_error_entity.dart';
import '../../../domain/entities/device/device_entity.dart';
import '../../../domain/repositories/device_repository.dart';
import '../../../domain/usecases/alerts/get_alerts_usecase.dart';
import '../../../domain/usecases/device/get_device_list_usecase.dart';
import '../../../domain/usecases/base_usecase.dart';

part 'device_list_event.dart';
part 'device_list_state.dart';

class DeviceListBloc extends Bloc<DeviceListEvent, DeviceListState> {
  final GetAlertsUseCase _getAlertsUseCase;
  final GetDeviceListUseCase _getDeviceListUseCase;
  final DeviceRepository _deviceRepository;

  DeviceListBloc({
    required GetAlertsUseCase getAlertsUseCase,
    required GetDeviceListUseCase getDeviceListUseCase,
    required DeviceRepository deviceRepository,
  }) : _getAlertsUseCase = getAlertsUseCase,
       _getDeviceListUseCase = getDeviceListUseCase,
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
    (_deviceRepository as DeviceRepositoryImpl).invalidateCache(); // bust cache
    await _fetchData(emit);
  }

  Future<void> _fetchData(Emitter<DeviceListState> emit) async {
    debugPrint('[DeviceListBloc] Fetching alerts and devices');

    final alertsFuture = _getAlertsUseCase(NoParams());
    final devicesFuture = _getDeviceListUseCase(NoParams());

    final alertsResult = await alertsFuture;
    final devicesResult = await devicesFuture;

    // if either fails, emit error
    if (alertsResult.isLeft()) {
      final failure = alertsResult.fold((f) => f, (_) => null)!;
      debugPrint('[DeviceListBloc] Alerts fetch failed: ${failure.message}');
      emit(DeviceListError(failure.userMessage));
      return;
    }

    if (devicesResult.isLeft()) {
      final failure = devicesResult.fold((f) => f, (_) => null)!;
      debugPrint('[DeviceListBloc] Devices fetch failed: ${failure.message}');
      emit(DeviceListError(failure.userMessage));
      return;
    }

    // Now fold with perfect type safety! No casting required.
    final alerts = alertsResult.fold((_) => <AlertErrorEntity>[], (a) => a);

    final devices = devicesResult.fold((_) => <DeviceEntity>[], (d) => d);

    debugPrint(
      '[DeviceListBloc] Loaded ${alerts.length} alerts, ${devices.length} devices',
    );

    emit(DeviceListLoaded(alerts: alerts, devices: devices));
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
