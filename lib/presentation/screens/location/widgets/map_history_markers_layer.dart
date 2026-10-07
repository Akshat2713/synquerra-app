import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import '../../../../domain/entities/analytics/analytics_entity.dart';
import '../../../blocs/analytics/analytics_bloc.dart';
import '../../../themes/colors.dart';
import 'utils/curve_geometry.dart';

class MapHistoryMarkersLayer extends StatelessWidget {
  const MapHistoryMarkersLayer({super.key});

  bool _isNegligibleMove(AnalyticsEntity a, AnalyticsEntity b) {
    const threshold = 0.00005; // ~5 meters in lat/lng degrees, rough
    return (a.latitude! - b.latitude!).abs() < threshold &&
        (a.longitude! - b.longitude!).abs() < threshold;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnalyticsBloc, AnalyticsState>(
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

        final points = loaded.mappablePoints;
        if (points.isEmpty) return const SizedBox.shrink();

        // Same screen-space points the polyline uses, so angles match the line
        // (and include any map rotation).
        final camera = MapCamera.of(context);
        final offsets = points
            .map(
              (p) => camera.latLngToScreenOffset(
                LatLng(p.latitude!, p.longitude!),
              ),
            )
            .toList();

        final lastIndex = points.length - 1;
        final markers = <Marker>[];

        for (var index = 0; index <= lastIndex; index++) {
          final point = points[index];
          final isSelected = index == loaded.sliderIndex;

          if (index == lastIndex) {
            markers.add(
              _circleMarker(
                point: point,
                isSelected: isSelected,
                color: AppColors.primary(context),
              ),
            );
            continue;
          }

          final next = points[index + 1];
          if (_isNegligibleMove(point, next)) continue;

          final dir = CurveGeometry.tangentAt(offsets, index);
          if (dir == null) {
            // Overlapping on screen: no meaningful direction, show a dot.
            markers.add(
              _circleMarker(
                point: point,
                isSelected: isSelected,
                color: AppColors.primary(context),
              ),
            );
            continue;
          }

          // Icon points up; rotate clockwise from up to the screen direction.
          final angle = math.atan2(dir.dx, -dir.dy);

          markers.add(
            _arrowMarker(
              point: point,
              angleRadians: angle,
              isSelected: isSelected,
              color: isSelected
                  ? AppColors.activeLocation
                  : (index == 0
                        ? AppColors.success
                        : AppColors.primary(context)),
            ),
          );
        }
        return MarkerLayer(markers: markers);
      },
    );
  }

  Marker _circleMarker({
    required AnalyticsEntity point,
    required bool isSelected,
    required Color color,
  }) {
    final size = isSelected ? 20.0 : 16.0;
    return Marker(
      point: LatLng(point.latitude!, point.longitude!),
      width: size,
      height: size,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.activeLocation : color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: isSelected ? 2.5 : 2),
        ),
      ),
    );
  }

  Marker _arrowMarker({
    required AnalyticsEntity point,
    required double angleRadians,
    required bool isSelected,
    required Color color,
  }) {
    final size = isSelected ? 26.0 : 20.0;

    return Marker(
      point: LatLng(point.latitude!, point.longitude!),
      width: size + 6,
      height: size + 6,
      child: Transform.rotate(
        angle: angleRadians,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // White border
            Icon(Icons.navigation_rounded, size: size + 5, color: Colors.white),

            // Colored arrow
            Icon(Icons.navigation_rounded, size: size, color: color),
          ],
        ),
      ),
    );
  }
}
