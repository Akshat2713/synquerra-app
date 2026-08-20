// lib/presentation/widgets/analytics_filter_sheet.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:synquerra/presentation/utils/date_time_formatter.dart';
import 'package:synquerra/presentation/utils/unit_formatter.dart';
import '../../domain/entities/analytics/analytics_filter.dart';

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

void showCustomRangePicker({
  required BuildContext context,
  required void Function(DateTime start, DateTime end) onCustomSelected,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _AnalyticsFilterSheet(
      activeFilter: AnalyticsFilter.custom,
      onFilterSelected: (_) {},
      onCustomSelected: onCustomSelected,
      startAtCustomPicker: true,
    ),
  );
}

/// Allowed durations (hours) for a custom range. Max is 24h per business rule.
const List<int> _kDurationOptions = [2, 4, 6, 12, 18, 24];

class _AnalyticsFilterSheet extends StatefulWidget {
  final AnalyticsFilter activeFilter;
  final void Function(AnalyticsFilter filter) onFilterSelected;
  final void Function(DateTime start, DateTime end) onCustomSelected;
  final bool startAtCustomPicker;

  const _AnalyticsFilterSheet({
    required this.activeFilter,
    required this.onFilterSelected,
    required this.onCustomSelected,
    this.startAtCustomPicker = false,
  });

  @override
  State<_AnalyticsFilterSheet> createState() => _AnalyticsFilterSheetState();
}

class _AnalyticsFilterSheetState extends State<_AnalyticsFilterSheet> {
  bool _showCustomPicker = false;

  DateTime? _selectedDate;
  int _selectedHour = 0;
  int _durationIndex = 0;

  late final FixedExtentScrollController _hourController;
  late final FixedExtentScrollController _durationController;

  @override
  void initState() {
    super.initState();
    _showCustomPicker = widget.startAtCustomPicker;
    _selectedHour = DateTime.now().hour;
    _hourController = FixedExtentScrollController(initialItem: _selectedHour);
    _durationController = FixedExtentScrollController(
      initialItem: _durationIndex,
    );
  }

  @override
  void dispose() {
    _hourController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(2020),
      lastDate: now,
    );
    if (picked == null) return;
    setState(() => _selectedDate = picked);
  }

  DateTime get _startDateTime {
    final d = _selectedDate ?? DateTime.now();
    return DateTime(d.year, d.month, d.day, _selectedHour);
  }

  DateTime get _endDateTime =>
      _startDateTime.add(Duration(hours: _kDurationOptions[_durationIndex]));

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
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.onSurfaceVariant.withValues(alpha: 0.3),
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
              label: 'Custom Range',
              icon: Icons.tune_rounded,
              isActive: widget.activeFilter == AnalyticsFilter.custom,
              onTap: () => setState(() => _showCustomPicker = true),
              colors: colors,
            ),
          ] else ...[
            Row(
              children: [
                if (!widget.startAtCustomPicker) ...[
                  GestureDetector(
                    onTap: () => setState(() => _showCustomPicker = false),
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Text(
                  'Custom Range',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Max range is 24 hours',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 20),

            _dateTile(
              label: 'Date',
              date: _selectedDate,
              onTap: _pickDate,
              colors: colors,
            ),
            const SizedBox(height: 20),

            Text(
              'Start Time',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            _wheelPicker(
              controller: _hourController,
              itemCount: 24,
              labelBuilder: UnitFormatter.hourLabel,
              onChanged: (i) => setState(() => _selectedHour = i),
              colors: colors,
            ),
            const SizedBox(height: 20),

            Text(
              'Duration',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            _wheelPicker(
              controller: _durationController,
              itemCount: _kDurationOptions.length,
              labelBuilder: (i) => '${_kDurationOptions[i]} hrs',
              onChanged: (i) => setState(() => _durationIndex = i),
              colors: colors,
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${DateTimeFormatter.formatDateTime(_startDateTime)}  →  ${DateTimeFormatter.formatDateTime(_endDateTime)}',
                style: TextStyle(
                  color: colors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => widget.startAtCustomPicker
                        ? Navigator.pop(context)
                        : setState(() => _showCustomPicker = false),
                    child: const Text('Back'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _selectedDate != null
                        ? () {
                            Navigator.pop(context);
                            widget.onCustomSelected(
                              _startDateTime,
                              _endDateTime,
                            );
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

  Widget _wheelPicker({
    required FixedExtentScrollController controller,
    required int itemCount,
    required String Function(int index) labelBuilder,
    required void Function(int index) onChanged,
    required ColorScheme colors,
  }) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        border: Border.all(color: colors.outline),
        borderRadius: BorderRadius.circular(12),
      ),
      child: CupertinoPicker(
        scrollController: controller,
        itemExtent: 36,
        onSelectedItemChanged: onChanged,
        selectionOverlay: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: colors.primary.withValues(alpha: 0.4)),
              bottom: BorderSide(color: colors.primary.withValues(alpha: 0.4)),
            ),
          ),
        ),
        children: List.generate(
          itemCount,
          (i) => Center(
            child: Text(
              labelBuilder(i),
              style: TextStyle(color: colors.onSurface, fontSize: 15),
            ),
          ),
        ),
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
