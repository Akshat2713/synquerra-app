import 'package:flutter/material.dart';
import '../../domain/entities/device/device_entity.dart';
import '../../domain/entities/alerts/alert_entity.dart';

class DeviceCard extends StatelessWidget {
  final DeviceEntity device;
  final bool isActive;
  final List<AlertEntity> deviceAlerts;
  final VoidCallback onTap;
  final VoidCallback onToggleActive;

  const DeviceCard({
    super.key,
    required this.device,
    required this.isActive,
    required this.deviceAlerts,
    required this.onTap,
    required this.onToggleActive,
  });

  // Border color based on alert severity for this device
  Color _borderColor() {
    final hasCritical = deviceAlerts.any(
      (a) => a.severity == AlertSeverity.critical && !a.isAcknowledged,
    );
    final hasAdvisory = deviceAlerts.any(
      (a) => a.severity == AlertSeverity.advisory && !a.isAcknowledged,
    );

    if (hasCritical) return const Color(0xFFFF4444);
    if (hasAdvisory) return const Color(0xFFFFAA00);
    return const Color(0xFF22C55E);
  }

  Color _borderColorLight() => _borderColor().withOpacity(0.15);

  Widget _statChip({
    required IconData icon,
    required String? value,
    required Color color,
    String fallback = 'N/A',
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          value ?? fallback,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final border = _borderColor();
    final borderLight = _borderColorLight();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: border.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Top colored strip ────────────────────
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: border,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 12, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header row ───────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar / icon
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: borderLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.person_rounded,
                          color: border,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Name + IMEI
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              device.studentName,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: colors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'IMEI: ${device.imei}',
                              style: TextStyle(
                                fontSize: 11,
                                color: colors.onSurfaceVariant,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Three dots menu
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert_rounded,
                          color: colors.onSurfaceVariant,
                          size: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        itemBuilder: (_) => [
                          const PopupMenuItem(
                            value: 'details',
                            child: Text('View Details'),
                          ),
                          const PopupMenuItem(
                            value: 'alerts',
                            child: Text('View Alerts'),
                          ),
                          const PopupMenuItem(
                            value: 'settings',
                            child: Text('Device Settings'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── Stats row ────────────────────────
                  Row(
                    children: [
                      _statChip(
                        icon: Icons.battery_charging_full_rounded,
                        value: device.battery != null
                            ? '${device.battery}%'
                            : null,
                        color: _batteryColor(device.battery),
                      ),
                      const SizedBox(width: 16),
                      _statChip(
                        icon: Icons.signal_cellular_alt_rounded,
                        value: device.signal != null
                            ? '${device.signal}%'
                            : null,
                        color: colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 16),
                      _statChip(
                        icon: Icons.gps_fixed_rounded,
                        value: device.gpsStrength,
                        color: colors.onSurfaceVariant,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // ── Bottom row: temp + geoid + toggle ─
                  Row(
                    children: [
                      // Temperature
                      if (device.temperature != null) ...[
                        Icon(
                          Icons.thermostat_rounded,
                          size: 14,
                          color: colors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          device.temperature!,
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],

                      // Geo ID
                      Icon(
                        Icons.location_on_rounded,
                        size: 14,
                        color: colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Zone ${device.geoid}',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.onSurfaceVariant,
                        ),
                      ),

                      const Spacer(),

                      // Active/Inactive toggle
                      GestureDetector(
                        onTap: onToggleActive,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xFF22C55E).withOpacity(0.12)
                                : colors.onSurfaceVariant.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isActive
                                  ? const Color(0xFF22C55E)
                                  : colors.onSurfaceVariant.withOpacity(0.4),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? const Color(0xFF22C55E)
                                      : colors.onSurfaceVariant,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                isActive ? 'Active' : 'Inactive',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isActive
                                      ? const Color(0xFF22C55E)
                                      : colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _batteryColor(String? battery) {
    if (battery == null) return Colors.grey;
    final value = int.tryParse(battery) ?? 0;
    if (value <= 20) return const Color(0xFFFF4444);
    if (value <= 50) return const Color(0xFFFFAA00);
    return const Color(0xFF22C55E);
  }
}
