import 'package:flutter/material.dart';

// Simple model to hold the live status logs
class StatusLogEntry {
  final String label;
  final String value;
  final bool isHighlightValue;

  const StatusLogEntry({
    required this.label,
    required this.value,
    this.isHighlightValue = false,
  });
}

class TodayStatusCard extends StatefulWidget {
  final bool looksNormal;
  final List<StatusLogEntry> logs;

  const TodayStatusCard({
    super.key,
    required this.looksNormal,
    required this.logs,
  });

  @override
  State<TodayStatusCard> createState() => _TodayStatusCardState();
}

class _TodayStatusCardState extends State<TodayStatusCard> {
  bool _expanded = true; // Kept open by default matching image_4a1587.png

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    const kGreen = Color(0xFF3DDC84);

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.outlineVariant, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Row
          InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  const Text('📊', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.looksNormal
                          ? 'Today looks normal'
                          : 'Today has changes',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: colors.onSurfaceVariant,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),

          // Expandable Live Logs
          if (_expanded && widget.logs.isNotEmpty) ...[
            ...widget.logs.map(
              (log) => Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: colors.outlineVariant.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    // Status indicator dot
                    const Icon(Icons.circle, size: 8, color: kGreen),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        log.label,
                        style: TextStyle(
                          fontSize: 15,
                          color: colors.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      log.value,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: log.isHighlightValue
                            ? kGreen
                            : colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
