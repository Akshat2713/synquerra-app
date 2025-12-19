import 'package:flutter/material.dart';
import 'package:synquerra/theme/colors.dart';

class SosIntervalScreen extends StatefulWidget {
  const SosIntervalScreen({super.key});

  @override
  State<SosIntervalScreen> createState() => _SosIntervalScreenState();
}

class _SosIntervalScreenState extends State<SosIntervalScreen> {
  bool sosEnabled = true;
  String selectedOption = '5s';

  void _selectOption(String option) {
    if (sosEnabled) {
      setState(() {
        selectedOption = option;
      });
    }
  }

  void _showCustomInputDialog() async {
    TextEditingController controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text("Enter custom interval (seconds)"),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: "E.g. 8"),
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
      onTap: sosEnabled ? onTap : null,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: sosEnabled ? Colors.white : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
          border: isSelected && sosEnabled
              ? Border.all(color: AppColors.navBlue, width: 2)
              : null,
        ),
        child: Row(
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: sosEnabled ? Colors.black : Colors.grey,
              ),
            ),
            const Spacer(),
            if (isSelected && sosEnabled)
              const Icon(Icons.check_circle, color: AppColors.navBlue)
            else
              Icon(
                Icons.circle_outlined,
                color: sosEnabled ? Colors.grey : Colors.grey.shade400,
              ),
          ],
        ),
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
          "SOS Mode Interval",
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
              "Defines how frequently data packets are sent during an active SOS mode.\n\n"
              "Recommended: 5–10 seconds.\n\n"
              "Shows current SOS status and lets you deactivate if your role permits.",
              style: TextStyle(fontSize: 16, color: AppColors.darkText),
            ),
          ),
          Container(
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
            ),
            child: Row(
              children: [
                const Text(
                  "SOS Mode Active",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkText,
                  ),
                ),
                const Spacer(),
                Switch(
                  value: sosEnabled,
                  activeThumbColor: AppColors.safeGreen,
                  inactiveThumbColor: Colors.grey,
                  onChanged: (val) {
                    setState(() {
                      sosEnabled = val;
                    });
                  },
                ),
              ],
            ),
          ),
          _buildOptionRow("5s", () => _selectOption("5s")),
          _buildOptionRow("10s", () => _selectOption("10s")),
          _buildOptionRow("15s", () => _selectOption("15s")),
          _buildOptionRow("Custom", _showCustomInputDialog),
        ],
      ),
    );
  }
}
