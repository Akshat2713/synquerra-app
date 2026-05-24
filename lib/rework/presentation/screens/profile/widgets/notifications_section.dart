// lib/presentation/pages/profile/widgets/notifications_section.dart

import 'package:flutter/material.dart';
import '../../../../presentation/blocs/profile/profile_bloc.dart'
    show NotificationType;

/// Callback signature: (type, newValue)
typedef NotificationToggleCallback =
    void Function(NotificationType type, bool value);

class NotificationsSection extends StatelessWidget {
  final bool emergency;
  final bool daily;
  final bool movement;
  final bool battery;
  final NotificationToggleCallback onChanged;

  const NotificationsSection({
    super.key,
    required this.emergency,
    required this.daily,
    required this.movement,
    required this.battery,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _NotifRow(
            left: _NotifItem(
              icon: Icons.warning_amber_rounded,
              iconColor: colors.error,
              label: 'Emergency',
              value: emergency,
              onChanged: (v) => onChanged(NotificationType.emergency, v),
            ),
            right: _NotifItem(
              icon: Icons.calendar_today_rounded,
              iconColor: colors.primary,
              label: 'Daily',
              value: daily,
              onChanged: (v) => onChanged(NotificationType.daily, v),
            ),
            showDivider: true,
          ),
          _NotifRow(
            left: _NotifItem(
              icon: Icons.directions_walk_rounded,
              iconColor: colors.tertiary,
              label: 'Movement',
              value: movement,
              onChanged: (v) => onChanged(NotificationType.movement, v),
            ),
            right: _NotifItem(
              icon: Icons.battery_full_rounded,
              iconColor: Colors.green,
              label: 'Battery',
              value: battery,
              onChanged: (v) => onChanged(NotificationType.battery, v),
            ),
            showDivider: false,
          ),
        ],
      ),
    );
  }
}

// ── Private helpers ───────────────────────────────────────────────────────────

class _NotifItem {
  final IconData icon;
  final Color iconColor;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotifItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.onChanged,
  });
}

class _NotifRow extends StatelessWidget {
  final _NotifItem left;
  final _NotifItem right;
  final bool showDivider;

  const _NotifRow({
    required this.left,
    required this.right,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _NotifToggle(item: left)),
            Container(width: 1, height: 52, color: colors.outlineVariant),
            Expanded(child: _NotifToggle(item: right)),
          ],
        ),
        if (showDivider) Divider(height: 1, color: colors.outlineVariant),
      ],
    );
  }
}

class _NotifToggle extends StatelessWidget {
  final _NotifItem item;
  const _NotifToggle({required this.item});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Icon(item.icon, size: 18, color: item.iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              item.label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: item.value,
              onChanged: item.onChanged,
              activeColor: colors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
