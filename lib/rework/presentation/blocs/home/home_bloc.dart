import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/alerts/alert_entity.dart';
import '../../../domain/entities/device/device_entity.dart';
import '../../../domain/failures/failure.dart';
import '../../../domain/usecases/alerts/get_alerts_usecase.dart';
import '../../../domain/usecases/device/get_device_list_usecase.dart';
import '../../../domain/usecases/base_usecase.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetAlertsUseCase _getAlertsUseCase;
  final GetDeviceListUseCase _getDeviceListUseCase;

  HomeBloc({
    required GetAlertsUseCase getAlertsUseCase,
    required GetDeviceListUseCase getDeviceListUseCase,
  }) : _getAlertsUseCase = getAlertsUseCase,
       _getDeviceListUseCase = getDeviceListUseCase,
       super(HomeInitial()) {
    on<HomeLoadRequested>(_onLoad);
    on<HomeRefreshRequested>(_onRefresh);
    on<HomeDeviceToggled>(_onDeviceToggled);
  }

  Future<void> _onLoad(HomeLoadRequested event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    await _fetchData(emit);
  }

  Future<void> _onRefresh(
    HomeRefreshRequested event,
    Emitter<HomeState> emit,
  ) async {
    // keep existing data visible while refreshing
    await _fetchData(emit);
  }

  Future<void> _fetchData(Emitter<HomeState> emit) async {
    debugPrint('[HomeBloc] Fetching alerts and devices simultaneously');

    // Fire both calls at the same time
    final results = await Future.wait([
      _getAlertsUseCase(NoParams()),
      _getDeviceListUseCase(NoParams()),
    ]);

    final alertsResult = results[0];
    final devicesResult = results[1];

    // if either fails, emit error
    if (alertsResult.isLeft()) {
      final failure = alertsResult.fold((f) => f, (_) => null)!;
      debugPrint('[HomeBloc] Alerts fetch failed: ${failure.message}');
      emit(HomeError(_mapFailure(failure)));
      return;
    }

    if (devicesResult.isLeft()) {
      final failure = devicesResult.fold((f) => f, (_) => null)!;
      debugPrint('[HomeBloc] Devices fetch failed: ${failure.message}');
      emit(HomeError(_mapFailure(failure)));
      return;
    }

    final alerts = alertsResult.fold(
      (_) => <AlertEntity>[],
      (a) => a as List<AlertEntity>,
    );
    final devices = devicesResult.fold(
      (_) => <DeviceEntity>[],
      (d) => d as List<DeviceEntity>,
    );

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

  String _mapFailure(Failure failure) {
    if (failure is NetworkFailure) return 'No internet connection.';
    if (failure is ServerFailure)
      return failure.message.isNotEmpty ? failure.message : 'Server error.';
    return 'Something went wrong.';
  }
}
