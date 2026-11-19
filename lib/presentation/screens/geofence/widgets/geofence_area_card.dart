import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../../../../domain/entities/geofence/geofence_entity.dart';
import '../../../themes/app_text_styles.dart';
import '../../../themes/app_tokens.dart';
import '../../../themes/colors.dart';
import '../../../utils/app_icons.dart';
import '../../../widgets/app_surfaces.dart';
import 'geofence_map_preview.dart';

/// "Geofence area" card: map preview (or empty tile) + colour picker icon.
class GeofenceAreaCard extends StatelessWidget {
  final List<Coordinate>? coordinates;
  final Color color;
  final ValueChanged<Color> onColorChanged;
  final VoidCallback onOpenMap;

  const GeofenceAreaCard({
    super.key,
    required this.coordinates,
    required this.color,
    required this.onColorChanged,
    required this.onOpenMap,
  });

  void _pickColor(BuildContext context) {
    HapticFeedback.selectionClick();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: color,
            onColorChanged: onColorChanged,
            enableAlpha: false,
            labelTypes: const [],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final points = coordinates;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.md,
        children: [
          Row(
            spacing: AppSpacing.smd,
            children: [
              IconTile(
                icon: AppIcons.mapArea,
                background: AppColors.success,
                foreground: AppColors.onSuccess,
              ),
              Expanded(
                child: Text(
                  'Geofence area',
                  style: AppTextStyles.sectionWithColor(context),
                ),
              ),
              IconButton(
                onPressed: () => _pickColor(context),
                tooltip: 'Geofence color',
                icon: Icon(
                  AppIcons.palette,
                  size: AppSize.iconLg,
                  color: color,
                ),
              ),
            ],
          ),
          if (points == null)
            _EmptyAreaTile(onTap: onOpenMap)
          else
            GeofenceMapPreview(
              coordinates: points,
              color: color,
              onTap: onOpenMap,
            ),
        ],
      ),
    );
  }
}

class _EmptyAreaTile extends StatelessWidget {
  final VoidCallback onTap;

  const _EmptyAreaTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InsetRow(
      onTap: onTap,
      child: Padding(
        padding: AppSpacing.mdVertical,
        child: SizedBox(
          width: double.infinity,
          child: Column(
            spacing: AppSpacing.xs,
            children: [
              IconTile(
                icon: AppIcons.editLocation,
                circle: true,
                background: AppColors.primary(context),
                foreground: AppColors.onPrimary(context),
              ),
              Text(
                'Tap to draw on map',
                style: AppTextStyles.sectionWithColor(context),
              ),
              // TODO(logic): the "5 points" rule belongs to the map picker config.
              Text(
                'Place exactly 5 points to define the zone',
                textAlign: TextAlign.center,
                style: AppTextStyles.metaWithColor(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
