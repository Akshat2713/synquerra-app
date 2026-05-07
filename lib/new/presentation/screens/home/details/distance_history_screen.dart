// // lib/presentation/screens/home/details/distance_history_screen.dart
// import 'package:flutter/material.dart';
// import 'package:synquerra/business/entities/analytics_entity.dart';
// import '../../../themes/colors.dart';
// import '../../../widgets/timeline/timeline_item.dart';

// class DistanceHistoryScreen extends StatelessWidget {
//   final List<AnalyticsDistanceEntity> data;
//   final String imei;

//   const DistanceHistoryScreen({
//     super.key,
//     required this.data,
//     required this.imei,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final displayList = data.reversed.toList();
//     final totalDistance = displayList.isNotEmpty
//         ? displayList.first.cumulative
//         : 0.0;

//     return Scaffold(
//       backgroundColor: theme.brightness == Brightness.dark
//           ? Colors.black87
//           : const Color(0xFFF2F4F7),
//       appBar: AppBar(
//         title: const Text("24h Travel Log"),
//         backgroundColor: AppColors.navBlue,
//         elevation: 0,
//       ),
//       body: Column(
//         children: [
//           // Header Summary
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: AppColors.navBlue,
//               borderRadius: const BorderRadius.only(
//                 bottomLeft: Radius.circular(30),
//                 bottomRight: Radius.circular(30),
//               ),
//             ),
//             child: Column(
//               children: [
//                 Text(
//                   "Total Distance (24h)",
//                   style: TextStyle(
//                     color: Colors.white.withOpacity(0.8),
//                     fontSize: 14,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   "${totalDistance.toStringAsFixed(2)} km",
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 36,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 12,
//                     vertical: 4,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     "IMEI: $imei",
//                     style: const TextStyle(color: Colors.white, fontSize: 12),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Timeline List
//           Expanded(
//             child: ListView.builder(
//               padding: const EdgeInsets.all(16),
//               itemCount: displayList.length,
//               itemBuilder: (context, index) {
//                 final item = displayList[index];
//                 final isLast = index == displayList.length - 1;
//                 return TimelineItem(item: item, isLast: isLast);
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// lib/presentation/screens/home/details/distance_history_screen.dart
import 'package:flutter/material.dart';
import 'package:synquerra/new/business/entities/analytics_entity.dart';
import '../../../widgets/core/app_card.dart';
import '../../../widgets/core/app_button.dart';
import '../../../widgets/core/app_empty.dart';
import '../../../widgets/core/app_loading.dart';
import '../../../widgets/timeline/timeline_item.dart';
import '../../../themes/colors.dart';

class DistanceHistoryScreen extends StatelessWidget {
  final List<AnalyticsDistanceEntity> data;
  final String imei;
  final bool isLoading;

  const DistanceHistoryScreen({
    super.key,
    required this.data,
    required this.imei,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final displayList = data.reversed.toList();
    final totalDistance = displayList.isNotEmpty
        ? displayList.first.cumulative
        : 0.0;

    return Scaffold(
      backgroundColor: isDark ? Colors.black87 : const Color(0xFFF2F4F7),
      appBar: AppBar(
        title: const Text("24h Travel Log"),
        backgroundColor: AppColors.navBlue,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(context, displayList, totalDistance, isDark),
    );
  }

  Widget _buildBody(
    BuildContext context,
    List<AnalyticsDistanceEntity> displayList,
    double totalDistance,
    bool isDark,
  ) {
    // Loading State
    if (isLoading) {
      return const AppLoading(message: "Loading distance data...");
    }

    // Empty State
    if (displayList.isEmpty) {
      return AppEmpty(
        title: "No distance data",
        subtitle: "No travel history available for the last 24 hours",
        icon: Icons.route_rounded,
        onRefresh: () {
          // TODO: Implement refresh callback
          Navigator.pop(context);
        },
        buttonText: "Go Back",
      );
    }

    // Data Loaded State
    return Column(
      children: [
        // Header Summary Card
        _buildHeaderCard(context, totalDistance),

        // Timeline List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: displayList.length,
            itemBuilder: (context, index) {
              final item = displayList[index];
              final isLast = index == displayList.length - 1;
              return TimelineItem(item: item, isLast: isLast);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderCard(BuildContext context, double totalDistance) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.navBlue, Color(0xFF4A6FA5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.navBlue.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.route_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            "Total Distance",
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),

          // Distance Value
          Text(
            "${totalDistance.toStringAsFixed(2)} km",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 42,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Subtitle
          Text(
            "Last 24 Hours",
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),

          // IMEI Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Text(
              "IMEI: $imei",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
