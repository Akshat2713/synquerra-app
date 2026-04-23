// lib/presentation/screens/home/details/detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../business/blocs/device_bloc/device_bloc.dart';
import '../../../../business/blocs/searched_device_bloc/searched_device_bloc.dart';
import '../../../../business/blocs/auth_bloc/auth_bloc.dart';
import '../../../widgets/cards/telemetry_history_card.dart';
import '../../../widgets/layout/loading_state.dart';
import '../../../widgets/layout/empty_state.dart';
import '../../../utils/date_time_formatter.dart';
import '../../../themes/colors.dart';

class DeviceDetailsScreen extends StatelessWidget {
  final String imei;

  const DeviceDetailsScreen({super.key, required this.imei});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final isOwnDevice =
        authState is AuthAuthenticated && imei == authState.user.imei;

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF0A0C10)
          : const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: AppColors.navBlue,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Full Telemetry Log",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              "IMEI: $imei",
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'monospace',
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
      body: BlocBuilder<DeviceBloc, DeviceState>(
        builder: (context, deviceState) {
          if (deviceState is DeviceLoading) {
            return const LoadingState(message: "Loading telemetry data...");
          }

          if (deviceState is DeviceLoaded &&
              deviceState.allPackets.isNotEmpty) {
            final historyData = deviceState.allPackets.reversed
                .take(50)
                .toList();
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: historyData.length,
              itemBuilder: (context, index) =>
                  TelemetryHistoryCard(data: historyData[index]),
            );
          }

          if (deviceState is DeviceError) {
            return Center(child: Text(deviceState.message));
          }

          return EmptyState(
            message: "No logs found",
            subtitle: "Waiting for device data...",
          );
        },
      ),
    );
  }
}
