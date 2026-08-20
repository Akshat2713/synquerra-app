// presentation/pages/mode/widgets/mode_list_tile.dart
import 'package:flutter/material.dart';

import '../../../../domain/entities/modes/mode_entity.dart';
import '../../../themes/colors.dart';
import '../../../utils/date_time_formatter.dart';

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

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryContainer.withValues(alpha: 0.5)
              : AppColors.surface(context),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.outlineVariant(context),
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
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary(context),
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
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.outlineVariant(context),
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
                  color: AppColors.textSecondary(context),
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
                  value: DateTimeFormatter.formatInterval(
                    mode.normalSendingInterval,
                  ),
                ),
                const SizedBox(width: 8),
                _StatChip(
                  icon: Icons.radar_rounded,
                  label: 'Scan',
                  value: DateTimeFormatter.formatInterval(
                    mode.normalScanningInterval,
                  ),
                ),
                const SizedBox(width: 8),
                _StatChip(
                  icon: Icons.sos_rounded,
                  label: 'SOS',
                  value: DateTimeFormatter.formatInterval(
                    mode.sosSendingInterval,
                  ),
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
    final textTheme = Theme.of(context).textTheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant(context).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(height: 4),
            Text(
              value,
              style: textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary(context),
              ),
            ),
            Text(
              label,
              style: textTheme.labelSmall?.copyWith(
                fontSize: 9,
                color: AppColors.textSecondary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
