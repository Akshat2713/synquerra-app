import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../data/network/map_tile_config.dart';
import '../../../domain/entities/geofence/geofence_entity.dart';
import '../device_detail/widgets/map_icon_button.dart';

class GeofencePreviewPage extends StatefulWidget {
  final GeofenceEntity geofence;

  const GeofencePreviewPage({super.key, required this.geofence});

  @override
  State<GeofencePreviewPage> createState() => _GeofencePreviewPageState();
}

class _GeofencePreviewPageState extends State<GeofencePreviewPage> {
  late final MapController _mapController;

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

  Color _hexToColor(String hex) {
    final cleaned = hex.replaceFirst('#', '');
    final value = int.tryParse(cleaned, radix: 16);
    if (value == null) return Colors.blue;
    return Color(0xFF000000 | value);
  }

  LatLng get _centroid {
    final coords = widget.geofence.coordinates;
    final lat =
        coords.map((c) => c.lat).reduce((a, b) => a + b) / coords.length;
    final lng =
        coords.map((c) => c.lng).reduce((a, b) => a + b) / coords.length;
    return LatLng(lat, lng);
  }

  void _fitGeofence() {
    final points = widget.geofence.coordinates
        .map((c) => LatLng(c.lat, c.lng))
        .toList();
    if (points.isEmpty) return;
    if (points.length == 1) {
      _mapController.move(points.first, MapTileConfig.defaultZoom);
      return;
    }
    final bounds = LatLngBounds.fromPoints(points);
    _mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(64)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final geofence = widget.geofence;
    final borderColor = _hexToColor(geofence.geofenceColor);
    final points = geofence.coordinates
        .map((c) => LatLng(c.lat, c.lng))
        .toList();

    return Scaffold(
      body: Stack(
        children: [
          // ── Map ───────────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _centroid,
              initialZoom: MapTileConfig.defaultZoom,
              onMapReady: _fitGeofence,
            ),
            children: [
              TileLayer(
                urlTemplate: MapTileConfig.tileUrlTemplate,
                userAgentPackageName: MapTileConfig.userAgentPackageName,
              ),
              PolygonLayer(
                polygons: [
                  Polygon(
                    points: points,
                    color: borderColor.withValues(alpha: 0.2),
                    borderColor: borderColor,
                    borderStrokeWidth: 2.5,
                  ),
                ],
              ),
              // Numbered corner markers
              MarkerLayer(
                markers: geofence.coordinates
                    .take(5) // skip closing point
                    .toList()
                    .asMap()
                    .entries
                    .map(
                      (e) => Marker(
                        point: LatLng(e.value.lat, e.value.lng),
                        width: 26,
                        height: 26,
                        child: Container(
                          decoration: BoxDecoration(
                            color: borderColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Center(
                            child: Text(
                              '${e.key + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
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
                        geofence.geofenceName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom info card ──────────────────────
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: borderColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      geofence.geofenceName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: geofence.isActive
                          ? colors.primaryContainer
                          : colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      geofence.isActive ? 'Active' : 'Inactive',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: geofence.isActive
                            ? colors.onPrimaryContainer
                            : colors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Zoom controls ─────────────────────────
          Positioned(
            right: 12,
            bottom: 120,
            child: Column(
              children: [
                MapIconButton(
                  icon: Icons.add_rounded,
                  onTap: () => _mapController.move(
                    _mapController.camera.center,
                    _mapController.camera.zoom + 1,
                  ),
                  colors: colors,
                ),
                const SizedBox(height: 8),
                MapIconButton(
                  icon: Icons.remove_rounded,
                  onTap: () => _mapController.move(
                    _mapController.camera.center,
                    _mapController.camera.zoom - 1,
                  ),
                  colors: colors,
                ),
                const SizedBox(height: 8),
                MapIconButton(
                  icon: Icons.fit_screen_rounded,
                  onTap: _fitGeofence,
                  colors: colors,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
