import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../themes/app_text_styles.dart';
import '../../../themes/app_tokens.dart';
import '../../../themes/colors.dart';
import '../../../utils/app_icons.dart';
import '../../../widgets/app_surfaces.dart';

import '../../../utils/date_time_formatter.dart';
import '../../../widgets/app_picker_field.dart';
import 'day_selector_row.dart';
import 'section_header.dart';

class TimingRecurrenceSection extends StatelessWidget {
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final bool crossesMidnight;
  final List<int> selectedDays;
  final String dateSelectionMode;
  final DateTime startDate;
  final DateTime? endDate;
  final bool noEndDate;
  final List<DateTime> customSelectedDates;

  final ValueChanged<TimeOfDay> onStartTimeChanged;
  final ValueChanged<TimeOfDay> onEndTimeChanged;
  final ValueChanged<bool> onCrossesMidnightChanged;
  final ValueChanged<int> onDayToggled;
  final ValueChanged<String> onDateModeChanged;
  final ValueChanged<DateTime> onStartDateChanged;
  final ValueChanged<DateTime?> onEndDateChanged;
  final ValueChanged<bool> onNoEndDateChanged;
  final ValueChanged<DateTime> onCustomDateAdded;
  final ValueChanged<DateTime> onCustomDateRemoved;

  const TimingRecurrenceSection({
    super.key,
    required this.startTime,
    required this.endTime,
    required this.crossesMidnight,
    required this.selectedDays,
    required this.dateSelectionMode,
    required this.startDate,
    required this.endDate,
    required this.noEndDate,
    required this.customSelectedDates,
    required this.onStartTimeChanged,
    required this.onEndTimeChanged,
    required this.onCrossesMidnightChanged,
    required this.onDayToggled,
    required this.onDateModeChanged,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
    required this.onNoEndDateChanged,
    required this.onCustomDateAdded,
    required this.onCustomDateRemoved,
  });

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  Future<DateTime?> _pickDate({
    required BuildContext context,
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
  }) {
    final safeFirstDate = _dateOnly(firstDate);
    final safeLastDate = _dateOnly(lastDate);
    var safeInitialDate = _dateOnly(initialDate);

    if (safeInitialDate.isBefore(safeFirstDate)) {
      safeInitialDate = safeFirstDate;
    } else if (safeInitialDate.isAfter(safeLastDate)) {
      safeInitialDate = safeLastDate;
    }

    return showDatePicker(
      context: context,
      initialDate: safeInitialDate,
      firstDate: safeFirstDate,
      lastDate: safeLastDate,
    );
  }

  Future<void> _pickTime(
    BuildContext context,
    TimeOfDay initial,
    ValueChanged<TimeOfDay> onPicked,
  ) async {
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) onPicked(picked);
  }

  @override
  Widget build(BuildContext context) {
    final today = _dateOnly(DateTime.now());
    final lastAllowedDate = DateTime(2100, 12, 31);
    final normalizedStartDate = _dateOnly(startDate);
    final normalizedEndDate = endDate == null ? null : _dateOnly(endDate!);
    // final reduceMotion = MediaQuery.disableAnimationsOf(context);
    // final animationDuration = reduceMotion ? Duration.zero : AppMotion.base;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Timing & Recurrence'),
        AppCard(
          padding: AppSpacing.mdAll,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                spacing: AppSpacing.smd,
                children: [
                  Expanded(
                    child: AppPickerField(
                      label: 'Start Time',
                      value: startTime.format(context),
                      icon: AppIcons.time,
                      onTap: () =>
                          _pickTime(context, startTime, onStartTimeChanged),
                    ),
                  ),
                  Expanded(
                    child: AppPickerField(
                      label: 'End Time',
                      value: endTime.format(context),
                      icon: AppIcons.time,
                      onTap: () =>
                          _pickTime(context, endTime, onEndTimeChanged),
                    ),
                  ),
                ],
              ),
              if (crossesMidnight)
                InfoPill(
                  label: 'Ends next day (+1 day)',
                  icon: AppIcons.overnight,
                  background: AppColors.primaryContainer(context),
                  foreground: AppColors.onPrimaryContainer(context),
                ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Repeat Days',
                style: AppTextStyles.bodyWithColor(
                  context,
                  color: AppColors.textSecondary(context),
                ).copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSpacing.sm),
              DaySelectorRow(
                selectedDays: selectedDays,
                onDayToggled: onDayToggled,
              ),
              const SizedBox(height: AppSpacing.lg),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment<String>(
                    value: 'range',
                    label: Text('Date Range'),
                    icon: Icon(AppIcons.dateRange),
                  ),
                  ButtonSegment<String>(
                    value: 'custom',
                    label: Text('Specific Dates'),
                    icon: Icon(AppIcons.schedule),
                  ),
                ],
                selected: {dateSelectionMode},
                onSelectionChanged: (selection) {
                  if (selection.isNotEmpty) {
                    onDateModeChanged(selection.first);
                  }
                },
              ),
              const SizedBox(height: AppSpacing.md),
              if (dateSelectionMode == 'range') ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AppPickerField(
                        label: 'Start Date',
                        value: DateTimeFormatter.formatDate(
                          normalizedStartDate,
                        ),
                        icon: AppIcons.dateRange,
                        onTap: () async {
                          final picked = await _pickDate(
                            context: context,
                            initialDate: normalizedStartDate,
                            firstDate: DateTime(2000, 1, 1),
                            lastDate: lastAllowedDate,
                          );

                          if (picked != null) {
                            final newStartDate = _dateOnly(picked);
                            onStartDateChanged(newStartDate);

                            if (!noEndDate &&
                                normalizedEndDate != null &&
                                normalizedEndDate.isBefore(newStartDate)) {
                              onEndDateChanged(newStartDate);
                            }
                          }
                        },
                      ),
                    ),
                    if (!noEndDate) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: AppPickerField(
                          label: 'End Date',
                          value: normalizedEndDate != null
                              ? DateTimeFormatter.formatDate(normalizedEndDate)
                              : 'Select end date',
                          icon: AppIcons.date,
                          onTap: () async {
                            final picked = await _pickDate(
                              context: context,
                              initialDate:
                                  normalizedEndDate ?? normalizedStartDate,
                              firstDate: normalizedStartDate,
                              lastDate: lastAllowedDate,
                            );

                            if (picked != null) {
                              onEndDateChanged(_dateOnly(picked));
                            }
                          },
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(
                    'No End Date',
                    style: AppTextStyles.bodyWithColor(
                      context,
                      color: AppColors.textPrimary(context),
                    ).copyWith(fontWeight: FontWeight.w500),
                  ),
                  value: noEndDate,
                  onChanged: onNoEndDateChanged,
                ),
              ] else if (dateSelectionMode == 'custom') ...[
                AppPickerField(
                  label: 'Add Custom Date',
                  value: 'Choose a date',
                  icon: AppIcons.add,
                  onTap: () async {
                    final picked = await _pickDate(
                      context: context,
                      initialDate: today,
                      firstDate: today,
                      lastDate: lastAllowedDate,
                    );

                    if (picked != null) {
                      final selectedDate = _dateOnly(picked);
                      final alreadySelected = customSelectedDates.any(
                        (date) => _dateOnly(date) == selectedDate,
                      );

                      if (!alreadySelected) {
                        onCustomDateAdded(selectedDate);
                      }
                    }
                  },
                ),
                if (customSelectedDates.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.xs,
                    children: customSelectedDates.map((date) {
                      return Chip(
                        label: Text(
                          DateTimeFormatter.formatDate(date),
                          style: AppTextStyles.metaWithColor(
                            context,
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                        deleteIcon: const Icon(AppIcons.delete),
                        onDeleted: () => onCustomDateRemoved(date),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// class _TimingSectionHeader extends StatelessWidget {
//   final String title;

//   const _TimingSectionHeader({required this.title});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: AppSpacing.smHorizontal,
//       child: Padding(
//         padding: const EdgeInsets.only(
//           top: AppSpacing.md,
//           bottom: AppSpacing.sm,
//         ),
//         child: Text(
//           title,
//           style: AppTextStyles.sectionWithColor(
//             context,
//             color: AppColors.primary(context),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _TimePickerTile extends StatelessWidget {
//   final String label;
//   final TimeOfDay time;
//   final VoidCallback onTap;

//   const _TimePickerTile({
//     required this.label,
//     required this.time,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: AppColors.surfaceVariant(context),
//         borderRadius: AppRadius.mdAll,
//         border: Border.all(color: AppColors.outline(context)),
//       ),
//       child: Material(
//         color: Colors.transparent,
//         borderRadius: AppRadius.mdAll,
//         clipBehavior: Clip.antiAlias,
//         child: InkWell(
//           onTap: () {
//             HapticFeedback.selectionClick();
//             onTap();
//           },
//           child: Padding(
//             padding: AppSpacing.smAll,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   label,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: AppTextStyles.metaWithColor(
//                     context,
//                     color: AppColors.textSecondary(context),
//                   ),
//                 ),
//                 const SizedBox(height: AppSpacing.xs),
//                 Row(
//                   children: [
//                     Icon(
//                       AppIcons.time,
//                       size: AppSize.icon,
//                       color: AppColors.primary(context),
//                     ),
//                     const SizedBox(width: AppSpacing.xs),
//                     Expanded(
//                       child: Text(
//                         time.format(context),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style: AppTextStyles.bodyWithColor(
//                           context,
//                           color: AppColors.textPrimary(context),
//                         ).copyWith(fontWeight: FontWeight.w600),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _DatePickerTile extends StatelessWidget {
//   final String label;
//   final String value;
//   final IconData icon;
//   final VoidCallback onTap;

//   const _DatePickerTile({
//     required this.label,
//     required this.value,
//     required this.icon,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: AppColors.surfaceVariant(context),
//         borderRadius: AppRadius.mdAll,
//         border: Border.all(color: AppColors.outline(context)),
//       ),
//       child: Material(
//         color: Colors.transparent,
//         borderRadius: AppRadius.mdAll,
//         clipBehavior: Clip.antiAlias,
//         child: InkWell(
//           onTap: () {
//             HapticFeedback.selectionClick();
//             onTap();
//           },
//           child: Padding(
//             padding: AppSpacing.smAll,
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Icon(
//                   icon,
//                   size: AppSize.icon,
//                   color: AppColors.primary(context),
//                 ),
//                 const SizedBox(width: AppSpacing.xs),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         label,
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style: AppTextStyles.metaWithColor(
//                           context,
//                           color: AppColors.textSecondary(context),
//                         ),
//                       ),
//                       const SizedBox(height: AppSpacing.xs),
//                       Text(
//                         value,
//                         style: AppTextStyles.metaWithColor(
//                           context,
//                           color: AppColors.textPrimary(context),
//                         ).copyWith(fontWeight: FontWeight.w600),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
