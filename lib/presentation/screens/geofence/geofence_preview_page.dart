import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/config/map_config.dart';
import '../../../core/di/injection_container.dart';
import '../../../domain/entities/geofence/geofence_entity.dart';
import '../../themes/colors.dart';
import '../../utils/colour_util.dart';
import '../location/widgets/map_icon_button.dart';
import 'utils/map_bounds_util.dart';
import 'widgets/geofence_status_chip.dart';
import 'widgets/map_numbered_marker.dart';
import 'widgets/map_top_header_bar.dart';

class GeofencePreviewPage extends StatefulWidget {
  final GeofenceEntity geofence;

  const GeofencePreviewPage({super.key, required this.geofence});

  @override
  State<GeofencePreviewPage> createState() => _GeofencePreviewPageState();
}

class _GeofencePreviewPageState extends State<GeofencePreviewPage> {
  late final MapController _mapController;
  late final TileProvider _tileProvider;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _tileProvider = sl<TileProvider>();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _fitGeofence() {
    fitBoundsToPoints(
      _mapController,
      widget.geofence.coordinates.map((c) => LatLng(c.lat, c.lng)).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final geofence = widget.geofence;
    final borderColor = colorFromHex(geofence.geofenceColor);
    final points = geofence.coordinates
        .map((c) => LatLng(c.lat, c.lng))
        .toList();

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              // initialCenter: centroidOf(points) ?? const LatLng(0, 0),
              initialZoom: MapConfig.defaultZoom,
              onMapReady: _fitGeofence,
            ),
            children: [
              TileLayer(
                urlTemplate: MapConfig.tileUrlTemplate,
                userAgentPackageName: MapConfig.userAgentPackageName,
                tileProvider: _tileProvider,
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
              MarkerLayer(
                markers: geofence.coordinates
                    .take(5)
                    .toList()
                    .asMap()
                    .entries
                    .map(
                      (e) => Marker(
                        point: LatLng(e.value.lat, e.value.lng),
                        width: 26,
                        height: 26,
                        child: MapNumberedMarker(
                          number: e.key + 1,
                          backgroundColor: borderColor,
                          size: 26,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),

          MapTopHeaderBar(
            title: geofence.geofenceName,
            onBackTap: () => Navigator.pop(context),
          ),

          // Bottom Info Card
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface(context),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow(context).withValues(alpha: 0.08),
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
                  GeofenceStatusChip(isActive: geofence.isActive),
                ],
              ),
            ),
          ),

          // Zoom Controls
          // Zoom Controls section within build()
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
                ),
                const SizedBox(height: 8),
                MapIconButton(
                  icon: Icons.remove_rounded,
                  onTap: () => _mapController.move(
                    _mapController.camera.center,
                    _mapController.camera.zoom - 1,
                  ),
                ),
                const SizedBox(height: 8),
                MapIconButton(
                  icon: Icons.fit_screen_rounded,
                  onTap: _fitGeofence,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
