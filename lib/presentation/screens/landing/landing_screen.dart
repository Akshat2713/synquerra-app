// lib/presentation/screens/landing/landing_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/alerts/alert_entity.dart';
import '../../../domain/entities/analytics/analytics_entity.dart';
import '../../../domain/entities/device/device_entity.dart';
import '../../../domain/utils/alert_device_matcher.dart';
import '../../blocs/analytics/analytics_bloc.dart';
import '../../blocs/device_list/device_list_bloc.dart';
import '../../blocs/landing/landing_bloc.dart';
import '../../themes/colors.dart';
import '../../utils/colour_util.dart';
import '../../utils/date_time_formatter.dart';
import 'landing_skeleton.dart';
import 'widgets/activity_feed_card.dart';
import 'widgets/attention_banner.dart';
import 'widgets/bottom_status_bar.dart';
import 'widgets/hero_section.dart';
import 'widgets/info_card.dart';
import 'widgets/today_schedule_card.dart';
import 'widgets/today_status_card.dart';

class LandingScreen extends StatefulWidget {
  final DeviceEntity device;
  final VoidCallback? onAttentionTap;
  const LandingScreen({super.key, required this.device, this.onAttentionTap});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  void initState() {
    super.initState();
    context.read<LandingBloc>().add(LandingLoadRequested(widget.device));
  }

  Future<void> _onRefresh() async {
    final landingBloc = context.read<LandingBloc>();
    final analyticsBloc = context.read<AnalyticsBloc>();

    landingBloc.add(LandingLoadRequested(widget.device));
    analyticsBloc.add(
      AnalyticsLoadDefault(
        deviceId: widget.device.id,
        imei: widget.device.imei,
      ),
    );

    await landingBloc.stream.firstWhere((s) => s is! LandingLoading);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AADYA', style: TextStyle(fontSize: 25)),
        centerTitle: true,
      ),
      body: BlocBuilder<LandingBloc, LandingState>(
        builder: (context, state) {
          if (state is LandingInitial || state is LandingLoading) {
            return const LandingSkeleton();
          }

          if (state is LandingError) {
            return _ErrorBody(
              message: state.message,
              onRetry: () => context.read<LandingBloc>().add(
                LandingLoadRequested(widget.device),
              ),
            );
          }

          if (state is LandingLoaded) {
            return BlocBuilder<AnalyticsBloc, AnalyticsState>(
              builder: (context, analyticsState) {
                // Show skeleton only on the very first initial load when no data exists yet
                final isInitialAnalyticsLoading =
                    (analyticsState is AnalyticsInitial ||
                    analyticsState is AnalyticsLoading);

                if (isInitialAnalyticsLoading &&
                    analyticsState is! AnalyticsLoaded) {
                  return const LandingSkeleton();
                }

                // Extract latest point from WebSocket or REST fetch
                final latest =
                    analyticsState is AnalyticsLoaded &&
                        analyticsState.points.isNotEmpty
                    ? analyticsState.points.first
                    : null;

                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  color: AppColors.primary,
                  child: _LoadedBody(
                    device: widget.device,
                    state: state,
                    latest: latest,
                    onAttentionTap: widget.onAttentionTap,
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _LoadedBody extends StatelessWidget {
  final DeviceEntity device;
  final LandingLoaded state;
  final AnalyticsEntity? latest;
  final VoidCallback? onAttentionTap;

  const _LoadedBody({
    required this.device,
    required this.state,
    required this.latest,
    this.onAttentionTap,
  });

  List<ActivityFeedEntry> _buildActivityFeed(
    DeviceEntity device,
    List<AlertEntity> allAlerts,
  ) {
    final deviceAlerts = alertsForDevice(device, allAlerts).toList()
      ..sort((a, b) {
        final aTime = DateTimeFormatter.parseUtcToLocal(a.createdAt);
        final bTime = DateTimeFormatter.parseUtcToLocal(b.createdAt);
        if (aTime == null || bTime == null) return 0;
        return bTime.compareTo(aTime);
      });

    return deviceAlerts
        .map(
          (a) => ActivityFeedEntry(
            title: a.description.isNotEmpty ? a.description : a.code,
            time: DateTimeFormatter.toTimeAmPm(a.createdAt),
            color: alertColor(a),
            date: DateTimeFormatter.parseUtcToLocal(a.createdAt),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    const kBlue = Color(0xFF5B8DEF);

    final deviceListState = context.watch<DeviceListBloc>().state;
    final allDevices = deviceListState is DeviceListLoaded
        ? deviceListState.devices
        : <DeviceEntity>[];

    final statusLogs = [
      const StatusLogEntry(label: 'Left home', value: '7:58 AM'),
      const StatusLogEntry(label: 'Arrived school', value: '8:42 AM'),
    ];
    const defaultSchedule = <ScheduleEntry>[
      ScheduleEntry(time: '18:00', label: 'Evening routine', id: 'uiyghcvjhb'),
    ];

    final activityFeed = _buildActivityFeed(device, state.alerts);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            children: [
              AttentionBanner(
                devices: allDevices,
                alerts: state.alerts,
                onTap: onAttentionTap ?? () {},
              ),
              const SizedBox(height: 16),
              HeroSection(device: device, latest: latest),
              const SizedBox(height: 16),
              InfoCard(
                icon: Icons.location_on_rounded,
                iconBg: kBlue.withValues(alpha: 0.15),
                iconColor: kBlue,
                title: latest?.userAddress ?? 'Address Unavailable',
                subtitle: latest?.deviceTimestamp != null
                    ? 'Updated ${DateTimeFormatter.formatRelativeTime(latest!.deviceTimestamp)}'
                    : 'Awaiting first fix',
              ),
              const SizedBox(height: 16),
              TodayStatusCard(looksNormal: true, logs: statusLogs),
              const SizedBox(height: 16),
              const TodayScheduleCard(schedule: defaultSchedule),
              const SizedBox(height: 16),
              ActivityFeedCard(activities: activityFeed),
              const SizedBox(height: 16),
            ],
          ),
        ),
        BottomMetricsBar(battery: device.battery ?? 0),
      ],
    );
  }
}

class _ErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorBody({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppColors.danger,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(color: AppColors.danger),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
