import 'package:flutter/material.dart';
import '../../../../domain/entities/device/device_entity.dart';
import '../../../../domain/entities/alerts/alert_entity.dart';
import '../../../themes/colors.dart';
import '../../../utils/colour_util.dart';
import '../../../utils/device_display_util.dart';

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

  Color _railColor() => deviceSeverityColor(deviceAlerts);

  bool get _isOnline => device.isOnline ?? false;
  bool get _isCharging => device.isCharging ?? false;

  int _signalBarsFilled(int? signal) {
    final s = signal ?? 0;
    if (s >= 75) return 4;
    if (s >= 50) return 3;
    if (s >= 25) return 2;
    if (s > 0) return 1;
    return 0;
  }

  Widget _batteryGauge(ColorScheme colors) {
    final level = device.battery;
    final color = batteryColor(level);
    return SizedBox(
      width: 42,
      height: 42,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 38,
            height: 38,
            child: CircularProgressIndicator(
              value: (level ?? 0) / 100,
              strokeWidth: 3.5,
              backgroundColor: colors.onSurfaceVariant.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          Text(
            '${level ?? '–'}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          if (_isCharging)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: colors.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.bolt_rounded,
                  size: 11,
                  color: AppColors.alertWarning,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _signalMeter(ColorScheme colors) {
    final filled = _signalBarsFilled(device.signal);
    const heights = [7.0, 11.0, 15.0, 19.0];
    return SizedBox(
      width: 42,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(4, (i) {
              final isFilled = i < filled;
              return Container(
                width: 4,
                height: heights[i],
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                decoration: BoxDecoration(
                  color: isFilled
                      ? AppColors.info
                      : colors.onSurfaceVariant.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(1.5),
                ),
              );
            }),
          ),
          const SizedBox(height: 4),
          Text(
            device.signal != null ? '${device.signal}%' : '–',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _gpsReadout(ColorScheme colors) {
    return SizedBox(
      width: 42,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.satellite_alt_rounded,
            size: 16,
            color: colors.onSurfaceVariant,
          ),
          const SizedBox(height: 6),
          Text(
            device.gpsStrength ?? '–',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              fontFamily: 'monospace',
              color: colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _panelDivider(ColorScheme colors) => Container(
    width: 1,
    height: 34,
    color: colors.onSurfaceVariant.withValues(alpha: 0.15),
  );

  Widget _statusDot({
    required bool state,
    required String onLabel,
    required String offLabel,
    required Color onColor,
    required ColorScheme colors,
  }) {
    final color = state
        ? onColor
        : colors.onSurfaceVariant.withValues(alpha: 0.6);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          state ? onLabel : offLabel,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
            color: color,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final rail = _railColor();
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
              color: Colors.black.withValues(alpha: 0.06),
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
              Container(width: 5, color: rail),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              ownerDisplayName(device, currentUserFullName),
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
                            _batteryGauge(colors),
                            _panelDivider(colors),
                            _signalMeter(colors),
                            _panelDivider(colors),
                            _gpsReadout(colors),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
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
                      Row(
                        children: [
                          _statusDot(
                            state: _isOnline,
                            onLabel: 'ONLINE',
                            offLabel: 'OFFLINE',
                            onColor: AppColors.alertSuccess,
                            colors: colors,
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
                          _statusDot(
                            state: isActive,
                            onLabel: 'ACTIVE',
                            offLabel: 'INACTIVE',
                            onColor: AppColors.alertSuccess,
                            colors: colors,
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
