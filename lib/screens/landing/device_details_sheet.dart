import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:synquerra/providers/user_provider.dart';
import 'package:synquerra/providers/device_provider.dart';
import 'package:synquerra/providers/searched_device_provider.dart';
import 'package:synquerra/screens/landing/home/details/data_telemetry_screen.dart';
import 'package:synquerra/theme/colors.dart';

class DeviceDetailsSheet extends StatelessWidget {
  final bool showingSearch;
  final VoidCallback onToggleHistory;
  final bool isHistoryVisible;

  const DeviceDetailsSheet({
    super.key,
    required this.showingSearch,
    required this.onToggleHistory,
    required this.isHistoryVisible,
  });

  String _formatDateTime(String? timestamp) {
    if (timestamp == null || !timestamp.contains('T')) return 'Fetching...';
    try {
      final parts = timestamp.split('T');
      final dateParts = parts[0].split('-');
      final time = parts[1].split('.')[0];
      return "${dateParts[2]}/${dateParts[1]}/${dateParts[0]} $time";
    } catch (e) {
      return timestamp;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final user = context.watch<UserProvider>().user;
    final myProv = context.watch<DeviceProvider>();
    final searchProv = context.watch<SearchedDeviceProvider>();

    final activeTelemetry = showingSearch
        ? searchProv.latestTelemetry
        : myProv.latestTelemetry;
    final activeHealth = showingSearch
        ? searchProv.healthData
        : myProv.healthData;

    final String currentImei = showingSearch
        ? (searchProv.currentImei ?? "")
        : (user?.imei ?? "");

    final int batteryLevel =
        int.tryParse(activeTelemetry?.battery ?? '100') ?? 100;
    final Color batteryColor = batteryLevel <= 20
        ? AppColors.emergencyRed
        : (batteryLevel <= 50 ? AppColors.warningAmber : AppColors.safeGreen);

    return DraggableScrollableSheet(
      initialChildSize: 0.15,
      minChildSize: 0.15,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.2),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: CustomScrollView(
              controller: scrollController,
              slivers: [
                // Drag Handle
                SliverToBoxAdapter(
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.3,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                // Header Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 8.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          (showingSearch
                                                  ? colorScheme.secondary
                                                  : colorScheme.primary)
                                              .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      showingSearch
                                          ? "SEARCHED DEVICE"
                                          : "YOUR DEVICE",
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: showingSearch
                                            ? colorScheme.secondary
                                            : colorScheme.primary,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    showingSearch
                                        ? "Device Tracking"
                                        : (user?.firstName ?? 'User'),
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 24,
                                          color: colorScheme.onSurface,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: batteryColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: batteryColor.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    batteryLevel <= 20
                                        ? Icons.battery_alert_rounded
                                        : Icons.battery_full_rounded,
                                    color: batteryColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "$batteryLevel%",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: batteryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 16,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Last update: ${_formatDateTime(activeTelemetry?.timestamp)}",
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Divider
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 12.0,
                    ),
                    child: Container(
                      height: 1,
                      color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                    ),
                  ),
                ),

                // === SECTION 1: Live Telemetry Data ===
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 12.0),
                    child: Text(
                      "LIVE TELEMETRY",
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                        letterSpacing: 0.5,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),

                // Telemetry Cards in a Wrap (not grid)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  sliver: SliverToBoxAdapter(
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _buildTelemetryChip(
                          context,
                          icon: Icons.person_outline_rounded,
                          label: "Role",
                          value: user!.userType,
                        ),
                        _buildTelemetryChip(
                          context,
                          icon: Icons.location_on_rounded,
                          label: "GEO ID",
                          value: activeTelemetry?.geoid ?? 'N/A',
                        ),
                        _buildTelemetryChip(
                          context,
                          icon: Icons.score_rounded,
                          label: "GPS Score",
                          value: "${activeHealth?.gpsScore?.toInt() ?? 0}/100",
                        ),
                        _buildTelemetryChip(
                          context,
                          icon: Icons.speed_rounded,
                          label: "Speed",
                          value:
                              "${activeTelemetry?.speed?.toStringAsFixed(1) ?? '0.0'} km/h",
                        ),
                        _buildTelemetryChip(
                          context,
                          icon: Icons.thermostat_rounded,
                          label: "Temperature",
                          value: "${activeTelemetry?.temperature ?? '32'}°C",
                        ),
                        _buildTelemetryChip(
                          context,
                          icon: Icons.signal_cellular_alt_rounded,
                          label: "Signal",
                          value: "${activeTelemetry?.signal ?? '74'}%",
                        ),
                        _buildTelemetryChip(
                          context,
                          icon: Icons.timer_rounded,
                          label: "Interval",
                          value: "${activeTelemetry?.interval ?? '--'} sec",
                        ),
                        _buildTelemetryChip(
                          context,
                          icon: Icons.sos_rounded,
                          label: "SOS",
                          value: "--Enable--",
                        ),
                      ],
                    ),
                  ),
                ),

                // Divider
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 16.0,
                    ),
                    child: Container(
                      height: 1,
                      color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                    ),
                  ),
                ),

                // === SECTION 2: Location History Controls ===
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: onToggleHistory,
                            icon: Icon(
                              isHistoryVisible
                                  ? Icons.layers_clear_rounded
                                  : Icons.route_rounded,
                              size: 18,
                            ),
                            label: Text(
                              isHistoryVisible
                                  ? "Hide History"
                                  : "Show History",
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isHistoryVisible
                                  ? AppColors.emergencyRed
                                  : colorScheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DataTelemetryScreen(imei: currentImei),
                                ),
                              );
                            },
                            icon: const Icon(Icons.analytics_rounded, size: 18),
                            label: const Text(
                              "Details",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.secondaryContainer,
                              foregroundColor: colorScheme.onSecondaryContainer,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // === SECTION 3: Guardian Contacts ===
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 12.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.contact_emergency_rounded,
                            color: Colors.green,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "GUARDIAN CONTACTS",
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                            letterSpacing: 0.5,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  sliver: SliverToBoxAdapter(
                    child: _buildContactCard(
                      theme,
                      name: "--Rajesh Kumar--",
                      phoneNumber: "--9988XXXXXX--",
                      secondaryPhone: "--8899XXXXXX--",
                    ),
                  ),
                ),

                // Divider
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 16.0,
                    ),
                    child: Container(
                      height: 1,
                      color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                    ),
                  ),
                ),

                // === SECTION 4: Device Information ===
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 12.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: colorScheme.secondary.withValues(
                              alpha: 0.15,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.devices_rounded,
                            color: colorScheme.secondary,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "DEVICE INFORMATION",
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.secondary,
                            letterSpacing: 0.5,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Device Info Rows
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildInfoRow(
                        theme,
                        icon: Icons.qr_code_scanner_rounded,
                        label: "IMEI",
                        value: currentImei.isEmpty ? "---" : currentImei,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        theme,
                        icon: Icons.memory_rounded,
                        label: "Firmware",
                        value: "--1dfv3515--",
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        theme,
                        icon: Icons.sim_card_rounded,
                        label: "SIM Number",
                        value: "--1798658789--",
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        theme,
                        icon: Icons.numbers_rounded,
                        label: "MSDN Number",
                        value: "--1234567890--",
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        theme,
                        icon: Icons.badge_rounded,
                        label: "Profile Code",
                        value: "--14683515--",
                      ),
                    ]),
                  ),
                ),

                // Return to My Device Button (if searching)
                if (showingSearch)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 32.0),
                    sliver: SliverToBoxAdapter(
                      child: ElevatedButton(
                        onPressed: () => context
                            .read<SearchedDeviceProvider>()
                            .clearSearch(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.arrow_back_rounded, size: 18),
                            SizedBox(width: 8),
                            Text(
                              "Return to My Device",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Bottom Spacing
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTelemetryChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width:
          (MediaQuery.of(context).size.width - 64) /
          2, // Exactly half width minus spacing
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 14, color: colorScheme.primary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
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

  Widget _buildInfoRow(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colorScheme.secondary),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.secondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(
    ThemeData theme, {
    required String name,
    required String phoneNumber,
    String? secondaryPhone,
  }) {
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_rounded,
                  color: Colors.green,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.phone_rounded, size: 16, color: Colors.green),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        phoneNumber,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.call_rounded,
                              color: Colors.green,
                              size: 18,
                            ),
                            onPressed: () {},
                            padding: const EdgeInsets.all(6),
                            constraints: const BoxConstraints(),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.chat_rounded,
                              color: Colors.orange,
                              size: 18,
                            ),
                            onPressed: () {},
                            padding: const EdgeInsets.all(6),
                            constraints: const BoxConstraints(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (secondaryPhone != null) ...[
                  const SizedBox(height: 8),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.phone_rounded, size: 16, color: Colors.orange),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          secondaryPhone,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.chat_rounded,
                            color: Colors.orange,
                            size: 18,
                          ),
                          onPressed: () {},
                          padding: const EdgeInsets.all(6),
                          constraints: const BoxConstraints(),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
