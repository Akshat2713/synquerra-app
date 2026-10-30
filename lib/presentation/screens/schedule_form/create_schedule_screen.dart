// lib/presentation/screens/user_schedule/create_schedule_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:synquerra/presentation/themes/app_text_styles.dart';
import 'package:synquerra/presentation/themes/app_tokens.dart';
import 'package:synquerra/presentation/themes/colors.dart';
import 'package:synquerra/presentation/utils/app_icons.dart';
import '../../../domain/entities/device/device_entity.dart';
import '../../../domain/entities/schedule/schedule_entity.dart';
import '../../blocs/device_list/device_list_bloc.dart';
import '../../blocs/schedule_form/schedule_form_bloc.dart';
import '../../widgets/app_motion_widgets.dart';
import '../../widgets/app_overlays.dart';
import 'widgets/basic_details_section.dart';
import 'widgets/grace_buffer_section.dart';
import 'widgets/timing_recurrence_section.dart';

class CreateScheduleScreen extends StatefulWidget {
  final String? scheduleId;
  final DeviceEntity? initialDevice;

  const CreateScheduleScreen({super.key, this.scheduleId, this.initialDevice});

  bool get isEdit => scheduleId != null;

  @override
  State<CreateScheduleScreen> createState() => _CreateScheduleScreenState();
}

class _CreateScheduleScreenState extends State<CreateScheduleScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _arrivalGraceController = TextEditingController(text: '10');
  final _departureBufferController = TextEditingController(text: '5');
  final _minStayController = TextEditingController();

  String? _selectedGeofenceId;
  String _selectedPriority = 'MEDIUM';

  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 15, minute: 0);
  bool _crossesMidnight = false;

  String _dateSelectionMode = 'range';

  final List<DateTime> _customSelectedDates = [];
  DateTime _startDate = DateTime.now();
  DateTime? _endDate = DateTime.now().add(const Duration(days: 90));
  bool _noEndDate = false;

  final List<int> _selectedDays = [0, 1, 2, 3, 4];

  bool _prefilled = false;

  @override
  void initState() {
    super.initState();

    final formBloc = context.read<ScheduleFormBloc>();

    if (widget.isEdit) {
      formBloc.add(ScheduleFormEditRequested(widget.scheduleId!));
      return;
    }

    String? deviceId = widget.initialDevice?.id;

    if (deviceId == null) {
      final state = context.read<DeviceListBloc>().state;
      if (state is DeviceListLoaded && state.devices.isNotEmpty) {
        deviceId = state.devices.first.id;
      }
    }

    if (deviceId != null) {
      formBloc.add(ScheduleFormDeviceChanged(deviceId));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _arrivalGraceController.dispose();
    _departureBufferController.dispose();
    _minStayController.dispose();
    super.dispose();
  }

  bool _computeCrossesMidnight(TimeOfDay start, TimeOfDay end) {
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    return endMinutes <= startMinutes;
  }

  TimeOfDay _parseTime(String timeStr) {
    if (timeStr.isEmpty) {
      return const TimeOfDay(hour: 0, minute: 0);
    }

    final cleanStr = timeStr.split('.').first;
    final parts = cleanStr.split(':');

    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 0,
      minute: parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0,
    );
  }

  String _formatTime(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:'
      '${time.minute.toString().padLeft(2, '0')}';

  String _formatDate(DateTime date) => date.toIso8601String().split('T').first;

  void _prefillFrom(ScheduleEntity schedule) {
    _titleController.text = schedule.title;
    _descController.text = schedule.description ?? '';
    _arrivalGraceController.text = schedule.arrivalGraceMins.toString();
    _departureBufferController.text = schedule.departureBufferMins.toString();
    _minStayController.text = schedule.minimumStayMins?.toString() ?? '';

    _selectedGeofenceId = schedule.geofenceId;
    _selectedPriority = schedule.priority;

    _startTime = _parseTime(schedule.startTime);
    _endTime = _parseTime(schedule.endTime);
    _crossesMidnight = _computeCrossesMidnight(_startTime, _endTime);

    _dateSelectionMode = schedule.customDates.isNotEmpty ? 'custom' : 'range';

    _selectedDays
      ..clear()
      ..addAll(schedule.daysOfWeek);

    _customSelectedDates
      ..clear()
      ..addAll(schedule.customDates.map(DateTime.parse));

    _startDate = DateTime.parse(schedule.startDate);
    _endDate = schedule.endDate != null
        ? DateTime.parse(schedule.endDate!)
        : null;
    _noEndDate = schedule.endDate == null;
  }

  Map<String, dynamic> _buildRequestBody({
    required String deviceId,
    required String targetUserId,
  }) {
    final isRange = _dateSelectionMode == 'range';

    return {
      'target_user_id': targetUserId,
      'device_id': deviceId,
      'geofence_id': _selectedGeofenceId,
      'title': _titleController.text.trim(),
      'description': _descController.text.trim().isEmpty
          ? null
          : _descController.text.trim(),
      'start_time': '${_formatTime(_startTime)}:00',
      'end_time': '${_formatTime(_endTime)}:00',
      'timezone': 'Asia/Kolkata',
      'recurrence_type': isRange ? 'WEEKLY' : 'CUSTOM_DATES',
      'days_of_week': isRange ? _selectedDays : <int>[],
      'custom_dates': isRange
          ? <String>[]
          : _customSelectedDates.map(_formatDate).toList(),
      'start_date': isRange
          ? _formatDate(_startDate)
          : _formatDate(
              _customSelectedDates.isNotEmpty
                  ? _customSelectedDates.first
                  : DateTime.now(),
            ),
      'end_date': (isRange && !_noEndDate && _endDate != null)
          ? _formatDate(_endDate!)
          : null,
      'crosses_midnight': _crossesMidnight,
      'priority': _selectedPriority,
      'grace_config': {
        'arrival_grace_mins': int.tryParse(_arrivalGraceController.text) ?? 0,
        'departure_buffer_mins':
            int.tryParse(_departureBufferController.text) ?? 0,
        'minimum_stay_mins': int.tryParse(_minStayController.text),
      },
    };
  }

  void _showError(String message) {
    AppSnackBar.error(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final device = widget.initialDevice;
    final currentUserFullName = device?.displayOwnerName ?? '';

    return BlocListener<DeviceListBloc, DeviceListState>(
      listener: (context, deviceState) {
        if (widget.isEdit || widget.initialDevice != null) return;
        if (deviceState is! DeviceListLoaded || deviceState.devices.isEmpty) {
          return;
        }

        final formBloc = context.read<ScheduleFormBloc>();

        if (formBloc.state.selectedDeviceId == null) {
          setState(() => _selectedGeofenceId = null);
          formBloc.add(ScheduleFormDeviceChanged(deviceState.devices.first.id));
        }
      },
      child: BlocListener<ScheduleFormBloc, ScheduleFormState>(
        listenWhen: (previous, current) =>
            previous.loadStatus != current.loadStatus ||
            previous.submitStatus != current.submitStatus,
        listener: (context, state) {
          if (state.loadStatus == ScheduleFormLoadStatus.loaded &&
              !_prefilled &&
              state.schedule != null) {
            _prefilled = true;
            setState(() => _prefillFrom(state.schedule!));
          }

          if (state.loadStatus == ScheduleFormLoadStatus.error) {
            _showError(state.errorMessage ?? 'Failed to load schedule');
          }

          if (state.submitStatus == ScheduleFormSubmitStatus.success) {
            Navigator.pop(context, true);
          }

          if (state.submitStatus == ScheduleFormSubmitStatus.error) {
            _showError(state.submitError ?? 'Failed to save schedule');
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.background(context),
          appBar: AppBar(
            title: Text(widget.isEdit ? 'Edit Schedule' : 'Create Schedule'),
            leading: IconButton(
              tooltip: 'Back',
              icon: const Icon(AppIcons.back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: BlocBuilder<ScheduleFormBloc, ScheduleFormState>(
            builder: (context, formState) {
              if (widget.isEdit && formState.isLoadingSchedule) {
                return const Center(child: CircularProgressIndicator());
              }

              return Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: AppSpacing.mdAll,
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: AppSpacing.md,
                    children: [
                      BlocBuilder<DeviceListBloc, DeviceListState>(
                        builder: (context, deviceState) {
                          final List<DeviceEntity> devices =
                              deviceState is DeviceListLoaded
                              ? deviceState.devices
                              : const [];

                          return BasicDetailsSection(
                            titleController: _titleController,
                            descController: _descController,
                            devices: devices,
                            currentUserFullName: currentUserFullName,
                            selectedDeviceId: formState.selectedDeviceId,
                            onDeviceChanged: (deviceId) {
                              setState(() => _selectedGeofenceId = null);
                              context.read<ScheduleFormBloc>().add(
                                ScheduleFormDeviceChanged(deviceId),
                              );
                            },
                            geofences: formState.geofences,
                            geofenceLoading: formState.isLoadingGeofences,
                            geofenceError: formState.geofenceError,
                            selectedGeofenceId: _selectedGeofenceId,
                            onGeofenceChanged: (value) {
                              setState(() => _selectedGeofenceId = value);
                            },
                            selectedPriority: _selectedPriority,
                            onPriorityChanged: (value) {
                              setState(() => _selectedPriority = value);
                            },
                          );
                        },
                      ).entrance(context, index: 0),
                      TimingRecurrenceSection(
                        startTime: _startTime,
                        endTime: _endTime,
                        crossesMidnight: _crossesMidnight,
                        selectedDays: _selectedDays,
                        dateSelectionMode: _dateSelectionMode,
                        startDate: _startDate,
                        endDate: _endDate,
                        noEndDate: _noEndDate,
                        customSelectedDates: _customSelectedDates,
                        onStartTimeChanged: (time) {
                          setState(() {
                            _startTime = time;
                            _crossesMidnight = _computeCrossesMidnight(
                              _startTime,
                              _endTime,
                            );
                          });
                        },
                        onEndTimeChanged: (time) {
                          setState(() {
                            _endTime = time;
                            _crossesMidnight = _computeCrossesMidnight(
                              _startTime,
                              _endTime,
                            );
                          });
                        },
                        onCrossesMidnightChanged: (value) {
                          setState(() => _crossesMidnight = value);
                        },
                        onDayToggled: (index) {
                          setState(() {
                            if (_selectedDays.contains(index)) {
                              _selectedDays.remove(index);
                            } else {
                              _selectedDays.add(index);
                            }
                          });
                        },
                        onDateModeChanged: (mode) {
                          setState(() => _dateSelectionMode = mode);
                        },
                        onStartDateChanged: (date) {
                          setState(() {
                            _startDate = date;
                            if (_endDate != null &&
                                _endDate!.isBefore(_startDate)) {
                              _endDate = _startDate;
                            }
                          });
                        },
                        onEndDateChanged: (date) {
                          setState(() => _endDate = date);
                        },
                        onNoEndDateChanged: (value) {
                          setState(() => _noEndDate = value);
                        },
                        onCustomDateAdded: (date) {
                          if (!_customSelectedDates.any(
                            (selected) => selected.isAtSameMomentAs(date),
                          )) {
                            setState(() => _customSelectedDates.add(date));
                          }
                        },
                        onCustomDateRemoved: (date) {
                          setState(() => _customSelectedDates.remove(date));
                        },
                      ).entrance(context, index: 1),
                      GraceBufferSection(
                        arrivalGraceController: _arrivalGraceController,
                        departureBufferController: _departureBufferController,
                        minStayController: _minStayController,
                      ).entrance(context, index: 2),
                      const SizedBox(height: AppSpacing.md),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: formState.isSubmitting
                              ? null
                              : () {
                                  if (!_formKey.currentState!.validate()) {
                                    return;
                                  }

                                  final deviceId = formState.selectedDeviceId;

                                  if (deviceId == null) {
                                    _showError('Please select a device');
                                    return;
                                  }

                                  if (_selectedGeofenceId == null) {
                                    _showError('Please select a geofence');
                                    return;
                                  }

                                  final targetUserId =
                                      device?.displayRealUserId;

                                  if (targetUserId == null ||
                                      targetUserId.isEmpty) {
                                    _showError(
                                      'User not found for this device.',
                                    );
                                    return;
                                  }

                                  final body = _buildRequestBody(
                                    deviceId: deviceId,
                                    targetUserId: targetUserId,
                                  );

                                  if (widget.isEdit) {
                                    context.read<ScheduleFormBloc>().add(
                                      ScheduleFormUpdateSubmitted(
                                        scheduleId: widget.scheduleId!,
                                        body: body,
                                      ),
                                    );
                                  } else {
                                    context.read<ScheduleFormBloc>().add(
                                      ScheduleFormCreateSubmitted(body),
                                    );
                                  }
                                },
                          child: formState.isSubmitting
                              ? SizedBox(
                                  width: AppSize.icon,
                                  height: AppSize.icon,
                                  child: CircularProgressIndicator(
                                    strokeWidth: AppSize.stroke,
                                    color: AppColors.onPrimary(context),
                                  ),
                                )
                              : Text(
                                  widget.isEdit
                                      ? 'Update Schedule Rule'
                                      : 'Save Schedule Rule',
                                  style: AppTextStyles.button,
                                ),
                        ),
                      ).entrance(context, index: 3),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
