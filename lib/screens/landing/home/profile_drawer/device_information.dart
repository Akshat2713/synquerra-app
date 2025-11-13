import 'package:flutter/material.dart';
import 'package:safe_track/theme/colors.dart';

class DeviceInformationScreen extends StatelessWidget {
  const DeviceInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Device Information",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.navBlue,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInfoTile("Firmware Version", "1.0.7"),
          _buildInfoTile("Hardware Version", "HX-200"),
          _buildInfoTile("Last Sync Timestamp", "12 Jul 2025, 14:55"),
          _buildInfoTile("Battery Level", "82%"),
          _buildInfoTile("Network Signal Strength", "-65 dBm"),
          _buildInfoTile("GPS Status", "Enabled"),
          _buildInfoTile("SOS Feature Status", "On"),
          _buildInfoTile("Geofence Status", "Inside"),
        ],
      ),
    );
  }

  Widget _buildInfoTile(
    String title,
    String value, {
    bool isClickable = false,
  }) {
    return GestureDetector(
      onTap: isClickable ? () {} : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 16, color: AppColors.darkText),
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
