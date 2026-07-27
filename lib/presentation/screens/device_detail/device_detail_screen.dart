// presentation/screens/device_detail/device_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../data/network/map_tile_config.dart';
import '../../../domain/entities/analytics/analytics_entity.dart';
import '../../../domain/entities/device/device_entity.dart';
import '../../blocs/analytics/analytics_bloc.dart';
import '../../blocs/geofence/geofence_bloc.dart';
import '../../widgets/geofence_polygon_layer.dart';
import 'widgets/map_icon_button.dart';
import 'widgets/timeline_slider.dart';
// imports — remove analytics_filter_sheet import, add:
import 'widgets/view_tabs.dart';
import 'widgets/history_filter_chips.dart';

class DeviceDetailScreen extends StatefulWidget {
  final DeviceEntity device;
  const DeviceDetailScreen({super.key, required this.device});

  @override
  State<DeviceDetailScreen> createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends State<DeviceDetailScreen> {
  late final MapController _mapController;
  bool _showTimeline = false;
  // bool _mapReady = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    context.read<AnalyticsBloc>().add(AnalyticsLoadDefault(widget.device.id));
    context.read<GeofenceBloc>().add(GeofenceLoad(widget.device.id));
    debugPrint(
      '[DeviceDetailScreen] initState → deviceId: ${widget.device.id}',
    );
  }

  LatLng get _defaultCenter => widget.device.hasLocation
      ? LatLng(widget.device.latitude!, widget.device.longitude!)
      : const LatLng(28.6172, 77.2094);

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  // delete _openFilterSheet() entirely, replace with:
  void _onViewChanged(bool history) {
    setState(() => _showTimeline = history);
    context.read<AnalyticsBloc>().add(
      AnalyticsFilterChanged(
        deviceId: widget.device.id,
        filter: history ? AnalyticsFilter.lastHour : AnalyticsFilter.latest,
      ),
    );
  }

  void _fitMapToPoints(List<AnalyticsEntity> points) {
    final mappable = points.where((p) => p.hasLocation).toList();
    if (mappable.isEmpty) return;

    // Single point or latest — just move, never fitCamera
    if (mappable.length == 1) {
      _mapController.move(
        LatLng(mappable.first.latitude!, mappable.first.longitude!),
        MapTileConfig.defaultZoom,
      );
      return;
    }

    // Multiple points but not showing timeline = default load, skip fit
    if (!_showTimeline) {
      _mapController.move(
        LatLng(mappable.first.latitude!, mappable.first.longitude!),
        MapTileConfig.defaultZoom,
      );
      return;
    }

    final bounds = LatLngBounds.fromPoints(
      mappable.map((p) => LatLng(p.latitude!, p.longitude!)).toList(),
    );
    _mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(48)),
    );
    debugPrint('[DeviceDetailScreen] fit map to ${mappable.length} points');
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
      child: BlocListener<AnalyticsBloc, AnalyticsState>(
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
        child: Stack(
          children: [
            // ── Map — never rebuilds ─────────────────────
            RepaintBoundary(
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _defaultCenter,
                  initialZoom: MapTileConfig.defaultZoom,
                  // remove onMapReady entirely
                ),
                children: [
                  TileLayer(
                    urlTemplate: MapTileConfig.tileUrlTemplate,
                    userAgentPackageName: MapTileConfig.userAgentPackageName,
                  ),
                  // Geofence — only rebuilds on GeofenceBloc changes
                  GeofencePolygonLayer(onGeofenceTap: (_) {}),
                  // Route polyline — only rebuilds when points list changes
                  BlocBuilder<AnalyticsBloc, AnalyticsState>(
                    buildWhen: (prev, curr) {
                      if (prev is AnalyticsLoaded && curr is AnalyticsLoaded) {
                        return prev.points.isEmpty != curr.points.isEmpty;
                      }
                      return prev.runtimeType != curr.runtimeType;
                    },
                    builder: (context, state) {
                      final loaded = state is AnalyticsLoaded ? state : null;
                      if (loaded == null || loaded.mappablePoints.length < 2) {
                        return const SizedBox.shrink();
                      }
                      return PolylineLayer(
                        polylines: [
                          Polyline(
                            points: loaded.mappablePoints
                                .map((p) => LatLng(p.latitude!, p.longitude!))
                                .toList(),
                            color: Theme.of(context).colorScheme.primary,
                            strokeWidth: 3,
                          ),
                        ],
                      );
                    },
                  ),
                  // Markers — rebuilds on slider OR points change
                  BlocBuilder<AnalyticsBloc, AnalyticsState>(
                    buildWhen: (prev, curr) {
                      if (prev is AnalyticsLoaded && curr is AnalyticsLoaded) {
                        return prev.sliderIndex != curr.sliderIndex ||
                            prev.points != curr.points;
                      }
                      return prev.runtimeType != curr.runtimeType;
                    },
                    builder: (context, state) {
                      final loaded = state is AnalyticsLoaded ? state : null;
                      if (loaded == null) return const SizedBox.shrink();
                      final colors = Theme.of(context).colorScheme;
                      return MarkerLayer(
                        markers: loaded.mappablePoints
                            .asMap()
                            .entries
                            .map(
                              (e) => Marker(
                                point: LatLng(
                                  e.value.latitude!,
                                  e.value.longitude!,
                                ),
                                width: e.key == loaded.sliderIndex ? 18 : 12,
                                height: e.key == loaded.sliderIndex ? 18 : 12,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: e.key == loaded.sliderIndex
                                        ? colors.primary
                                        : colors.primary.withValues(alpha: 0.4),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: e.key == loaded.sliderIndex
                                          ? 2
                                          : 1,
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                ],
              ),
            ),

            // ── No data banner ───────────────────────────
            BlocBuilder<AnalyticsBloc, AnalyticsState>(
              buildWhen: (prev, curr) =>
                  (prev is AnalyticsLoaded) != (curr is AnalyticsLoaded),
              builder: (context, state) {
                final loaded = state is AnalyticsLoaded ? state : null;
                if (loaded == null || loaded.points.isNotEmpty) {
                  return const SizedBox.shrink();
                }
                final colors = Theme.of(context).colorScheme;
                return Positioned(
                  top: MediaQuery.of(context).padding.top + 12,
                  left: 64,
                  right: 64,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: colors.errorContainer.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: colors.onErrorContainer,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'No data found for this timeframe.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: colors.onErrorContainer,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            // add a new Positioned for the tabs, top-left (near where the old filter button used to signal state):
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 12,
              child: ViewTabs(
                isHistory: _showTimeline,
                onChanged: _onViewChanged,
              ),
            ),

            // ── Top right: filter + zoom ─────────────────
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const SizedBox(height: 8),
                  MapIconButton(
                    icon: Icons.add_rounded,
                    onTap: () => _mapController.move(
                      _mapController.camera.center,
                      _mapController.camera.zoom + 1,
                    ),
                    colors: Theme.of(context).colorScheme,
                  ),
                  const SizedBox(height: 8),
                  MapIconButton(
                    icon: Icons.remove_rounded,
                    onTap: () => _mapController.move(
                      _mapController.camera.center,
                      _mapController.camera.zoom - 1,
                    ),
                    colors: Theme.of(context).colorScheme,
                  ),
                ],
              ),
            ),
            Positioned(
              right: 12,
              bottom: _showTimeline ? 235 : 255,
              child: MapIconButton(
                icon: Icons.location_searching,
                onTap: null,
                colors: Theme.of(context).colorScheme,
              ),
            ),
            // ── Bottom right: my location ────────────────
            Positioned(
              right: 12,
              bottom: _showTimeline ? 180 : 200,
              child: MapIconButton(
                icon: Icons.my_location_rounded,
                onTap: () => _mapController.move(_defaultCenter, 14),
                colors: Theme.of(context).colorScheme,
              ),
            ),

            // ── Bottom panel ─────────────────────────────
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
                    // fall back so chips still know what's "active" during loading/error
                    final activeFilter =
                        loaded?.activeFilter ?? AnalyticsFilter.lastHour;

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
