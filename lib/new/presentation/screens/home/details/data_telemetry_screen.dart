// lib/presentation/screens/home/details/data_telemetry_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../business/blocs/device_bloc/device_bloc.dart';
import '../../../../business/blocs/searched_device_bloc/searched_device_bloc.dart';
import '../../../../business/blocs/auth_bloc/auth_bloc.dart';
import '../../../../business/entities/analytics_entity.dart';
import '../../../widgets/cards/status_card.dart';
import '../../../widgets/cards/distance_card.dart';
import '../../../widgets/cards/health_card.dart';
import '../../../widgets/cards/uptime_card.dart';
import '../../../widgets/layout/loading_state.dart';
import '../../../widgets/layout/empty_state.dart';
import '../../../widgets/feedback/custom_snackbar.dart';
import '../../../themes/colors.dart';

class DataTelemetryScreen extends StatefulWidget {
  final String imei;
  const DataTelemetryScreen({super.key, required this.imei});

  @override
  State<DataTelemetryScreen> createState() => _DataTelemetryScreenState();
}

class _DataTelemetryScreenState extends State<DataTelemetryScreen> {
  bool _isManualRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final deviceState = context.read<DeviceBloc>().state;
    final authState = context.read<AuthBloc>().state;

    // Check if this is the user's own device
    if (authState is AuthAuthenticated && widget.imei == authState.user.imei) {
      // Only fetch if no data OR data is for a different device
      if (deviceState is DeviceInitial ||
          (deviceState is DeviceLoaded &&
              deviceState.latestTelemetry?.imei != widget.imei)) {
        debugPrint('🔄 Loading data for device: ${widget.imei}');
        context.read<DeviceBloc>().add(DeviceDataRequested(imei: widget.imei));
      } else {
        debugPrint('✅ Using existing data for device: ${widget.imei}');
      }
    } else {
      // Searched device - use SearchedDeviceBloc
      final searchedState = context.read<SearchedDeviceBloc>().state;
      if (searchedState is SearchedDeviceInitial ||
          (searchedState is SearchedDeviceLoaded &&
              searchedState.imei != widget.imei)) {
        context.read<SearchedDeviceBloc>().add(
          SearchedDeviceFetchRequested(imei: widget.imei),
        );
      }
    }
  }

  Future<void> _handleManualRefresh() async {
    if (_isManualRefreshing) return;
    setState(() => _isManualRefreshing = true);

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      if (widget.imei == authState.user.imei) {
        // Force refresh - this will update data everywhere
        context.read<DeviceBloc>().add(
          DeviceRefreshRequested(imei: widget.imei),
        );
      } else {
        context.read<SearchedDeviceBloc>().add(
          SearchedDeviceFetchRequested(imei: widget.imei),
        );
      }
    }

    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      CustomSnackbar.show(
        context,
        message: "Telemetry data updated",
        type: SnackbarType.success,
      );
      setState(() => _isManualRefreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = context.watch<AuthBloc>().state;
    final deviceState = context.watch<DeviceBloc>().state;
    final searchedState = context.watch<SearchedDeviceBloc>().state;

    final bool isOwnDevice =
        authState is AuthAuthenticated && widget.imei == authState.user.imei;
    final isLoading = isOwnDevice
        ? deviceState is DeviceLoading
        : searchedState is SearchedDeviceLoading;
    final hasData = isOwnDevice
        ? (deviceState is DeviceLoaded && deviceState.hasData)
        : (searchedState is SearchedDeviceLoaded && searchedState.hasData);

    if (isLoading && !hasData) {
      return const LoadingState(message: "Loading Telemetry Data...");
    }

    if (!hasData && !isLoading) {
      return EmptyState(
        message: "No telemetry data available",
        subtitle: "This device hasn't sent any data yet",
        onRefresh: _handleManualRefresh,
      );
    }

    // Get data with proper typing
    List<AnalyticsDataEntity> allPackets = [];
    AnalyticsDataEntity? latestData;
    List<AnalyticsDistanceEntity> distanceData = [];
    AnalyticsHealthEntity? healthData;
    AnalyticsUptimeEntity? uptimeData;

    if (isOwnDevice && deviceState is DeviceLoaded) {
      allPackets = deviceState.allPackets;
      latestData = deviceState.latestTelemetry;
      distanceData = deviceState.distanceData;
      healthData = deviceState.healthData;
      uptimeData = deviceState.uptimeData;
    } else if (!isOwnDevice && searchedState is SearchedDeviceLoaded) {
      allPackets = searchedState.allPackets;
      latestData = searchedState.latestTelemetry;
      distanceData = searchedState.distanceData;
      healthData = searchedState.healthData;
      uptimeData = searchedState.uptimeData;
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text("Data Telemetry"),
        backgroundColor: AppColors.navBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: _isManualRefreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.refresh_rounded),
            onPressed: _isManualRefreshing ? null : _handleManualRefresh,
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                StatusCard(data: latestData),
                const SizedBox(height: 24),
                DistanceCard(
                  data: distanceData,
                  currentSpeed: latestData?.speed,
                ),
                const SizedBox(height: 24),
                HealthCard(data: healthData),
                const SizedBox(height: 24),
                UptimeCard(data: uptimeData),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
