import 'package:flutter/material.dart';

import '../../../themes/colors.dart';
import '../../../utils/date_time_formatter.dart';

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

class ActivityFeedCard extends StatefulWidget {
  final List<ActivityFeedEntry> activities;

  const ActivityFeedCard({super.key, required this.activities});

  @override
  State<ActivityFeedCard> createState() => _ActivityFeedCardState();
}

class _ActivityFeedCardState extends State<ActivityFeedCard> {
  bool _isExpanded = false;

  List<Widget> _buildGroupedItems() {
    final today = <ActivityFeedEntry>[];
    final yesterday = <ActivityFeedEntry>[];
    final older = <ActivityFeedEntry>[];

    for (final item in widget.activities) {
      if (item.date == null) {
        older.add(item);
      } else if (DateTimeFormatter.isToday(item.date!)) {
        today.add(item);
      } else if (DateTimeFormatter.isYesterday(item.date!)) {
        yesterday.add(item);
      } else {
        older.add(item);
      }
    }

    final widgets = <Widget>[];
    if (today.isNotEmpty) {
      widgets.add(_sectionHeader('Today'));
      widgets.addAll(today.map((item) => _buildItemRow(item)));
    }
    if (yesterday.isNotEmpty) {
      widgets.add(_sectionHeader('Yesterday'));
      widgets.addAll(yesterday.map((item) => _buildItemRow(item)));
    }
    if (older.isNotEmpty) {
      widgets.add(_sectionHeader('Earlier'));
      widgets.addAll(older.map((item) => _buildItemRow(item)));
    }
    return widgets;
  }

  Widget _sectionHeader(String label) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary(context).withValues(alpha: 0.7),
          letterSpacing: 0.5,
        ),
      ),
    ),
  );

  Widget _buildItemRow(ActivityFeedEntry item) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Row(
      children: [
        Icon(Icons.circle, size: 8, color: item.color),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            item.title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: item.color,
            ),
          ),
        ),
        const SizedBox(width: 3),
        Text(
          item.time,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary(context),
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.outlineVariant(context).withValues(alpha: 1),
        ),
      ),
      child: Column(
        children: [
          // ── Collapsible Header ─────────────────────────────────────
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textSecondary(context),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Activity Feed',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Expandable Feed Items ────────────────────────────────
          if (_isExpanded) ...[
            Divider(
              height: 1,
              color: AppColors.outlineVariant(context).withValues(alpha: 0.3),
            ),
            ..._buildGroupedItems(),
          ],
        ],
      ),
    );
  }
}
