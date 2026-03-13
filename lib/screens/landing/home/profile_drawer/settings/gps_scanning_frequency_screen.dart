import 'package:flutter/material.dart';
import 'package:synquerra/theme/colors.dart';

class GPSScanningFrequencyScreen extends StatefulWidget {
  const GPSScanningFrequencyScreen({super.key});

  @override
  State<GPSScanningFrequencyScreen> createState() =>
      _GPSScanningFrequencyScreenState();
}

class _GPSScanningFrequencyScreenState
    extends State<GPSScanningFrequencyScreen> {
  String selectedOption = '60s'; // default selection

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
          title: const Text("Enter custom interval (in seconds)"),
          backgroundColor: Colors.white,
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: "e.g. 120"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // close dialog
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
      appBar: AppBar(
        backgroundColor: AppColors.navBlue,
        title: const Text(
          "Location Scan Interval",
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
              "Defines how often the device captures GPS data (not necessarily how often it transmits).\n\n"
              "Recommended: 30–60 seconds during motion, longer during idle/sleep mode.",
              style: TextStyle(fontSize: 16, color: AppColors.darkText),
            ),
          ),
          _buildOptionRow("30s", () => _selectOption("30s")),
          _buildOptionRow("60s", () => _selectOption("60s")),
          _buildOptionRow("300s", () => _selectOption("300s")),
          _buildOptionRow("Custom", _showCustomInputDialog),
        ],
      ),
    );
  }
}
