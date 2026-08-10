// presentation/screens/device_detail/widgets/map_controls_column.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../blocs/user_location/user_location_bloc.dart';
import 'map_icon_button.dart';

class MapControlsColumn extends StatelessWidget {
  final MapController mapController;
  final UserLocationBloc userLocationBloc;
  final LatLng deviceCenter;

  const MapControlsColumn({
    super.key,
    required this.mapController,
    required this.userLocationBloc,
    required this.deviceCenter,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MapIconButton(
          icon: Icons.add_rounded,
          colors: colors,
          onTap: () => mapController.move(
            mapController.camera.center,
            mapController.camera.zoom + 1,
          ),
        ),
        const SizedBox(height: 8),
        MapIconButton(
          icon: Icons.remove_rounded,
          colors: colors,
          onTap: () => mapController.move(
            mapController.camera.center,
            mapController.camera.zoom - 1,
          ),
        ),
        const SizedBox(height: 8),
        _CompassButton(mapController: mapController, colors: colors),
        const SizedBox(height: 8),
        // Reserved for future use — intentionally disabled (onTap: null).
        MapIconButton(
          icon: Icons.location_searching,
          onTap: null,
          colors: colors,
        ),
        const SizedBox(height: 8),
        // Recenter on the device's last known location.
        MapIconButton(
          icon: Icons.phone_android,
          colors: colors,
          onTap: () => mapController.move(deviceCenter, 14),
        ),
        const SizedBox(height: 8),
        // Recenter on the user's real GPS location.
        _MyLocationButton(
          mapController: mapController,
          userLocationBloc: userLocationBloc,
          colors: colors,
        ),
      ],
    );
  }
}

class _CompassButton extends StatelessWidget {
  final MapController mapController;
  final ColorScheme colors;

  const _CompassButton({required this.mapController, required this.colors});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MapEvent>(
      stream: mapController.mapEventStream,
      builder: (context, _) {
        final rotationDeg = mapController.camera.rotation;
        final isNorthUp = rotationDeg.abs() < 0.5;
        return MapIconButton(
          icon: Icons.explore_rounded,
          colors: colors,
          onTap: isNorthUp ? null : () => mapController.rotate(0),
          child: Transform.rotate(
            angle: -rotationDeg * (math.pi / 180),
            child: Icon(
              Icons.explore_rounded,
              size: 20,
              color: isNorthUp
                  ? colors.onSurfaceVariant.withValues(alpha: 0.4)
                  : colors.onSurface,
            ),
          ),
        );
      },
    );
  }
}

class _MyLocationButton extends StatelessWidget {
  final MapController mapController;
  final UserLocationBloc userLocationBloc;
  final ColorScheme colors;

  const _MyLocationButton({
    required this.mapController,
    required this.userLocationBloc,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserLocationBloc, UserLocationState>(
      bloc: userLocationBloc,
      builder: (context, state) {
        final isLoading = state is UserLocationLoading;
        return MapIconButton(
          icon: isLoading
              ? Icons.hourglass_bottom_rounded
              : Icons.my_location_rounded,
          colors: colors,
          onTap: isLoading
              ? null
              : () => userLocationBloc.add(FetchUserLocation()),
        );
      },
    );
  }
}
