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
import '../../widgets/app_motion_widgets.dart';
import '../../widgets/async_state_view.dart';
import 'landing_skeleton.dart';
import 'widgets/activity_feed_card.dart';
import 'widgets/attention_banner.dart';
import 'widgets/bottom_status_bar.dart';
import 'widgets/hero_section.dart';
import 'widgets/info_card.dart';
import 'widgets/today_schedule_card.dart';
import 'widgets/today_status_card.dart';
import '../../themes/app_tokens.dart';

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

    await landingBloc.stream
        .firstWhere((s) => s is! LandingLoading)
        .timeout(AppMotion.refreshTimeout, onTimeout: () => landingBloc.state);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/app_name_logo.png',
          height: AppSize.appBarLogo,
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<LandingBloc, LandingState>(
        builder: (context, state) {
          if (state is LandingInitial || state is LandingLoading) {
            return const LandingSkeleton();
          }

          if (state is LandingError) {
            return AsyncStateView(
              isLoading: false,
              errorMessage: state.message,
              onRetry: () => context.read<LandingBloc>().add(
                LandingLoadRequested(widget.device),
              ),
              builder: () => const SizedBox.shrink(),
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
                  color: AppColors.primary(context),
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
    final deviceListState = context.watch<DeviceListBloc>().state;
    final allDevices = deviceListState is DeviceListLoaded
        ? deviceListState.devices
        : <DeviceEntity>[];

    // TODO(logic): replace mock data with bloc state.
    const statusLogs = [
      StatusLogEntry(label: 'Left home', value: '7:58 AM'),
      StatusLogEntry(label: 'Arrived school', value: '8:42 AM'),
    ];
    // const defaultSchedule = <ScheduleEntry>[
    //   ScheduleEntry(id: 'evening', time: '18:00', label: 'Evening routine'),
    // ];

    final items = <Widget>[
      AttentionBanner(
        devices: allDevices,
        alerts: state.alerts,
        onTap: onAttentionTap ?? () {},
      ),
      HeroSection(device: device, latest: latest),
      InfoCard(
        icon: Icons.location_on_rounded,
        iconBg: AppColors.primary(context),
        iconColor: AppColors.onPrimary(context),
        title: latest?.userAddress ?? 'Address Unavailable',
        subtitle: latest?.deviceTimestamp != null
            ? 'Updated ${DateTimeFormatter.formatRelativeTime(latest!.deviceTimestamp)}'
            : 'Awaiting first fix',
      ),
      const TodayStatusCard(looksNormal: true, logs: statusLogs),
      TodayScheduleCard(device: device),
      ActivityFeedCard(activities: _buildActivityFeed(device, state.alerts)),
    ];

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.smd,
              AppSpacing.md,
              AppSpacing.md,
            ),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, i) => items[i].entrance(context, index: i),
          ),
        ),
        BottomMetricsBar(
          battery: device.battery ?? 0,
          temperature: device.temperature ?? 'NA',
        ),
      ],
    );
  }
}
