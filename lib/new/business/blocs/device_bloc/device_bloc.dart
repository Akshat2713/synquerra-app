// lib/business/blocs/device_bloc/device_bloc.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import 'package:latlong2/latlong.dart';
import '../../repositories/device_repository.dart';
import '../../entities/analytics_entity.dart';
import '../../failures/failure.dart';

part 'device_event.dart';
part 'device_state.dart';

class DeviceBloc extends Bloc<DeviceEvent, DeviceState> {
  final DeviceRepository _deviceRepository;

  DeviceBloc({required DeviceRepository deviceRepository})
    : _deviceRepository = deviceRepository,
      super(DeviceInitial()) {
    on<DeviceDataRequested>(_onDataRequested);
    on<DeviceRefreshRequested>(_onRefreshRequested);
    on<DeviceHistoryRequested>(_onHistoryRequested);
    on<DeviceDataCleared>(_onDataCleared);
  }

  /// Handle data request
  Future<void> _onDataRequested(
    DeviceDataRequested event,
    Emitter<DeviceState> emit,
  ) async {
    emit(DeviceLoading());

    final result = await _deviceRepository.getAnalyticsByImei(event.imei);

    await result.fold(
      (failure) async {
        emit(DeviceError(message: _mapFailureToMessage(failure)));
      },
      (packets) async {
        final latestTelemetry = _findLatestValidTelemetry(packets);
        final lastDataTimestamp = latestTelemetry?.timestamp;

        emit(
          DeviceLoaded(
            allPackets: packets,
            latestTelemetry: latestTelemetry,
            distanceData: const [],
            healthData: null,
            uptimeData: null,
            lastDataTimestamp: lastDataTimestamp,
          ),
        );

        // Load secondary data AFTER emitting initial state
        await _loadSecondaryData(event.imei, emit);
      },
    );
  }

  /// Handle refresh request
  Future<void> _onRefreshRequested(
    DeviceRefreshRequested event,
    Emitter<DeviceState> emit,
  ) async {
    final currentState = state;
    if (currentState is DeviceLoaded) {
      // emit(DeviceLoading());
    }

    final result = await _deviceRepository.refreshDevice(event.imei);

    await result.fold(
      (failure) async {
        emit(DeviceError(message: _mapFailureToMessage(failure)));
      },
      (packets) async {
        final latestTelemetry = _findLatestValidTelemetry(packets);
        final lastDataTimestamp = latestTelemetry?.timestamp;

        emit(
          DeviceLoaded(
            allPackets: packets,
            latestTelemetry: latestTelemetry,
            distanceData: currentState is DeviceLoaded
                ? currentState.distanceData
                : const [],
            healthData: currentState is DeviceLoaded
                ? currentState.healthData
                : null,
            uptimeData: currentState is DeviceLoaded
                ? currentState.uptimeData
                : null,
            lastDataTimestamp: lastDataTimestamp,
          ),
        );

        await _loadSecondaryData(event.imei, emit);
      },
    );
  }

  /// Handle history request
  Future<void> _onHistoryRequested(
    DeviceHistoryRequested event,
    Emitter<DeviceState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DeviceLoaded) return;

    // Process history points from existing packets
    final historyResult = _processHistoryPoints(
      currentState.allPackets,
      currentState.latestTelemetry,
    );

    emit(
      DeviceLoaded(
        allPackets: currentState.allPackets,
        latestTelemetry: currentState.latestTelemetry,
        distanceData: currentState.distanceData,
        healthData: currentState.healthData,
        uptimeData: currentState.uptimeData,
        historyPoints: historyResult.points,
        historyBearings: historyResult.bearings,
        historyTimestamps: historyResult.timestamps,
        lastDataTimestamp: currentState.lastDataTimestamp,
      ),
    );
  }

  /// Handle data cleared (logout)
  void _onDataCleared(DeviceDataCleared event, Emitter<DeviceState> emit) {
    emit(DeviceInitial());
  }

  /// Load secondary data (distance, health, uptime)
  Future<void> _loadSecondaryData(
    String imei,
    Emitter<DeviceState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DeviceLoaded) return;

    final distanceResult = await _deviceRepository.getDistance24(imei);
    final healthResult = await _deviceRepository.getHealth(imei);
    final uptimeResult = await _deviceRepository.getUptime(imei);

    List<AnalyticsDistanceEntity> distanceData = currentState.distanceData;
    AnalyticsHealthEntity? healthData = currentState.healthData;
    AnalyticsUptimeEntity? uptimeData = currentState.uptimeData;

    distanceResult.fold((failure) => null, (data) => distanceData = data);

    healthResult.fold((failure) => null, (data) => healthData = data);

    uptimeResult.fold((failure) => null, (data) => uptimeData = data);

    // Only emit if the state is still DeviceLoaded
    if (state is DeviceLoaded) {
      emit(
        DeviceLoaded(
          allPackets: currentState.allPackets,
          latestTelemetry: currentState.latestTelemetry,
          distanceData: distanceData,
          healthData: healthData,
          uptimeData: uptimeData,
          historyPoints: currentState.historyPoints,
          historyBearings: currentState.historyBearings,
          historyTimestamps: currentState.historyTimestamps,
          lastDataTimestamp: currentState.lastDataTimestamp,
        ),
      );
    }
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

  /// Process history points from packets
  _HistoryResult _processHistoryPoints(
    List<AnalyticsDataEntity> packets,
    AnalyticsDataEntity? latestTelemetry,
  ) {
    if (packets.isEmpty || latestTelemetry == null) {
      return _HistoryResult(points: [], bearings: [], timestamps: []);
    }

    final now = DateTime.now();
    final cutoff = now.subtract(const Duration(hours: 24));

    List<LatLng> points = [];
    List<double> bearings = [];
    List<String> timestamps = [];
    LatLng nextPoint = LatLng(
      latestTelemetry.latitude!,
      latestTelemetry.longitude!,
    );

    for (int i = packets.length - 5; i >= 0; i -= 5) {
      final packet = packets[i];
      if (!packet.hasValidLocation || packet.timestamp.isBefore(cutoff)) {
        continue;
      }

      final point = LatLng(packet.latitude!, packet.longitude!);
      points.add(point);

      // Calculate bearing
      final bearing = _calculateBearing(point, nextPoint);
      bearings.add(bearing);
      timestamps.add(packet.timestamp.toIso8601String());
      nextPoint = point;
    }

    return _HistoryResult(
      points: points,
      bearings: bearings,
      timestamps: timestamps,
    );
  }

  /// Calculate bearing between two points
  double _calculateBearing(LatLng from, LatLng to) {
    final rad = pi / 180;
    final lat1 = from.latitude * rad;
    final lon1 = from.longitude * rad;
    final lat2 = to.latitude * rad;
    final lon2 = to.longitude * rad;

    final dLon = lon2 - lon1;
    final y = sin(dLon) * cos(lat2);
    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);

    return atan2(y, x);
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

/// Helper class for history processing result
class _HistoryResult {
  final List<LatLng> points;
  final List<double> bearings;
  final List<String> timestamps;

  _HistoryResult({
    required this.points,
    required this.bearings,
    required this.timestamps,
  });
}
