import 'package:flutter/material.dart';
import 'package:safe_track/screens/landing/home/details/distence_history.dart';
import 'package:safe_track/screens/landing/home/details/detail_screen.dart';
import 'package:safe_track/core/models/analytics_model.dart';
import 'package:safe_track/core/services/device_service.dart';
import 'package:safe_track/theme/colors.dart';

class DataTelemetryScreen extends StatefulWidget {
  final String imei;
  const DataTelemetryScreen({super.key, required this.imei});

  @override
  State<DataTelemetryScreen> createState() => _TelemetryDashboardScreenState();
}

class _TelemetryDashboardScreenState extends State<DataTelemetryScreen> {
  final DeviceService _service = DeviceService();

  // Data Containers
  AnalyticsData? _latestDeviceData;
  List<AnalyticsDistance> _distanceData = [];
  AnalyticsHealth? _healthData;
  AnalyticsUptime? _uptimeData;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  Future<void> _fetchAllData() async {
    setState(() => _isLoading = true);
    final packets = await _service.getAnalyticsByImei(widget.imei);
    final dist = await _service.getDistance24(widget.imei);
    final health = await _service.getHealth(widget.imei);
    final uptime = await _service.getUptime(widget.imei);

    if (mounted) {
      setState(() {
        _latestDeviceData = packets.isNotEmpty ? packets.last : null;
        _distanceData = dist;
        _healthData = health;
        _uptimeData = uptime;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Background color based on theme
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchAllData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader("Live Status", theme),
                    _buildDeviceStatusCard(theme),
                    const SizedBox(height: 24),

                    _sectionHeader("Movement & Travel", theme),
                    _buildDistanceCard(theme),
                    const SizedBox(height: 24),

                    _sectionHeader("System Health", theme),
                    _buildHealthCard(theme),
                    const SizedBox(height: 24),

                    _sectionHeader("Connectivity", theme),
                    _buildUptimeCard(theme),
                    const SizedBox(height: 40), // Bottom padding
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

  // --- CARD 1: DEVICE STATUS (Detailed) ---
  Widget _buildDeviceStatusCard(ThemeData theme) {
    final data = _latestDeviceData;
    final isOnline = data != null; // Simple check, refine logic if needed

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
                data?.temperature ?? '-',
                "℃",
                Icons.thermostat,
                Colors.redAccent,
              ), // Assuming you added satellites to model
            ],
            theme: theme,
          ),
          const SizedBox(height: 16),
          // Raw Data Expansion
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
              // _detailRow("ID", data?.id ?? "N/A", theme),
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
                  builder: (_) => DeviceDetailsScreen(imei: widget.imei),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- CARD 2: DISTANCE (Detailed) ---
  Widget _buildDistanceCard(ThemeData theme) {
    double total = _distanceData.isNotEmpty
        ? _distanceData.last.cumulative
        : 0.0;
    double lastHour = _distanceData.isNotEmpty
        ? _distanceData.last.distance
        : 0.0;

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
          _detailRow(
            "Data Points",
            "${_distanceData.length} hours recorded",
            theme,
          ),
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
                  builder: (_) => DistanceHistoryScreen(
                    data: _distanceData,
                    imei: widget.imei,
                  ),
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

  // --- CARD 3: HEALTH (Detailed) ---
  Widget _buildHealthCard(ThemeData theme) {
    // If movementStats is a List<String> in your model, display it
    final stats =
        _healthData?.movementStats ?? []; // Ensure model has this field

    return _BaseCard(
      theme: theme,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _ScoreBox(
                  "GPS Score",
                  _healthData?.gpsScore ?? 0,
                  Colors.teal,
                  theme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ScoreBox(
                  "Temp Index",
                  _healthData?.temperatureIndex ?? 0,
                  Colors.deepOrange,
                  theme,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _detailRow(
            "Temperature Status",
            _healthData?.temperatureStatus.toUpperCase() ?? "UNKNOWN",
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
          // Dynamic Stats Grid
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

  // --- CARD 4: UPTIME (Detailed) ---
  Widget _buildUptimeCard(ThemeData theme) {
    return _BaseCard(
      theme: theme,
      child: Column(
        children: [
          // Main Score
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                value: (_uptimeData?.score ?? 0) / 100,
                backgroundColor: theme.colorScheme.surfaceVariant,
                color: Colors.indigo,
                strokeWidth: 8,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${_uptimeData?.score.toStringAsFixed(1)} / 100",
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
          // Dense Data Grid
          _GridStat(
            items: [
              _StatItem(
                "Expected",
                "${_uptimeData?.expected}",
                "pkts",
                Icons.move_to_inbox,
                Colors.grey,
              ),
              _StatItem(
                "Received",
                "${_uptimeData?.received}",
                "pkts",
                Icons.inbox,
                Colors.green,
              ),
              _StatItem(
                "Loss",
                "${(_uptimeData?.expected ?? 0) - (_uptimeData?.received ?? 0)}",
                "pkts",
                Icons.warning_amber,
                Colors.red,
              ),
              _StatItem(
                "Max Gap",
                "${_uptimeData?.largestGap.toStringAsFixed(0)}",
                "sec",
                Icons.timer_off,
                Colors.orange,
              ),
            ],
            theme: theme,
          ),
          const SizedBox(height: 12),
          _detailRow(
            "Dropouts Detected",
            "${_uptimeData?.dropouts ?? 0}",
            theme,
          ),
        ],
      ),
    );
  }

  // --- REUSABLE WIDGETS ---

  // 1. The Card Container
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

  // 2. Key-Value Text Row
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

  // 3. Grid for Stats
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

  // 4. Box for Scores (GPS/Temp)
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

// Helper Class for Grid Items
class _StatItem {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;
  _StatItem(this.label, this.value, this.unit, this.icon, this.color);
}
