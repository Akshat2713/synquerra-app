import 'package:flutter/material.dart';
import '../blocs/analytics/analytics_bloc.dart';

/// A fully reusable filter bottom sheet for analytics pages.
/// Supports 1 hour, 24 hours, 1 week, and custom date range.
///
/// Usage:
/// ```dart
/// showAnalyticsFilterSheet(
///   context: context,
///   activeFilter: _currentFilter,
///   onFilterSelected: (filter) { ... },
///   onCustomSelected: (start, end) { ... },
/// );
/// ```
void showAnalyticsFilterSheet({
  required BuildContext context,
  required AnalyticsFilter activeFilter,
  required void Function(AnalyticsFilter filter) onFilterSelected,
  required void Function(DateTime start, DateTime end) onCustomSelected,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _AnalyticsFilterSheet(
      activeFilter: activeFilter,
      onFilterSelected: onFilterSelected,
      onCustomSelected: onCustomSelected,
    ),
  );
}

class _AnalyticsFilterSheet extends StatefulWidget {
  final AnalyticsFilter activeFilter;
  final void Function(AnalyticsFilter filter) onFilterSelected;
  final void Function(DateTime start, DateTime end) onCustomSelected;

  const _AnalyticsFilterSheet({
    required this.activeFilter,
    required this.onFilterSelected,
    required this.onCustomSelected,
  });

  @override
  State<_AnalyticsFilterSheet> createState() => _AnalyticsFilterSheetState();
}

class _AnalyticsFilterSheetState extends State<_AnalyticsFilterSheet> {
  bool _showCustomPicker = false;
  DateTime? _startDate;
  DateTime? _endDate;

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (_startDate ?? now) : (_endDate ?? now),
      firstDate: DateTime(2020),
      lastDate: now,
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
        // Reset end date if it's before new start
        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = null;
        }
      } else {
        _endDate = picked;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.onSurfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          if (!_showCustomPicker) ...[
            Text(
              'Filter by Time',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Select a time range for telemetry data',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            _filterOption(
              label: 'Last Hour',
              icon: Icons.access_time_rounded,
              isActive: widget.activeFilter == AnalyticsFilter.lastHour,
              onTap: () {
                Navigator.pop(context);
                widget.onFilterSelected(AnalyticsFilter.lastHour);
              },
              colors: colors,
            ),
            _filterOption(
              label: 'Last 24 Hours',
              icon: Icons.today_rounded,
              isActive: widget.activeFilter == AnalyticsFilter.last24Hours,
              onTap: () {
                Navigator.pop(context);
                widget.onFilterSelected(AnalyticsFilter.last24Hours);
              },
              colors: colors,
            ),
            _filterOption(
              label: 'Last Week',
              icon: Icons.date_range_rounded,
              isActive: widget.activeFilter == AnalyticsFilter.lastWeek,
              onTap: () {
                Navigator.pop(context);
                widget.onFilterSelected(AnalyticsFilter.lastWeek);
              },
              colors: colors,
            ),
            _filterOption(
              label: 'Custom Range',
              icon: Icons.tune_rounded,
              isActive: widget.activeFilter == AnalyticsFilter.custom,
              onTap: () => setState(() => _showCustomPicker = true),
              colors: colors,
            ),
          ] else ...[
            // ── Custom date picker ───────────────────────────────
            Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _showCustomPicker = false),
                  child: Icon(Icons.arrow_back_rounded, color: colors.primary),
                ),
                const SizedBox(width: 12),
                Text(
                  'Custom Range',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _dateTile(
              label: 'Start Date',
              date: _startDate,
              onTap: () => _pickDate(isStart: true),
              colors: colors,
            ),
            const SizedBox(height: 10),
            _dateTile(
              label: 'End Date',
              date: _endDate,
              onTap: () => _pickDate(isStart: false),
              colors: colors,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _showCustomPicker = false),
                    child: const Text('Back'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _startDate != null && _endDate != null
                        ? () {
                            Navigator.pop(context);
                            widget.onCustomSelected(_startDate!, _endDate!);
                          }
                        : null,
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _filterOption({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    required ColorScheme colors,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: isActive ? colors.primary : colors.onSurfaceVariant,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isActive ? colors.primary : colors.onSurface,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: isActive
          ? Icon(Icons.check_circle_rounded, color: colors.primary, size: 20)
          : Icon(Icons.chevron_right_rounded, color: colors.onSurfaceVariant),
      onTap: onTap,
    );
  }

  Widget _dateTile({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
    required ColorScheme colors,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(
            color: date != null ? colors.primary : colors.outline,
            width: date != null ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 18,
              color: date != null ? colors.primary : colors.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Text(
              date != null
                  ? '${date.day.toString().padLeft(2, '0')}/'
                        '${date.month.toString().padLeft(2, '0')}/'
                        '${date.year}'
                  : label,
              style: TextStyle(
                color: date != null
                    ? colors.onSurface
                    : colors.onSurfaceVariant,
                fontWeight: date != null ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
