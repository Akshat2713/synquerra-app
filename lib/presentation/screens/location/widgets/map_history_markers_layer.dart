import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import '../../../../core/utils/app_logger.dart';
import '../../../../domain/entities/analytics/analytics_entity.dart';
import '../../../blocs/analytics/analytics_bloc.dart';
import '../../../themes/app_tokens.dart';
import '../../../themes/colors.dart';
import '../../../utils/app_icons.dart';
import 'utils/curve_geometry.dart';

class MapHistoryMarkersLayer extends StatelessWidget {
  const MapHistoryMarkersLayer({super.key});

  static const _tag = 'MarkersLayer';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnalyticsBloc, AnalyticsState>(
      buildWhen: (prev, curr) {
        final rebuild = (prev is AnalyticsLoaded && curr is AnalyticsLoaded)
            ? prev.sliderIndex != curr.sliderIndex || prev.points != curr.points
            : prev.runtimeType != curr.runtimeType;
        AppLogger.d(
          _tag,
          'buildWhen → rebuild=$rebuild '
          '(prev=${prev.runtimeType}, curr=${curr.runtimeType})',
        );
        return rebuild;
      },
      builder: (context, state) {
        final loaded = state is AnalyticsLoaded ? state : null;
        if (loaded == null) {
          AppLogger.d(_tag, 'NOT rendered: state=${state.runtimeType}');
          return const SizedBox.shrink();
        }

        final points = loaded.mappablePoints;
        if (points.isEmpty) {
          AppLogger.d(
            _tag,
            'NOT rendered: 0 mappable (total=${loaded.points.length})',
          );
          return const SizedBox.shrink();
        }

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
        final builtPoints = <AnalyticsEntity>[];
        Marker? selectedMarker; // added last so it draws on top

        for (var index = 0; index <= lastIndex; index++) {
          final point = points[index];
          final isSelected = index == loaded.sliderIndex;
          final baseColor = AppColors.primary(context);

          Marker marker;

          if (index == lastIndex) {
            AppLogger.d(
              _tag,
              'BEFORE render [$index/$lastIndex] circle (last) → '
              '${point.latitude}, ${point.longitude} @ ${point.deviceTimestamp}',
            );
            marker = _circleMarker(
              point: point,
              isSelected: isSelected,
              color: baseColor,
            );
          } else {
            final dir = CurveGeometry.tangentAt(offsets, index);
            if (dir == null) {
              // Overlapping on screen: no meaningful direction, show a dot.
              AppLogger.d(
                _tag,
                'BEFORE render [$index/$lastIndex] circle (no direction) → '
                '${point.latitude}, ${point.longitude} @ ${point.deviceTimestamp}',
              );
              marker = _circleMarker(
                point: point,
                isSelected: isSelected,
                color: baseColor,
              );
            } else {
              final angle = math.atan2(dir.dx, -dir.dy);
              AppLogger.d(
                _tag,
                'BEFORE render [$index/$lastIndex] arrow → '
                '${point.latitude}, ${point.longitude} @ ${point.deviceTimestamp}',
              );
              marker = _arrowMarker(
                point: point,
                angleRadians: angle,
                isSelected: isSelected,
                color: isSelected
                    ? AppColors.activeLocation
                    : (index == 0 ? AppColors.success : baseColor),
              );
            }
          }

          builtPoints.add(point);
          if (isSelected) {
            selectedMarker = marker;
          } else {
            markers.add(marker);
          }
        }

        if (selectedMarker != null) markers.add(selectedMarker);

        SchedulerBinding.instance.addPostFrameCallback((_) {
          for (final p in builtPoints) {
            final inView = camera.visibleBounds.contains(
              LatLng(p.latitude!, p.longitude!),
            );
            AppLogger.d(
              _tag,
              'AFTER render → ${p.latitude}, ${p.longitude} '
              '${inView ? "RENDERED (visible)" : "BUILT but OFF-SCREEN"}',
            );
          }
        });

        return MarkerLayer(markers: markers);
      },
    );
  }

  Marker _circleMarker({
    required AnalyticsEntity point,
    required bool isSelected,
    required Color color,
  }) {
    final size = isSelected ? AppSize.icon : AppSize.iconSm;
    return Marker(
      point: LatLng(point.latitude!, point.longitude!),
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.activeLocation : color,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.mapMarkerOutline,
            width: AppSize.stroke,
          ),
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
    final size = isSelected ? AppSize.iconLg : AppSize.icon;
    return Marker(
      point: LatLng(point.latitude!, point.longitude!),
      width: size + AppSpacing.sm,
      height: size + AppSpacing.sm,
      child: Transform.rotate(
        angle: angleRadians,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              AppIcons.directionMarker,
              size: size + AppSpacing.xs,
              color: AppColors.mapMarkerOutline,
            ),
            Icon(AppIcons.directionMarker, size: size, color: color),
          ],
        ),
      ),
    );
  }
}
