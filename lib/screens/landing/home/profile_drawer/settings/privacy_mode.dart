import 'package:flutter/material.dart';
import 'package:safe_track/theme/colors.dart';

class PrivacyModeScreen extends StatefulWidget {
  const PrivacyModeScreen({super.key});

  @override
  State<PrivacyModeScreen> createState() => _PrivacyModeScreenState();
}

class _PrivacyModeScreenState extends State<PrivacyModeScreen> {
  bool stealthMode = false; // default OFF

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.navBlue,
        title: const Text(
          "Privacy Mode",
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
              "Stealth Tracking Mode disables live updates but continues to cache positions "
              "for post-review by admins only.",
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
                  "Stealth Tracking Mode",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkText,
                  ),
                ),
                const Spacer(),
                Switch(
                  value: stealthMode,
                  activeThumbColor: AppColors.safeGreen,
                  inactiveThumbColor: Colors.grey,
                  onChanged: (val) {
                    setState(() {
                      stealthMode = val;
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
