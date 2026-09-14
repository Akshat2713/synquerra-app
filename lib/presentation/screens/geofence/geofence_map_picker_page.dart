import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/config/map_config.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/utils/app_logger.dart';
import '../../../domain/entities/geofence/geofence_entity.dart';
import '../../blocs/user_location/user_location_bloc.dart';
import '../../themes/colors.dart';
import '../location/widgets/map_icon_button.dart';
import 'utils/map_bounds_util.dart';
import 'widgets/map_numbered_marker.dart';
import 'widgets/map_top_header_bar.dart';

class GeofenceMapPickerPage extends StatefulWidget {
  final LatLng initialCenter;
  final List<Coordinate>? initialPoints;

  const GeofenceMapPickerPage({
    super.key,
    required this.initialCenter,
    this.initialPoints,
  });

  @override
  State<GeofenceMapPickerPage> createState() => _GeofenceMapPickerPageState();
}

class _GeofenceMapPickerPageState extends State<GeofenceMapPickerPage> {
  late final MapController _mapController;
  late final UserLocationBloc _userLocationBloc;
  late final TileProvider _tileProvider;

  final List<LatLng> _points = [];
  static const int _maxPoints = 5;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _userLocationBloc = sl<UserLocationBloc>();
    _tileProvider = sl<TileProvider>();
    if (widget.initialPoints != null && widget.initialPoints!.isNotEmpty) {
      _points.addAll(
        widget.initialPoints!.take(_maxPoints).map((c) => LatLng(c.lat, c.lng)),
      );
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    _userLocationBloc.close();
    super.dispose();
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    if (_points.length >= _maxPoints) return;
    setState(() => _points.add(point));
    AppLogger.d('MapPicker', 'Point ${_points.length}: $point');
  }

  void _removeLastPoint() {
    if (_points.isEmpty) return;
    setState(() => _points.removeLast());
  }

  void _onDone() {
    final closed = [..._points, _points.first];
    final coordinates = closed
        .map((p) => Coordinate(lat: p.latitude, lng: p.longitude))
        .toList();
    Navigator.pop(context, coordinates);
  }

  String get _headerInstruction {
    if (_points.isEmpty) return 'Tap on map to place point 1';
    if (_points.length == _maxPoints) return 'All 5 points placed — tap Done';
    return 'Tap to place point ${_points.length + 1} of 5';
  }

  @override
  Widget build(BuildContext context) {
    final isDone = _points.length == _maxPoints;

    return Scaffold(
      body: BlocListener<UserLocationBloc, UserLocationState>(
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
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                onMapReady: () {
                  if (_points.isNotEmpty) {
                    fitBoundsToPoints(_mapController, _points);
                  }
                },
                initialCenter: widget.initialCenter,
                initialZoom: MapConfig.defaultZoom,
                onTap: _onMapTap,
              ),
              children: [
                TileLayer(
                  urlTemplate: MapConfig.tileUrlTemplate,
                  userAgentPackageName: MapConfig.userAgentPackageName,
                  tileProvider: _tileProvider,
                ),
                if (_points.length >= 3)
                  PolygonLayer(
                    polygons: [
                      Polygon(
                        points: isDone ? [..._points, _points.first] : _points,
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderColor: AppColors.primary,
                        borderStrokeWidth: 2,
                      ),
                    ],
                  ),
                if (_points.length >= 2)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _points,
                        color: AppColors.primary,
                        strokeWidth: 2,
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: _points.asMap().entries.map((e) {
                    return Marker(
                      point: e.value,
                      width: 28,
                      height: 28,
                      child: MapNumberedMarker(
                        number: e.key + 1,
                        backgroundColor: AppColors.primary,
                        size: 28,
                      ),
                    );
                  }).toList(),
                ),
                if (widget.initialPoints == null ||
                    widget.initialPoints!.isEmpty)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: widget.initialCenter,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_pin,
                          color: AppColors.success,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                BlocBuilder<UserLocationBloc, UserLocationState>(
                  bloc: _userLocationBloc,
                  builder: (context, state) {
                    if (state is UserLocationLoaded) {
                      return MarkerLayer(
                        markers: [
                          Marker(
                            point: state.position,
                            width: 32,
                            height: 32,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.4,
                                    ),
                                    blurRadius: 8,
                                    spreadRadius: 4,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.person_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),

            MapTopHeaderBar(
              title: _headerInstruction,
              onBackTap: () => Navigator.pop(context),
            ),

            // Location Controls
            // Location Controls & Bottom Actions section within build()
            Positioned(
              bottom: 100,
              right: 24,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MapIconButton(
                    icon: Icons.phone_android,
                    onTap: () {
                      _mapController.move(widget.initialCenter, 16.0);
                    },
                  ),
                  const SizedBox(height: 12),
                  BlocBuilder<UserLocationBloc, UserLocationState>(
                    bloc: _userLocationBloc,
                    builder: (context, state) {
                      final isLoading = state is UserLocationLoading;
                      return MapIconButton(
                        icon: isLoading
                            ? Icons.hourglass_bottom_rounded
                            : Icons.my_location_rounded,
                        onTap: isLoading
                            ? null
                            : () => _userLocationBloc.add(FetchUserLocation()),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Bottom Actions
            Positioned(
              bottom: 32,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  MapIconButton(
                    icon: Icons.undo_rounded,
                    onTap: _points.isEmpty ? null : _removeLastPoint,
                  ),
                  const Spacer(),
                  AnimatedOpacity(
                    opacity: isDone ? 1.0 : 0.4,
                    duration: const Duration(milliseconds: 200),
                    child: FilledButton.icon(
                      onPressed: isDone ? _onDone : null,
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Done'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
