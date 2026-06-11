import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../blocs/geofence/geofence_bloc.dart';
import '../../domain/entities/geofence/geofence_entity.dart';

class GeofencePolygonLayer extends StatelessWidget {
  /// Optional — if provided, tapping a geofence calls this.
  final void Function(GeofenceEntity)? onGeofenceTap;

  const GeofencePolygonLayer({super.key, this.onGeofenceTap});

  Color _hexToColor(String hex) {
    final cleaned = hex.replaceFirst('#', '');
    final value = int.tryParse(cleaned, radix: 16);
    if (value == null) return Colors.blue;
    return Color(0xFF000000 | value);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GeofenceBloc, GeofenceState>(
      builder: (context, state) {
        if (state is! GeofenceLoaded) return const SizedBox.shrink();

        final geofences = state.activeGeofences;

        if (onGeofenceTap != null) {
          // Use MarkerLayer trick — PolygonLayer has no onTap,
          // so we overlay transparent tap targets at the centroid.
          return Stack(
            children: [
              PolygonLayer(polygons: _buildPolygons(geofences)),
              MarkerLayer(
                markers: geofences.map((g) {
                  final center = _centroid(g.coordinates);
                  return Marker(
                    point: center,
                    width: 48,
                    height: 48,
                    child: GestureDetector(
                      onTap: () => onGeofenceTap!(g),
                      child: const ColoredBox(color: Colors.transparent),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        }

        return PolygonLayer(polygons: _buildPolygons(geofences));
      },
    );
  }

  List<Polygon> _buildPolygons(List<GeofenceEntity> geofences) {
    return geofences.map((g) {
      final borderColor = _hexToColor(g.geofenceColor);
      return Polygon(
        points: g.coordinates.map((c) => LatLng(c.lat, c.lng)).toList(),
        color: borderColor.withValues(alpha: 0.2),
        borderColor: borderColor,
        borderStrokeWidth: 2,
      );
    }).toList();
  }

  LatLng _centroid(List<Coordinate> coords) {
    final lat =
        coords.map((c) => c.lat).reduce((a, b) => a + b) / coords.length;
    final lng =
        coords.map((c) => c.lng).reduce((a, b) => a + b) / coords.length;
    return LatLng(lat, lng);
  }
}
