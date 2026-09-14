// presentation/screens/device_detail/widgets/map_controls_column.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../blocs/user_location/user_location_bloc.dart';
import '../../../themes/colors.dart';
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MapIconButton(
          icon: Icons.add_rounded,
          onTap: () => mapController.move(
            mapController.camera.center,
            mapController.camera.zoom + 1,
          ),
        ),
        const SizedBox(height: 8),
        MapIconButton(
          icon: Icons.remove_rounded,
          onTap: () => mapController.move(
            mapController.camera.center,
            mapController.camera.zoom - 1,
          ),
        ),
        const SizedBox(height: 8),
        _CompassButton(mapController: mapController),
        const SizedBox(height: 8),
        // Reserved for future use — intentionally disabled (onTap: null).
        const MapIconButton(icon: Icons.location_searching, onTap: null),
        const SizedBox(height: 8),
        // Recenter on the device's last known location.
        MapIconButton(
          icon: Icons.phone_android,
          onTap: () => mapController.move(deviceCenter, 16),
        ),
        const SizedBox(height: 8),
        // Recenter on the user's real GPS location.
        _MyLocationButton(
          mapController: mapController,
          userLocationBloc: userLocationBloc,
        ),
      ],
    );
  }
}

class _CompassButton extends StatelessWidget {
  final MapController mapController;

  const _CompassButton({required this.mapController});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MapEvent>(
      stream: mapController.mapEventStream,
      builder: (context, _) {
        final rotationDeg = mapController.camera.rotation;
        final isNorthUp = rotationDeg.abs() < 0.5;
        return MapIconButton(
          icon: Icons.explore_rounded,
          onTap: isNorthUp ? null : () => mapController.rotate(0),
          child: Transform.rotate(
            angle: -rotationDeg * (math.pi / 180),
            child: Icon(
              Icons.explore_rounded,
              size: 20,
              color: isNorthUp
                  ? AppColors.textSecondary(context).withValues(alpha: 0.4)
                  : AppColors.textPrimary(context),
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

  const _MyLocationButton({
    required this.mapController,
    required this.userLocationBloc,
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
          onTap: isLoading
              ? null
              : () => userLocationBloc.add(FetchUserLocation()),
        );
      },
    );
  }
}
