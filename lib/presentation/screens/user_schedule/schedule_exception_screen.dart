import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/schedule/schedule_override_entity.dart';
import '../../blocs/schedule_override/schedule_overrides_bloc.dart';
import '../../themes/colors.dart';
import '../../widgets/app_text_field.dart';

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

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
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
    _dateController.text = _selectedDate != null
        ? DateFormat('EEE, MMM d, yyyy').format(_selectedDate!)
        : existing.date;

    if (existing.startTime != null) {
      _startTime = _parseTimeOfDay(existing.startTime!);
      _startTimeController.text = existing.startTime!;
    }
    if (existing.endTime != null) {
      _endTime = _parseTimeOfDay(existing.endTime!);
      _endTimeController.text = existing.endTime!;
    }
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
    _dateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface(context),
              onSurface: AppColors.textPrimary(context),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('EEE, MMM d, yyyy').format(picked);
      });
    }
  }

  Future<void> _pickTime(BuildContext context, {required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart
          ? (_startTime ?? const TimeOfDay(hour: 9, minute: 0))
          : (_endTime ?? const TimeOfDay(hour: 17, minute: 0)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface(context),
              onSurface: AppColors.textPrimary(context),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
          _startTimeController.text = picked.format(context);
        } else {
          _endTime = picked;
          _endTimeController.text = picked.format(context);
        }
      });
    }
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
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: Text(
          widget.isEditing
              ? 'Edit Schedule Exception'
              : 'Add Schedule Exception',
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.iconPrimary(context)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocListener<ScheduleOverridesBloc, ScheduleOverridesState>(
        listener: (context, state) {
          if (_wasSubmitting && !state.isSubmitting) {
            if (state.actionError == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    widget.isEditing
                        ? 'Exception updated successfully!'
                        : 'Schedule exception saved successfully!',
                  ),
                  backgroundColor: AppColors.success,
                ),
              );
              Navigator.of(context).pop();
            } else {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.actionError!)));
            }
          }
          _wasSubmitting = state.isSubmitting;
        },
        child: BlocBuilder<ScheduleOverridesBloc, ScheduleOverridesState>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Action Type',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<ExceptionType>(
                      initialValue: _selectedType,
                      dropdownColor: AppColors.surface(context),
                      style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontSize: 15,
                      ),
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          _selectedType == ExceptionType.cancel
                              ? Icons.event_busy_outlined
                              : Icons.access_time_outlined,
                          size: 20,
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: ExceptionType.cancel,
                          child: Text('Cancel Schedule'),
                        ),
                        DropdownMenuItem(
                          value: ExceptionType.modify,
                          child: Text('Modify Hours'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedType = value);
                        }
                      },
                    ),
                    const SizedBox(height: 20),

                    GestureDetector(
                      onTap: () => _pickDate(context),
                      child: AbsorbPointer(
                        child: AppTextField(
                          controller: _dateController,
                          label: 'Date',
                          hint: 'Select Exception Date',
                          prefixIcon: Icons.calendar_today_outlined,
                          readOnly: true,
                          validator: (val) => (val == null || val.isEmpty)
                              ? 'Please select a date'
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    if (_selectedType == ExceptionType.modify) ...[
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _pickTime(context, isStart: true),
                              child: AbsorbPointer(
                                child: AppTextField(
                                  controller: _startTimeController,
                                  label: 'Start Time',
                                  hint: '09:00 AM',
                                  prefixIcon: Icons.schedule_outlined,
                                  readOnly: true,
                                  validator: (val) {
                                    if (_selectedType == ExceptionType.modify &&
                                        (val == null || val.isEmpty)) {
                                      return 'Required';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _pickTime(context, isStart: false),
                              child: AbsorbPointer(
                                child: AppTextField(
                                  controller: _endTimeController,
                                  label: 'End Time',
                                  hint: '05:00 PM',
                                  prefixIcon: Icons.schedule_outlined,
                                  readOnly: true,
                                  validator: (val) {
                                    if (_selectedType == ExceptionType.modify &&
                                        (val == null || val.isEmpty)) {
                                      return 'Required';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],

                    AppTextField(
                      controller: _descriptionController,
                      label: 'Description / Reason',
                      hint:
                          'Provide context for this exception (e.g., Public Holiday, Maintenance)',
                      prefixIcon: Icons.description_outlined,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.done,
                      validator: (val) => (val == null || val.trim().isEmpty)
                          ? 'Please provide a description'
                          : null,
                    ),
                    const SizedBox(height: 32),

                    ElevatedButton(
                      onPressed: state.isSubmitting ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: state.isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              widget.isEditing
                                  ? 'Update Exception'
                                  : 'Save Exception',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
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
