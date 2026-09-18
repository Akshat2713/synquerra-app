import 'package:flutter/material.dart';
import 'package:synquerra/presentation/themes/colors.dart';

import '../../utils/date_time_formatter.dart';
import 'day_selector_row.dart';
import 'section_card.dart';
import 'section_header.dart';
import 'time_picker_tile.dart';

class TimingRecurrenceSection extends StatelessWidget {
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final bool crossesMidnight;
  final List<int> selectedDays;
  final String dateSelectionMode;
  final DateTimeRange dateRange;
  final List<DateTime> customSelectedDates;

  final ValueChanged<TimeOfDay> onStartTimeChanged;
  final ValueChanged<TimeOfDay> onEndTimeChanged;
  final ValueChanged<bool> onCrossesMidnightChanged;
  final ValueChanged<int> onDayToggled;
  final ValueChanged<String> onDateModeChanged;
  final ValueChanged<DateTimeRange> onDateRangeChanged;
  final ValueChanged<DateTime> onCustomDateAdded;
  final ValueChanged<DateTime> onCustomDateRemoved;

  const TimingRecurrenceSection({
    super.key,
    required this.startTime,
    required this.endTime,
    required this.crossesMidnight,
    required this.selectedDays,
    required this.dateSelectionMode,
    required this.dateRange,
    required this.customSelectedDates,
    required this.onStartTimeChanged,
    required this.onEndTimeChanged,
    required this.onCrossesMidnightChanged,
    required this.onDayToggled,
    required this.onDateModeChanged,
    required this.onDateRangeChanged,
    required this.onCustomDateAdded,
    required this.onCustomDateRemoved,
  });

  @override
  Widget build(BuildContext context) {
    final inputTextStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary(context),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Timing & Recurrence'),
        SectionCard(
          children: [
            Row(
              children: [
                Expanded(
                  child: TimePickerTile(
                    label: 'Start Time',
                    time: startTime,
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: startTime,
                      );
                      if (picked != null) onStartTimeChanged(picked);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TimePickerTile(
                    label: 'End Time',
                    time: endTime,
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: endTime,
                      );
                      if (picked != null) onEndTimeChanged(picked);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Crosses Midnight',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary(context),
                ),
              ),
              value: crossesMidnight,
              activeThumbColor: AppColors.primary,
              onChanged: onCrossesMidnightChanged,
            ),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Repeat Days',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary(context),
              ),
            ),
            const SizedBox(height: 8),
            DaySelectorRow(
              selectedDays: selectedDays,
              onDayToggled: onDayToggled,
            ),
            const SizedBox(height: 16),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'range',
                  label: Text('Date Range'),
                  icon: Icon(Icons.date_range_rounded, size: 18),
                ),
                ButtonSegment(
                  value: 'custom',
                  label: Text('Specific Dates'),
                  icon: Icon(Icons.calendar_month_rounded, size: 18),
                ),
              ],
              selected: {dateSelectionMode},
              onSelectionChanged: (selection) =>
                  onDateModeChanged(selection.first),
            ),
            const SizedBox(height: 12),
            if (dateSelectionMode == 'range')
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2025),
                    lastDate: DateTime(2030),
                    initialDateRange: dateRange,
                  );
                  if (picked != null) onDateRangeChanged(picked);
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.outline(context)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.date_range_rounded,
                        size: 20,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Active Date Range',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary(context),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${DateTimeFormatter.formatDate(dateRange.start)}  →  ${DateTimeFormatter.formatDate(dateRange.end)}',
                            style: inputTextStyle,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        firstDate: DateTime(2025),
                        lastDate: DateTime(2030),
                        initialDate: DateTime.now(),
                      );
                      if (picked != null) {
                        onCustomDateAdded(
                          DateTime(picked.year, picked.month, picked.day),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant(context),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.outline(context)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.add_task_rounded,
                            size: 20,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Add Custom Date',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (customSelectedDates.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: customSelectedDates.map((date) {
                        return Chip(
                          label: Text(
                            DateTimeFormatter.formatDate(date),
                            style: const TextStyle(fontSize: 12),
                          ),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () => onCustomDateRemoved(date),
                          backgroundColor: AppColors.surfaceVariant(context),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
          ],
        ),
      ],
    );
  }
}
