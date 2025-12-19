import 'package:flutter/material.dart';
import 'package:synquerra/theme/colors.dart';

class IntervalProfilesScreen extends StatefulWidget {
  const IntervalProfilesScreen({super.key});

  @override
  State<IntervalProfilesScreen> createState() => _IntervalProfilesScreenState();
}

class _IntervalProfilesScreenState extends State<IntervalProfilesScreen> {
  String normal = "300s";
  String insideGeofence = "120s";
  String outsideGeofence = "600s";
  String lowBattery = "900s";

  void _showCustomInputDialog({
    required String title,
    required String hint,
    required Function(String) onSave,
  }) async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text("Set $title"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(hintText: hint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(color: AppColors.emergencyRed),
            ),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                onSave("${controller.text}s");
              }
              Navigator.pop(context);
            },
            child: const Text(
              "Save",
              style: TextStyle(color: AppColors.safeGreen),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(String text) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, color: AppColors.darkText),
      ),
    );
  }

  Widget _buildProfileBlock({
    required String title,
    required String value,
    required VoidCallback onChange,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                value,
                style: const TextStyle(fontSize: 20, color: AppColors.darkText),
              ),
              const Spacer(),
              TextButton(
                onPressed: onChange,
                child: const Text(
                  "Change",
                  style: TextStyle(
                    color: AppColors.safeGreen,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.navBlue,
        title: const Text(
          "Interval Profiles",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          _buildDescription(
            "Define different data transmission intervals based on conditions like normal operation, "
            "geofence zone, or low battery. Helps optimize power and network usage.",
          ),
          _buildProfileBlock(
            title: "Normal",
            value: normal,
            onChange: () {
              _showCustomInputDialog(
                title: "Normal Interval (s)",
                hint: "e.g. 300",
                onSave: (val) => setState(() => normal = val),
              );
            },
          ),
          _buildProfileBlock(
            title: "Inside Geofence",
            value: insideGeofence,
            onChange: () {
              _showCustomInputDialog(
                title: "Inside Geofence Interval (s)",
                hint: "e.g. 120",
                onSave: (val) => setState(() => insideGeofence = val),
              );
            },
          ),
          _buildProfileBlock(
            title: "Outside Geofence",
            value: outsideGeofence,
            onChange: () {
              _showCustomInputDialog(
                title: "Outside Geofence Interval (s)",
                hint: "e.g. 600",
                onSave: (val) => setState(() => outsideGeofence = val),
              );
            },
          ),
          _buildProfileBlock(
            title: "Low Battery",
            value: lowBattery,
            onChange: () {
              _showCustomInputDialog(
                title: "Low Battery Interval (s)",
                hint: "e.g. 900",
                onSave: (val) => setState(() => lowBattery = val),
              );
            },
          ),
        ],
      ),
    );
  }
}
