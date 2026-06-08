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

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetAlertsUseCase _getAlertsUseCase;
  final GetDeviceListUseCase _getDeviceListUseCase;
  final DeviceRepository _deviceRepository;

  HomeBloc({
    required GetAlertsUseCase getAlertsUseCase,
    required GetDeviceListUseCase getDeviceListUseCase,
    required DeviceRepository deviceRepository,
  }) : _getAlertsUseCase = getAlertsUseCase,
       _getDeviceListUseCase = getDeviceListUseCase,
       _deviceRepository = deviceRepository,

       super(const HomeInitial()) {
    on<HomeLoadRequested>(_onLoad);
    on<HomeRefreshRequested>(_onRefresh);
    on<HomeDeviceToggled>(_onDeviceToggled);
  }

  Future<void> _onLoad(HomeLoadRequested event, Emitter<HomeState> emit) async {
    emit(const HomeLoading());
    await _fetchData(emit);
  }

  Future<void> _onRefresh(
    HomeRefreshRequested event,
    Emitter<HomeState> emit,
  ) async {
    (_deviceRepository as DeviceRepositoryImpl).invalidateCache(); // bust cache
    await _fetchData(emit);
  }

  Future<void> _fetchData(Emitter<HomeState> emit) async {
    debugPrint('[HomeBloc] Fetching alerts and devices');

    final alertsFuture = _getAlertsUseCase(NoParams());
    final devicesFuture = _getDeviceListUseCase(NoParams());

    final alertsResult = await alertsFuture;
    final devicesResult = await devicesFuture;

    // if either fails, emit error
    if (alertsResult.isLeft()) {
      final failure = alertsResult.fold((f) => f, (_) => null)!;
      debugPrint('[HomeBloc] Alerts fetch failed: ${failure.message}');
      emit(HomeError(failure.userMessage));
      return;
    }

    if (devicesResult.isLeft()) {
      final failure = devicesResult.fold((f) => f, (_) => null)!;
      debugPrint('[HomeBloc] Devices fetch failed: ${failure.message}');
      emit(HomeError(failure.userMessage));
      return;
    }

    // Now fold with perfect type safety! No casting required.
    final alerts = alertsResult.fold((_) => <AlertErrorEntity>[], (a) => a);

    final devices = devicesResult.fold((_) => <DeviceEntity>[], (d) => d);

    debugPrint(
      '[HomeBloc] Loaded ${alerts.length} alerts, ${devices.length} devices',
    );

    emit(HomeLoaded(alerts: alerts, devices: devices));
  }

  void _onDeviceToggled(HomeDeviceToggled event, Emitter<HomeState> emit) {
    if (state is! HomeLoaded) return;
    final current = state as HomeLoaded;

    final toggled = Set<String>.from(current.toggledImeis);
    if (toggled.contains(event.imei)) {
      toggled.remove(event.imei);
    } else {
      toggled.add(event.imei);
    }

    debugPrint(
      '[HomeBloc] Device ${event.imei} toggled → active: ${current.isDeviceActive(current.devices.firstWhere((d) => d.imei == event.imei))}',
    );

    emit(current.copyWith(toggledImeis: toggled));
  }
}
