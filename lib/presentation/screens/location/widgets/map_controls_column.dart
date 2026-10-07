// presentation/screens/device_detail/widgets/map_controls_column.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import '../../../themes/colors.dart';
import 'map_icon_button.dart';
import 'map_zoom_slider.dart';
import 'package:synquerra/presentation/themes/app_tokens.dart';

class MapControlsColumn extends StatelessWidget {
  final MapController mapController;

  const MapControlsColumn({super.key, required this.mapController});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        MapZoomSlider(mapController: mapController),
        const SizedBox(height: 8),
        _CompassButton(mapController: mapController),
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
                  ? AppColors.textSecondary(context).withValues(alpha: AppAlpha.border)
                  : AppColors.textPrimary(context),
            ),
          ),
        );
      },
    );
  }
}
