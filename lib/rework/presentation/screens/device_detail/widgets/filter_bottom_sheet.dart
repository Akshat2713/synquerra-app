import 'package:flutter/material.dart';
import '../../../blocs/analytics/analytics_bloc.dart';

class FilterBottomSheet extends StatefulWidget {
  final void Function(AnalyticsFilter filter) onFilterSelected;
  final void Function(DateTime start, DateTime end) onCustomSelected;

  const FilterBottomSheet({
    super.key,
    required this.onFilterSelected,
    required this.onCustomSelected,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  DateTime? _startDate;
  DateTime? _endDate;
  bool _showCustomPicker = false;

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (_startDate ?? now) : (_endDate ?? now),
      firstDate: now.subtract(const Duration(days: 90)),
      lastDate: now,
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
      } else {
        _endDate = picked;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 20,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
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

          Text(
            'Select Time Range',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 16),

          // Preset options
          if (!_showCustomPicker) ...[
            _filterOption(
              label: 'Last Hour',
              icon: Icons.access_time_rounded,
              onTap: () {
                Navigator.pop(context);
                widget.onFilterSelected(AnalyticsFilter.lastHour);
              },
              colors: colors,
            ),
            _filterOption(
              label: 'Last 24 Hours',
              icon: Icons.today_rounded,
              onTap: () {
                Navigator.pop(context);
                widget.onFilterSelected(AnalyticsFilter.last24Hours);
              },
              colors: colors,
            ),
            _filterOption(
              label: 'Last Week',
              icon: Icons.date_range_rounded,
              onTap: () {
                Navigator.pop(context);
                widget.onFilterSelected(AnalyticsFilter.lastWeek);
              },
              colors: colors,
            ),
            _filterOption(
              label: 'Custom Range',
              icon: Icons.tune_rounded,
              onTap: () => setState(() => _showCustomPicker = true),
              colors: colors,
            ),
          ],

          // Custom date picker
          if (_showCustomPicker) ...[
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
    required VoidCallback onTap,
    required ColorScheme colors,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: colors.primary),
      title: Text(label, style: TextStyle(color: colors.onSurface)),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: colors.onSurfaceVariant,
      ),
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
          border: Border.all(color: colors.outline),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded, size: 18, color: colors.primary),
            const SizedBox(width: 12),
            Text(
              date != null ? '${date.day}/${date.month}/${date.year}' : label,
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
