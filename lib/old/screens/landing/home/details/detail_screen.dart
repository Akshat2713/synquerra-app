import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Add this
import 'package:intl/intl.dart';
import 'package:synquerra/old/core/models/analytics_model.dart';
import 'package:synquerra/old/providers/device_provider.dart'; // Import your providers
import 'package:synquerra/old/providers/searched_device_provider.dart';
import 'package:synquerra/old/theme/colors.dart';

class DeviceDetailsScreen extends StatelessWidget {
  final String imei;

  const DeviceDetailsScreen({super.key, required this.imei});

  // --- Formatters ---
  static String _formatTime(String isoString) {
    try {
      final dt = DateTime.parse(isoString).toLocal();
      return DateFormat('HH:mm:ss').format(dt);
    } catch (_) {
      return '--:--';
    }
  }

  static String _formatDate(String isoString) {
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

    // 1. Determine which provider to watch based on current state
    final myProv = context.watch<DeviceProvider>();
    final searchProv = context.watch<SearchedDeviceProvider>();
    final bool isSearched = searchProv.currentImei == imei;

    // 2. Extract relevant data and loading state directly from Provider
    final List<AnalyticsData> allPackets = isSearched
        ? searchProv.allPackets
        : myProv.allPackets;
    final bool isLoading = isSearched ? searchProv.isLoading : myProv.isLoading;

    // 3. Process data for the list (Reverse and Take 50)
    final List<AnalyticsData> historyData = allPackets.reversed
        .take(50)
        .toList();

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0A0C10)
          : const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: AppColors.navBlue,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Full Telemetry Log",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              "IMEI: $imei",
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
            icon: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.refresh, size: 28),
            onPressed: () {
              // 4. Trigger global refresh inside Provider
              if (isSearched) {
                context.read<SearchedDeviceProvider>().fetchSearchedDevice(
                  imei,
                );
              } else {
                context.read<DeviceProvider>().refreshMyDevice(imei);
              }
            },
          ),
        ],
      ),
      body: isLoading && historyData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : historyData.isEmpty
          ? _buildEmptyState(theme)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: historyData.length,
              itemBuilder: (context, index) =>
                  _buildTelemetryCard(historyData[index], theme),
            ),
    );
  }

  // ... Keep your existing _buildEmptyState, _buildTelemetryCard, and helper methods ...

  // --- EMPTY STATE ---
  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sd_storage_outlined,
            size: 100,
            color: theme.disabledColor.withOpacity(0.4),
          ),
          const SizedBox(height: 24),
          Text(
            "No logs found",
            style: TextStyle(
              color: theme.disabledColor,
              fontSize: 22,
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

  // --- TELEMETRY CARD ---
  Widget _buildTelemetryCard(AnalyticsData data, ThemeData theme) {
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

    final double battery =
        double.tryParse(data.battery?.toString() ?? '0') ?? 0;
    final double signal = double.tryParse(data.signal?.toString() ?? '0') ?? 0;
    final String temp = data.temperature ?? '--';

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
              Container(width: 8, color: statusColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _formatTime(data.timestamp),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _formatDate(data.timestamp),
                                style: TextStyle(
                                  fontSize: 13,
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
                      const SizedBox(height: 20),
                      // Row 1: Location & Speed
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest
                                    .withOpacity(0.3),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    hasGps ? Icons.gps_fixed : Icons.gps_off,
                                    size: 20,
                                    color: hasGps ? Colors.green : Colors.grey,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      hasGps
                                          ? "${data.latitude!.toStringAsFixed(5)}, ${data.longitude!.toStringAsFixed(5)}"
                                          : " -- , -- ",
                                      style: TextStyle(
                                        fontSize: 14,
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
                                      fontSize: 14,
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
                      const SizedBox(height: 16),
                      // Row 2: Metrics
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
                            temp != '--' ? "$temp°C" : "--",
                            Colors.redAccent,
                            theme,
                          ),
                        ],
                      ),
                      // Alerts
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
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      // Advanced Expansion
                      const SizedBox(height: 8),
                      Theme(
                        data: theme.copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          tilePadding: EdgeInsets.zero,
                          title: Text(
                            "Advanced Telemetry",
                            style: TextStyle(
                              fontSize: 14,
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

  // --- Helpers ---
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
          fontSize: 13,
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
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.5,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
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
