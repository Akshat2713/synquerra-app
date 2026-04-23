// lib/business/blocs/device_bloc/device_state.dart
part of 'device_bloc.dart';

/// Base class for device states
abstract class DeviceState extends Equatable {
  const DeviceState();

  @override
  List<Object?> get props => [];
}

/// Initial state - no data loaded
class DeviceInitial extends DeviceState {}

/// Loading state
class DeviceLoading extends DeviceState {}

/// Data loaded successfully
class DeviceLoaded extends DeviceState {
  final List<AnalyticsDataEntity> allPackets;
  final AnalyticsDataEntity? latestTelemetry;
  final List<AnalyticsDistanceEntity> distanceData;
  final AnalyticsHealthEntity? healthData;
  final AnalyticsUptimeEntity? uptimeData;
  final List<LatLng> historyPoints;
  final List<double> historyBearings;
  final List<String> historyTimestamps;
  final DateTime? lastDataTimestamp;

  const DeviceLoaded({
    required this.allPackets,
    this.latestTelemetry,
    required this.distanceData,
    this.healthData,
    this.uptimeData,
    this.historyPoints = const [],
    this.historyBearings = const [],
    this.historyTimestamps = const [],
    this.lastDataTimestamp,
  });

  bool get hasData => allPackets.isNotEmpty;

  bool get isOnline => latestTelemetry?.isOnline ?? false;

  @override
  List<Object?> get props => [
    allPackets,
    latestTelemetry,
    distanceData,
    healthData,
    uptimeData,
    historyPoints,
    historyBearings,
    historyTimestamps,
    lastDataTimestamp,
  ];
}

/// Error state
class DeviceError extends DeviceState {
  final String message;

  const DeviceError({required this.message});

  @override
  List<Object?> get props => [message];
}
