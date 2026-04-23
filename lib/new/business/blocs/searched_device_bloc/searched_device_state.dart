// lib/business/blocs/searched_device_bloc/searched_device_state.dart
part of 'searched_device_bloc.dart';

/// Base class for searched device states
abstract class SearchedDeviceState extends Equatable {
  const SearchedDeviceState();

  @override
  List<Object?> get props => [];
}

/// Initial state - no searched device
class SearchedDeviceInitial extends SearchedDeviceState {}

/// Loading state
class SearchedDeviceLoading extends SearchedDeviceState {}

/// Data loaded successfully
class SearchedDeviceLoaded extends SearchedDeviceState {
  final String imei;
  final List<AnalyticsDataEntity> allPackets;
  final AnalyticsDataEntity? latestTelemetry;
  final List<AnalyticsDistanceEntity> distanceData;
  final AnalyticsHealthEntity? healthData;
  final AnalyticsUptimeEntity? uptimeData;

  const SearchedDeviceLoaded({
    required this.imei,
    required this.allPackets,
    this.latestTelemetry,
    required this.distanceData,
    this.healthData,
    this.uptimeData,
  });

  bool get hasData => allPackets.isNotEmpty;

  @override
  List<Object?> get props => [
    imei,
    allPackets,
    latestTelemetry,
    distanceData,
    healthData,
    uptimeData,
  ];
}

/// Error state
class SearchedDeviceError extends SearchedDeviceState {
  final String message;

  const SearchedDeviceError({required this.message});

  @override
  List<Object?> get props => [message];
}
