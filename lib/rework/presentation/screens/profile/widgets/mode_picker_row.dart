// presentation/pages/profile/widgets/mode_picker_row.dart
import 'package:flutter/material.dart';
import '../../../../domain/entities/modes/mode_entity.dart';

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

  String _fmt(int seconds) {
    if (seconds < 60) return '${seconds}s';
    if (seconds < 3600) return '${seconds ~/ 60}m';
    return '${seconds ~/ 3600}h';
  }

  IconData _iconFor(ModeEntity mode) {
    switch (mode.name.toLowerCase()) {
      case 'normal':
        return Icons.radio_button_checked_rounded;
      case 'battery saving':
      case 'battery':
        return Icons.battery_saver_rounded;
      case 'live':
        return Icons.sensors_rounded;
      case 'private':
        return Icons.visibility_off_rounded;
      case 'do not track':
        return Icons.do_not_disturb_on_rounded;
      default:
        return Icons.tune_rounded;
    }
  }

  void _showDetailSheet(BuildContext context, ModeEntity mode) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(_iconFor(mode), color: colors.primary, size: 22),
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
              value: _fmt(mode.normalSendingInterval),
            ),
            _DetailRow(
              icon: Icons.radar_rounded,
              label: 'Scan Interval',
              value: _fmt(mode.normalScanningInterval),
            ),
            _DetailRow(
              icon: Icons.sos_rounded,
              label: 'SOS Interval',
              value: _fmt(mode.sosSendingInterval),
            ),
            _DetailRow(
              icon: Icons.airplanemode_active_rounded,
              label: 'Airplane Interval',
              value: _fmt(mode.airplaneInterval),
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
                          _iconFor(mode),
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
                    : '${activeMode.name} · Send every ${_fmt(activeMode.normalSendingInterval)}',
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
// class ModePickerRow extends StatelessWidget {
//   final List<ModeEntity> modes;
//   final String? activeModeId;
//   final bool isSwitching;
//   final ValueChanged<String> onChanged;

//   const ModePickerRow({
//     super.key,
//     required this.modes,
//     required this.activeModeId,
//     required this.isSwitching,
//     required this.onChanged,
//   });

//   // Humanize seconds
//   String _fmt(int seconds) {
//     if (seconds < 60) return '${seconds}s';
//     if (seconds < 3600) return '${seconds ~/ 60}m';
//     return '${seconds ~/ 3600}h';
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colors = Theme.of(context).colorScheme;

//     if (modes.isEmpty) {
//       return Text(
//         'No modes available',
//         style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
//       );
//     }

//     final activeMode = modes.firstWhere(
//       (m) => m.id == activeModeId,
//       orElse: () => modes.first,
//     );

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // ── Scrollable mode chips ──────────────────
//         SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           child: Row(
//             children: modes.map((mode) {
//               final isSelected = mode.id == activeModeId;
//               return GestureDetector(
//                 onTap: (isSwitching || isSelected)
//                     ? null
//                     : () => onChanged(mode.id),
//                 child: AnimatedContainer(
//                   duration: const Duration(milliseconds: 200),
//                   margin: const EdgeInsets.only(right: 8),
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 10,
//                   ),
//                   decoration: BoxDecoration(
//                     color: isSelected
//                         ? colors.primary
//                         : colors.surfaceContainerHighest,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Text(
//                     mode.name,
//                     style: TextStyle(
//                       fontSize: 13,
//                       fontWeight: isSelected
//                           ? FontWeight.w700
//                           : FontWeight.w500,
//                       color: isSelected
//                           ? colors.onPrimary
//                           : colors.onSurfaceVariant,
//                     ),
//                   ),
//                 ),
//               );
//             }).toList(),
//           ),
//         ),

//         const SizedBox(height: 10),

//         // ── Active mode detail card ────────────────
//         AnimatedSwitcher(
//           duration: const Duration(milliseconds: 250),
//           child: isSwitching
//               ? _SwitchingIndicator(colors: colors)
//               : _ModeDetailCard(mode: activeMode, fmt: _fmt),
//         ),
//       ],
//     );
//   }
// }

// class _ModeDetailCard extends StatelessWidget {
//   final ModeEntity mode;
//   final String Function(int) fmt;

//   const _ModeDetailCard({required this.mode, required this.fmt});

//   @override
//   Widget build(BuildContext context) {
//     final colors = Theme.of(context).colorScheme;
//     final textTheme = Theme.of(context).textTheme;

//     return Container(
//       key: ValueKey(mode.id),
//       width: double.infinity,
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           if (mode.description.isNotEmpty) ...[
//             Text(
//               mode.description,
//               style: textTheme.bodySmall?.copyWith(
//                 color: colors.onSurfaceVariant,
//               ),
//             ),
//             const SizedBox(height: 8),
//           ],
//           Row(
//             children: [
//               _MiniStat(label: 'Send', value: fmt(mode.normalSendingInterval)),
//               const SizedBox(width: 8),
//               _MiniStat(label: 'Scan', value: fmt(mode.normalScanningInterval)),
//               const SizedBox(width: 8),
//               _MiniStat(label: 'SOS', value: fmt(mode.sosSendingInterval)),
//               const SizedBox(width: 8),
//               _MiniStat(label: 'Low bat', value: '${mode.lowbatLimit}%'),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _SwitchingIndicator extends StatelessWidget {
//   final ColorScheme colors;
//   const _SwitchingIndicator({required this.colors});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       key: const ValueKey('switching'),
//       width: double.infinity,
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         children: [
//           SizedBox(
//             width: 14,
//             height: 14,
//             child: CircularProgressIndicator(
//               strokeWidth: 2,
//               color: colors.primary,
//             ),
//           ),
//           const SizedBox(width: 10),
//           Text(
//             'Applying mode…',
//             style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _MiniStat extends StatelessWidget {
//   final String label;
//   final String value;
//   const _MiniStat({required this.label, required this.value});

//   @override
//   Widget build(BuildContext context) {
//     final colors = Theme.of(context).colorScheme;
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 6),
//         decoration: BoxDecoration(
//           color: colors.surface,
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Column(
//           children: [
//             Text(
//               value,
//               style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
//             ),
//             Text(
//               label,
//               style: TextStyle(fontSize: 9, color: colors.onSurfaceVariant),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
