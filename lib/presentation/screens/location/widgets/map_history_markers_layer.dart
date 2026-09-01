// lib/presentation/screens/location/widgets/map_history_markers_layer.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../domain/entities/analytics/analytics_entity.dart';
import '../../../../domain/utils/bearing_calculator.dart';
import '../../../blocs/analytics/analytics_bloc.dart';
import '../../../themes/colors.dart';

class MapHistoryMarkersLayer extends StatelessWidget {
  const MapHistoryMarkersLayer({super.key});

  // map_history_markers_layer.dart — only the relevant part changes

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
                color: AppColors.primary,
              ),
            );
            continue;
          }

          final next = points[index + 1];
          if (_isNegligibleMove(point, next)) {
            continue;
          } // just skip — no marker for this jittery point

          final bearing = BearingCalculator.calculate(
            startLat: point.latitude!,
            startLng: point.longitude!,
            endLat: next.latitude!,
            endLng: next.longitude!,
          );
          markers.add(
            _arrowMarker(
              point: point,
              bearingDegrees: bearing,
              isSelected: isSelected,
              color: index == 0 ? AppColors.success : AppColors.primary,
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
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: isSelected ? 2.5 : 2),
        ),
      ),
    );
  }

  Marker _arrowMarker({
    required AnalyticsEntity point,
    required double bearingDegrees,
    required bool isSelected,
    required Color color,
  }) {
    final size = isSelected ? 26.0 : 20.0;
    return Marker(
      point: LatLng(point.latitude!, point.longitude!),
      width: size,
      height: size,
      child: Transform.rotate(
        angle: bearingDegrees * (math.pi / 180),
        child: Icon(Icons.navigation_rounded, size: size, color: color),
      ),
    );
  }
}
