import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/config/map_config.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../domain/entities/geofence/geofence_entity.dart';
import '../../../themes/app_text_styles.dart';
import '../../../themes/colors.dart';
import '../../../utils/app_icons.dart';
import '../utils/map_bounds_util.dart';
import '../../../themes/app_tokens.dart';

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
            padding: AppSpacing.mdAll,
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
        borderRadius: AppRadius.mdAll,
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
                        color: widget.color.withValues(alpha: AppAlpha.border),
                        borderColor: widget.color,
                        borderStrokeWidth: AppSize.stroke,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned.fill(
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    widget.onTap();
                  },
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.smd,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      AppColors.onColorDark.withValues(alpha: AppAlpha.overlay),
                      AppColors.onColorDark.withValues(alpha: AppAlpha.tint),
                    ],
                  ),
                ),
                child: Row(
                  spacing: AppSpacing.xs,
                  children: [
                    Icon(
                      AppIcons.editLocation,
                      size: AppSize.iconSm,
                      color: AppColors.onColorLight,
                    ),
                    Expanded(
                      child: Text(
                        'Tap to adjust geofence boundary',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.metaWithColor(
                          context,
                          color: AppColors.onColorLight,
                        ).copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Icon(
                      AppIcons.chevron,
                      size: AppSize.iconSm,
                      color: AppColors.onColorLight.withValues(
                        alpha: AppAlpha.overlay,
                      ),
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
