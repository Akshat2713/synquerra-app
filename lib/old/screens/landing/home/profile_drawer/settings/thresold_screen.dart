import 'package:flutter/material.dart';
import 'package:synquerra/old/theme/colors.dart';

class ThresholdSettingsScreen extends StatefulWidget {
  const ThresholdSettingsScreen({super.key});

  @override
  State<ThresholdSettingsScreen> createState() =>
      _ThresholdSettingsScreenState();
}

class _ThresholdSettingsScreenState extends State<ThresholdSettingsScreen> {
  String speed = "70 km/hr";
  String temp = "50°C";
  String battery = "20%";

  void _showCustomInputDialog({
    required String title,
    required String hint,
    required Function(String) onSave,
  }) async {
    TextEditingController controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
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
                  onSave(controller.text);
                }
                Navigator.pop(context);
              },
              child: const Text(
                "Save",
                style: TextStyle(color: AppColors.safeGreen),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDescription(String text) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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

  Widget _buildThresholdContainer({
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
              Text(value, style: const TextStyle(fontSize: 20)),
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
          "Threshold Settings",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          _buildDescription(
            "Max Speed Alert:\nRecommended to keep at 70 km/hr to avoid excessive speed alerts. "
            "You can set a custom value as per your safety protocols.",
          ),
          _buildThresholdContainer(
            title: "Max Speed Alert",
            value: speed,
            onChange: () {
              _showCustomInputDialog(
                title: "Max Speed Alert (km/hr)",
                hint: "e.g. 70",
                onSave: (val) {
                  setState(() {
                    speed = "$val km/hr";
                  });
                },
              );
            },
          ),
          _buildDescription(
            "Temperature Alert Limit:\nUsually set to 50°C to protect internal components. "
            "Adjust if your device operates in hotter environments.",
          ),
          _buildThresholdContainer(
            title: "Temperature Alert Limit",
            value: temp,
            onChange: () {
              _showCustomInputDialog(
                title: "Temperature Limit (°C)",
                hint: "e.g. 50",
                onSave: (val) {
                  setState(() {
                    temp = "$val°C";
                  });
                },
              );
            },
          ),
          _buildDescription(
            "Low Battery Threshold:\nRecommended to set at 20% to ensure early alerts "
            "and prevent unexpected shutdowns.",
          ),
          _buildThresholdContainer(
            title: "Low Battery Threshold",
            value: battery,
            onChange: () {
              _showCustomInputDialog(
                title: "Low Battery (%)",
                hint: "e.g. 20",
                onSave: (val) {
                  setState(() {
                    battery = "$val%";
                  });
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
