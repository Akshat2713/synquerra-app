import 'package:flutter/material.dart';

import '../../../domain/entities/analytics/analytics_entity.dart';
import '../../blocs/analytics/analytics_bloc.dart';
import 'telemerty_card.dart';

class TelemetryList extends StatelessWidget {
  final List<AnalyticsEntity> points;
  final AnalyticsFilter filter;
  final DateTime? startDate;
  final DateTime? endDate;

  const TelemetryList({
    super.key,
    required this.points,
    required this.filter,
    this.startDate,
    this.endDate,
  });

  String get _subtitle {
    switch (filter) {
      case AnalyticsFilter.latest:
        return 'Latest record';
      case AnalyticsFilter.lastHour:
        return 'Last 1 hour';
      case AnalyticsFilter.last24Hours:
        return 'Last 24 hours';
      case AnalyticsFilter.lastWeek:
        return 'Last 7 days';
      case AnalyticsFilter.custom:
        if (startDate != null && endDate != null) {
          return '${startDate!.day}/${startDate!.month}/${startDate!.year}'
              ' – ${endDate!.day}/${endDate!.month}/${endDate!.year}';
        }
        return 'Custom range';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      children: [
        Container(
          width: double.infinity,
          color: colors.primaryContainer.withValues(alpha: 0.4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(
                Icons.timeline_rounded,
                size: 16,
                color: colors.onPrimaryContainer,
              ),
              const SizedBox(width: 8),
              Text(
                '$_subtitle  ·  ${points.length} record${points.length == 1 ? '' : 's'}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: colors.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            itemCount: points.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) =>
                TelemetryCard(point: points[i], index: i),
          ),
        ),
      ],
    );
  }
}
