import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:safe_track/core/models/analytics_model.dart';
import 'package:safe_track/core/services/device_service.dart';
import 'package:safe_track/theme/colors.dart';

class DeviceDetailsScreen extends StatefulWidget {
  final String imei;

  const DeviceDetailsScreen({super.key, required this.imei});

  @override
  State<DeviceDetailsScreen> createState() => _DeviceDetailsScreenState();
}

class _DeviceDetailsScreenState extends State<DeviceDetailsScreen> {
  final DeviceService _analyticsService = DeviceService();
  List<AnalyticsData> _historyData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final allData = await _analyticsService.getAnalyticsByImei(widget.imei);
    // Showing last 50 records
    final recentData = allData.reversed.take(50).toList();

    if (!mounted) return;
    setState(() {
      _historyData = recentData;
      _isLoading = false;
    });
  }

  // --- Formatters ---
  String _formatTime(String isoString) {
    try {
      final dt = DateTime.parse(isoString).toLocal();
      return DateFormat('HH:mm:ss').format(dt);
    } catch (_) {
      return '--:--';
    }
  }

  String _formatDate(String isoString) {
    try {
      final dt = DateTime.parse(isoString).toLocal();
      return DateFormat('MMM dd, yyyy').format(dt);
    } catch (_) {
      return isoString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0A0C10)
          : const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: AppColors.navBlue,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Full Telemetry Log",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              "IMEI: ${widget.imei}",
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'monospace',
                color: Colors.white70,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 28),
            onPressed: _fetchData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchData,
              child: _historyData.isEmpty
                  ? _buildEmptyState(theme)
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _historyData.length,
                      itemBuilder: (context, index) {
                        return _buildTelemetryCard(_historyData[index], theme);
                      },
                    ),
            ),
    );
  }

  // --- BIGGER EMPTY STATE ---
  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sd_storage_outlined,
            size: 100, // Much bigger icon
            color: theme.disabledColor.withOpacity(0.4),
          ),
          const SizedBox(height: 24),
          Text(
            "No logs found",
            style: TextStyle(
              color: theme.disabledColor,
              fontSize: 22, // Bigger text
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Waiting for device data...",
            style: TextStyle(color: theme.disabledColor, fontSize: 16),
          ),
        ],
      ),
    );
  }

  // --- THE NEW "ALL PARAMETERS" CARD ---
  Widget _buildTelemetryCard(AnalyticsData data, ThemeData theme) {
    // 1. Determine Status & Colors
    final bool isAlert =
        data.packetType == 'A' ||
        (data.alert != null && data.alert!.isNotEmpty);
    final bool hasGps = data.latitude != null && data.latitude != 0;

    Color statusColor = AppColors.navBlue;
    if (isAlert) {
      statusColor = Colors.redAccent;
    } else if (!hasGps) {
      statusColor = Colors.orangeAccent;
    } else if ((data.speed ?? 0) > 0) {
      statusColor = Colors.green;
    }

    // 2. Parse Numeric Values
    final double battery =
        double.tryParse(data.battery?.toString() ?? '0') ?? 0;
    final double signal = double.tryParse(data.signal?.toString() ?? '0') ?? 0;
    final double temp =
        double.tryParse(data.temperature?.toString() ?? '0') ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Thicker Left Status Strip
              Container(width: 8, color: statusColor),

              // Main Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(18), // Increased Padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- HEADER: Time & Packet Type ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _formatTime(data.timestamp),
                                style: const TextStyle(
                                  fontSize: 20, // Increased from 16
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _formatDate(data.timestamp),
                                style: TextStyle(
                                  fontSize: 13, // Increased from 11
                                  fontWeight: FontWeight.w500,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                          _buildPacketBadge(data.packetType, statusColor),
                        ],
                      ),
                      const SizedBox(height: 20), // More breathing room
                      // --- ROW 1: Location & Speed ---
                      Row(
                        children: [
                          // GPS Box
                          Expanded(
                            flex: 3,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceVariant
                                    .withOpacity(0.3),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    hasGps ? Icons.gps_fixed : Icons.gps_off,
                                    size: 20, // Bigger Icon
                                    color: hasGps ? Colors.green : Colors.grey,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      hasGps
                                          ? "${data.latitude!.toStringAsFixed(5)}, ${data.longitude!.toStringAsFixed(5)}"
                                          : " -- , -- ",
                                      style: TextStyle(
                                        fontSize: 14, // Increased form 12
                                        fontFamily: 'monospace',
                                        fontWeight: FontWeight.w600,
                                        color: hasGps
                                            ? theme.colorScheme.onSurface
                                            : theme.disabledColor,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Speed Box
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.speed,
                                    size: 20,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "${data.speed ?? 0} km/h",
                                    style: const TextStyle(
                                      fontSize: 14, // Increased from 12
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16), // More breathing room
                      // --- ROW 2: Device Health ---
                      Row(
                        children: [
                          _buildMiniMetric(
                            Icons.battery_std,
                            "${battery.toInt()}%",
                            battery > 20 ? Colors.green : Colors.red,
                            theme,
                          ),
                          const SizedBox(width: 10),
                          _buildMiniMetric(
                            Icons.signal_cellular_alt,
                            "${signal.toInt()}%",
                            Colors.orange,
                            theme,
                          ),
                          const SizedBox(width: 10),
                          _buildMiniMetric(
                            Icons.thermostat,
                            temp > 0 ? "${temp.toInt()}°C" : "--",
                            Colors.redAccent,
                            theme,
                          ),
                        ],
                      ),

                      // --- ALERTS ---
                      if (isAlert)
                        Container(
                          margin: const EdgeInsets.only(top: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.redAccent.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                size: 20,
                                color: Colors.redAccent,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "Alert: ${data.alert ?? 'Unknown'}",
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14, // Bigger alert text
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // --- EXPANSION: ALL PARAMETERS ---
                      const SizedBox(height: 8),
                      Theme(
                        data: theme.copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          tilePadding: EdgeInsets.zero,
                          childrenPadding: EdgeInsets.zero,
                          title: Text(
                            "Advanced Telemetry",
                            style: TextStyle(
                              fontSize: 14, // Increased
                              color: theme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: Icon(
                            Icons.keyboard_arrow_down,
                            size: 24,
                            color: theme.primaryColor,
                          ),
                          children: [
                            const Divider(),
                            _buildTechRow("Record ID", data.id, theme),
                            _buildTechRow("Raw Packet", data.packetType, theme),
                            _buildTechRow("Server Time", data.timestamp, theme),
                            if (data.geoid != null)
                              _buildTechRow("Geofence ID", data.geoid!, theme),
                            _buildTechRow(
                              "Interval",
                              data.interval != null
                                  ? "${data.interval}s"
                                  : "N/A",
                              theme,
                            ),
                          ],
                        ),
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

  // --- Helper Widgets ---

  Widget _buildPacketBadge(String type, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5), width: 1.5),
      ),
      child: Text(
        "PKT: $type",
        style: TextStyle(
          fontSize: 13, // Increased from 11
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildMiniMetric(
    IconData icon,
    String value,
    Color color,
    ThemeData theme,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10), // Taller
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color), // Bigger icon
            const SizedBox(width: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 14, // Increased from 12
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8), // More spacing
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110, // Wider label area
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.5, // Increased form 11
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14, // Increased form 11
                fontFamily: 'monospace',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
