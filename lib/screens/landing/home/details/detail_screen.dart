import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Run 'flutter pub add intl' if needed
import 'package:safe_track/core/models/analytics_model.dart';
import 'package:safe_track/core/services/device_service.dart';
// import '../../theme/colors.dart'; // Uncomment if you have your colors file

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

  // --- The Fetching Logic ---
  Future<void> _fetchData() async {
    setState(() => _isLoading = true);

    // 1. Fetch all data
    List<AnalyticsData> allData = await _analyticsService.getAnalyticsByImei(
      widget.imei,
    );

    // 2. Logic: The API usually returns Oldest -> Newest.
    // We reverse it to show Newest first, then take the top 10.
    List<AnalyticsData> recentData = allData.reversed.take(10).toList();

    if (mounted) {
      setState(() {
        _historyData = recentData;
        _isLoading = false;
      });
    }
  }

  // Helper to make time readable
  String _formatTimestamp(String isoString) {
    try {
      final dt = DateTime.parse(isoString).toLocal();
      return DateFormat('MMM d, h:mm:ss a').format(dt);
    } catch (e) {
      return isoString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Device Details", style: TextStyle(fontSize: 18)),
            Text(
              "IMEI: ${widget.imei}",
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: theme.primaryColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchData, // This handles the "scroll up to refresh"
              child: _historyData.isEmpty
                  ? ListView(
                      // ListView allows pull-to-refresh even on empty screen
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: const Center(child: Text("No data available")),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _historyData.length,
                      itemBuilder: (context, index) {
                        return _buildHistoryCard(_historyData[index], theme);
                      },
                    ),
            ),
    );
  }

  // --- The UI Card for each data packet ---
  Widget _buildHistoryCard(AnalyticsData data, ThemeData theme) {
    // Logic: Color code the card based on data quality
    Color statusColor = Colors.green;
    IconData statusIcon = Icons.location_on;

    if (data.packetType == 'A') {
      statusColor = Colors.orange; // Alert/Heartbeat packet
      statusIcon = Icons.notifications_active;
    } else if (data.latitude == null) {
      statusColor = Colors.grey; // No GPS lock
      statusIcon = Icons.signal_wifi_off;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header: Time & Type
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(statusIcon, color: statusColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      _formatTimestamp(data.timestamp),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withOpacity(0.5)),
                  ),
                  child: Text(
                    data.packetType,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Data Grid
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDataColumn(
                  "Speed",
                  "${data.speed ?? 0} km/h",
                  Icons.speed,
                ),
                _buildDataColumn(
                  "Battery",
                  "${data.battery ?? '-'}%",
                  Icons.battery_std,
                ),
                _buildDataColumn(
                  "Signal",
                  "${data.signal ?? '-'}%",
                  Icons.signal_cellular_alt,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Location Bar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: data.latitude != null
                  ? Text(
                      "Lat: ${data.latitude}  |  Lng: ${data.longitude}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    )
                  : const Text(
                      "No GPS Coordinates",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}
