import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../core/config/map_config.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/utils/app_logger.dart';
import '../../../domain/entities/analytics/analytics_entity.dart';
import '../../../domain/entities/analytics/analytics_filter.dart';
import '../../../domain/entities/device/device_entity.dart';
import '../../blocs/analytics/analytics_bloc.dart';
import '../../blocs/geofence/geofence_bloc.dart';
import '../../blocs/user_location/user_location_bloc.dart';
import '../../widgets/geofence_polygon_layer.dart';
import 'widgets/address_card.dart';
import 'widgets/empty_data_banner.dart';
import 'widgets/history_filter_chips.dart';
import 'widgets/last_updated_badge.dart';
import 'widgets/map_controls_column.dart';
import 'widgets/map_history_markers_layer.dart';
import 'widgets/map_history_polyline_layer.dart';
import 'widgets/map_user_location_layer.dart';
import 'widgets/timeline_slider.dart';
import 'widgets/view_tabs.dart';

class LocationScreen extends StatefulWidget {
  final DeviceEntity device;
  const LocationScreen({super.key, required this.device});
  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  late final MapController _mapController;
  late final UserLocationBloc _userLocationBloc;
  late final TileProvider _tileProvider;
  bool _showTimeline = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _userLocationBloc = sl<UserLocationBloc>();
    _tileProvider = sl<TileProvider>();
    context.read<GeofenceBloc>().add(GeofenceLoad(widget.device.id));
    AppLogger.d('LocationScreen', 'initState → deviceId: ${widget.device.id}');
  }

  LatLng get _defaultCenter => widget.device.hasLocation
      ? LatLng(widget.device.latitude!, widget.device.longitude!)
      : const LatLng(28.6172, 77.2094);

  @override
  void dispose() {
    _mapController.dispose();
    _userLocationBloc.close();
    super.dispose();
  }

  void _onViewChanged(bool history) {
    setState(() => _showTimeline = history);
  }

  void _fitMapToPoints(List<AnalyticsEntity> points) {
    final mappable = points.where((p) => p.hasLocation).toList();
    if (mappable.isEmpty) return;
    if (mappable.length == 1) {
      _mapController.move(
        LatLng(mappable.first.latitude!, mappable.first.longitude!),
        MapConfig.defaultZoom,
      );
      return;
    }
    if (!_showTimeline) {
      _mapController.move(
        LatLng(mappable.first.latitude!, mappable.first.longitude!),
        MapConfig.defaultZoom,
      );
      return;
    }
    final bounds = LatLngBounds.fromPoints(
      mappable.map((p) => LatLng(p.latitude!, p.longitude!)).toList(),
    );
    _mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(48)),
    );
    AppLogger.d('LocationScreen', 'fit map to ${mappable.length} points');
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_showTimeline,
      onPopInvokedWithResult: (didPop, result) async {
        if (_showTimeline) {
          setState(() => _showTimeline = false);
          context.read<AnalyticsBloc>().add(
            AnalyticsFilterChanged(
              deviceId: widget.device.id,
              filter: AnalyticsFilter.latest,
            ),
          );
        }
        if (didPop) return;
      },
      child: MultiBlocListener(
        listeners: [
          BlocListener<AnalyticsBloc, AnalyticsState>(
            listenWhen: (prev, curr) =>
                prev is! AnalyticsLoaded ||
                (curr is AnalyticsLoaded && prev.points != curr.points),
            listener: (context, state) {
              if (state is AnalyticsLoaded && state.mappablePoints.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => _fitMapToPoints(state.points),
                );
              }
            },
          ),
          BlocListener<UserLocationBloc, UserLocationState>(
            bloc: _userLocationBloc,
            listener: (context, state) {
              if (state is UserLocationLoaded) {
                _mapController.move(state.position, 16.0);
              }
              if (state is UserLocationError) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
          ),
        ],
        child: Stack(
          children: [
            RepaintBoundary(
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _defaultCenter,
                  initialZoom: MapConfig.defaultZoom,
                ),
                children: [
                  TileLayer(
                    urlTemplate: MapConfig.tileUrlTemplate,
                    userAgentPackageName: MapConfig.userAgentPackageName,
                    tileProvider: _tileProvider,
                  ),
                  GeofencePolygonLayer(onGeofenceTap: (_) {}),
                  const MapHistoryPolylineLayer(),
                  const MapHistoryMarkersLayer(),
                  MapUserLocationLayer(userLocationBloc: _userLocationBloc),
                ],
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 12,
              child: ViewTabs(
                isHistory: _showTimeline,
                onChanged: _onViewChanged,
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  BlocBuilder<AnalyticsBloc, AnalyticsState>(
                    buildWhen: (prev, curr) {
                      final p = prev is AnalyticsLoaded
                          ? prev.currentPoint?.deviceTimestamp
                          : null;
                      final c = curr is AnalyticsLoaded
                          ? curr.currentPoint?.deviceTimestamp
                          : null;
                      return p != c || prev.runtimeType != curr.runtimeType;
                    },
                    builder: (context, state) {
                      final loaded = state is AnalyticsLoaded ? state : null;
                      return LastUpdatedBadge(
                        timestamp: loaded?.currentPoint?.deviceTimestamp,
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  MapControlsColumn(
                    mapController: _mapController,
                    userLocationBloc: _userLocationBloc,
                    deviceCenter: _defaultCenter,
                  ),
                ],
              ),
            ),

            Positioned(
              top: MediaQuery.of(context).padding.top + 8 + 54,
              left: 12,
              child: BlocBuilder<AnalyticsBloc, AnalyticsState>(
                buildWhen: (prev, curr) {
                  final prevPoint = prev is AnalyticsLoaded
                      ? prev.currentPoint
                      : null;
                  final currPoint = curr is AnalyticsLoaded
                      ? curr.currentPoint
                      : null;
                  return prevPoint != currPoint ||
                      prev.runtimeType != curr.runtimeType;
                },
                builder: (context, state) {
                  final loaded = state is AnalyticsLoaded ? state : null;
                  return AddressCard(
                    point: loaded?.currentPoint,
                    isLoading: state is AnalyticsLoading,
                  );
                },
              ),
            ),

            Positioned.fill(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: BlocBuilder<AnalyticsBloc, AnalyticsState>(
                  buildWhen: (prev, curr) {
                    if (prev is AnalyticsLoaded && curr is AnalyticsLoaded) {
                      return prev.sliderIndex != curr.sliderIndex ||
                          prev.points != curr.points;
                    }
                    return prev.runtimeType != curr.runtimeType;
                  },
                  builder: (context, state) {
                    if (!_showTimeline) return const SizedBox.shrink();
                    final isLoading = state is AnalyticsLoading;
                    final loaded = state is AnalyticsLoaded ? state : null;
                    final activeFilter =
                        loaded?.activeFilter ?? AnalyticsFilter.lastHour;
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Use horizontal padding to constrain width safely
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: const EmptyDataBanner(),
                        ),
                        const SizedBox(height: 20),
                        Skeletonizer(
                          enabled: isLoading,
                          child: TimelineSlider(
                            points: loaded?.mappablePoints ?? const [],
                            currentIndex: loaded?.sliderIndex ?? 0,
                            onChanged: (i) => context.read<AnalyticsBloc>().add(
                              AnalyticsSliderChanged(i),
                            ),
                          ),
                        ),
                        HistoryFilterChips(
                          activeFilter: activeFilter,
                          isLoading: isLoading,
                          onFilterSelected: (f) =>
                              context.read<AnalyticsBloc>().add(
                                AnalyticsFilterChanged(
                                  deviceId: widget.device.id,
                                  filter: f,
                                ),
                              ),
                          onCustomSelected: (start, end) =>
                              context.read<AnalyticsBloc>().add(
                                AnalyticsCustomRangeSelected(
                                  deviceId: widget.device.id,
                                  startDate: start,
                                  endDate: end,
                                ),
                              ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
