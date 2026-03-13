import 'package:flutter/material.dart';
import 'package:synquerra/theme/colors.dart';
import 'package:synquerra/widgets/info_card.dart';

class DeviceInformationScreen extends StatelessWidget {
  const DeviceInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          "Device Information",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- DEVICE PROFILE CARD ---
            _buildDeviceProfileCard(context),
            const SizedBox(height: 24),

            // --- QUICK STATS ROW ---
            _buildQuickStatsRow(context),
            const SizedBox(height: 28),

            // --- CORE DETAILS SECTION ---
            _buildSectionTitle(
              context,
              "Core Specifications",
              Icons.settings_input_component,
            ),
            const SizedBox(height: 16),
            _buildCoreDetailsCard(context),
            const SizedBox(height: 28),

            // --- LIVE STATUS SECTION ---
            _buildSectionTitle(context, "Live Status", Icons.analytics),
            const SizedBox(height: 16),
            _buildLiveStatusCard(context),
            const SizedBox(height: 28),

            // --- SIM 1 SECTION ---
            _buildSectionTitle(context, "SIM 1 - Primary", Icons.sim_card),
            const SizedBox(height: 16),
            _buildSimCard(
              context: context,
              simNumber: "1",
              isActive: true,
              status: "Active",
              simNumberValue: "9988XXXXXX",
              msdn: "8801500121121",
              profileCode: "1688156",
              dataUsage: "38/50 MB",
              sms: "5/100",
              calling: "Active",
              signal: "75%",
              roaming: "Disabled",
              operator: "Airtel",
            ),
            const SizedBox(height: 24),

            // --- SIM 2 SECTION ---
            _buildSectionTitle(
              context,
              "SIM 2 - Secondary",
              Icons.sim_card_outlined,
            ),
            const SizedBox(height: 16),
            _buildSimCard(
              context: context,
              simNumber: "2",
              isActive: false,
              status: "Not Inserted",
              simNumberValue: "N/A",
              msdn: "N/A",
              profileCode: "N/A",
              dataUsage: "N/A",
              sms: "N/A",
              calling: "N/A",
              signal: "0%",
              roaming: "N/A",
              operator: "N/A",
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSimCard({
    required BuildContext context,
    required String simNumber,
    required bool isActive,
    required String status,
    required String simNumberValue,
    required String msdn,
    required String profileCode,
    required String dataUsage,
    required String sms,
    required String calling,
    required String signal,
    required String roaming,
    required String operator,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isActive
              ? colorScheme.primary.withValues(alpha: 0.3)
              : colorScheme.error.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // SIM Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isActive
                    ? [
                        colorScheme.primary.withValues(alpha: 0.1),
                        colorScheme.primary.withValues(alpha: 0.02),
                      ]
                    : [
                        colorScheme.error.withValues(alpha: 0.1),
                        colorScheme.error.withValues(alpha: 0.02),
                      ],
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isActive ? colorScheme.primary : colorScheme.error,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    isActive
                        ? Icons.sim_card_rounded
                        : Icons.sim_card_alert_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "SIM $simNumber",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isActive
                                  ? colorScheme.primary
                                  : colorScheme.error,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  (isActive
                                          ? colorScheme.primary
                                          : colorScheme.error)
                                      .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isActive
                                    ? colorScheme.primary
                                    : colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        operator,
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // SIM Details Grid
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildSimMetricTile(
                  context,
                  icon: Icons.confirmation_number_rounded,
                  label: "SIM Number",
                  value: simNumberValue,
                  isActive: isActive,
                ),
                const SizedBox(height: 16),
                _buildSimMetricTile(
                  context,
                  icon: Icons.dialpad_rounded,
                  label: "MSDN",
                  value: msdn,
                  isActive: isActive,
                ),
                const SizedBox(height: 16),
                _buildSimMetricTile(
                  context,
                  icon: Icons.badge_rounded,
                  label: "Profile Code",
                  value: profileCode,
                  isActive: isActive,
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(),
                ),

                // Usage Metrics
                Row(
                  children: [
                    Expanded(
                      child: _buildUsageChip(
                        context,
                        icon: Icons.data_usage_rounded,
                        label: "Data",
                        value: dataUsage,
                        isActive: isActive,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildUsageChip(
                        context,
                        icon: Icons.sms_rounded,
                        label: "SMS",
                        value: sms,
                        isActive: isActive,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildUsageChip(
                        context,
                        icon: Icons.phone_forwarded_rounded,
                        label: "Calls",
                        value: calling,
                        isActive: isActive,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildUsageChip(
                        context,
                        icon: Icons.signal_cellular_alt_rounded,
                        label: "Signal",
                        value: signal,
                        isActive: isActive,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildRoamingTile(context, value: roaming, isActive: isActive),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceProfileCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.navBlue,
            Color(0xFF4A6FA5), // Slightly lighter blue
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.navBlue.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // Device icon with background
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.devices_rounded,
              size: 48,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 20),
          // Device info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "ACTIVE DEVICE",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "26414152268",
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Device ID: 68FZ1F6",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsRow(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: _buildStatChip(
            context,
            icon: Icons.system_update_rounded,
            label: "Firmware",
            value: "3.12.09",
            color: Colors.purple,
          ),
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildStatChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 18, color: colorScheme.primary),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildCoreDetailsCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDetailRow(
            context,
            icon: Icons.tag_rounded,
            label: "IMEI",
            value: "26414152268",
            color: Colors.blue,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          _buildDetailRow(
            context,
            icon: Icons.qr_code_scanner_rounded,
            label: "Device ID",
            value: "68FZ1F6",
            color: Colors.purple,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          _buildDetailRow(
            context,
            icon: Icons.system_update_rounded,
            label: "Firmware Version",
            value: "3.12.09",
            color: Colors.teal,
          ),
        ],
      ),
    );
  }

  Widget _buildLiveStatusCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withValues(alpha: 0.05),
            colorScheme.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          _buildLiveStatusRow(
            context,
            icon: Icons.power_settings_new_rounded,
            label: "Device Status",
            value: "Offline",
            statusType: "offline",
          ),
          const SizedBox(height: 16),
          _buildLiveStatusRow(
            context,
            icon: Icons.access_time_rounded,
            label: "Last Seen",
            value: "2 mins ago",
            statusType: "normal",
          ),
          const SizedBox(height: 16),
          _buildLiveStatusRow(
            context,
            icon: Icons.speed_rounded,
            label: "Current Speed",
            value: "0 km/h",
            statusType: "normal",
          ),
          const SizedBox(height: 16),
          _buildLiveStatusRow(
            context,
            icon: Icons.notifications_active_rounded,
            label: "Last Alert",
            value: "Geofence Exit",
            statusType: "warning",
          ),
          const SizedBox(height: 16),
          _buildLiveStatusRow(
            context,
            icon: Icons.update_rounded,
            label: "Last Update",
            value: "24/10/2025 01:25",
            statusType: "normal",
          ),
        ],
      ),
    );
  }

  Widget _buildLiveStatusRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required String statusType,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    Color valueColor;
    switch (statusType) {
      case "offline":
        valueColor = Colors.red;
        break;
      case "warning":
        valueColor = Colors.orange;
        break;
      case "success":
        valueColor = Colors.green;
        break;
      default:
        valueColor = colorScheme.onSurface;
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(width: 14),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: valueColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSimMetricTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required bool isActive,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
          ),
        ),
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isActive
                  ? colorScheme.primary.withValues(alpha: 0.08)
                  : colorScheme.error.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isActive ? colorScheme.primary : colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUsageChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required bool isActive,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    Color valueColor = isActive ? colorScheme.primary : colorScheme.error;

    // Parse value for color coding if active
    if (isActive && value != "N/A") {
      if (label == "Signal" && value.contains('%')) {
        final signalValue = int.tryParse(value.replaceAll('%', '')) ?? 0;
        if (signalValue > 70)
          valueColor = Colors.green;
        else if (signalValue > 30)
          valueColor = Colors.orange;
        else
          valueColor = Colors.red;
      } else if (label == "Data" && value.contains('/')) {
        final parts = value.split('/');
        if (parts.length == 2) {
          final used = int.tryParse(parts[0].trim()) ?? 0;
          final total = int.tryParse(parts[1].split(' ')[0].trim()) ?? 1;
          final percentage = (used / total) * 100;
          if (percentage > 80)
            valueColor = Colors.orange;
          else if (percentage > 50)
            valueColor = Colors.blue;
          else
            valueColor = Colors.green;
        }
      }
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: valueColor),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildRoamingTile(
    BuildContext context, {
    required String value,
    required bool isActive,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            Icons.public_rounded,
            size: 16,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Text(
            "Roaming",
            style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: value == "Enabled" || value == "Active"
                  ? Colors.green.withValues(alpha: 0.1)
                  : value == "Disabled"
                  ? Colors.orange.withValues(alpha: 0.1)
                  : colorScheme.error.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: value == "Enabled" || value == "Active"
                    ? Colors.green
                    : value == "Disabled"
                    ? Colors.orange
                    : colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
