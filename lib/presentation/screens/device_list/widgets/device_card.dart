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
  final String currentUserFullName;
  final List deviceAlerts;
  final VoidCallback onTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onViewModesTap;

  const DeviceCard({
    super.key,
    required this.device,
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
    final currentMode = device.currentMode;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow(context).withValues(alpha: 0.06),
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              device.displayOwnerName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary(context),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          StatusDot(
                            state: _isOnline,
                            onLabel: 'ONLINE',
                            offLabel: 'OFFLINE',
                            onColor: AppColors.success,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Metrics Panel
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.textSecondary(
                            context,
                          ).withValues(alpha: 0.05),
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

                      // -------------------------------------------------------
                      // Location, Temp & Mode Row with Dynamic Spacers
                      // -------------------------------------------------------
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Zone Location (Flexible multi-line text)
                          Flexible(
                            flex: 3,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.location_on_rounded,
                                  size: 13,
                                  color: AppColors.textSecondary(context),
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    'Zone : ${device.geoidLocation ?? 'N/A'}',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontFamily: 'monospace',
                                      color: AppColors.textSecondary(context),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Spacer before Temperature
                          if (device.temperature != null) ...[
                            const Spacer(),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.thermostat_rounded,
                                  size: 13,
                                  color: AppColors.textSecondary(context),
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  device.temperature!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontFamily: 'monospace',
                                    color: AppColors.textSecondary(context),
                                  ),
                                ),
                              ],
                            ),
                          ],

                          // Spacer after Temperature / before Mode Badge
                          const Spacer(),

                          // Mode Badge (Flexible multi-line text)
                          Flexible(
                            flex: 2,
                            child: Container(
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
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.info,
                                ),
                              ),
                            ),
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
    return Container(
      width: 1,
      height: 34,
      color: AppColors.textSecondary(context).withValues(alpha: 0.15),
    );
  }
}
