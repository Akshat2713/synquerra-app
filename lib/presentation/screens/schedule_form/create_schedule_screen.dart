import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:synquerra/core/di/injection_container.dart';
import 'package:synquerra/presentation/themes/colors.dart';
import 'package:synquerra/presentation/widgets/app_text_field.dart';

import '../../../domain/entities/device/device_entity.dart';
import '../../../domain/entities/schedule/schedule_entity.dart';
import '../../blocs/device_list/device_list_bloc.dart';
import '../../blocs/schedule_form/schedule_form_bloc.dart';
import 'basic_details_section.dart';
import 'section_card.dart';
import 'section_header.dart';
import 'timing_recurrence_section.dart';

class CreateScheduleScreen extends StatefulWidget {
  /// Non-null puts this screen in edit mode and preloads the schedule.
  final String? scheduleId;

  const CreateScheduleScreen({super.key, this.scheduleId});

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
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime.now(),
    end: DateTime.now().add(const Duration(days: 90)),
  );

  /// Monday = 0 .. Sunday = 6 convention (matches DaySelectorRow and backend API).
  final List<int> _selectedDays = [0, 1, 2, 3, 4];

  bool _alertAbsence = true;
  bool _alertLateArrival = true;
  bool _alertEarlyDeparture = true;
  bool _alertEarlyEntry = false;
  bool _alertReentry = false;
  bool _sendPush = true;

  bool _prefilled = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) {
      context.read<ScheduleFormBloc>().add(
        ScheduleFormEditRequested(widget.scheduleId!),
      );
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

  TimeOfDay _parseTime(String hhmmss) {
    final parts = hhmmss.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  String _formatDate(DateTime d) => d.toIso8601String().split('T').first;

  void _prefillFrom(ScheduleEntity s) {
    _titleController.text = s.title;
    _descController.text = s.description ?? '';
    _arrivalGraceController.text = s.arrivalGraceMins.toString();
    _departureBufferController.text = s.departureBufferMins.toString();
    _minStayController.text = s.minimumStayMins?.toString() ?? '';
    _selectedGeofenceId = s.geofenceId;
    _selectedPriority = s.priority;
    _startTime = _parseTime(s.startTime);
    _endTime = _parseTime(s.endTime);
    _crossesMidnight = s.crossesMidnight;
    _dateSelectionMode = s.customDates.isNotEmpty ? 'custom' : 'range';
    _selectedDays
      ..clear()
      ..addAll(s.daysOfWeek);
    _customSelectedDates
      ..clear()
      ..addAll(s.customDates.map(DateTime.parse));
    final start = DateTime.parse(s.startDate);
    _dateRange = DateTimeRange(
      start: start,
      end: s.endDate != null
          ? DateTime.parse(s.endDate!)
          : start.add(const Duration(days: 90)),
    );
    _alertAbsence = s.alertOnAbsence;
    _alertLateArrival = s.alertOnLateArrival;
    _alertEarlyDeparture = s.alertOnEarlyDeparture;
    _alertEarlyEntry = s.alertOnEarlyEntry;
    _alertReentry = s.alertOnReentry;
    _sendPush = s.sendPushNotification;
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
          ? _formatDate(_dateRange.start)
          : _formatDate(
              _customSelectedDates.isNotEmpty
                  ? _customSelectedDates.first
                  : DateTime.now(),
            ),
      'end_date': isRange ? _formatDate(_dateRange.end) : null,
      'crosses_midnight': _crossesMidnight,
      'priority': _selectedPriority,
      'grace_config': {
        'arrival_grace_mins': int.tryParse(_arrivalGraceController.text) ?? 0,
        'departure_buffer_mins':
            int.tryParse(_departureBufferController.text) ?? 0,
        'minimum_stay_mins': int.tryParse(_minStayController.text),
      },
      'alert_settings': {
        'alert_on_absence': _alertAbsence,
        'alert_on_late_arrival': _alertLateArrival,
        'alert_on_early_departure': _alertEarlyDeparture,
        'alert_on_early_entry': _alertEarlyEntry,
        'alert_on_reentry': _alertReentry,
        'send_push_notification': _sendPush,
      },
    };
  }

  @override
  Widget build(BuildContext context) {
    final user = sl<UserHolder>().user;
    final personId = user?.personId;
    final currentUserFullName = user?.fullName ?? 'Myself';

    return BlocListener<ScheduleFormBloc, ScheduleFormState>(
      listenWhen: (p, c) =>
          p.loadStatus != c.loadStatus || p.submitStatus != c.submitStatus,
      listener: (context, state) {
        if (state.loadStatus == ScheduleFormLoadStatus.loaded &&
            !_prefilled &&
            state.schedule != null) {
          _prefilled = true;
          setState(() => _prefillFrom(state.schedule!));
        }
        if (state.loadStatus == ScheduleFormLoadStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Failed to load schedule'),
            ),
          );
        }
        if (state.submitStatus == ScheduleFormSubmitStatus.success) {
          Navigator.pop(context, true);
        }
        if (state.submitStatus == ScheduleFormSubmitStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.submitError ?? 'Failed to save schedule'),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        appBar: AppBar(
          title: Text(widget.isEdit ? 'Edit Schedule' : 'Create Schedule'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
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
              child: ListView(
                padding: const EdgeInsets.all(16),
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
                        onGeofenceChanged: (val) =>
                            setState(() => _selectedGeofenceId = val),
                        selectedPriority: _selectedPriority,
                        onPriorityChanged: (val) =>
                            setState(() => _selectedPriority = val),
                      );
                    },
                  ),
                  TimingRecurrenceSection(
                    startTime: _startTime,
                    endTime: _endTime,
                    crossesMidnight: _crossesMidnight,
                    selectedDays: _selectedDays,
                    dateSelectionMode: _dateSelectionMode,
                    dateRange: _dateRange,
                    customSelectedDates: _customSelectedDates,
                    onStartTimeChanged: (time) =>
                        setState(() => _startTime = time),
                    onEndTimeChanged: (time) => setState(() => _endTime = time),
                    onCrossesMidnightChanged: (val) =>
                        setState(() => _crossesMidnight = val),
                    onDayToggled: (index) {
                      setState(() {
                        _selectedDays.contains(index)
                            ? _selectedDays.remove(index)
                            : _selectedDays.add(index);
                      });
                    },
                    onDateModeChanged: (mode) =>
                        setState(() => _dateSelectionMode = mode),
                    onDateRangeChanged: (range) =>
                        setState(() => _dateRange = range),
                    onCustomDateAdded: (date) {
                      if (!_customSelectedDates.any(
                        (d) => d.isAtSameMomentAs(date),
                      )) {
                        setState(() => _customSelectedDates.add(date));
                      }
                    },
                    onCustomDateRemoved: (date) =>
                        setState(() => _customSelectedDates.remove(date)),
                  ),
                  const SectionHeader(title: 'Grace & Buffer Rules'),
                  SectionCard(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              controller: _arrivalGraceController,
                              label: 'Arrival Grace',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppTextField(
                              controller: _departureBufferController,
                              label: 'Departure Buffer',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _minStayController,
                        label: 'Minimum Stay Duration',
                        prefixIcon: Icons.timer_outlined,
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                  const SectionHeader(title: 'Alert Triggers'),
                  SectionCard(
                    children: [
                      _buildSwitchRow(
                        'Alert on Absence',
                        'Notify if student does not arrive',
                        _alertAbsence,
                        (v) => setState(() => _alertAbsence = v),
                      ),
                      _buildSwitchRow(
                        'Alert on Late Arrival',
                        'Notify after grace period ends',
                        _alertLateArrival,
                        (v) => setState(() => _alertLateArrival = v),
                      ),
                      _buildSwitchRow(
                        'Alert on Early Departure',
                        'Notify if leaving before schedule ends',
                        _alertEarlyDeparture,
                        (v) => setState(() => _alertEarlyDeparture = v),
                      ),
                      _buildSwitchRow(
                        'Alert on Early Entry',
                        'Notify if arriving well before start',
                        _alertEarlyEntry,
                        (v) => setState(() => _alertEarlyEntry = v),
                      ),
                      _buildSwitchRow(
                        'Alert on Re-entry',
                        'Notify if student enters zone again',
                        _alertReentry,
                        (v) => setState(() => _alertReentry = v),
                      ),
                      const Divider(),
                      _buildSwitchRow(
                        'Push Notifications',
                        'Send alert notifications to mobile',
                        _sendPush,
                        (v) => setState(() => _sendPush = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: formState.isSubmitting
                          ? null
                          : () {
                              if (!_formKey.currentState!.validate()) return;
                              final deviceId = formState.selectedDeviceId;
                              if (deviceId == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please select a device'),
                                  ),
                                );
                                return;
                              }
                              if (_selectedGeofenceId == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please select a geofence'),
                                  ),
                                );
                                return;
                              }
                              if (personId == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'User not found. Please log in again.',
                                    ),
                                  ),
                                );
                                return;
                              }
                              final body = _buildRequestBody(
                                deviceId: deviceId,
                                targetUserId: personId,
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
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              widget.isEdit
                                  ? 'Update Schedule Rule'
                                  : 'Save Schedule Rule',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSwitchRow(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary(context),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary(context),
        ),
      ),
      value: value,
      activeThumbColor: AppColors.primary,
      onChanged: onChanged,
    );
  }
}
