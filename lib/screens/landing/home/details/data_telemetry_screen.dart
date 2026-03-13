import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:synquerra/providers/device_provider.dart';
import 'package:synquerra/providers/searched_device_provider.dart';
import 'package:synquerra/providers/user_provider.dart';
// import 'package:synquerra/screens/landing/home/details/distance_history.dart';
import 'package:synquerra/screens/landing/home/details/detail_screen.dart';
import 'package:synquerra/core/models/analytics_model.dart';
import 'package:synquerra/screens/landing/home/details/distence_history.dart';
import 'package:synquerra/theme/colors.dart';
import 'package:synquerra/widgets/custom_snackbar.dart';

class DataTelemetryScreen extends StatefulWidget {
  final String imei;
  const DataTelemetryScreen({super.key, required this.imei});

  @override
  State<DataTelemetryScreen> createState() => _TelemetryDashboardScreenState();
}

class _TelemetryDashboardScreenState extends State<DataTelemetryScreen>
    with TickerProviderStateMixin {
  bool _isManualRefreshing = false;
  late final AnimationController _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseAnimation.dispose();
    super.dispose();
  }

  Future<void> _handleManualRefresh() async {
    if (_isManualRefreshing) return;

    setState(() => _isManualRefreshing = true);

    try {
      final user = context.read<UserProvider>().user;
      if (!mounted || user == null) return;

      if (widget.imei == user.imei) {
        await context.read<DeviceProvider>().refreshMyDevice(
          widget.imei,
          forceRefresh: true,
        );
      } else {
        await context.read<SearchedDeviceProvider>().fetchSearchedDevice(
          widget.imei,
        );
      }

      if (mounted) {
        CustomSnackbar.show(
          context,
          message: "Telemetry data updated successfully",
          type: SnackbarType.success,
        );
      }
    } catch (e) {
      debugPrint("Refresh failed: $e");
      if (mounted) {
        CustomSnackbar.show(
          context,
          message: "Refresh failed",
          type: SnackbarType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isManualRefreshing = false);
      }
    }
  }

  String _formatLastSeen(String? timestamp) {
    if (timestamp == null) return 'Never';

    try {
      final DateTime packetTime = DateTime.parse(timestamp).toLocal();
      final DateTime now = DateTime.now();
      final Duration difference = now.difference(packetTime);

      if (difference.inSeconds < 60) {
        return '${difference.inSeconds}s ago';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else {
        final String hour = packetTime.hour.toString().padLeft(2, '0');
        final String minute = packetTime.minute.toString().padLeft(2, '0');
        final String day = packetTime.day.toString().padLeft(2, '0');
        final String month = packetTime.month.toString().padLeft(2, '0');
        return '$day/$month $hour:$minute';
      }
    } catch (e) {
      debugPrint("Timestamp Parse Error: $e");
      return '--:--';
    }
  }

  Color _getBatteryColor(String? batteryStr) {
    if (batteryStr == null) return Colors.grey;
    final battery = int.tryParse(batteryStr) ?? 100;
    if (battery <= 20) return AppColors.emergencyRed;
    if (battery <= 50) return AppColors.warningAmber;
    return AppColors.safeGreen;
  }

  @override
  Widget build(BuildContext context) {
    final myProv = context.watch<DeviceProvider>();
    final searchProv = context.watch<SearchedDeviceProvider>();

    final bool isSearched = searchProv.currentImei == widget.imei;

    final allPackets = isSearched ? searchProv.allPackets : myProv.allPackets;
    final latestData = allPackets.isNotEmpty ? allPackets.last : null;
    final distanceData = isSearched
        ? searchProv.distanceData
        : myProv.distanceData;
    final healthData = isSearched ? searchProv.healthData : myProv.healthData;
    final uptimeData = isSearched ? searchProv.uptimeData : myProv.uptimeData;
    final isLoading = isSearched ? searchProv.isLoading : myProv.isLoading;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (allPackets.isEmpty && isLoading) {
      return _buildLoadingState();
    }

    if (allPackets.isEmpty && !isLoading) {
      return _buildEmptyState();
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // Modern App Bar
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: AppColors.navBlue,
            leading: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            leadingWidth: 20, // Give more space for the back button
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.zero, // Remove default padding
              title: Padding(
                padding: const EdgeInsets.only(
                  left: 50,
                  right: 16,
                  bottom: 16,
                ), // Start after back button
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text(
                      "Data Telemetry",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "IMEI: ${widget.imei}",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              // Last Updated & Refresh Button
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          "LAST UPDATE",
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.white70,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, child) {
                                return Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: latestData != null
                                        ? Colors.green
                                        : Colors.red,
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            (latestData != null
                                                    ? Colors.green
                                                    : Colors.red)
                                                .withValues(alpha: 0.4),
                                        blurRadius:
                                            8 *
                                            (1 + _pulseAnimation.value * 0.5),
                                        spreadRadius:
                                            2 *
                                            (1 + _pulseAnimation.value * 0.5),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _formatLastSeen(latestData?.timestamp),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                      child: IconButton(
                        icon: _isManualRefreshing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.refresh_rounded),
                        onPressed: _isManualRefreshing
                            ? null
                            : _handleManualRefresh,
                        color: Colors.white,
                        iconSize: 22,
                        constraints: const BoxConstraints(
                          minWidth: 30,
                          minHeight: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Main Content
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Live Status Card
                _buildModernStatusCard(latestData, allPackets, theme),

                const SizedBox(height: 24),

                // Movement & Travel
                _buildModernDistanceCard(distanceData, theme, latestData),

                const SizedBox(height: 24),

                // System Health
                _buildModernHealthCard(healthData, theme),

                const SizedBox(height: 24),

                // Connectivity
                _buildModernUptimeCard(uptimeData, theme),

                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppColors.navBlue,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Loading Telemetry Data",
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              "Fetching latest device information...",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text("No Data"),
        backgroundColor: AppColors.navBlue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.3,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.sensors_off_rounded,
                size: 64,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "No telemetry data available",
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "This device hasn't sent any data yet",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _handleManualRefresh,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text("Refresh Now"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernStatusCard(
    AnalyticsData? data,
    List<AnalyticsData> allPackets,
    ThemeData theme,
  ) {
    final isOnline = data != null;
    final batteryColor = _getBatteryColor(data?.battery);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.surface,
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isOnline ? Colors.green : Colors.red,
                        boxShadow: [
                          BoxShadow(
                            color: (isOnline ? Colors.green : Colors.red)
                                .withValues(alpha: 0.4),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      isOnline ? "DEVICE ACTIVE" : "DEVICE OFFLINE",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: isOnline ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    data?.timestamp.split('T').last.split('.')[0] ?? 'No Data',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Quick Stats Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              childAspectRatio: 1,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: [
                _buildQuickStat(
                  context,
                  icon: Icons.speed_rounded,
                  value: "${data?.speed ?? 0}",
                  unit: "km/h",
                  label: "Speed",
                  color: Colors.blue,
                ),
                _buildQuickStat(
                  context,
                  icon: Icons.battery_full_rounded,
                  value: data?.battery ?? '-',
                  unit: "%",
                  label: "Battery",
                  color: batteryColor,
                ),
                _buildQuickStat(
                  context,
                  icon: Icons.signal_cellular_alt_rounded,
                  value: data?.signal ?? '-',
                  unit: "%",
                  label: "Signal",
                  color: Colors.orange,
                ),
                _buildQuickStat(
                  context,
                  icon: Icons.thermostat_rounded,
                  value: data?.temperature ?? '-',
                  unit: "°C",
                  label: "Temp",
                  color: Colors.redAccent,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Raw Packet Details (Collapsible)
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.2,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Theme(
                data: theme.copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.data_array_rounded,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  title: const Text(
                    "Raw Packet Details",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildDetailRow(
                            "Packet Type",
                            data?.packetType ?? "N/A",
                            theme,
                          ),
                          const SizedBox(height: 8),
                          _buildDetailRow(
                            "Latitude",
                            "${data?.latitude ?? '--'}",
                            theme,
                          ),
                          const SizedBox(height: 8),
                          _buildDetailRow(
                            "Longitude",
                            "${data?.longitude ?? '--'}",
                            theme,
                          ),
                          const SizedBox(height: 8),
                          _buildDetailRow(
                            "Alert Code",
                            data?.alert ?? "None",
                            theme,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // History Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  side: BorderSide(
                    color: theme.colorScheme.primary.withValues(alpha: 0.5),
                  ),
                ),
                icon: Icon(
                  Icons.history_rounded,
                  color: theme.colorScheme.primary,
                ),
                label: Text(
                  "View Full History Log",
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
      ),
    );
  }

  Widget _buildQuickStat(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String unit,
    required String label,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              text: value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: theme.colorScheme.onSurface,
              ),
              children: [
                TextSpan(
                  text: " $unit",
                  style: const TextStyle(fontSize: 8, color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildModernDistanceCard(
    List<AnalyticsDistance> data,
    ThemeData theme,
    AnalyticsData? latestData,
  ) {
    double total = data.isNotEmpty ? data.last.cumulative : 0.0;
    double lastHour = data.isNotEmpty ? data.last.distance : 0.0;

    // Calculate speed from latest data for context
    double currentSpeed = latestData?.speed ?? 0.0;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.surface,
            Colors.blue.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.navBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.alt_route_rounded,
                    color: AppColors.navBlue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Movement Analysis",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    title: "TOTAL DISTANCE",
                    value: "${total.toStringAsFixed(2)}",
                    unit: "km",
                    subtitle: "Last 24 hours",
                    color: AppColors.navBlue,
                    icon: Icons.route_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricTile(
                    title: "CURRENT SPEED",
                    value: currentSpeed.toStringAsFixed(1),
                    unit: "km/h",
                    subtitle: "Live",
                    color: Colors.green,
                    icon: Icons.speed_rounded,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Last Hour",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${lastHour.toStringAsFixed(2)} km",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        "Data Points",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${data.length} hours",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
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
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required String unit,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              text: value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              children: [
                TextSpan(
                  text: " $unit",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildModernHealthCard(AnalyticsHealth? data, ThemeData theme) {
    final stats = data?.movementStats ?? [];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.surface,
            Colors.teal.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.teal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.health_and_safety_rounded,
                    color: Colors.teal,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "System Health",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: _buildScoreCircle(
                    "GPS Score",
                    data?.gpsScore ?? 0,
                    Colors.teal,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildScoreCircle(
                    "Temp Index",
                    data?.temperatureIndex ?? 0,
                    Colors.deepOrange,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Temperature Status",
                    style: TextStyle(fontSize: 14),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          (data?.temperatureStatus ?? '').toLowerCase() ==
                              'normal'
                          ? Colors.green.withValues(alpha: 0.15)
                          : Colors.orange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      data?.temperatureStatus?.toUpperCase() ?? "UNKNOWN",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color:
                            (data?.temperatureStatus ?? '').toLowerCase() ==
                                'normal'
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (stats.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text(
                "Movement Distribution",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: stats.map((stat) {
                  final parts = stat.split(':');
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 13,
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
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCircle(String label, double score, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 70,
                height: 70,
                child: CircularProgressIndicator(
                  value: score / 100,
                  backgroundColor: color.withValues(alpha: 0.1),
                  color: color,
                  strokeWidth: 6,
                ),
              ),
              Text(
                "${score.toInt()}",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernUptimeCard(AnalyticsUptime? data, ThemeData theme) {
    if (data == null) return const SizedBox();

    final expected = data.expected ?? 0;
    final received = data.received ?? 0;
    final loss = expected - received;
    final lossPercent = expected > 0 ? (loss / expected * 100) : 0;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.surface,
            Colors.indigo.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.wifi_rounded,
                    color: Colors.indigo,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Connectivity Analysis",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Connectivity Score",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          text: "${data.score?.toStringAsFixed(1)}",
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                          children: const [
                            TextSpan(
                              text: " / 100",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: lossPercent > 10
                          ? Colors.red.withValues(alpha: 0.1)
                          : Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "${lossPercent.toStringAsFixed(1)}%",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: lossPercent > 10 ? Colors.red : Colors.green,
                          ),
                        ),
                        const Text(
                          "Packet Loss",
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              childAspectRatio: 1,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: [
                _buildStatBox(
                  icon: Icons.move_to_inbox_rounded,
                  value: "$expected",
                  label: "Expected",
                  color: Colors.grey,
                ),
                _buildStatBox(
                  icon: Icons.inbox_rounded,
                  value: "$received",
                  label: "Received",
                  color: Colors.green,
                ),
                _buildStatBox(
                  icon: Icons.warning_amber_rounded,
                  value: "$loss",
                  label: "Loss",
                  color: Colors.red,
                ),
                _buildStatBox(
                  icon: Icons.timer_off_rounded,
                  value: "${data.largestGap?.toStringAsFixed(0) ?? '0'}s",
                  label: "Max Gap",
                  color: Colors.orange,
                ),
              ],
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Dropouts Detected",
                    style: TextStyle(fontSize: 14),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: (data.dropouts ?? 0) > 5
                          ? Colors.red.withValues(alpha: 0.1)
                          : Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      "${data.dropouts ?? 0} events",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: (data.dropouts ?? 0) > 5
                            ? Colors.red
                            : Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: color,
            ),
          ),
          Text(label, style: const TextStyle(fontSize: 8, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.3,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ),
      ],
    );
  }
}
