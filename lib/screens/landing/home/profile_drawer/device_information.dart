import 'package:flutter/material.dart';
import 'package:synquerra/theme/colors.dart';
import 'package:synquerra/widgets/info_card.dart'; // IMPORT the reusable widgets

class DeviceInformationScreen extends StatelessWidget {
  const DeviceInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Device Information")),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- TOP HEADER SECTION ---
          _buildDeviceHeader(context),
          const SizedBox(height: 24),

          // --- SEPARATION LINE ---
          Divider(color: colorScheme.outlineVariant, thickness: 1),
          const SizedBox(height: 24),

          // --- CORE DETAILS CONTAINER ---
          const InfoContainer(
            // Use the new reusable widget
            title: "Core Details",
            children: [
              DetailRow(icon: Icons.tag, title: "IMEI", value: "26414152268"),
              DetailRow(
                icon: Icons.perm_identity,
                title: "Device ID",
                value: "68FZ1F6",
              ),
              DetailRow(
                icon: Icons.developer_mode,
                title: "Firmware Version",
                value: "3.12.09",
              ),
            ],
          ),

          // --- LIVE TELEMETRY CONTAINER ---
          const InfoContainer(
            title: "Live Telemetry",
            children: [
              DetailRow(
                icon: Icons.power_settings_new,
                title: "Device Status",
                value: "Offline",
              ),
              DetailRow(
                icon: Icons.visibility,
                title: "Last Seen",
                value: "2 mins ago",
              ),
              DetailRow(
                icon: Icons.battery_full,
                title: "Battery Level",
                value: "82%",
              ),
              DetailRow(
                icon: Icons.speed,
                title: "Current Speed",
                value: "0 km/h",
              ),
              DetailRow(
                icon: Icons.notifications_active,
                title: "Last Alert",
                value: "Geofence Exit",
              ),
              DetailRow(
                icon: Icons.timer,
                title: "Last Data Timestamp",
                value: "24/10/2025 01:25",
              ),
            ],
          ),

          // --- SIM 1 CONTAINER ---
          // --- SIM 1 CONTAINER ---
          const InfoContainer(
            title: "SIM 1",
            children: [
              DetailRow(
                icon: Icons.sim_card,
                title: "SIM Status",
                value: "Active",
              ),
              DetailRow(
                icon: Icons.confirmation_number,
                title: "SIM Number",
                value: "9988XXXXXX",
              ),
              DetailRow(
                icon: Icons.dialpad,
                title: "MSDN Number",
                value: "8801500121121",
              ),
              DetailRow(
                icon: Icons.badge,
                title: "Profile Code",
                value: "1688156",
              ),
              DetailRow(
                icon: Icons.data_usage, // Corrected icon
                title: "Data Usage",
                value: "-- 38/50 MB--",
              ),
              DetailRow(
                icon: Icons.sms, // Corrected icon
                title: "SMS",
                value: "--5/100--",
              ),
              DetailRow(
                icon: Icons.phone_forwarded, // Corrected icon
                title: "Calling Function",
                value: "Active",
              ),
              DetailRow(
                icon: Icons.signal_cellular_alt,
                title: "Signal",
                value: "75%",
              ),
              DetailRow(
                icon: Icons.public, // Corrected icon for Roaming
                title: "Roaming", // Corrected spelling
                value: "Disabled",
              ),
            ],
          ),

          // --- SIM 2 CONTAINER (Mirrored Fields) ---
          const InfoContainer(
            title: "SIM 2",
            children: [
              DetailRow(
                icon: Icons.sim_card_alert,
                title: "SIM Status",
                value: "Not Inserted",
              ),
              DetailRow(
                icon: Icons.confirmation_number,
                title: "SIM Number",
                value: "N/A",
              ),
              DetailRow(
                icon: Icons.dialpad,
                title: "MSDN Number",
                value: "N/A",
              ),
              DetailRow(icon: Icons.badge, title: "Profile Code", value: "N/A"),
              DetailRow(
                icon: Icons.data_usage,
                title: "Data Usage",
                value: "N/A",
              ),
              DetailRow(icon: Icons.sms, title: "SMS", value: "N/A"),
              DetailRow(
                icon: Icons.phone_forwarded,
                title: "Calling Function",
                value: "N/A",
              ),
              DetailRow(
                icon: Icons.signal_cellular_alt,
                title: "Signal",
                value: "0%",
              ),
              DetailRow(icon: Icons.public, title: "Roaming", value: "N/A"),
            ],
          ),
        ],
      ),
    );
  }

  // --- WIDGET FOR THE TOP HEADER ---
  // This widget is unique to this screen, so it stays here.
  Widget _buildDeviceHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(Icons.devices_other, size: 60, color: AppColors.navBlue),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "26414152268",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface, // Correctly theme-aware
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "68FZ1F6",
                style: TextStyle(
                  fontSize: 16,
                  color: colorScheme.onSurfaceVariant, // Correctly theme-aware
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
