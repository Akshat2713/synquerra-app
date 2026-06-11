// presentation/pages/profile/widgets/mode_picker_row.dart
import 'package:flutter/material.dart';
import 'package:synquerra/presentation/utils/date_time_formatter.dart';
import '../../../../domain/entities/modes/mode_entity.dart';
import '../../../utils/mode_icon_resolver.dart';

class ModePickerRow extends StatelessWidget {
  final List<ModeEntity> modes;
  final String? activeModeId;
  final bool isSwitching;
  final ValueChanged<String> onChanged;

  const ModePickerRow({
    super.key,
    required this.modes,
    required this.activeModeId,
    required this.isSwitching,
    required this.onChanged,
  });

  void _showDetailSheet(BuildContext context, ModeEntity mode) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              ModeIconResolver.resolve(mode),
              color: colors.primary,
              size: 22,
            ),
            const SizedBox(width: 10),
            Text(
              mode.name,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            if (mode.isSystemMode)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: colors.secondaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'System',
                  style: textTheme.labelSmall?.copyWith(
                    color: colors.onSecondaryContainer,
                  ),
                ),
              ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (mode.description.isNotEmpty) ...[
              Text(
                mode.description,
                style: textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
            ],
            _DetailRow(
              icon: Icons.send_rounded,
              label: 'Send Interval',
              value: DateTimeFormatter.formatInterval(
                mode.normalSendingInterval,
              ),
            ),
            _DetailRow(
              icon: Icons.radar_rounded,
              label: 'Scan Interval',
              value: DateTimeFormatter.formatInterval(
                mode.normalScanningInterval,
              ),
            ),
            _DetailRow(
              icon: Icons.sos_rounded,
              label: 'SOS Interval',
              value: DateTimeFormatter.formatInterval(mode.sosSendingInterval),
            ),
            _DetailRow(
              icon: Icons.airplanemode_active_rounded,
              label: 'Airplane Interval',
              value: DateTimeFormatter.formatInterval(mode.airplaneInterval),
            ),
            _DetailRow(
              icon: Icons.speed_rounded,
              label: 'Speed Limit',
              value: '${mode.speedLimit.toInt()} km/h',
            ),
            _DetailRow(
              icon: Icons.thermostat_rounded,
              label: 'Temp Limit',
              value: '${mode.temperatureLimit.toInt()}°C',
            ),
            _DetailRow(
              icon: Icons.battery_alert_rounded,
              label: 'Low Battery',
              value: '${mode.lowbatLimit}%',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (modes.isEmpty) {
      return Text(
        'No modes available',
        style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
      );
    }

    // Find active mode for subtitle — fallback to first
    final activeMode = modes.firstWhere(
      (m) => m.id == activeModeId,
      orElse: () => modes.first,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Mode chips row ─────────────────────────
        Row(
          children: modes.map((mode) {
            final isSelected = mode.id == activeModeId;
            return Expanded(
              child: GestureDetector(
                onTap: (isSwitching || isSelected)
                    ? null
                    : () => onChanged(mode.id),
                onLongPress: () => _showDetailSheet(context, mode),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colors.primary
                        : colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(color: colors.primary, width: 2)
                        : null,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Show spinner on the active chip while switching
                      if (isSwitching && isSelected)
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colors.onPrimary,
                          ),
                        )
                      else
                        Icon(
                          ModeIconResolver.resolve(mode),
                          size: 20,
                          color: isSelected
                              ? colors.onPrimary
                              : colors.onSurfaceVariant,
                        ),
                      const SizedBox(height: 4),
                      Text(
                        mode.name,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected
                              ? colors.onPrimary
                              : colors.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 8),

        // ── Active mode subtitle ───────────────────
        Row(
          children: [
            Expanded(
              child: Text(
                isSwitching
                    ? 'Applying mode…'
                    : '${activeMode.name} · Send every ${DateTimeFormatter.formatInterval(activeMode.normalSendingInterval)}',
                style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
              ),
            ),
            Text(
              'Hold for details',
              style: TextStyle(
                fontSize: 10,
                color: colors.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Detail row ─────────────────────────────────────────────────────────────
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, size: 15, color: colors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
