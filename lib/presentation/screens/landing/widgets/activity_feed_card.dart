import 'package:flutter/material.dart';
import 'package:synquerra/presentation/themes/app_text_styles.dart';
import 'package:synquerra/presentation/themes/app_tokens.dart';
import 'package:synquerra/presentation/themes/colors.dart';
import 'package:synquerra/presentation/utils/date_time_formatter.dart';
import 'package:synquerra/presentation/widgets/app_surfaces.dart';
import 'package:synquerra/presentation/widgets/expandable_card.dart';

class ActivityFeedEntry {
  final String title;
  final String time;
  final Color color;
  final DateTime? date;
  const ActivityFeedEntry({
    required this.title,
    required this.time,
    required this.color,
    this.date,
  });
}

class ActivityFeedCard extends StatelessWidget {
  final List<ActivityFeedEntry> activities;

  const ActivityFeedCard({super.key, required this.activities});

  // TODO(logic): move day-grouping to a util / bloc.
  List<Widget> _groupedRows() {
    final today = <ActivityFeedEntry>[];
    final yesterday = <ActivityFeedEntry>[];
    final older = <ActivityFeedEntry>[];

    for (final item in activities) {
      final d = item.date;
      if (d == null) {
        older.add(item);
      } else if (DateTimeFormatter.isToday(d)) {
        today.add(item);
      } else if (DateTimeFormatter.isYesterday(d)) {
        yesterday.add(item);
      } else {
        older.add(item);
      }
    }

    return [
      for (final g in [
        ('Today', today),
        ('Yesterday', yesterday),
        ('Earlier', older),
      ])
        if (g.$2.isNotEmpty) ...[
          _SectionHeader(g.$1),
          for (final item in g.$2) _FeedRow(item: item),
        ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ExpandableCard(
      leading: const IconTile(
        icon: Icons.notifications_active_rounded,
        background: AppColors.info,
        foreground: AppColors.onInfo,
      ),
      title: 'Activity Feed',
      child: activities.isEmpty
          ? const ExpandableCardEmpty('No activity yet.')
          : Column(children: _groupedRows()),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.xs),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label.toUpperCase(),
          style: AppTextStyles.microWithColor(
            context,
          ).copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _FeedRow extends StatelessWidget {
  final ActivityFeedEntry item;
  const _FeedRow({required this.item});

  @override
  Widget build(BuildContext context) => InsetRow(
    onTap: () {}, // TODO(logic): wire destination
    child: Row(
      children: [
        Icon(Icons.circle, size: AppSize.dot, color: item.color),
        const SizedBox(width: AppSpacing.smd),
        Expanded(
          child: Text(
            item.title,
            style: AppTextStyles.bodyWithColor(
              context,
              color: AppColors.textPrimary(context),
            ).copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        InfoPill(
          label: item.time,
          background: AppAlpha.withAlpha(item.color, AppAlpha.fill),
          foreground: AppColors.textPrimary(context),
        ),
      ],
    ),
  );
}
