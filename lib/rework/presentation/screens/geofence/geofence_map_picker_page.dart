import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/di/injection_container.dart';
import '../../../data/network/map_tile_config.dart';
import '../../../domain/entities/geofence/geofence_entity.dart';
import '../../blocs/user_location/user_location_bloc.dart';
import '../../themes/colors.dart';
import '../device_detail/widgets/map_icon_button.dart';
// import '../../widgets/map_icon_button.dart';

class GeofenceMapPickerPage extends StatefulWidget {
  final LatLng initialCenter;

  const GeofenceMapPickerPage({super.key, required this.initialCenter});

  @override
  State<GeofenceMapPickerPage> createState() => _GeofenceMapPickerPageState();
}

class _GeofenceMapPickerPageState extends State<GeofenceMapPickerPage> {
  late final MapController _mapController;
  late final UserLocationBloc _userLocationBloc;
  final List<LatLng> _points = [];
  static const int _maxPoints = 5;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _userLocationBloc = sl<UserLocationBloc>();
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
    debugPrint('[MapPicker] Point ${_points.length}: $point');
  }

  void _removeLastPoint() {
    if (_points.isEmpty) return;
    setState(() => _points.removeLast());
  }

  void _onDone() {
    // Close the polygon — last point = first point
    final closed = [..._points, _points.first];
    final coordinates = closed
        .map((p) => Coordinate(lat: p.latitude, lng: p.longitude))
        .toList();
    Navigator.pop(context, coordinates);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDone = _points.length == _maxPoints;

    return Scaffold(
      body: BlocListener<UserLocationBloc, UserLocationState>(
        bloc: _userLocationBloc,
        listener: (context, state) {
          if (state is UserLocationLoaded) {
            _mapController.move(state.position, 16.0); // Zoom in on user
          }
          if (state is UserLocationError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Stack(
          children: [
            // ── Map ───────────────────────────────────
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: widget.initialCenter,
                initialZoom: MapTileConfig.defaultZoom,
                onTap: _onMapTap,
              ),
              children: [
                TileLayer(
                  urlTemplate: MapTileConfig.tileUrlTemplate,
                  userAgentPackageName: MapTileConfig.userAgentPackageName,
                ),
                // ── Polygon preview ──────────────────
                if (_points.length >= 3)
                  PolygonLayer(
                    polygons: [
                      Polygon(
                        points: isDone ? [..._points, _points.first] : _points,
                        color: colors.primary.withValues(alpha: 0.15),
                        borderColor: colors.primary,
                        borderStrokeWidth: 2,
                      ),
                    ],
                  ),
                // ── Lines between points ─────────────
                if (_points.length >= 2)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _points,
                        color: colors.primary,
                        strokeWidth: 2,
                      ),
                    ],
                  ),
                // ── Numbered markers ─────────────────
                MarkerLayer(
                  markers: _points.asMap().entries.map((e) {
                    return Marker(
                      point: e.value,
                      width: 28,
                      height: 28,
                      child: Container(
                        decoration: BoxDecoration(
                          color: colors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            '${e.key + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                // ── Device & User Markers ─────────────────
                MarkerLayer(
                  markers: [
                    // Device Location (Initial Center)
                    Marker(
                      point: widget.initialCenter,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_pin,
                        color: AppColors.safeGreen,
                        size: 32,
                      ),
                    ),
                  ],
                ),
                // Reactive User Marker
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
                                color: colors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: colors.primary.withValues(
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

            // ── Top bar ───────────────────────────────
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    MapIconButton(
                      icon: Icons.arrow_back_rounded,
                      onTap: () => Navigator.pop(context),
                      colors: colors,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: colors.surface.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          _points.isEmpty
                              ? 'Tap on map to place point 1'
                              : isDone
                              ? 'All 5 points placed — tap Done'
                              : 'Tap to place point ${_points.length + 1} of 5',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Bottom Left Location Controls ────────
            Positioned(
              bottom: 100,
              right: 24,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. Center on Device (Tracker)
                  MapIconButton(
                    icon: Icons.phone_android,
                    onTap: () {
                      _mapController.move(widget.initialCenter, 16.0);
                    },
                    colors: colors,
                  ),
                  const SizedBox(height: 12),

                  // 2. Center on User Phone
                  BlocBuilder<UserLocationBloc, UserLocationState>(
                    bloc: _userLocationBloc, // <--- YOU MUST ADD THIS LINE
                    builder: (context, state) {
                      final isLoading = state is UserLocationLoading;
                      return MapIconButton(
                        icon: isLoading
                            ? Icons.hourglass_bottom_rounded
                            : Icons.my_location_rounded,
                        onTap: isLoading
                            ? null
                            // <--- AND CALL THE BLOC DIRECTLY HERE, DO NOT USE context.read()
                            : () => _userLocationBloc.add(FetchUserLocation()),
                        colors: colors,
                      );
                    },
                  ),
                ],
              ),
            ),
            // ── Bottom buttons ────────────────────────
            Positioned(
              bottom: 32,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  // Undo last point
                  MapIconButton(
                    icon: Icons.undo_rounded,
                    onTap: _points.isEmpty ? null : _removeLastPoint,
                    colors: colors,
                  ),
                  const Spacer(),
                  // Done
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
