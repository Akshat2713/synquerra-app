// presentation/widgets/alert_error_card.dart
import 'package:flutter/material.dart';
import 'package:synquerra/rework/presentation/utils/date_time_formatter.dart';
import '../../domain/entities/alerts/alert_error_entity.dart';
// your toFullDateTime lives here

class AlertErrorCard extends StatelessWidget {
  final AlertErrorEntity item;

  const AlertErrorCard({super.key, required this.item});

  Color _severityColor(BuildContext context) => switch (item.severity) {
    AlertSeverity.critical => Colors.red.shade700,
    AlertSeverity.warning => Colors.amber.shade700,
    AlertSeverity.advisory => Colors.blue.shade600,
  };

  IconData _severityIcon() => switch (item.severity) {
    AlertSeverity.critical => Icons.error_rounded,
    AlertSeverity.warning => Icons.warning_amber_rounded,
    AlertSeverity.advisory => Icons.info_rounded,
  };

  String _severityLabel() => switch (item.severity) {
    AlertSeverity.critical => 'Critical',
    AlertSeverity.warning => 'Warning',
    AlertSeverity.advisory => 'Advisory',
  };

  @override
  Widget build(BuildContext context) {
    final color = _severityColor(context);
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(_severityIcon(), color: color, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _severityLabel(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        DateTimeFormatter.toFullDateTime(item.createdAt),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(item.description, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
