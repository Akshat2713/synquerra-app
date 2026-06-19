import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:synquerra/presentation/app/app_router.dart';
import '../../blocs/home_detail/home_detail_bloc.dart';
import 'home_detail_skeleton.dart';

// Import the segmented component files
import 'widgets/attention_banner.dart';
import 'widgets/hero_section.dart';
import 'widgets/info_card.dart';
import 'widgets/today_schedule_card.dart';
import 'widgets/today_status_card.dart';
import 'widgets/insight_card.dart';

class HomeDetailScreen extends StatefulWidget {
  const HomeDetailScreen({super.key});

  @override
  State<HomeDetailScreen> createState() => _HomeDetailScreenState();
}

class _HomeDetailScreenState extends State<HomeDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HomeDetailBloc>().add(const HomeDetailLoadRequested());
  }

  Future<void> _onRefresh() async {
    final bloc = context.read<HomeDetailBloc>();
    bloc.add(const HomeDetailRefreshRequested());
    await bloc.stream.firstWhere((s) => s is! HomeDetailLoading);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navigate to notification subsystem route
            },
          ),
        ],
      ),
      body: BlocBuilder<HomeDetailBloc, HomeDetailState>(
        builder: (context, state) {
          if (state is HomeDetailInitial || state is HomeDetailLoading) {
            return const HomeDetailSkeleton();
          }

          if (state is HomeDetailError) {
            return _ErrorBody(
              message: state.message,
              onRetry: () => context.read<HomeDetailBloc>().add(
                const HomeDetailLoadRequested(),
              ),
            );
          }

          if (state is HomeDetailLoaded) {
            return RefreshIndicator(
              onRefresh: _onRefresh,
              color: colors.primary,
              child: _LoadedBody(state: state),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _LoadedBody extends StatelessWidget {
  final HomeDetailLoaded state;
  const _LoadedBody({required this.state});

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

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        AttentionBanner(
          attentionCount: state.attentionCount,
          totalMembers: state.members.length,
          members: state.members,
          onTap: () => Navigator.pushNamed(context, AppRoutes.home),
        ),
        const SizedBox(height: 24),
        // MemberRow(
        //   members: state.members,
        //   selectedId: d.summary.id,
        //   onSelect: (id) =>
        //       context.read<HomeDetailBloc>().add(HomeDetailMemberSelected(id)),
        // ),
        const SizedBox(height: 20),
        HeroSection(detail: d),
        const SizedBox(height: 20),
        InfoCard(
          icon: Icons.location_on_rounded,
          iconBg: kBlue.withOpacity(0.15),
          iconColor: kBlue,
          title: d.locationLabel,
          subtitle: d.locationSubtitle,
        ),
        const SizedBox(height: 12),
        // InfoCard(
        //   icon: Icons.shield_outlined,
        //   iconBg: kBlue.withOpacity(0.15),
        //   iconColor: kBlue,
        //   title: 'Safe streak: ${d.safeStreakDays} days',
        //   subtitle: 'Keep it up!',
        // ),
        const SizedBox(height: 12),
        TodayStatusCard(looksNormal: d.todayLooksNormal, logs: statusLogs),
        const SizedBox(height: 12),
        TodayScheduleCard(schedule: d.todaySchedule),
        const SizedBox(height: 12), const SizedBox(height: 12),
        InsightCard(insightText: d.insightText, riskLevel: d.riskLevel),
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
