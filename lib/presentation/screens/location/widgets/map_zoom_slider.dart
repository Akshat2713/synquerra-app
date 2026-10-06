// presentation/screens/device_detail/widgets/map_zoom_slider.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import '../../../themes/colors.dart';

class MapZoomSlider extends StatelessWidget {
  final MapController mapController;
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

        return Container(
          height: 140,
          width: 44,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant(context),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(
                Icons.add_rounded,
                size: 16,
                color: AppColors.textSecondary(context),
              ),
              Expanded(
                child: RotatedBox(
                  quarterTurns: 3,
                  child: SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 6,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 12,
                      ),
                      activeTrackColor: AppColors.primary(context),
                      inactiveTrackColor: AppColors.textSecondary(
                        context,
                      ).withValues(alpha: 0.2),
                      thumbColor: AppColors.primary(context),
                    ),
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
              ),
              Icon(
                Icons.remove_rounded,
                size: 16,
                color: AppColors.textSecondary(context),
              ),
            ],
          ),
        );
      },
    );
  }
}
