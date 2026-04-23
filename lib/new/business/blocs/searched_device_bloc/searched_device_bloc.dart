// lib/business/blocs/searched_device_bloc/searched_device_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import '../../repositories/device_repository.dart';
import '../../entities/analytics_entity.dart';
import '../../failures/failure.dart';

part 'searched_device_event.dart';
part 'searched_device_state.dart';

class SearchedDeviceBloc
    extends Bloc<SearchedDeviceEvent, SearchedDeviceState> {
  final DeviceRepository _deviceRepository;

  SearchedDeviceBloc({required DeviceRepository deviceRepository})
    : _deviceRepository = deviceRepository,
      super(SearchedDeviceInitial()) {
    on<SearchedDeviceFetchRequested>(_onFetchRequested);
    on<SearchedDeviceCleared>(_onCleared);
  }

  /// Handle fetch request
  Future<void> _onFetchRequested(
    SearchedDeviceFetchRequested event,
    Emitter<SearchedDeviceState> emit,
  ) async {
    emit(SearchedDeviceLoading());

    // Fetch all data one by one to avoid type issues
    final analyticsResult = await _deviceRepository.getAnalyticsByImei(
      event.imei,
    );

    Either<Failure, List<AnalyticsDistanceEntity>>? distanceResult;
    Either<Failure, AnalyticsHealthEntity?>? healthResult;
    Either<Failure, AnalyticsUptimeEntity?>? uptimeResult;

    if (analyticsResult.isRight()) {
      final results = await Future.wait([
        _deviceRepository.getDistance24(event.imei),
        _deviceRepository.getHealth(event.imei),
        _deviceRepository.getUptime(event.imei),
      ]);

      distanceResult =
          results[0] as Either<Failure, List<AnalyticsDistanceEntity>>;
      healthResult = results[1] as Either<Failure, AnalyticsHealthEntity?>;
      uptimeResult = results[2] as Either<Failure, AnalyticsUptimeEntity?>;
    }

    // Check for errors
    Failure? failure;
    analyticsResult.fold((f) => failure = f, (_) => null);
    distanceResult?.fold((f) => failure = f, (_) => null);
    healthResult?.fold((f) => failure = f, (_) => null);
    uptimeResult?.fold((f) => failure = f, (_) => null);

    if (failure != null) {
      emit(SearchedDeviceError(message: _mapFailureToMessage(failure!)));
      return;
    }

    // Extract data
    final allPackets = analyticsResult.getOrElse(() => []);
    final latestTelemetry = _findLatestValidTelemetry(allPackets);

    List<AnalyticsDistanceEntity> distanceData = const [];
    if (distanceResult != null) {
      distanceData = distanceResult.getOrElse(() => []);
    }

    AnalyticsHealthEntity? healthData;
    if (healthResult != null) {
      healthData = healthResult.getOrElse(() => null);
    }

    AnalyticsUptimeEntity? uptimeData;
    if (uptimeResult != null) {
      uptimeData = uptimeResult.getOrElse(() => null);
    }

    emit(
      SearchedDeviceLoaded(
        imei: event.imei,
        allPackets: allPackets,
        latestTelemetry: latestTelemetry,
        distanceData: distanceData,
        healthData: healthData,
        uptimeData: uptimeData,
      ),
    );
  }

  /// Handle clear
  void _onCleared(
    SearchedDeviceCleared event,
    Emitter<SearchedDeviceState> emit,
  ) {
    emit(SearchedDeviceInitial());
  }

  /// Find the latest valid telemetry point with location
  AnalyticsDataEntity? _findLatestValidTelemetry(
    List<AnalyticsDataEntity> packets,
  ) {
    for (int i = packets.length - 1; i >= 0; i--) {
      final packet = packets[i];
      if (packet.hasValidLocation) {
        return packet;
      }
    }
    return packets.isNotEmpty ? packets.last : null;
  }

  /// Map failure to user-friendly message
  String _mapFailureToMessage(Failure failure) {
    if (failure is NetworkFailure) {
      return 'No internet connection. Please check your network.';
    } else if (failure is ServerFailure) {
      return failure.message.isNotEmpty
          ? failure.message
          : 'Server error. Please try again later.';
    } else {
      return 'Something went wrong. Please try again.';
    }
  }
}
