import 'package:flutter/material.dart';

import '../../../domain/entities/analytics/analytics_entity.dart';
import '../../utils/alert_code_helper.dart';
import '../../utils/colour_util.dart';
import '../../utils/date_time_formatter.dart';
import 'data_chip.dart';
import 'packet_badge.dart';

class TelemetryCard extends StatelessWidget {
  final AnalyticsEntity point;
  final int index;

  const TelemetryCard({super.key, required this.point, required this.index});

  bool get _isAlert => point.packet?.toUpperCase() == 'A';

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    // AlertCodeHelper.resolve() looks up e.g. 'A1002' → {label:'SOS', icon:...}
    // This is a pure in-memory lookup — no page navigation, no UI.
    final alertMeta = _isAlert ? AlertCodeHelper.resolve(point.alert) : null;
    final alertColor = _isAlert
        ? AlertCodeHelper.colorFor(point.alert, colors)
        : colors.primary;

    final cardColor = _isAlert
        ? colors.errorContainer.withOpacity(0.35)
        : colors.surfaceContainerHighest.withOpacity(0.5);
    final borderColor = _isAlert
        ? colors.error.withOpacity(0.4)
        : colors.outlineVariant;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ───────────────────────────────────────────────
            Row(
              children: [
                PacketBadge(isAlert: _isAlert, colors: colors),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    DateTimeFormatter.toFullDateTime(point.deviceTimestamp),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
                Text(
                  '#${index + 1}',
                  style: TextStyle(
                    fontSize: 11,
                    color: colors.onSurfaceVariant.withOpacity(0.6),
                  ),
                ),
              ],
            ),

            // ── Alert chip ───────────────────────────────────────────
            // Only shown when packet == 'A'.
            // Resolved label comes from AlertCodeHelper — e.g. 'SOS', 'Tampered'
            if (_isAlert && alertMeta != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: alertColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(alertMeta.icon, size: 14, color: alertColor),
                    const SizedBox(width: 6),
                    Text(
                      alertMeta.label, // human-readable name
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: alertColor,
                      ),
                    ),
                    if (point.alert != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        '(${point.alert})', // raw code e.g. (A1002)
                        style: TextStyle(
                          fontSize: 10,
                          color: alertColor.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // ── Data field chips ──────────────────────────────────────
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (point.latitude != null && point.longitude != null)
                  DataChip(
                    icon: Icons.location_on_rounded,
                    label: 'Location',
                    value:
                        '${point.latitude!.toStringAsFixed(5)}, ${point.longitude!.toStringAsFixed(5)}',
                    colors: colors,
                  ),
                if (point.speed != null)
                  DataChip(
                    icon: Icons.speed_rounded,
                    label: 'Speed',
                    value: '${point.speed} km/h',
                    colors: colors,
                  ),
                if (point.battery != null)
                  DataChip(
                    icon: Icons.battery_charging_full_rounded,
                    label: 'Battery',
                    value: '${point.battery}%',
                    colors: colors,
                    accent: batteryColor(point.battery),
                  ),
                if (point.signal != null)
                  DataChip(
                    icon: Icons.signal_cellular_alt_rounded,
                    label: 'Signal',
                    value: '${point.signal}',
                    colors: colors,
                  ),
                if (point.temperature != null)
                  DataChip(
                    icon: Icons.thermostat_rounded,
                    label: 'Temp',
                    value: '${point.temperature}°C',
                    colors: colors,
                  ),
                if (point.geoid != null)
                  DataChip(
                    icon: Icons.public_rounded,
                    label: 'GeoID',
                    value: point.geoid!,
                    colors: colors,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
