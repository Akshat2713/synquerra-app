import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/schedule/schedule_override_entity.dart';
import '../../blocs/schedule_override/schedule_overrides_bloc.dart';
import '../../themes/colors.dart';
import '../../utils/app_icons.dart';
import '../../utils/date_time_formatter.dart';
import '../../widgets/app_dropdown_field.dart';
import '../../widgets/app_motion_widgets.dart';
import '../../widgets/app_overlays.dart';
import '../../widgets/app_picker_field.dart';
import '../../widgets/app_surfaces.dart';
import '../../widgets/app_text_field.dart';
import '../../themes/app_tokens.dart';

enum ExceptionType { cancel, modify }

class ScheduleExceptionScreen extends StatefulWidget {
  final String scheduleId;
  final ScheduleOverrideEntity? existingOverride;

  const ScheduleExceptionScreen({
    super.key,
    required this.scheduleId,
    this.existingOverride,
  });

  bool get isEditing => existingOverride != null;

  @override
  State<ScheduleExceptionScreen> createState() =>
      _ScheduleExceptionScreenState();
}

class _ScheduleExceptionScreenState extends State<ScheduleExceptionScreen> {
  final _formKey = GlobalKey<FormState>();

  ExceptionType _selectedType = ExceptionType.cancel;

  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  // final TextEditingController _dateController = TextEditingController();
  // final TextEditingController _startTimeController = TextEditingController();
  // final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _wasSubmitting = false;

  @override
  void initState() {
    super.initState();
    _prefillFromExisting();
  }

  void _prefillFromExisting() {
    final existing = widget.existingOverride;
    if (existing == null) return;

    _selectedType = existing.overrideType.toUpperCase() == 'CANCEL'
        ? ExceptionType.cancel
        : ExceptionType.modify;

    _selectedDate = DateTime.tryParse(existing.date);
    if (existing.startTime != null)
      _startTime = _parseTimeOfDay(existing.startTime!);
    if (existing.endTime != null) _endTime = _parseTimeOfDay(existing.endTime!);
    _descriptionController.text = existing.reason ?? '';
  }

  TimeOfDay? _parseTimeOfDay(String value) {
    // Expects 'HH:mm' or 'HH:mm:ss'
    final parts = value.split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  String _formatTimeOfDay24(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00';
  }

  @override
  void dispose() {
    // _dateController.dispose();
    // _startTimeController.dispose();
    // _endTimeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final selected = _selectedDate;
    final firstDate = (selected != null && selected.isBefore(now))
        ? selected
        : now;
    final picked = await showDatePicker(
      context: context,
      initialDate: selected ?? now,
      firstDate: firstDate,
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart
          ? (_startTime ?? const TimeOfDay(hour: 9, minute: 0))
          : (_endTime ?? const TimeOfDay(hour: 17, minute: 0)),
    );
    if (picked == null) return;
    setState(() => isStart ? _startTime = picked : _endTime = picked);
  }

  Map<String, dynamic> _buildBody() {
    final body = <String, dynamic>{
      'date': DateFormat('yyyy-MM-dd').format(_selectedDate!),
      'override_type': _selectedType == ExceptionType.cancel
          ? 'cancel'
          : 'modify',
      'reason': _descriptionController.text.trim(),
    };

    if (_selectedType == ExceptionType.modify) {
      body['start_time'] = _formatTimeOfDay24(_startTime!);
      body['end_time'] = _formatTimeOfDay24(_endTime!);
    }

    return body;
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) return;

    final body = _buildBody();
    final bloc = context.read<ScheduleOverridesBloc>();

    if (widget.isEditing) {
      bloc.add(
        ScheduleOverrideUpdated(
          scheduleId: widget.scheduleId,
          overrideId: widget.existingOverride!.id,
          updateBody: body,
        ),
      );
    } else {
      bloc.add(
        ScheduleOverrideCreated(
          scheduleId: widget.scheduleId,
          overrideBody: body,
        ),
      );
    }
    // Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    String? required(String? v) => (v == null || v.isEmpty) ? 'Required' : null;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: Text(
          widget.isEditing
              ? 'Edit Schedule Exception'
              : 'Add Schedule Exception',
        ),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(AppIcons.back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocListener<ScheduleOverridesBloc, ScheduleOverridesState>(
        listener: (context, state) {
          if (_wasSubmitting && !state.isSubmitting) {
            if (state.actionError == null) {
              AppSnackBar.success(
                context,
                widget.isEditing
                    ? 'Exception updated successfully!'
                    : 'Schedule exception saved successfully!',
              );
              Navigator.of(context).pop();
            } else {
              AppSnackBar.error(context, state.actionError!);
            }
          }
          _wasSubmitting = state.isSubmitting;
        },
        child: BlocBuilder<ScheduleOverridesBloc, ScheduleOverridesState>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: AppSpacing.mdAll,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: AppSpacing.md,
                  children: [
                    AppCard(
                      child: Column(
                        spacing: AppSpacing.md,
                        children: [
                          AppDropdownField<ExceptionType>(
                            label: 'Action Type',
                            prefixIcon: _selectedType == ExceptionType.cancel
                                ? AppIcons.eventBusy
                                : AppIcons.time,
                            value: _selectedType,
                            items: ExceptionType.values,
                            itemLabel: (t) => switch (t) {
                              ExceptionType.cancel => 'Cancel Schedule',
                              ExceptionType.modify => 'Modify Hours',
                            },
                            onChanged: (v) {
                              if (v != null) setState(() => _selectedType = v);
                            },
                          ),
                          AppPickerField(
                            label: 'Date',
                            value: _selectedDate == null
                                ? ''
                                : DateTimeFormatter.formatDate(_selectedDate),
                            icon: AppIcons.date,
                            onTap: _pickDate,
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Please select a date'
                                : null,
                          ),
                          if (_selectedType == ExceptionType.modify)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: AppSpacing.smd,
                              children: [
                                Expanded(
                                  child: AppPickerField(
                                    label: 'Start Time',
                                    value: _startTime?.format(context) ?? '',
                                    icon: AppIcons.time,
                                    onTap: () => _pickTime(isStart: true),
                                    validator: required,
                                  ),
                                ),
                                Expanded(
                                  child: AppPickerField(
                                    label: 'End Time',
                                    value: _endTime?.format(context) ?? '',
                                    icon: AppIcons.time,
                                    onTap: () => _pickTime(isStart: false),
                                    validator: required,
                                  ),
                                ),
                              ],
                            ),
                          AppTextField(
                            controller: _descriptionController,
                            label: 'Description / Reason',
                            hint:
                                'Provide context for this exception (e.g., Public Holiday, Maintenance)',
                            prefixIcon: AppIcons.description,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.done,
                            validator: (val) =>
                                (val == null || val.trim().isEmpty)
                                ? 'Please provide a description'
                                : null,
                          ),
                        ],
                      ),
                    ).entrance(context, index: 0),
                    FilledButton(
                      onPressed: state.isSubmitting ? null : _submitForm,
                      child: state.isSubmitting
                          ? SizedBox.square(
                              dimension: AppSize.icon,
                              child: CircularProgressIndicator(
                                strokeWidth: AppSize.stroke,
                                color: AppColors.onPrimary(context),
                              ),
                            )
                          : Text(
                              widget.isEditing
                                  ? 'Update Exception'
                                  : 'Save Exception',
                            ),
                    ).entrance(context, index: 1),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
