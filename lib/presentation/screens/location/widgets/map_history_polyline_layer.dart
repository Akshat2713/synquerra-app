import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../blocs/analytics/analytics_bloc.dart';

class MapHistoryPolylineLayer extends StatelessWidget {
  const MapHistoryPolylineLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnalyticsBloc, AnalyticsState>(
      buildWhen: (prev, curr) {
        if (prev is AnalyticsLoaded && curr is AnalyticsLoaded) {
          return prev.points.isEmpty != curr.points.isEmpty;
        }
        return prev.runtimeType != curr.runtimeType;
      },
      builder: (context, state) {
        final loaded = state is AnalyticsLoaded ? state : null;
        if (loaded == null || loaded.mappablePoints.length < 2) {
          return const SizedBox.shrink();
        }
        return PolylineLayer(
          polylines: [
            Polyline(
              points: loaded.mappablePoints
                  .map((p) => LatLng(p.latitude!, p.longitude!))
                  .toList(),
              color: Theme.of(context).colorScheme.primary,
              strokeWidth: 3,
            ),
          ],
        );
      },
    );
  }
}
