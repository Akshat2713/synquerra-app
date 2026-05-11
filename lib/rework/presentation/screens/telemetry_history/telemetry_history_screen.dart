import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:synquerra/rework/presentation/utils/alert_code_helper.dart';
import '../../../domain/entities/device/device_entity.dart';
import '../../../domain/entities/analytics/analytics_entity.dart';
import '../../blocs/analytics/analytics_bloc.dart';
import '../../utils/date_time_formatter.dart';
import '../../widgets/analytics_filter_sheet.dart';
// import '../../core/utils/alert_code_helper.dart'; // ← pure utility, no UI
// import '../../core/utils/date_time_formatter.dart'; // your DateTimeFormatter

class TelemetryHistoryScreen extends StatefulWidget {
  // final DeviceEntity device;
  final DeviceEntity device;

  const TelemetryHistoryScreen({super.key, required this.device});

  @override
  State<TelemetryHistoryScreen> createState() => _TelemetryHistoryScreenState();
}

class _TelemetryHistoryScreenState extends State<TelemetryHistoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AnalyticsBloc>().add(AnalyticsLoadDefault(widget.device.imei));
  }

  void _onFilterSelected(AnalyticsFilter filter) {
    context.read<AnalyticsBloc>().add(
      AnalyticsFilterChanged(imei: widget.device.imei, filter: filter),
    );
  }

  void _onCustomSelected(DateTime start, DateTime end) {
    context.read<AnalyticsBloc>().add(
      AnalyticsCustomRangeSelected(
        imei: widget.device.imei,
        startDate: start,
        endDate: end,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Telemetry History',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'IMEI: ${widget.device.imei}',
              style: TextStyle(
                fontSize: 11,
                color: colors.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        // Only the filter icon in the app bar
        actions: [
          BlocBuilder<AnalyticsBloc, AnalyticsState>(
            builder: (context, state) {
              final activeFilter = state is AnalyticsLoaded
                  ? state.activeFilter
                  : AnalyticsFilter.latest;
              return IconButton(
                icon: const Icon(Icons.filter_list_rounded),
                tooltip: 'Filter',
                onPressed: () => showAnalyticsFilterSheet(
                  context: context,
                  activeFilter: activeFilter,
                  onFilterSelected: _onFilterSelected,
                  onCustomSelected: _onCustomSelected,
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<AnalyticsBloc, AnalyticsState>(
        builder: (context, state) {
          if (state is AnalyticsLoading || state is AnalyticsInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AnalyticsError) {
            return _ErrorView(message: state.message);
          }
          if (state is AnalyticsLoaded) {
            if (state.points.isEmpty) {
              return _EmptyView(filter: state.activeFilter);
            }
            return _TelemetryList(
              points: state.points,
              filter: state.activeFilter,
              startDate: state.startDate,
              endDate: state.endDate,
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Telemetry List
// ─────────────────────────────────────────────────────────────────────────────

class _TelemetryList extends StatelessWidget {
  final List<AnalyticsEntity> points;
  final AnalyticsFilter filter;
  final DateTime? startDate;
  final DateTime? endDate;

  const _TelemetryList({
    required this.points,
    required this.filter,
    this.startDate,
    this.endDate,
  });

  String get _subtitle {
    switch (filter) {
      case AnalyticsFilter.latest:
        return 'Latest record';
      case AnalyticsFilter.lastHour:
        return 'Last 1 hour';
      case AnalyticsFilter.last24Hours:
        return 'Last 24 hours';
      case AnalyticsFilter.lastWeek:
        return 'Last 7 days';
      case AnalyticsFilter.custom:
        if (startDate != null && endDate != null) {
          return '${startDate!.day}/${startDate!.month}/${startDate!.year}'
              ' – ${endDate!.day}/${endDate!.month}/${endDate!.year}';
        }
        return 'Custom range';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      children: [
        Container(
          width: double.infinity,
          color: colors.primaryContainer.withOpacity(0.4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(
                Icons.timeline_rounded,
                size: 16,
                color: colors.onPrimaryContainer,
              ),
              const SizedBox(width: 8),
              Text(
                '$_subtitle  ·  ${points.length} record${points.length == 1 ? '' : 's'}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: colors.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            itemCount: points.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) =>
                _TelemetryCard(point: points[i], index: i),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Telemetry Card
// ─────────────────────────────────────────────────────────────────────────────

class _TelemetryCard extends StatelessWidget {
  final AnalyticsEntity point;
  final int index;

  const _TelemetryCard({required this.point, required this.index});

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
                _PacketBadge(isAlert: _isAlert, colors: colors),
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
                  _DataChip(
                    icon: Icons.location_on_rounded,
                    label: 'Location',
                    value:
                        '${point.latitude!.toStringAsFixed(5)}, ${point.longitude!.toStringAsFixed(5)}',
                    colors: colors,
                  ),
                if (point.speed != null)
                  _DataChip(
                    icon: Icons.speed_rounded,
                    label: 'Speed',
                    value: '${point.speed} km/h',
                    colors: colors,
                  ),
                if (point.battery != null)
                  _DataChip(
                    icon: Icons.battery_charging_full_rounded,
                    label: 'Battery',
                    value: '${point.battery}%',
                    colors: colors,
                    accent: _batteryColor(point.battery, colors),
                  ),
                if (point.signal != null)
                  _DataChip(
                    icon: Icons.signal_cellular_alt_rounded,
                    label: 'Signal',
                    value: '${point.signal}',
                    colors: colors,
                  ),
                if (point.temperature != null)
                  _DataChip(
                    icon: Icons.thermostat_rounded,
                    label: 'Temp',
                    value: '${point.temperature}°C',
                    colors: colors,
                  ),
                if (point.geoid != null)
                  _DataChip(
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

  Color _batteryColor(String? battery, ColorScheme colors) {
    final val = int.tryParse(battery ?? '') ?? 100;
    if (val <= 20) return colors.error;
    if (val <= 40) return Colors.orange;
    return Colors.green;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Supporting widgets
// ─────────────────────────────────────────────────────────────────────────────

class _PacketBadge extends StatelessWidget {
  final bool isAlert;
  final ColorScheme colors;
  const _PacketBadge({required this.isAlert, required this.colors});

  @override
  Widget build(BuildContext context) {
    final bg = isAlert ? colors.error : colors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAlert ? Icons.warning_rounded : Icons.check_circle_rounded,
            size: 12,
            color: isAlert ? colors.onError : colors.onPrimary,
          ),
          const SizedBox(width: 4),
          Text(
            isAlert ? 'Alert' : 'Normal',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isAlert ? colors.onError : colors.onPrimary,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _DataChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ColorScheme colors;
  final Color? accent;

  const _DataChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.colors,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final fg = accent ?? colors.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surface.withOpacity(0.7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  color: colors.onSurfaceVariant.withOpacity(0.7),
                  letterSpacing: 0.3,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final AnalyticsFilter filter;
  const _EmptyView({required this.filter});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inbox_rounded,
            size: 60,
            color: colors.onSurfaceVariant.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No telemetry data',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 6),
          Text(
            'Try a different time range using the filter icon above.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 60,
              color: colors.error.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load telemetry',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: colors.onSurface),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
