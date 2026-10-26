// lib/presentation/widgets/analytics_filter_sheet.dart
import 'package:flutter/cupertino.dart' show CupertinoPicker;
import 'package:flutter/material.dart';
import 'package:synquerra/presentation/utils/date_time_formatter.dart';
import 'package:synquerra/presentation/utils/unit_formatter.dart';
import '../../domain/entities/analytics/analytics_filter.dart';
import '../themes/app_text_styles.dart';
import '../themes/colors.dart';
import '../utils/app_icons.dart';
import 'app_overlays.dart';
import 'app_surfaces.dart';
import 'package:synquerra/presentation/themes/app_tokens.dart';

void showAnalyticsFilterSheet({
  required BuildContext context,
  required AnalyticsFilter activeFilter,
  required void Function(AnalyticsFilter filter) onFilterSelected,
  required void Function(DateTime start, DateTime end) onCustomSelected,
}) {
  showAppBottomSheet<void>(
    context,
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
  showAppBottomSheet<void>(
    context,
    builder: (_) => _AnalyticsFilterSheet(
      activeFilter: AnalyticsFilter.custom,
      onFilterSelected: (_) {},
      onCustomSelected: onCustomSelected,
      startAtCustomPicker: true,
    ),
  );
}

/// Allowed durations (hours) for a custom range. Max is 24h per business rule.
// TODO(logic): business rule, move next to the filter/bloc constants.
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
    // The theme supplies surface, shape and drag handle (showDragHandle).
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: _showCustomPicker ? _buildCustom(context) : _buildPresets(context),
    );
  }

  // ---------------------------------------------------------------- presets
  Widget _buildPresets(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _Header(
          title: 'Filter by Time',
          subtitle: 'Select a time range for telemetry data',
        ),
        const SizedBox(height: AppSpacing.md),
        _FilterOption(
          label: 'Last Hour',
          icon: AppIcons.lastHour,
          isActive: widget.activeFilter == AnalyticsFilter.lastHour,
          onTap: () {
            Navigator.pop(context);
            widget.onFilterSelected(AnalyticsFilter.lastHour);
          },
        ),
        _FilterOption(
          label: 'Last 24 Hours',
          icon: AppIcons.last24Hours,
          isActive: widget.activeFilter == AnalyticsFilter.last24Hours,
          onTap: () {
            Navigator.pop(context);
            widget.onFilterSelected(AnalyticsFilter.last24Hours);
          },
        ),
        _FilterOption(
          label: 'Custom Range',
          icon: AppIcons.customRange,
          isActive: widget.activeFilter == AnalyticsFilter.custom,
          onTap: () => setState(() => _showCustomPicker = true),
        ),
      ],
    );
  }

  // ----------------------------------------------------------------- custom
  Widget _buildCustom(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: AppSpacing.md,
      children: [
        Row(
          spacing: AppSpacing.sm,
          children: [
            if (!widget.startAtCustomPicker)
              IconButton(
                icon: const Icon(AppIcons.back),
                color: AppColors.primary(context),
                tooltip: 'Back',
                onPressed: () => setState(() => _showCustomPicker = false),
              ),
            Expanded(
              child: _Header(
                title: 'Custom Range',
                subtitle: 'Max range is 24 hours',
              ),
            ),
          ],
        ),
        _DateTile(label: 'Date', date: _selectedDate, onTap: _pickDate),
        _LabeledWheel(
          label: 'Start Time',
          child: _WheelPicker(
            controller: _hourController,
            itemCount: 24,
            labelBuilder: UnitFormatter.hourLabel,
            onChanged: (i) => setState(() => _selectedHour = i),
          ),
        ),
        _LabeledWheel(
          label: 'Duration',
          child: _WheelPicker(
            controller: _durationController,
            itemCount: _kDurationOptions.length,
            labelBuilder: (i) => '${_kDurationOptions[i]} hrs',
            onChanged: (i) => setState(() => _durationIndex = i),
          ),
        ),
        _RangeSummary(
          text:
              '${DateTimeFormatter.formatDateTime(_startDateTime)}  →  '
              '${DateTimeFormatter.formatDateTime(_endDateTime)}',
        ),
        Row(
          spacing: AppSpacing.smd,
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => widget.startAtCustomPicker
                    ? Navigator.pop(context)
                    : setState(() => _showCustomPicker = false),
                child: const Text('Back'),
              ),
            ),
            Expanded(
              child: FilledButton(
                onPressed: _selectedDate != null
                    ? () {
                        Navigator.pop(context);
                        widget.onCustomSelected(_startDateTime, _endDateTime);
                      }
                    : null,
                child: const Text('Apply'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final String subtitle;
  const _Header({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: AppSpacing.xs,
    children: [
      Text(title, style: AppTextStyles.titleWithColor(context)),
      Text(subtitle, style: AppTextStyles.metaWithColor(context)),
    ],
  );
}

class _FilterOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterOption({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isActive,
      child: InsetRow(
        onTap: onTap,
        child: Row(
          spacing: AppSpacing.smd,
          children: [
            IconTile(
              icon: icon,
              background: isActive
                  ? AppColors.primary(context)
                  : AppColors.surface(context),
              foreground: isActive
                  ? AppColors.onPrimary(context)
                  : AppColors.textSecondary(context),
            ),
            Expanded(
              child: Text(
                label,
                style:
                    AppTextStyles.bodyWithColor(
                      context,
                      color: AppColors.textPrimary(context),
                    ).copyWith(
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    ),
              ),
            ),
            Icon(
              isActive ? AppIcons.activeCheck : AppIcons.chevron,
              size: AppSize.icon,
              color: isActive
                  ? AppColors.primary(context)
                  : AppColors.textSecondary(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const _DateTile({
    required this.label,
    required this.date,
    required this.onTap,
  });

  // TODO(logic): use a DateTimeFormatter method instead of manual dd/MM/yyyy.
  String get _text =>
      '${date!.day.toString().padLeft(2, '0')}/'
      '${date!.month.toString().padLeft(2, '0')}/'
      '${date!.year}';

  @override
  Widget build(BuildContext context) {
    final selected = date != null;
    return Semantics(
      button: true,
      child: InsetRow(
        onTap: onTap,
        child: Row(
          spacing: AppSpacing.smd,
          children: [
            IconTile(
              icon: AppIcons.date,
              background: selected
                  ? AppColors.primary(context)
                  : AppColors.surface(context),
              foreground: selected
                  ? AppColors.onPrimary(context)
                  : AppColors.textSecondary(context),
            ),
            Expanded(
              child: Text(
                selected ? _text : label,
                style:
                    AppTextStyles.bodyWithColor(
                      context,
                      color: selected
                          ? AppColors.textPrimary(context)
                          : AppColors.textSecondary(context),
                    ).copyWith(
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LabeledWheel extends StatelessWidget {
  final String label;
  final Widget child;
  const _LabeledWheel({required this.label, required this.child});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: AppSpacing.sm,
    children: [
      Text(
        label,
        style: AppTextStyles.bodyWithColor(
          context,
          color: AppColors.textPrimary(context),
        ).copyWith(fontWeight: FontWeight.w600),
      ),
      child,
    ],
  );
}

class _WheelPicker extends StatelessWidget {
  final FixedExtentScrollController controller;
  final int itemCount;
  final String Function(int index) labelBuilder;
  final void Function(int index) onChanged;

  const _WheelPicker({
    required this.controller,
    required this.itemCount,
    required this.labelBuilder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selectionBorder = BorderSide(
      color: AppColors.primaryBorder(context),
      width: AppSize.hairline,
    );

    return Container(
      height: AppSize.pickerHeight,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant(context),
        borderRadius: AppRadius.mdAll,
        border: Border.all(
          color: AppAlpha.withOverlayAlpha(AppColors.outline(context)),
          width: AppSize.hairline,
        ),
      ),
      child: CupertinoPicker(
        scrollController: controller,
        itemExtent: AppSize.pickerItem,
        onSelectedItemChanged: onChanged,
        selectionOverlay: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(top: selectionBorder, bottom: selectionBorder),
          ),
        ),
        children: List.generate(
          itemCount,
          (i) => Center(
            child: Text(
              labelBuilder(i),
              style: AppTextStyles.bodyWithColor(
                context,
                color: AppColors.textPrimary(context),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RangeSummary extends StatelessWidget {
  final String text;
  const _RangeSummary({required this.text});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.smd,
      vertical: AppSpacing.smd,
    ),
    decoration: BoxDecoration(
      color: AppColors.primaryContainer(context),
      borderRadius: AppRadius.mdAll,
    ),
    child: Row(
      spacing: AppSpacing.sm,
      children: [
        Icon(
          AppIcons.dateRange,
          size: AppSize.icon,
          color: AppColors.onPrimaryContainer(context),
        ),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.metaWithColor(
              context,
              color: AppColors.onPrimaryContainer(context),
            ).copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}
