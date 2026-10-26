// presentation/screens/device_detail/widgets/map_zoom_slider.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import '../../../themes/colors.dart';
import '../../../utils/app_icons.dart';
import '../../../widgets/app_surfaces.dart';
import 'package:synquerra/presentation/themes/app_tokens.dart';

class MapZoomSlider extends StatelessWidget {
  final MapController mapController;
  // TODO(logic): take these from MapConfig instead of hardcoding.
  final double minZoom;
  final double maxZoom;

  const MapZoomSlider({
    super.key,
    required this.mapController,
    this.minZoom = 3.0,
    this.maxZoom = 18.0,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MapEvent>(
      stream: mapController.mapEventStream,
      builder: (context, snapshot) {
        final currentZoom = mapController.camera.zoom.clamp(minZoom, maxZoom);

        return SizedBox(
          width: AppSize.tile,
          height: AppSize.mapSlider,
          child: AppCard(
            padding: AppSpacing.smVertical,
            child: Column(
              children: [
                Icon(
                  AppIcons.zoomIn,
                  size: AppSize.iconSm,
                  color: AppColors.textSecondary(context),
                ),
                Expanded(
                  child: RotatedBox(
                    quarterTurns: 3,
                    // Colors, track and thumb come from sliderTheme in app_theme.
                    child: Slider(
                      value: currentZoom,
                      min: minZoom,
                      max: maxZoom,
                      onChanged: (newZoom) {
                        mapController.move(
                          mapController.camera.center,
                          newZoom,
                        );
                      },
                    ),
                  ),
                ),
                Icon(
                  AppIcons.zoomOut,
                  size: AppSize.iconSm,
                  color: AppColors.textSecondary(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
