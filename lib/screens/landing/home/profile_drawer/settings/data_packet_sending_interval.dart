import 'package:flutter/material.dart';
import 'package:synquerra/theme/colors.dart';

class DataPacketSendingIntervalScreen extends StatefulWidget {
  const DataPacketSendingIntervalScreen({super.key});

  @override
  State<DataPacketSendingIntervalScreen> createState() =>
      _DataPacketSendingIntervalScreenState();
}

class _DataPacketSendingIntervalScreenState
    extends State<DataPacketSendingIntervalScreen> {
  String selectedOption = '300s'; // default selection

  void _selectOption(String option) {
    setState(() {
      selectedOption = option;
    });
  }

  void _showCustomInputDialog() async {
    TextEditingController controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text("Enter custom interval (in seconds)"),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: "e.g. 900"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Cancel",
                style: TextStyle(color: AppColors.emergencyRed),
              ),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  setState(() {
                    selectedOption = "${controller.text}s";
                  });
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

  Widget _buildOptionRow(String text, VoidCallback onTap) {
    bool isSelected = selectedOption == text;
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
          border: isSelected
              ? Border.all(color: AppColors.navBlue, width: 2)
              : null,
        ),
        child: Row(
          children: [
            Text(
              text,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.navBlue)
            else
              const Icon(Icons.circle_outlined, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // your theme rule
      appBar: AppBar(
        backgroundColor: AppColors.navBlue,
        title: const Text(
          "Data Packet Interval",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              "This defines how often normal data packets are transmitted.\n"
              "Default is 300 seconds (5 min). You can also adjust to 15 or 30 minutes, "
              "or set a custom interval. "
              "\n\nAdvanced profiles can adjust this based on geofences, battery level, or user profiles.",
              style: TextStyle(fontSize: 16, color: AppColors.darkText),
            ),
          ),
          _buildOptionRow("300s (5 min)", () => _selectOption("300s")),
          _buildOptionRow("900s (15 min)", () => _selectOption("900s")),
          _buildOptionRow("1800s (30 min)", () => _selectOption("1800s")),
          _buildOptionRow("Custom", _showCustomInputDialog),
        ],
      ),
    );
  }
}
