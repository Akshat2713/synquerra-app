import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../data/network/map_tile_config.dart';
import '../../../domain/entities/geofence/geofence_entity.dart';
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
  final List<LatLng> _points = [];
  static const int _maxPoints = 5;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
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
      body: Stack(
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
            ],
          ),

          // ── Top bar ───────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
    );
  }
}
