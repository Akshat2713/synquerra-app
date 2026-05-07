// lib/presentation/screens/home/device_details_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../business/blocs/device_bloc/device_bloc.dart';
import '../../../business/blocs/searched_device_bloc/searched_device_bloc.dart';
import '../../../business/blocs/auth_bloc/auth_bloc.dart';
import '../../widgets/core/app_card.dart';
import '../../widgets/core/app_info_row.dart';
import '../../widgets/core/app_chip.dart';
import '../../widgets/core/app_button.dart';
import '../../widgets/core/app_section.dart';
import '../../widgets/core/app_metric_grid.dart';
import '../../widgets/core/app_status_badge.dart';
import '../../widgets/core/app_icon_with_bg.dart';
import '../../widgets/core/app_progress_indicator.dart';
import '../../widgets/common/logo_widget.dart';
import '../../utils/date_time_formatter.dart';
import '../../utils/color_utils.dart';
import '../../themes/colors.dart';
import 'details/data_telemetry_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final authState = context.watch<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;

    final deviceState = context.watch<DeviceBloc>().state;
    final searchedState = context.watch<SearchedDeviceBloc>().state;

    final activeTelemetry = showingSearch
        ? (searchedState is SearchedDeviceLoaded
              ? searchedState.latestTelemetry
              : null)
        : (deviceState is DeviceLoaded ? deviceState.latestTelemetry : null);

    final activeHealth = showingSearch
        ? (searchedState is SearchedDeviceLoaded
              ? searchedState.healthData
              : null)
        : (deviceState is DeviceLoaded ? deviceState.healthData : null);

    final String currentImei = showingSearch
        ? (searchedState is SearchedDeviceLoaded ? searchedState.imei : "")
        : (user?.imei ?? "");

    final int batteryLevel = activeTelemetry?.battery ?? 100;
    final int signalLevel = activeTelemetry?.signal ?? 74;
    final double speed = activeTelemetry?.speed ?? 0.0;
    final int temperature = activeTelemetry?.temperature ?? 32;
    final double gpsScore = activeHealth?.gpsScore ?? 0.0;
    final double tempIndex = activeHealth?.temperatureIndex ?? 100.0;
    final String tempStatus = activeHealth?.temperatureStatus ?? "normal";

    return DraggableScrollableSheet(
      initialChildSize: 0.15,
      minChildSize: 0.15,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.2),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: CustomScrollView(
              controller: scrollController,
              slivers: [
                // Drag Handle
                SliverToBoxAdapter(
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.3,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                // Header Section
                SliverToBoxAdapter(
                  child: _buildHeader(
                    context,
                    user,
                    activeTelemetry?.timestamp,
                    batteryLevel,
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // === SECTION 1: Live Telemetry Data ===
                SliverToBoxAdapter(
                  child: AppSection(
                    title: "LIVE TELEMETRY",
                    icon: Icons.speed_rounded,
                    children: [
                      AppMetricGrid(
                        children: [
                          AppChip(
                            icon: Icons.speed_rounded,
                            label: "Speed",
                            value: "${speed.toStringAsFixed(1)} km/h",
                            color: Colors.blue,
                          ),
                          AppChip(
                            icon: Icons.battery_full_rounded,
                            label: "Battery",
                            value: "$batteryLevel%",
                            color: ColorUtils.getBatteryColor(batteryLevel),
                          ),
                          AppChip(
                            icon: Icons.signal_cellular_alt_rounded,
                            label: "Signal",
                            value: "$signalLevel%",
                            color: ColorUtils.getSignalColor(signalLevel),
                          ),
                          AppChip(
                            icon: Icons.thermostat_rounded,
                            label: "Temp",
                            value: "$temperature°C",
                            color: ColorUtils.getTemperatureColor(temperature),
                          ),
                          AppChip(
                            icon: Icons.person_outline_rounded,
                            label: "Role",
                            value: user?.userType ?? '--',
                          ),
                          AppChip(
                            icon: Icons.location_on_rounded,
                            label: "GEO ID",
                            value: activeTelemetry?.geoid ?? 'N/A',
                          ),
                          AppChip(
                            icon: Icons.timer_rounded,
                            label: "Interval",
                            value: "${activeTelemetry?.interval ?? '--'} sec",
                          ),
                          AppChip(
                            icon: Icons.sos_rounded,
                            label: "SOS",
                            value: "--Enable--",
                          ), // TODO: Replace with actual SOS status
                        ],
                      ),
                    ],
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // === SECTION 2: Health Metrics ===
                SliverToBoxAdapter(
                  child: AppSection(
                    title: "SYSTEM HEALTH",
                    icon: Icons.health_and_safety_rounded,
                    color: Colors.teal,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: AppCard(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  AppIconWithBg(
                                    icon: Icons.gps_fixed,
                                    color: Colors.teal,
                                    size: 24,
                                    padding: 12,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "GPS Score",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${gpsScore.toInt()}/100",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  AppProgressIndicator(
                                    value: gpsScore,
                                    height: 4,
                                    valueColor: Colors.teal,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppCard(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  AppIconWithBg(
                                    icon: Icons.thermostat,
                                    color: Colors.deepOrange,
                                    size: 24,
                                    padding: 12,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "Temp Index",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${tempIndex.toInt()}/100",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepOrange,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  AppProgressIndicator(
                                    value: tempIndex,
                                    height: 4,
                                    valueColor: Colors.deepOrange,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      AppCard(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Temperature Status",
                              style: TextStyle(
                                fontSize: 14,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            AppStatusBadge(
                              text: tempStatus.toUpperCase(),
                              color: tempStatus == "normal"
                                  ? Colors.green
                                  : Colors.orange,
                              showDot: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // === SECTION 3: Location History Controls ===
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            onPressed: onToggleHistory,
                            label: isHistoryVisible
                                ? "Hide History"
                                : "Show History",
                            icon: isHistoryVisible
                                ? Icons.layers_clear_rounded
                                : Icons.route_rounded,
                            backgroundColor: isHistoryVisible
                                ? AppColors.emergencyRed
                                : colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DataTelemetryScreen(imei: currentImei),
                                ),
                              );
                            },
                            label: "Details",
                            icon: Icons.analytics_rounded,
                            isOutlined: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // === SECTION 4: Guardian Contacts ===
                SliverToBoxAdapter(
                  child: AppSection(
                    title: "GUARDIAN CONTACTS",
                    icon: Icons.contact_emergency_rounded,
                    color: Colors.green,
                    children: [
                      _buildContactCard(
                        context,
                        name:
                            "--Rajesh Kumar--", // TODO: Replace with real guardian name
                        phoneNumber:
                            "--9988XXXXXX--", // TODO: Replace with real phone
                        secondaryPhone:
                            "--8899XXXXXX--", // TODO: Replace with real secondary phone
                      ),
                    ],
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // === SECTION 5: Device Information ===
                SliverToBoxAdapter(
                  child: AppSection(
                    title: "DEVICE INFORMATION",
                    icon: Icons.devices_rounded,
                    color: colorScheme.secondary,
                    children: [
                      AppInfoRow(
                        icon: Icons.qr_code_scanner_rounded,
                        label: "IMEI",
                        value: currentImei.isEmpty ? "---" : currentImei,
                      ),
                      const SizedBox(height: 8),
                      AppInfoRow(
                        icon: Icons.memory_rounded,
                        label: "Firmware",
                        value: "--1dfv3515--",
                      ), // TODO: Replace with actual firmware
                      const SizedBox(height: 8),
                      AppInfoRow(
                        icon: Icons.sim_card_rounded,
                        label: "SIM Number",
                        value: "--1798658789--",
                      ), // TODO: Replace with actual SIM number
                      const SizedBox(height: 8),
                      AppInfoRow(
                        icon: Icons.numbers_rounded,
                        label: "MSDN Number",
                        value: "--1234567890--",
                      ), // TODO: Replace with actual MSDN
                      const SizedBox(height: 8),
                      AppInfoRow(
                        icon: Icons.badge_rounded,
                        label: "Profile Code",
                        value: "--14683515--",
                      ), // TODO: Replace with actual profile code
                    ],
                  ),
                ),

                // Return to My Device Button (if searching)
                if (showingSearch)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                    sliver: SliverToBoxAdapter(
                      child: AppButton(
                        onPressed: () {
                          context.read<SearchedDeviceBloc>().add(
                            SearchedDeviceCleared(),
                          );
                        },
                        label: "Return to My Device",
                        icon: Icons.arrow_back_rounded,
                        backgroundColor: colorScheme.primary,
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    user,
    DateTime? lastUpdate,
    int batteryLevel,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final batteryColor = ColorUtils.getBatteryColor(batteryLevel);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppStatusBadge(
                      text: showingSearch ? "SEARCHED DEVICE" : "YOUR DEVICE",
                      color: showingSearch
                          ? colorScheme.secondary
                          : colorScheme.primary,
                      showDot: false,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      showingSearch
                          ? "Device Tracking"
                          : (user?.fullName ?? 'User'),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              AppCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                hasShadow: false,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      batteryLevel <= 20
                          ? Icons.battery_alert_rounded
                          : Icons.battery_full_rounded,
                      color: batteryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "$batteryLevel%",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: batteryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            hasShadow: false,
            child: Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Last update: ${DateTimeFormatter.formatRelativeTime(lastUpdate)}",
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurfaceVariant,
                    ),
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
    BuildContext context, {
    required String name,
    required String phoneNumber,
    String? secondaryPhone,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppIconWithBg(
                icon: Icons.person_rounded,
                color: Colors.green,
                size: 18,
                padding: 8,
              ),
              const SizedBox(width: 12),
              Text(
                name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppCard(
            padding: const EdgeInsets.all(12),
            backgroundColor: colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.2,
            ),
            hasShadow: false,
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.phone_rounded, size: 16, color: Colors.green),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        phoneNumber,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildContactActionButton(
                          Icons.call_rounded,
                          Colors.green,
                        ),
                        const SizedBox(width: 4),
                        _buildContactActionButton(
                          Icons.chat_rounded,
                          Colors.orange,
                        ),
                      ],
                    ),
                  ],
                ),
                if (secondaryPhone != null) ...[
                  const SizedBox(height: 8),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.phone_rounded, size: 16, color: Colors.orange),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          secondaryPhone,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      _buildContactActionButton(
                        Icons.chat_rounded,
                        Colors.orange,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactActionButton(IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 18),
        onPressed: () {},
        padding: const EdgeInsets.all(6),
        constraints: const BoxConstraints(),
      ),
    );
  }
}
