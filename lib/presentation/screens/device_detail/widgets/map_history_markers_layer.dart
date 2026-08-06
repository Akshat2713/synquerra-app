import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../blocs/analytics/analytics_bloc.dart';

class MapHistoryMarkersLayer extends StatelessWidget {
  const MapHistoryMarkersLayer({super.key});

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
        final colors = Theme.of(context).colorScheme;

        return MarkerLayer(
          markers: loaded.mappablePoints
              .asMap()
              .entries
              .map(
                (e) => Marker(
                  point: LatLng(e.value.latitude!, e.value.longitude!),
                  width: e.key == loaded.sliderIndex ? 18 : 12,
                  height: e.key == loaded.sliderIndex ? 18 : 12,
                  child: Container(
                    decoration: BoxDecoration(
                      color: e.key == loaded.sliderIndex
                          ? colors.primary
                          : colors.primary.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: e.key == loaded.sliderIndex ? 2 : 1,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}
