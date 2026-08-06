import 'package:flutter/material.dart';

import '../../../../domain/entities/alerts/alert_entity.dart';
import '../../../../domain/entities/device/device_entity.dart';
import '../../../themes/colors.dart';
import '../../../utils/colour_util.dart';
import 'device_card/battery_gauge.dart';
import 'device_card/gps_readout.dart';
import 'device_card/signal_meter.dart';
import 'device_card/status_dot.dart';

class DeviceCard extends StatelessWidget {
  final DeviceEntity device;
  final bool isActive;
  final String currentUserFullName;
  final List<AlertEntity> deviceAlerts;
  final VoidCallback onTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onViewModesTap;

  const DeviceCard({
    super.key,
    required this.device,
    required this.isActive,
    required this.currentUserFullName,
    required this.deviceAlerts,
    required this.onTap,
    this.onSettingsTap,
    this.onViewModesTap,
  });

  Color get _railColor => deviceSeverityColor(deviceAlerts);
  bool get _isOnline => device.isOnline ?? false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final currentMode = device.currentMode;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 5, color: _railColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              device.displayOwnerName(currentUserFullName),
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: colors.onSurface,
                              ),
                            ),
                          ),
                          PopupMenuButton<String>(
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              Icons.more_vert_rounded,
                              color: colors.onSurfaceVariant,
                              size: 20,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            onSelected: (value) {
                              switch (value) {
                                case 'modes':
                                  onViewModesTap?.call();
                                  break;
                                case 'settings':
                                  onSettingsTap?.call();
                                  break;
                              }
                            },
                            itemBuilder: (_) => [
                              PopupMenuItem(
                                value: 'modes',
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('View Modes'),
                                    const SizedBox(width: 6),
                                    Text(
                                      currentMode,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.info,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
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

                      // Metrics Panel
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: colors.onSurfaceVariant.withValues(
                            alpha: 0.05,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            BatteryGauge(
                              batteryLevel: device.battery,
                              isCharging: device.isCharging ?? false,
                            ),
                            const PanelDivider(),
                            SignalMeter(signal: device.signal),
                            const PanelDivider(),
                            GpsReadout(gpsStrength: device.gpsStrength),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Location & Temperature
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 13,
                            color: colors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'Zone ${device.geoid ?? 'N/A'}',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontFamily: 'monospace',
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ),
                          if (device.temperature != null) ...[
                            const SizedBox(width: 12),
                            Icon(
                              Icons.thermostat_rounded,
                              size: 13,
                              color: colors.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              device.temperature!,
                              style: TextStyle(
                                fontSize: 11,
                                fontFamily: 'monospace',
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 10),

                      Divider(
                        height: 1,
                        color: colors.onSurfaceVariant.withValues(alpha: 0.12),
                      ),
                      const SizedBox(height: 8),

                      // Status Footer
                      Row(
                        children: [
                          StatusDot(
                            state: _isOnline,
                            onLabel: 'ONLINE',
                            offLabel: 'OFFLINE',
                            onColor: AppColors.alertSuccess,
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.info.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.info.withValues(alpha: 0.35),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              currentMode,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.info,
                              ),
                            ),
                          ),
                          const Spacer(),
                          StatusDot(
                            state: isActive,
                            onLabel: 'ACTIVE',
                            offLabel: 'INACTIVE',
                            onColor: AppColors.alertSuccess,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PanelDivider extends StatelessWidget {
  const PanelDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: 1,
      height: 34,
      color: colors.onSurfaceVariant.withValues(alpha: 0.15),
    );
  }
}
