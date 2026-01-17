import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:synquerra/providers/user_provider.dart';
import 'package:synquerra/providers/device_provider.dart';
import 'package:synquerra/providers/searched_device_provider.dart';
import 'package:synquerra/screens/landing/home/details/data_telemetry_screen.dart';
// Ensure you import your telemetry screen here
// import 'package:synquerra/screens/data_telemetry_screen.dart';

class DeviceDetailsSheet extends StatelessWidget {
  final bool showingSearch;
  final VoidCallback onToggleHistory;
  final bool isHistoryVisible;

  const DeviceDetailsSheet({
    super.key,
    required this.showingSearch,
    required this.onToggleHistory,
    required this.isHistoryVisible,
  });

  String _formatDateTime(String? timestamp) {
    if (timestamp == null || !timestamp.contains('T')) return 'Fetching...';
    try {
      final parts = timestamp.split('T');
      final dateParts = parts[0].split('-');
      final time = parts[1].split('.')[0];
      return "${dateParts[2]}/${dateParts[1]}/${dateParts[0]} $time";
    } catch (e) {
      return timestamp;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final user = context.watch<UserProvider>().user;
    final myProv = context.watch<DeviceProvider>();
    final searchProv = context.watch<SearchedDeviceProvider>();

    final activeTelemetry = showingSearch
        ? searchProv.latestTelemetry
        : myProv.latestTelemetry;
    final activeHealth = showingSearch
        ? searchProv.healthData
        : myProv.healthData;

    // --- HANDLE IMEI EXTRACTION ---
    final String currentImei = showingSearch
        ? (searchProv.currentImei ?? "")
        : (user?.imei ?? "");

    final int batteryLevel =
        int.tryParse(activeTelemetry?.battery ?? '100') ?? 100;
    final Color batteryColor = batteryLevel <= 20 ? Colors.red : Colors.green;

    return DraggableScrollableSheet(
      initialChildSize: 0.15,
      minChildSize: 0.15,
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 5,
              ),
            ],
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          showingSearch
                              ? "Viewing Searched"
                              : "Tracking ${user?.firstName ?? 'User'}",
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              "$batteryLevel%",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              batteryLevel <= 20
                                  ? Icons.battery_alert
                                  : Icons.battery_full,
                              color: batteryColor,
                              size: 24,
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      "Last Seen: ${_formatDateTime(activeTelemetry?.timestamp)}",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(indent: 20, endIndent: 20, thickness: 2.0),

              _buildInfoRow(
                theme,
                icon: Icons.location_history,
                label: "GEO Number:",
                value: "--3--",
                valueSuffix: "-- Safe Zone--",
                valueSuffixColor: Colors.green,
              ),
              _buildInfoRow(
                theme,
                icon: Icons.score,
                label: "GPS Score:",
                value: "${activeHealth?.gpsScore.toInt() ?? 0}",
                valueSuffix: " / 100",
                valueSuffixColor: Colors.blue,
              ),
              _buildInfoRow(
                theme,
                icon: Icons.speed,
                label: "Speed",
                value: "${activeTelemetry?.speed ?? 0.0} Km/hr",
              ),
              _buildInfoRow(
                theme,
                icon: Icons.thermostat,
                label: "Temperature",
                value: "${activeTelemetry?.temperature ?? '32'}°C",
              ),
              _buildInfoRow(
                theme,
                icon: Icons.signal_cellular_alt,
                label: "SIM 1",
                value: "Signal Strength: ",
                valueSuffix: "${activeTelemetry?.signal ?? 74}%",
                valueSuffixColor: Colors.green,
              ),
              _buildInfoRow(
                theme,
                icon: Icons.sos,
                label: "SOS",
                value: "--Enable--",
              ),

              // --- NEW: DETAILED TELEMETRY BUTTON ---
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to Detailed Telemetry Screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DataTelemetryScreen(imei: currentImei),
                      ),
                    );
                    debugPrint(
                      "Navigating to detailed telemetry for IMEI: $currentImei",
                    );
                  },
                  icon: const Icon(Icons.analytics_outlined),
                  label: const Text("View Detailed Telemetry"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.secondaryContainer,
                    foregroundColor: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 4.0,
                ),
                child: ElevatedButton.icon(
                  onPressed: onToggleHistory,
                  icon: Icon(
                    isHistoryVisible ? Icons.layers_clear : Icons.route,
                  ),
                  label: Text(
                    isHistoryVisible
                        ? "Hide Location History"
                        : "Show 24h Location History",
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isHistoryVisible
                        ? Colors.redAccent
                        : theme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),

              const Divider(indent: 60, endIndent: 60),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Guardian Contacts:",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              _buildContactCard(
                theme,
                name: "--Rajesh Kumar--",
                phoneNumber: "--9988XXXXXX--",
                secondaryPhone: "--8899XXXXXX--",
              ),

              const Divider(indent: 60, endIndent: 60),

              _buildInfoRow(
                theme,
                icon: Icons.devices,
                label: "IMEI (Device):",
                value: currentImei.isEmpty ? "---" : currentImei,
              ),
              _buildInfoRow(
                theme,
                icon: Icons.memory,
                label: "Firmware:",
                value: "--1dfv3515--",
              ),
              _buildInfoRow(
                theme,
                icon: Icons.sim_card,
                label: "SIM No:",
                value: "--1798658789--",
              ),
              _buildInfoRow(
                theme,
                icon: Icons.numbers,
                label: "MSDN No:",
                value: "--1234567890--",
              ),
              _buildInfoRow(
                theme,
                icon: Icons.badge,
                label: "Profile Code:",
                value: "--14683515--",
              ),

              if (showingSearch)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 16.0,
                  ),
                  child: ElevatedButton(
                    onPressed: () =>
                        context.read<SearchedDeviceProvider>().clearSearch(),
                    child: const Text("Return to My Device"),
                  ),
                ),
              const SizedBox(height: 100),
            ],
          ),
        );
      },
    );
  }

  // ... (Keep your _buildInfoRow and _buildContactCard helpers as they were)
  Widget _buildInfoRow(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String value,
    String? valueSuffix,
    Color? valueSuffixColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Text(value, style: const TextStyle(fontSize: 18)),
                if (valueSuffix != null)
                  Text(
                    valueSuffix,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: valueSuffixColor,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(
    ThemeData theme, {
    required String name,
    required String phoneNumber,
    String? secondaryPhone,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                phoneNumber,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.call, color: Colors.green),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.chat, color: Colors.orange),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
          if (secondaryPhone != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  secondaryPhone,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                IconButton(
                  icon: const Icon(Icons.chat, color: Colors.orange),
                  onPressed: () {},
                ),
              ],
            ),
        ],
      ),
    );
  }
}

//______________________________________________________________________________
// Device Details Sheet Widget
//______________________________________________________________________________

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:synquerra/providers/user_provider.dart';
// import 'package:synquerra/providers/device_provider.dart';
// import 'package:synquerra/providers/searched_device_provider.dart';

// class DeviceDetailsSheet extends StatelessWidget {
//   final bool showingSearch;
//   final VoidCallback onToggleHistory;
//   final bool isHistoryVisible;

//   const DeviceDetailsSheet({
//     super.key,
//     required this.showingSearch,
//     required this.onToggleHistory,
//     required this.isHistoryVisible,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;

//     // Watch relevant providers
//     final user = context.watch<UserProvider>().user;
//     final myProv = context.watch<DeviceProvider>();
//     final searchProv = context.watch<SearchedDeviceProvider>();

//     final activeTelemetry = showingSearch
//         ? searchProv.latestTelemetry
//         : myProv.latestTelemetry;
//     final activeHealth = showingSearch
//         ? searchProv.healthData
//         : myProv.healthData;

//     return DraggableScrollableSheet(
//       initialChildSize: 0.15,
//       minChildSize: 0.15,
//       maxChildSize: 0.8,
//       builder: (context, scrollController) {
//         return Container(
//           decoration: BoxDecoration(
//             color: colorScheme.surface,
//             borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.3),
//                 blurRadius: 15,
//                 spreadRadius: 5,
//               ),
//             ],
//           ),
//           child: ListView(
//             controller: scrollController,
//             padding: const EdgeInsets.symmetric(vertical: 12.0),
//             children: [
//               // Drag Handle
//               Center(
//                 child: Container(
//                   width: 40,
//                   height: 5,
//                   decoration: BoxDecoration(
//                     color: Colors.grey[300],
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//               ),

//               // Tracking Header
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16.0,
//                   vertical: 8.0,
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       showingSearch
//                           ? "Viewing Searched"
//                           : "Tracking ${user?.firstName ?? 'User'}",
//                       style: theme.textTheme.titleLarge?.copyWith(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     Row(
//                       children: [
//                         Text(
//                           "${activeTelemetry?.battery ?? '0'}%",
//                           style: const TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                         const SizedBox(width: 4),
//                         const Icon(
//                           Icons.battery_full,
//                           color: Colors.green,
//                           size: 24,
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),

//               // Restored Fields
//               _buildInfoRow(
//                 theme,
//                 icon: Icons.location_history,
//                 label: "GEO Number:",
//                 value: "3",
//                 valueSuffix: " Safe Zone",
//                 valueSuffixColor: Colors.green,
//               ),
//               _buildInfoRow(
//                 theme,
//                 icon: Icons.score,
//                 label: "GPS Score:",
//                 value: "${activeHealth?.gpsScore.toInt() ?? 0}",
//                 valueSuffix: " / 100",
//                 valueSuffixColor: Colors.blue,
//               ),
//               _buildInfoRow(
//                 theme,
//                 icon: Icons.speed,
//                 label: "${activeTelemetry?.speed ?? 0.0} Km/hr",
//                 value:
//                     "${activeTelemetry?.temperature?.replaceAll('c', '').trim() ?? '32'}°C",
//               ),
//               _buildInfoRow(
//                 theme,
//                 icon: Icons.signal_cellular_alt,
//                 label: "SIM 1",
//                 value: "Signal Strength: ",
//                 valueSuffix: "${activeTelemetry?.signal ?? 74}%",
//                 valueSuffixColor: Colors.green,
//               ),

//               const Divider(indent: 60, endIndent: 60),

//               // Guardian Contacts
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Text(
//                   "Guardian Contacts:",
//                   style: theme.textTheme.titleMedium?.copyWith(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 18,
//                   ),
//                 ),
//               ),
//               _buildContactCard(
//                 theme,
//                 name: "${user?.firstName} ${user?.lastName}",
//                 phoneNumber: user?.mobile ?? "N/A",
//                 email: user?.email ?? "N/A",
//               ),

//               const Divider(indent: 60, endIndent: 60),

//               // Device Details
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Text(
//                   "Device Details",
//                   style: theme.textTheme.titleMedium?.copyWith(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 18,
//                   ),
//                 ),
//               ),
//               _buildInfoRow(
//                 theme,
//                 icon: Icons.devices,
//                 label: "IMEI (Device):",
//                 value: user?.imei ?? "---",
//               ),
//               _buildInfoRow(
//                 theme,
//                 icon: Icons.memory,
//                 label: "Firmware:",
//                 value: "1dfv3515",
//               ),
//               _buildInfoRow(
//                 theme,
//                 icon: Icons.history,
//                 label: "History Path:",
//                 value: isHistoryVisible ? "Visible" : "Hidden",
//               ),
//               const SizedBox(height: 12),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton.icon(
//                   icon: Icon(
//                     isHistoryVisible ? Icons.layers_clear : Icons.route,
//                   ),
//                   label: Text(
//                     isHistoryVisible
//                         ? "Hide Location History"
//                         : "Show 24h Location History",
//                   ),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: isHistoryVisible
//                         ? Colors.redAccent
//                         : theme.primaryColorLight,
//                   ),
//                   onPressed: onToggleHistory,
//                 ),
//               ),

//               if (showingSearch)
//                 Padding(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 16.0,
//                     vertical: 20,
//                   ),
//                   child: ElevatedButton(
//                     onPressed: () =>
//                         context.read<SearchedDeviceProvider>().clearSearch(),
//                     child: const Text("Return to My Device"),
//                   ),
//                 ),
//               const SizedBox(height: 100),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   // Internal Helper widgets moved here
//   Widget _buildInfoRow(
//     ThemeData theme, {
//     required IconData icon,
//     required String label,
//     required String value,
//     String? valueSuffix,
//     Color? valueSuffixColor,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
//       child: Row(
//         children: [
//           Icon(
//             icon,
//             size: 20,
//             color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
//           ),
//           const SizedBox(width: 10),
//           SizedBox(
//             width: 120,
//             child: Text(
//               label,
//               style: theme.textTheme.bodyLarge?.copyWith(
//                 fontSize: 18,
//                 color: theme.colorScheme.onSurfaceVariant,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Row(
//               children: [
//                 Text(value, style: const TextStyle(fontSize: 18)),
//                 if (valueSuffix != null)
//                   Text(
//                     valueSuffix,
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w600,
//                       color: valueSuffixColor,
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildContactCard(
//     ThemeData theme, {
//     required String name,
//     required String phoneNumber,
//     required String email,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   name,
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Text(
//                   phoneNumber,
//                   style: const TextStyle(fontSize: 16, color: Colors.grey),
//                 ),
//                 Text(
//                   email,
//                   style: const TextStyle(fontSize: 16, color: Colors.grey),
//                 ),
//               ],
//             ),
//           ),
//           IconButton(
//             icon: const Icon(Icons.call, color: Colors.white),
//             style: IconButton.styleFrom(backgroundColor: theme.primaryColor),
//             onPressed: () {},
//           ),
//         ],
//       ),
//     );
//   }
// }
