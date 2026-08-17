import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/config/map_config.dart';

/// Moves/fits [controller]'s camera to contain [points].
/// - No points: no-op.
/// - One point: centers on it at [singlePointZoom].
/// - Multiple points: fits bounds with [padding].
void fitBoundsToPoints(
  MapController controller,
  List<LatLng> points, {
  double singlePointZoom = MapConfig.defaultZoom,
  EdgeInsets padding = const EdgeInsets.all(64),
}) {
  if (points.isEmpty) return;
  if (points.length == 1) {
    controller.move(points.first, singlePointZoom);
    return;
  }
  final bounds = LatLngBounds.fromPoints(points);
  controller.fitCamera(CameraFit.bounds(bounds: bounds, padding: padding));
}

/// Average of a set of points. Returns null if empty.
LatLng? centroidOf(List<LatLng> points) {
  if (points.isEmpty) return null;
  final lat =
      points.map((p) => p.latitude).reduce((a, b) => a + b) / points.length;
  final lng =
      points.map((p) => p.longitude).reduce((a, b) => a + b) / points.length;
  return LatLng(lat, lng);
}
