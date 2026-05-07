import 'package:flutter/material.dart';
import '../../../../domain/entities/device/device_entity.dart';
// import '../../../../domain/entities/analytics/analytics_entity.dart';
import '../../../blocs/analytics/analytics_bloc.dart';

class DeviceInfoPanel extends StatelessWidget {
  final DeviceEntity device;
  final AnalyticsLoaded? loaded;

  const DeviceInfoPanel({
    super.key,
    required this.device,
    required this.loaded,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.onSurfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Scrollable content
          SizedBox(
            height: 180,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Row(
                children: [
                  _infoCard(
                    context: context,
                    icon: Icons.person_rounded,
                    label: 'Student',
                    value: device.studentName,
                    colors: colors,
                  ),
                  _infoCard(
                    context: context,
                    icon: Icons.battery_charging_full_rounded,
                    label: 'Battery',
                    value: device.battery != null
                        ? '${device.battery}%'
                        : 'N/A',
                    colors: colors,
                    valueColor: _batteryColor(device.battery),
                  ),
                  _infoCard(
                    context: context,
                    icon: Icons.signal_cellular_alt_rounded,
                    label: 'Signal',
                    value: device.signal != null ? '${device.signal}%' : 'N/A',
                    colors: colors,
                  ),
                  _infoCard(
                    context: context,
                    icon: Icons.gps_fixed_rounded,
                    label: 'GPS',
                    value: device.gpsStrength ?? 'N/A',
                    colors: colors,
                  ),
                  _infoCard(
                    context: context,
                    icon: Icons.thermostat_rounded,
                    label: 'Temperature',
                    value: device.temperature ?? 'N/A',
                    colors: colors,
                  ),
                  _infoCard(
                    context: context,
                    icon: Icons.speed_rounded,
                    label: 'Speed',
                    value: device.speed ?? 'N/A',
                    colors: colors,
                  ),
                  _infoCard(
                    context: context,
                    icon: Icons.location_on_rounded,
                    label: 'Zone',
                    value: 'Zone ${device.geoid}',
                    colors: colors,
                  ),
                  _infoCard(
                    context: context,
                    icon: Icons.sim_card_rounded,
                    label: 'IMEI',
                    value: device.imei,
                    colors: colors,
                    narrow: false,
                  ),
                  _infoCard(
                    context: context,
                    icon: Icons.update_rounded,
                    label: 'Last Update',
                    value: _formatTimestamp(device.timestamp),
                    colors: colors,
                    narrow: false,
                  ),
                  // Latest analytics point if available
                  if (loaded != null && loaded!.points.isNotEmpty) ...[
                    _divider(colors),
                    _infoCard(
                      context: context,
                      icon: Icons.analytics_rounded,
                      label: 'Data Points',
                      value: '${loaded!.points.length}',
                      colors: colors,
                    ),
                    _infoCard(
                      context: context,
                      icon: Icons.route_rounded,
                      label: 'Mapped',
                      value: '${loaded!.mappablePoints.length}',
                      colors: colors,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required ColorScheme colors,
    Color? valueColor,
    bool narrow = true,
  }) {
    return Container(
      width: narrow ? 100 : 140,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, size: 20, color: colors.primary),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: valueColor ?? colors.onSurface,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _divider(ColorScheme colors) {
    return Container(
      width: 1,
      height: 80,
      margin: const EdgeInsets.only(right: 10),
      color: colors.outlineVariant,
    );
  }

  Color _batteryColor(String? battery) {
    if (battery == null) return Colors.grey;
    final v = int.tryParse(battery) ?? 0;
    if (v <= 20) return const Color(0xFFFF4444);
    if (v <= 50) return const Color(0xFFFFAA00);
    return const Color(0xFF22C55E);
  }

  String _formatTimestamp(String? ts) {
    if (ts == null) return 'N/A';
    try {
      final dt = DateTime.parse(ts);
      return '${dt.day}/${dt.month} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return ts;
    }
  }
}
