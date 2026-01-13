import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:synquerra/providers/device_provider.dart';
import 'package:synquerra/providers/searched_device_provider.dart';
import 'package:synquerra/core/services/user_preferences.dart';
import 'package:synquerra/screens/landing/home/details/distence_history.dart';
import 'package:synquerra/screens/landing/home/details/detail_screen.dart';
import 'package:synquerra/core/models/analytics_model.dart';
import 'package:synquerra/theme/colors.dart';

class DataTelemetryScreen extends StatefulWidget {
  final String imei;
  const DataTelemetryScreen({super.key, required this.imei});

  @override
  State<DataTelemetryScreen> createState() => _TelemetryDashboardScreenState();
}

class _TelemetryDashboardScreenState extends State<DataTelemetryScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch data from global provider on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _triggerGlobalRefresh();
    });
  }

  // Determines which provider to hit based on the IMEI
  Future<void> _triggerGlobalRefresh() async {
    final user = await UserPreferences().getUser();
    if (!mounted) return;

    if (widget.imei == user?.imei) {
      // Update primary device data
      context.read<DeviceProvider>().refreshMyDevice(widget.imei);
    } else {
      // Update searched device data
      context.read<SearchedDeviceProvider>().fetchSearchedDevice(widget.imei);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Listen to both providers
    final myProv = context.watch<DeviceProvider>();
    final searchProv = context.watch<SearchedDeviceProvider>();

    // 2. Identify active data source
    // If the current search IMEI matches this screen, use searchProv, else use myProv
    final bool isSearched = searchProv.currentImei == widget.imei;

    final latestData = isSearched
        ? searchProv.latestTelemetry
        : myProv.latestTelemetry;
    final allPackets = isSearched ? searchProv.allPackets : myProv.allPackets;
    final distanceData = isSearched
        ? searchProv.distanceData
        : myProv.distanceData;
    final healthData = isSearched ? searchProv.healthData : myProv.healthData;
    final uptimeData = isSearched ? searchProv.uptimeData : myProv.uptimeData;
    final isLoading = isSearched ? searchProv.isLoading : myProv.isLoading;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? Colors.black87 : const Color(0xFFF2F4F7);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Data Telemetry",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "IMEI: ${widget.imei}",
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        backgroundColor: AppColors.navBlue,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _triggerGlobalRefresh,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader("Live Status", theme),
                    _buildDeviceStatusCard(latestData, allPackets, theme),
                    const SizedBox(height: 24),
                    _sectionHeader("Movement & Travel", theme),
                    _buildDistanceCard(distanceData, theme),
                    const SizedBox(height: 24),
                    _sectionHeader("System Health", theme),
                    _buildHealthCard(healthData, theme),
                    const SizedBox(height: 24),
                    _sectionHeader("Connectivity", theme),
                    _buildUptimeCard(uptimeData, theme),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _sectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
    );
  }

  // --- CARD 1: DEVICE STATUS ---
  Widget _buildDeviceStatusCard(
    AnalyticsData? data,
    List<AnalyticsData> allPackets,
    ThemeData theme,
  ) {
    final isOnline = data != null;

    return _BaseCard(
      theme: theme,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isOnline ? Colors.green : Colors.red,
                      boxShadow: [
                        BoxShadow(
                          color: (isOnline ? Colors.green : Colors.red)
                              .withOpacity(0.4),
                          blurRadius: 6,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isOnline ? "Active" : "Offline",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Text(
                data?.timestamp.split('T').last.split('.')[0] ?? 'No Data',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          _GridStat(
            items: [
              _StatItem(
                "Speed",
                "${data?.speed ?? 0}",
                "km/h",
                Icons.speed,
                Colors.blue,
              ),
              _StatItem(
                "Battery",
                "${data?.battery ?? '-'}",
                "%",
                Icons.battery_std,
                Colors.green,
              ),
              _StatItem(
                "Signal",
                "${data?.signal ?? '-'}",
                "%",
                Icons.signal_cellular_alt,
                Colors.orange,
              ),
              _StatItem(
                "Temperature",
                data?.temperature?.toLowerCase().replaceAll('c', '').trim() ??
                    '-',
                "℃",
                Icons.thermostat,
                Colors.redAccent,
              ),
            ],
            theme: theme,
          ),
          const SizedBox(height: 16),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: const Text(
              "Raw Packet Details",
              style: TextStyle(fontSize: 14),
            ),
            children: [
              _detailRow("Packet Type", data?.packetType ?? "N/A", theme),
              _detailRow("Latitude", "${data?.latitude}", theme),
              _detailRow("Longitude", "${data?.longitude}", theme),
              _detailRow("Alert Code", data?.alert ?? "None", theme),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.history),
              label: const Text("View Full History Log"),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      DeviceDetailsScreen(imei: widget.imei, data: allPackets),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- CARD 2: DISTANCE ---
  Widget _buildDistanceCard(List<AnalyticsDistance> data, ThemeData theme) {
    double total = data.isNotEmpty ? data.last.cumulative : 0.0;
    double lastHour = data.isNotEmpty ? data.last.distance : 0.0;

    return _BaseCard(
      theme: theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Total Distance (24h)",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  Text(
                    "${total.toStringAsFixed(2)} km",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navBlue,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.navBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.directions_car_filled,
                  color: AppColors.navBlue,
                  size: 30,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _detailRow(
            "Distance (Last Hour)",
            "${lastHour.toStringAsFixed(3)} km",
            theme,
          ),
          _detailRow("Data Points", "${data.length} hours recorded", theme),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navBlue,
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      DistanceHistoryScreen(data: data, imei: widget.imei),
                ),
              ),
              child: const Text(
                "View Hourly Breakdown",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- CARD 3: HEALTH ---
  Widget _buildHealthCard(AnalyticsHealth? data, ThemeData theme) {
    final stats = data?.movementStats ?? [];

    return _BaseCard(
      theme: theme,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _ScoreBox(
                  "GPS Score",
                  data?.gpsScore ?? 0,
                  Colors.teal,
                  theme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ScoreBox(
                  "Temp Index",
                  data?.temperatureIndex ?? 0,
                  Colors.deepOrange,
                  theme,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _detailRow(
            "Temperature Status",
            data?.temperatureStatus.toUpperCase() ?? "UNKNOWN",
            theme,
          ),
          const Divider(height: 24),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Movement Distribution (Last 24h)",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: stats.map((stat) {
              final parts = stat.split(':');
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 12,
                    ),
                    children: [
                      TextSpan(text: "${parts[0].toUpperCase()} "),
                      TextSpan(
                        text: parts.length > 1 ? parts[1] : "",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // --- CARD 4: UPTIME ---
  Widget _buildUptimeCard(AnalyticsUptime? data, ThemeData theme) {
    return _BaseCard(
      theme: theme,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                value: (data?.score ?? 0) / 100,
                backgroundColor: theme.colorScheme.surfaceVariant,
                color: Colors.indigo,
                strokeWidth: 8,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${data?.score.toStringAsFixed(1)} / 100",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                  const Text(
                    "Connectivity Score",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          _GridStat(
            items: [
              _StatItem(
                "Expected",
                "${data?.expected}",
                "pkts",
                Icons.move_to_inbox,
                Colors.grey,
              ),
              _StatItem(
                "Received",
                "${data?.received}",
                "pkts",
                Icons.inbox,
                Colors.green,
              ),
              _StatItem(
                "Loss",
                "${(data?.expected ?? 0) - (data?.received ?? 0)}",
                "pkts",
                Icons.warning_amber,
                Colors.red,
              ),
              _StatItem(
                "Max Gap",
                "${data?.largestGap.toStringAsFixed(0)}",
                "sec",
                Icons.timer_off,
                Colors.orange,
              ),
            ],
            theme: theme,
          ),
          const SizedBox(height: 12),
          _detailRow("Dropouts Detected", "${data?.dropouts ?? 0}", theme),
        ],
      ),
    );
  }

  // --- REUSABLE HELPERS ---
  Widget _BaseCard({required Widget child, required ThemeData theme}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _detailRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _GridStat({required List<_StatItem> items, required ThemeData theme}) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2.5,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: items.map((item) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(item.icon, color: item.color, size: 20),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    text: TextSpan(
                      text: item.value,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: theme.colorScheme.onSurface,
                      ),
                      children: [
                        TextSpan(
                          text: " ${item.unit}",
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    item.label,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _ScoreBox(String label, double score, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            "${score.toStringAsFixed(1)} / 100",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }
}

class _StatItem {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;
  _StatItem(this.label, this.value, this.unit, this.icon, this.color);
}
