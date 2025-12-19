import 'package:flutter/material.dart';
import 'package:synquerra/theme/colors.dart';

class RechargeRenewalOptionsScreen extends StatefulWidget {
  const RechargeRenewalOptionsScreen({super.key});

  @override
  State<RechargeRenewalOptionsScreen> createState() =>
      _RechargeRenewalOptionsScreenState();
}

class _RechargeRenewalOptionsScreenState
    extends State<RechargeRenewalOptionsScreen> {
  String _selectedPlan = "Monthly";
  bool _autoRenew = false;
  final TextEditingController _couponController = TextEditingController();

  final List<Map<String, String>> plans = [
    {"name": "Monthly", "duration": "30 days", "price": "₹199"},
    {"name": "Quarterly", "duration": "90 days", "price": "₹499"},
    {"name": "Half-Yearly", "duration": "180 days", "price": "₹899"},
    {"name": "Yearly", "duration": "365 days", "price": "₹1599"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Recharge / Change Plan",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.navBlue,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Select a Plan:",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 12),
          ...plans.map((plan) => _buildPlanTile(plan)),
          const SizedBox(height: 8),
          const Text(
            "Above plans are excluding GST/applicable taxes",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.navBlue,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
            ),
            onPressed: () {
              // integrate Razorpay or show dialog
            },
            child: const Text("PAY WITH RAZORPAY"),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Auto-Renewal",
                style: TextStyle(fontSize: 16, color: AppColors.darkText),
              ),
              Switch(
                value: _autoRenew,
                activeThumbColor: AppColors.safeGreen,
                onChanged: (val) {
                  setState(() => _autoRenew = val);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "Apply Coupon / Promo Code",
            style: TextStyle(fontSize: 16, color: AppColors.darkText),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _couponController,
            decoration: InputDecoration(
              hintText: "Enter code",
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: IconButton(
                icon: const Icon(
                  Icons.check_circle,
                  color: AppColors.safeGreen,
                ),
                onPressed: () {
                  // Apply code logic
                },
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          const Text(
            "Transaction History",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 12),
          _buildHistoryTile("12 Jul 2025", "₹199", "Monthly"),
          _buildHistoryTile("15 Apr 2025", "₹499", "Quarterly"),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.safeGreen,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 44),
            ),
            onPressed: () {
              // Download receipt logic
            },
            child: const Text("Download Receipt / Invoice"),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanTile(Map<String, String> plan) {
    final isSelected = _selectedPlan == plan["name"];
    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = plan["name"]!),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.navBlue.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.navBlue : Colors.grey.shade300,
            width: 1.4,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "• ${plan["name"]}   ${plan["duration"]}",
              style: TextStyle(
                fontSize: 16,
                color: AppColors.darkText,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            Text(
              plan["price"]!,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.navBlue : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTile(String date, String amount, String plan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            date,
            style: const TextStyle(fontSize: 15, color: AppColors.darkText),
          ),
          Text(amount, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(plan, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
