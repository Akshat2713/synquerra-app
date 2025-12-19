import 'package:flutter/material.dart';
import 'package:synquerra/core/models/analytics_model.dart';
import 'package:synquerra/theme/colors.dart';

class DistanceHistoryScreen extends StatelessWidget {
  final List<AnalyticsDistance> data;
  final String imei;

  const DistanceHistoryScreen({
    super.key,
    required this.data,
    required this.imei,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Reverse data to show latest time first
    final displayList = data.reversed.toList();

    // Get total distance from the latest cumulative point (which is the first item in reversed list)
    final totalDistance = displayList.isNotEmpty
        ? displayList.first.cumulative
        : 0.0;

    return Scaffold(
      backgroundColor: isDark ? Colors.black87 : const Color(0xFFF2F4F7),
      appBar: AppBar(
        title: const Text("24h Travel Log"),
        backgroundColor: AppColors.navBlue,
        elevation: 0,
      ),
      body: Column(
        children: [
          // --- HEADER SUMMARY ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.navBlue,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                Text(
                  "Total Distance (24h)",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "${totalDistance.toStringAsFixed(2)} km",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "IMEI: $imei",
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          // --- TIMELINE LIST ---
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: displayList.length,
              itemBuilder: (context, index) {
                final item = displayList[index];
                // Check if this is the last item to hide the bottom line connector
                final isLast = index == displayList.length - 1;
                return _buildTimelineItem(item, isLast, theme);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    AnalyticsDistance item,
    bool isLast,
    ThemeData theme,
  ) {
    final isIdle = item.distance == 0.0;

    // Visual logic: Active items are Blue, Idle items are Grey
    final Color activeColor = isIdle
        ? Colors.grey.withOpacity(0.4)
        : AppColors.navBlue;
    final Color cardColor = theme.colorScheme.surface;
    final Color textColor = theme.colorScheme.onSurface;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- LEFT: TIME COLUMN ---
          SizedBox(
            width: 50,
            child: Column(
              children: [
                Text(
                  item.hour,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // --- MIDDLE: LINE & DOT ---
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isIdle ? Colors.transparent : activeColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: activeColor, width: 2),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.grey.withOpacity(0.3),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),

          // --- RIGHT: DATA CARD ---
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  // Add a subtle border for active items
                  border: isIdle
                      ? null
                      : Border.all(color: activeColor.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isIdle ? "Idle / Stationary" : "Active Movement",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: activeColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              "${item.distance.toStringAsFixed(3)} km",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isIdle
                                    ? textColor.withOpacity(0.5)
                                    : textColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "Total So Far",
                          style: TextStyle(
                            fontSize: 10,
                            color: textColor.withOpacity(0.5),
                          ),
                        ),
                        Text(
                          "${item.cumulative.toStringAsFixed(2)} km",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: textColor.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
