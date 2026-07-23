import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/landing/landing_bloc.dart';
import 'landing_skeleton.dart';

// Import updated widgets
import 'widgets/activity_feed_card.dart';
import 'widgets/attention_banner.dart';
import 'widgets/bottom_status_bar.dart';
import 'widgets/hero_section.dart';
import 'widgets/info_card.dart';
import 'widgets/today_schedule_card.dart';
import 'widgets/today_status_card.dart';

class LandingScreen extends StatefulWidget {
  final VoidCallback? onAttentionTap;
  const LandingScreen({super.key, this.onAttentionTap});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  void initState() {
    super.initState();
    context.read<LandingBloc>().add(const LandingLoadRequested());
  }

  Future<void> _onRefresh() async {
    final bloc = context.read<LandingBloc>();
    bloc.add(const LandingRefreshRequested());
    await bloc.stream.firstWhere((s) => s is! LandingLoading);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(title: const Text('Home'), centerTitle: false),
      body: BlocBuilder<LandingBloc, LandingState>(
        builder: (context, state) {
          if (state is LandingInitial || state is LandingLoading) {
            return const LandingSkeleton();
          }

          if (state is LandingError) {
            return _ErrorBody(
              message: state.message,
              onRetry: () =>
                  context.read<LandingBloc>().add(const LandingLoadRequested()),
            );
          }

          if (state is LandingLoaded) {
            return RefreshIndicator(
              onRefresh: _onRefresh,
              color: colors.primary,
              child: _LoadedBody(
                state: state,
                onAttentionTap: widget.onAttentionTap,
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _LoadedBody extends StatelessWidget {
  final LandingLoaded state;
  final VoidCallback? onAttentionTap;

  const _LoadedBody({required this.state, this.onAttentionTap});

  @override
  Widget build(BuildContext context) {
    final d = state.selectedMember;
    const kBlue = Color(0xFF5B8DEF);

    final statusLogs = [
      const StatusLogEntry(label: 'Left home', value: '7:58 AM'),
      const StatusLogEntry(label: 'Arrived school', value: '8:42 AM'),
      const StatusLogEntry(
        label: 'Pattern check',
        value: 'Normal',
        isHighlightValue: true,
      ),
    ];

    const defaultActivities = [
      ActivityFeedEntry(
        title: 'SOS Cancelled',
        time: '5:12 PM',
        color: Color(0xFF3DDC84),
      ),
      ActivityFeedEntry(
        title: 'SOS Button Pressed',
        time: '5:08 PM',
        color: Colors.redAccent,
      ),
      ActivityFeedEntry(
        title: 'GPS Restored',
        time: '3:55 PM',
        color: Color(0xFF3DDC84),
      ),
    ];

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            children: [
              // ── 1. Attention Banner ───────────────────────────────
              AttentionBanner(
                attentionCount: state.attentionCount,
                totalMembers: state.members.length,
                members: state.members,
                onTap: onAttentionTap ?? () {},
              ),
              const SizedBox(height: 16),

              // ── 2. Hero Section ────────────────────────────────────
              HeroSection(detail: d),
              const SizedBox(height: 16),

              // ── 3. Info Card (Location) ────────────────────────────
              InfoCard(
                icon: Icons.location_on_rounded,
                iconBg: kBlue.withValues(alpha: 0.15),
                iconColor: kBlue,
                title: d.locationLabel,
                subtitle: d.locationSubtitle,
              ),
              const SizedBox(height: 16),

              // ── 4. Today Status Card ───────────────────────────────
              TodayStatusCard(
                looksNormal: d.todayLooksNormal,
                logs: statusLogs,
              ),
              const SizedBox(height: 16),

              // ── 5. Schedule Card ───────────────────────────────────
              TodayScheduleCard(schedule: d.todaySchedule),
              const SizedBox(height: 16),

              // ── 6. Activity Feed Card ─────────────────────────────
              const ActivityFeedCard(activities: defaultActivities),
              const SizedBox(height: 16),
            ],
          ),
        ),

        // ── Bottom Metrics Footer ───────────────────────────────────
        BottomMetricsBar(battery: d.batteryLevel),
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
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 48, color: colors.error),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(color: colors.error),
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
