// lib/presentation/screens/profile/subscription_status_screen.dart
import 'package:flutter/material.dart';
import '../../widgets/common/info_tile.dart';
import '../../themes/colors.dart';

class SubscriptionStatusScreen extends StatelessWidget {
  const SubscriptionStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Subscription Status",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.navBlue,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          InfoTile(title: "Current Plan Name", value: "Quarterly"),
          InfoTile(title: "Plan Start Date", value: "01 Jul 2025"),
          InfoTile(title: "Plan Expiry Date", value: "30 Sep 2025"),
          InfoTile(title: "Status", value: "Active"),
          InfoTile(title: "Auto-Renewal Enabled", value: "Yes"),
          InfoTile(title: "Outstanding Balance", value: "₹0"),
          InfoTile(title: "Renewal Reminder Date", value: "25 Sep 2025"),
        ],
      ),
    );
  }
}
