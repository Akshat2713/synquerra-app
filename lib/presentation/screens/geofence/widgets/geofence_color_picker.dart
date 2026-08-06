import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class GeofenceColorPickerTile extends StatelessWidget {
  final Color selectedColor;
  final ValueChanged<Color> onColorChanged;

  const GeofenceColorPickerTile({
    super.key,
    required this.selectedColor,
    required this.onColorChanged,
  });

  void _showColorPickerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: selectedColor,
            onColorChanged: onColorChanged,
            enableAlpha: false,
            labelTypes: const [],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Color', style: textTheme.labelLarge),
        const SizedBox(height: 8),
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showColorPickerDialog(context),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: selectedColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.outlineVariant),
            ),
          ),
        ),
      ],
    );
  }
}
