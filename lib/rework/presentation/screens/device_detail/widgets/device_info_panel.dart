import 'package:flutter/material.dart';
import '../../../../domain/entities/device/device_entity.dart';
import '../../../blocs/analytics/analytics_bloc.dart';
import '../../../utils/date_time_formatter.dart';

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

    return DraggableScrollableSheet(
      initialChildSize: 0.32,
      minChildSize: 0.14,
      maxChildSize: 0.72,
      snap: true,
      snapSizes: const [0.14, 0.32, 0.72],
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              // ── Drag handle ──────────────────────────
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 4),
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colors.onSurfaceVariant.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Name + Last seen header ───────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Avatar
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: colors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.person_rounded,
                          color: colors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              device.studentName,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: colors.onSurface,
                                letterSpacing: -0.3,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 12,
                                  color: colors.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Last seen ${DateTimeFormatter.toFullDateTime(device.timestamp)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor(device).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _statusLabel(device),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _statusColor(device),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Divider ──────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
                  child: Divider(
                    color: colors.outlineVariant.withOpacity(0.5),
                    height: 1,
                  ),
                ),
              ),

              // ── Data fields grid ─────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _sectionLabel('Device Status', colors),
                    const SizedBox(height: 8),
                    _fieldRow([
                      _fieldData(
                        icon: Icons.battery_charging_full_rounded,
                        label: 'Battery',
                        value: device.battery != null
                            ? '${device.battery}%'
                            : 'N/A',
                        valueColor: _batteryColor(device.battery),
                        colors: colors,
                      ),
                      _fieldData(
                        icon: Icons.signal_cellular_alt_rounded,
                        label: 'Signal',
                        value: device.signal != null
                            ? '${device.signal}%'
                            : 'N/A',
                        colors: colors,
                      ),
                    ]),
                    const SizedBox(height: 10),
                    _fieldRow([
                      _fieldData(
                        icon: Icons.gps_fixed_rounded,
                        label: 'GPS',
                        value: device.gpsStrength ?? 'N/A',
                        colors: colors,
                      ),
                      _fieldData(
                        icon: Icons.thermostat_rounded,
                        label: 'Temperature',
                        value: device.temperature ?? 'N/A',
                        colors: colors,
                      ),
                    ]),
                    const SizedBox(height: 10),
                    _fieldRow([
                      _fieldData(
                        icon: Icons.speed_rounded,
                        label: 'Speed',
                        value: device.speed ?? 'N/A',
                        colors: colors,
                      ),
                      _fieldData(
                        icon: Icons.location_on_rounded,
                        label: 'Zone',
                        value: 'Zone ${device.geoid}',
                        colors: colors,
                      ),
                    ]),
                    const SizedBox(height: 16),

                    _sectionLabel('Device Info', colors),
                    const SizedBox(height: 8),
                    _wideField(
                      icon: Icons.sim_card_rounded,
                      label: 'IMEI',
                      value: device.imei,
                      colors: colors,
                      monospace: true,
                    ),

                    // Analytics section — only when loaded
                    if (loaded != null && loaded!.points.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _sectionLabel('Analytics', colors),
                      const SizedBox(height: 8),
                      _fieldRow([
                        _fieldData(
                          icon: Icons.analytics_rounded,
                          label: 'Data Points',
                          value: '${loaded!.points.length}',
                          colors: colors,
                        ),
                        _fieldData(
                          icon: Icons.route_rounded,
                          label: 'Mapped Points',
                          value: '${loaded!.mappablePoints.length}',
                          colors: colors,
                        ),
                      ]),
                    ],

                    const SizedBox(height: 24),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Helpers ──────────────────────────────────────

  Widget _sectionLabel(String label, ColorScheme colors) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: colors.onSurfaceVariant,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _fieldRow(List<_FieldData> fields) {
    return Builder(
      builder: (context) {
        return Row(
          children: fields.map((f) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: f == fields.last ? 0 : 8),
                child: _buildFieldCard(context, f),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildFieldCard(BuildContext context, _FieldData f) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceVariant.withOpacity(0.45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.outlineVariant.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: colors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(f.icon, size: 18, color: colors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  f.label,
                  style: TextStyle(
                    fontSize: 11,
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  f.value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: f.valueColor ?? colors.onSurface,
                    fontFamily: f.monospace ? 'monospace' : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _wideField({
    required IconData icon,
    required String label,
    required String value,
    required ColorScheme colors,
    bool monospace = false,
  }) {
    return Builder(
      builder: (ctx) => _buildFieldCard(
        ctx,
        _fieldData(
          icon: icon,
          label: label,
          value: value,
          colors: colors,
          monospace: monospace,
        ),
      ),
    );
  }

  _FieldData _fieldData({
    required IconData icon,
    required String label,
    required String value,
    required ColorScheme colors,
    Color? valueColor,
    bool monospace = false,
  }) {
    return _FieldData(
      icon: icon,
      label: label,
      value: value,
      valueColor: valueColor,
      monospace: monospace,
    );
  }

  Color _batteryColor(String? battery) {
    if (battery == null) return Colors.grey;
    final v = int.tryParse(battery) ?? 0;
    if (v <= 20) return const Color(0xFFFF4444);
    if (v <= 50) return const Color(0xFFFFAA00);
    return const Color(0xFF22C55E);
  }

  Color _statusColor(DeviceEntity device) {
    if (device.battery == null) return Colors.grey;
    return const Color(0xFF22C55E);
  }

  String _statusLabel(DeviceEntity device) {
    if (device.battery == null) return 'Offline';
    return 'Online';
  }

  String _formatTimestamp(String? ts) {
    if (ts == null) return 'N/A';
    try {
      final dt = DateTime.parse(ts).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 1) return 'just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${dt.day}/${dt.month} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return ts;
    }
  }
}

// Simple data holder — avoids passing many named args through closures
class _FieldData {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final bool monospace;

  const _FieldData({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.monospace = false,
  });
}
