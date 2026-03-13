import 'package:flutter/material.dart';
import 'package:synquerra/theme/colors.dart';

class LedIndicatorScreen extends StatefulWidget {
  const LedIndicatorScreen({super.key});

  @override
  State<LedIndicatorScreen> createState() => _LedIndicatorScreenState();
}

class _LedIndicatorScreenState extends State<LedIndicatorScreen> {
  bool ledsEnabled = true; // default ON

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.navBlue,
        title: const Text(
          "LED Indicators",
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
              "Disable LED indicators for stealth mode operations, such as security tasks or covert monitoring.",
              style: TextStyle(fontSize: 16, color: AppColors.darkText),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Text(
                  "LED Indicators",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkText,
                  ),
                ),
                const Spacer(),
                Switch(
                  value: ledsEnabled,
                  activeThumbColor: AppColors.safeGreen,
                  inactiveThumbColor: Colors.grey,
                  onChanged: (val) {
                    setState(() {
                      ledsEnabled = val;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
