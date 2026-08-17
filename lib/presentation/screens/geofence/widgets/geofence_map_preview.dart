import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/config/map_config.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../domain/entities/geofence/geofence_entity.dart';
import '../utils/map_bounds_util.dart';

/// Compact, non-interactive square map thumbnail rendering a geofence polygon.
/// Tapping it fires [onTap] (e.g. reopen the picker to redraw).
class GeofenceMapPreview extends StatefulWidget {
  final List<Coordinate> coordinates;
  final Color color;
  final VoidCallback onTap;

  const GeofenceMapPreview({
    super.key,
    required this.coordinates,
    required this.color,
    required this.onTap,
  });

  @override
  State<GeofenceMapPreview> createState() => _GeofenceMapPreviewState();
}

class _GeofenceMapPreviewState extends State<GeofenceMapPreview> {
  late final MapController _mapController;

  List<LatLng> get _points =>
      widget.coordinates.map((c) => LatLng(c.lat, c.lng)).toList();

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void didUpdateWidget(covariant GeofenceMapPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.coordinates != widget.coordinates) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _fitToBox());
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _fitToBox() {
    if (!mounted) return;
    final points = _points;
    try {
      if (points.length >= 2) {
        _mapController.fitCamera(
          CameraFit.bounds(
            bounds: LatLngBounds.fromPoints(points),
            padding: const EdgeInsets.all(16),
            maxZoom: 18,
          ),
        );
      } else {
        _mapController.move(centroidOf(points) ?? points.first, 16);
      }
    } catch (_) {
      _mapController.move(centroidOf(points) ?? points.first, 15);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            IgnorePointer(
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: centroidOf(_points) ?? _points.first,
                  initialZoom: MapConfig.defaultZoom,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.none,
                  ),
                  onMapReady: () => WidgetsBinding.instance
                      .addPostFrameCallback((_) => _fitToBox()),
                ),
                children: [
                  TileLayer(
                    urlTemplate: MapConfig.tileUrlTemplate,
                    userAgentPackageName: MapConfig.userAgentPackageName,
                    tileProvider: sl<TileProvider>(),
                  ),
                  PolygonLayer(
                    polygons: [
                      Polygon(
                        points: _points,
                        color: widget.color.withValues(alpha: 0.2),
                        borderColor: widget.color,
                        borderStrokeWidth: 2,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(onTap: widget.onTap),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.55),
                      Colors.black.withValues(alpha: 0.0),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.edit_location_alt_outlined,
                      size: 15,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Tap to adjust geofence boundary',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
