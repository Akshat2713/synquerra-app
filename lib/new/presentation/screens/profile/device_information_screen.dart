// lib/presentation/screens/profile/device_information_screen.dart
import 'package:flutter/material.dart';
import 'package:synquerra/presentation/widgets/common/info_container.dart';
import '../../widgets/common/detail_row.dart';
import '../../themes/colors.dart';

class DeviceInformationScreen extends StatelessWidget {
  const DeviceInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          "Device Information",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Device Profile Card
            _buildDeviceProfileCard(context),
            const SizedBox(height: 24),

            // Core Specifications
            InfoContainer(
              title: "Core Specifications",
              children: [
                DetailRow(
                  icon: Icons.tag_rounded,
                  title: "IMEI",
                  value: "26414152268",
                ),
                const SizedBox(height: 12),
                DetailRow(
                  icon: Icons.qr_code_scanner_rounded,
                  title: "Device ID",
                  value: "68FZ1F6",
                ),
                const SizedBox(height: 12),
                DetailRow(
                  icon: Icons.system_update_rounded,
                  title: "Firmware",
                  value: "3.12.09",
                ),
              ],
            ),

            const SizedBox(height: 24),

            // SIM 1 Information
            InfoContainer(
              title: "SIM 1 - Primary",
              accentColor: Colors.green,
              children: [
                DetailRow(
                  icon: Icons.confirmation_number_rounded,
                  title: "SIM Number",
                  value: "9988XXXXXX",
                ),
                const SizedBox(height: 12),
                DetailRow(
                  icon: Icons.dialpad_rounded,
                  title: "MSDN",
                  value: "8801500121121",
                ),
                const SizedBox(height: 12),
                DetailRow(
                  icon: Icons.badge_rounded,
                  title: "Profile Code",
                  value: "1688156",
                ),
                const SizedBox(height: 12),
                DetailRow(
                  icon: Icons.data_usage_rounded,
                  title: "Data Usage",
                  value: "38/50 MB",
                ),
                const SizedBox(height: 12),
                DetailRow(
                  icon: Icons.signal_cellular_alt_rounded,
                  title: "Signal",
                  value: "75%",
                ),
              ],
            ),

            const SizedBox(height: 24),

            // SIM 2 Information
            InfoContainer(
              title: "SIM 2 - Secondary",
              accentColor: Colors.red,
              children: [
                DetailRow(
                  icon: Icons.confirmation_number_rounded,
                  title: "SIM Number",
                  value: "N/A",
                ),
                const SizedBox(height: 12),
                DetailRow(
                  icon: Icons.dialpad_rounded,
                  title: "MSDN",
                  value: "N/A",
                ),
                const SizedBox(height: 12),
                DetailRow(
                  icon: Icons.badge_rounded,
                  title: "Profile Code",
                  value: "N/A",
                ),
                const SizedBox(height: 12),
                DetailRow(
                  icon: Icons.data_usage_rounded,
                  title: "Data Usage",
                  value: "N/A",
                ),
                const SizedBox(height: 12),
                DetailRow(
                  icon: Icons.signal_cellular_alt_rounded,
                  title: "Signal",
                  value: "0%",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceProfileCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.navBlue, const Color(0xFF4A6FA5)],
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
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "26414152268",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
                    const Text(
                      "Device ID: 68FZ1F6",
                      style: TextStyle(fontSize: 14, color: Colors.white70),
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
}
