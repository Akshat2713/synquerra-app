import 'package:flutter/material.dart';
import '../../../../domain/entities/profile/profile_entity.dart';

class OperatingModeRow extends StatelessWidget {
  final OperatingMode selected;
  final ValueChanged<OperatingMode> onChanged;

  const OperatingModeRow({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: OperatingMode.values.map((mode) {
            final isSelected = mode == selected;
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(mode),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    // 1. Change to primary for a solid blue background
                    color: isSelected
                        ? colors.primary
                        : colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    // Border might not be needed if the background is solid primary,
                    // but leaving it here as it won't hurt.
                    border: isSelected
                        ? Border.all(color: colors.primary, width: 2)
                        : null,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _iconFor(mode),
                        size: 20,
                        // 2. Change to onPrimary (usually white) for contrast
                        color: isSelected
                            ? colors.onPrimary
                            : colors.onSurfaceVariant,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _labelFor(mode),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          // 3. Change to onPrimary here as well
                          color: isSelected
                              ? colors.onPrimary
                              : colors.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Text(
          _subtitleFor(selected),
          style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
        ),
      ],
    );
  }

  IconData _iconFor(OperatingMode mode) {
    switch (mode) {
      case OperatingMode.normal:
        return Icons.radio_button_checked_rounded;
      case OperatingMode.battery:
        return Icons.battery_saver_rounded;
      case OperatingMode.live:
        return Icons.sensors_rounded;
      case OperatingMode.private:
        return Icons.visibility_off_rounded;
      case OperatingMode.doNotTrack:
        return Icons.do_not_disturb_on_rounded;
    }
  }

  String _labelFor(OperatingMode mode) {
    switch (mode) {
      case OperatingMode.normal:
        return 'Normal';
      case OperatingMode.battery:
        return 'Battery';
      case OperatingMode.live:
        return 'Live';
      case OperatingMode.private:
        return 'Private';
      case OperatingMode.doNotTrack:
        return 'Do Not Tra…';
    }
  }

  String _subtitleFor(OperatingMode mode) {
    switch (mode) {
      case OperatingMode.normal:
        return 'Full visibility · Updates 30 sec';
      case OperatingMode.battery:
        return 'Reduced updates · Battery optimised';
      case OperatingMode.live:
        return 'Real-time updates · High accuracy';
      case OperatingMode.private:
        return 'Hidden from all guardians';
      case OperatingMode.doNotTrack:
        return 'Tracking disabled';
    }
  }
}
