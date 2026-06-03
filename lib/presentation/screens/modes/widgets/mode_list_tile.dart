// presentation/pages/mode/widgets/mode_list_tile.dart
import 'package:flutter/material.dart';

import '../../../../domain/entities/modes/mode_entity.dart';

class ModeListTile extends StatelessWidget {
  final ModeEntity mode;
  final bool isSelected;
  final VoidCallback onTap;

  const ModeListTile({
    super.key,
    required this.mode,
    required this.isSelected,
    required this.onTap,
  });

  // Humanize seconds → "30 min", "1 hr", etc.
  String _formatInterval(int seconds) {
    if (seconds < 60) return '${seconds}s';
    if (seconds < 3600) return '${seconds ~/ 60}m';
    return '${seconds ~/ 3600}h';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primaryContainer.withValues(alpha: 0.5)
              : colors.surface,
          border: Border.all(
            color: isSelected ? colors.primary : colors.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row ──────────────────────────
            Row(
              children: [
                Expanded(
                  child: Text(
                    mode.name,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isSelected ? colors.primary : colors.onSurface,
                    ),
                  ),
                ),
                if (mode.isSystemMode)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
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
                const SizedBox(width: 8),
                // Selection indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? colors.primary : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? colors.primary
                          : colors.outlineVariant,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: Colors.white,
                        )
                      : null,
                ),
              ],
            ),

            if (mode.description.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                mode.description,
                style: textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // ── Interval stats grid ──────────────────
            Row(
              children: [
                _StatChip(
                  icon: Icons.send_rounded,
                  label: 'Send',
                  value: _formatInterval(mode.normalSendingInterval),
                ),
                const SizedBox(width: 8),
                _StatChip(
                  icon: Icons.radar_rounded,
                  label: 'Scan',
                  value: _formatInterval(mode.normalScanningInterval),
                ),
                const SizedBox(width: 8),
                _StatChip(
                  icon: Icons.sos_rounded,
                  label: 'SOS',
                  value: _formatInterval(mode.sosSendingInterval),
                ),
                const SizedBox(width: 8),
                _StatChip(
                  icon: Icons.battery_2_bar_rounded,
                  label: 'Low bat',
                  value: '${mode.lowbatLimit}%',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: colors.primary),
            const SizedBox(height: 4),
            Text(
              value,
              style: textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
            ),
            Text(
              label,
              style: textTheme.labelSmall?.copyWith(
                fontSize: 9,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
