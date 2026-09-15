import 'package:flutter/material.dart';
import 'package:synquerra/presentation/themes/colors.dart';

class CreateScheduleScreen extends StatefulWidget {
  const CreateScheduleScreen({super.key});

  @override
  State<CreateScheduleScreen> createState() => _CreateScheduleScreenState();
}

class _CreateScheduleScreenState extends State<CreateScheduleScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController(text: 'School Hours Schedule');
  final _descController = TextEditingController(
    text: 'Mon-Fri morning school attendance rule',
  );

  String? _selectedGeofence = 'St. Xavier School Zone';
  String _selectedPriority = 'MEDIUM';

  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 15, minute: 0);
  bool _crossesMidnight = false;

  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime(2026, 9, 1),
    end: DateTime(2027, 6, 30),
  );

  final List<int> _selectedDays = [0, 1, 2, 3, 4];
  final List<String> _dayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  final _arrivalGraceController = TextEditingController(text: '10');
  final _departureBufferController = TextEditingController(text: '5');
  final _minStayController = TextEditingController(text: '30');

  bool _alertAbsence = true;
  bool _alertLateArrival = true;
  bool _alertEarlyDeparture = true;
  bool _alertReentry = false;
  bool _sendPush = true;

  // Shared Input Style Configuration
  InputDecoration _buildInputDecoration({
    required String labelText,
    IconData? prefixIcon,
    String? suffixText,
  }) {
    final textStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary(context),
    );

    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary(context),
      ),
      floatingLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      ),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, size: 20, color: AppColors.primary)
          : null,
      suffixText: suffixText,
      suffixStyle: textStyle,
      filled: true,
      fillColor: AppColors.surfaceVariant(context),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.outline(context)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.outline(context)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Base TextStyle enforced across input values
    final inputTextStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary(context),
    );

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Create Schedule'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionHeader('Basic Details'),
            _buildCard([
              TextFormField(
                controller: _titleController,
                style: inputTextStyle,
                decoration: _buildInputDecoration(
                  labelText: 'Schedule Title',
                  prefixIcon: Icons.title_rounded,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descController,
                maxLines: 2,
                style: inputTextStyle,
                decoration: _buildInputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icons.description_rounded,
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedGeofence,
                style: inputTextStyle,
                dropdownColor: AppColors.surface(context),
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textSecondary(context),
                ),
                decoration: _buildInputDecoration(
                  labelText: 'Target Geofence Zone',
                  prefixIcon: Icons.shield_outlined,
                ),
                items:
                    [
                          'St. Xavier School Zone',
                          'Allen Institute Campus',
                          'Home Zone',
                        ]
                        .map(
                          (zone) => DropdownMenuItem(
                            value: zone,
                            child: Text(zone, style: inputTextStyle),
                          ),
                        )
                        .toList(),
                onChanged: (val) => setState(() => _selectedGeofence = val),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedPriority,
                style: inputTextStyle,
                dropdownColor: AppColors.surface(context),
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textSecondary(context),
                ),
                decoration: _buildInputDecoration(
                  labelText: 'Priority',
                  prefixIcon: Icons.flag_rounded,
                ),
                items: ['LOW', 'MEDIUM', 'HIGH']
                    .map(
                      (p) => DropdownMenuItem(
                        value: p,
                        child: Text(p, style: inputTextStyle),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _selectedPriority = val!),
              ),
            ]),

            _buildSectionHeader('Timing & Recurrence'),
            _buildCard([
              Row(
                children: [
                  Expanded(
                    child: _buildTimeTile(
                      label: 'Start Time',
                      time: _startTime,
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: _startTime,
                        );
                        if (picked != null) setState(() => _startTime = picked);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTimeTile(
                      label: 'End Time',
                      time: _endTime,
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: _endTime,
                        );
                        if (picked != null) setState(() => _endTime = picked);
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
                value: _crossesMidnight,
                activeThumbColor: AppColors.primary,
                onChanged: (val) => setState(() => _crossesMidnight = val),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (index) {
                  final isSelected = _selectedDays.contains(index);
                  return InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedDays.remove(index);
                        } else {
                          _selectedDays.add(index);
                        }
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.surfaceVariant(context),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.outline(context),
                        ),
                      ),
                      child: Text(
                        _dayNames[index],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary(context),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2025),
                    lastDate: DateTime(2030),
                    initialDateRange: _dateRange,
                  );
                  if (picked != null) setState(() => _dateRange = picked);
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
                            '${_dateRange.start.toString().split(' ')[0]}  →  ${_dateRange.end.toString().split(' ')[0]}',
                            style: inputTextStyle,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ]),

            _buildSectionHeader('Grace & Buffer Rules'),
            _buildCard([
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _arrivalGraceController,
                      keyboardType: TextInputType.number,
                      style: inputTextStyle,
                      decoration: _buildInputDecoration(
                        labelText: 'Arrival Grace',
                        suffixText: 'mins',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _departureBufferController,
                      keyboardType: TextInputType.number,
                      style: inputTextStyle,
                      decoration: _buildInputDecoration(
                        labelText: 'Departure Buffer',
                        suffixText: 'mins',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _minStayController,
                keyboardType: TextInputType.number,
                style: inputTextStyle,
                decoration: _buildInputDecoration(
                  labelText: 'Minimum Stay Duration',
                  prefixIcon: Icons.timer_outlined,
                  suffixText: 'mins',
                ),
              ),
            ]),

            _buildSectionHeader('Alert Triggers'),
            _buildCard([
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
            ]),

            const SizedBox(height: 16),

            // Save Action Button
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
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.pop(context);
                  }
                },
                child: const Text(
                  'Save Schedule Rule',
                  style: TextStyle(
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
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline(context)),
      ),
      // Material widget added to hold ink splash rendering over the DecoratedBox
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ),
    );
  }

  Widget _buildTimeTile({
    required String label,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outline(context)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary(context),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  time.format(context),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ],
            ),
          ],
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
