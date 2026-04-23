import 'package:flutter/material.dart';
import 'package:synquerra/old/theme/colors.dart';

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
          _buildInfoTile("Current Plan Name", "Quarterly"),
          _buildInfoTile("Plan Start Date", "01 Jul 2025"),
          _buildInfoTile("Plan Expiry Date", "30 Sep 2025"),
          _buildInfoTile("Status", "Active"),
          _buildInfoTile("Auto-Renewal Enabled", "Yes"),
          _buildInfoTile("Outstanding Balance", "₹0"),
          _buildInfoTile("Renewal Reminder Date", "25 Sep 2025"),
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
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
