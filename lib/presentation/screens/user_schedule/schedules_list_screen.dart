import 'package:flutter/material.dart';
import 'package:synquerra/presentation/app/app_router.dart';
import 'package:synquerra/presentation/themes/colors.dart';

class SchedulesListScreen extends StatefulWidget {
  final String deviceId;

  const SchedulesListScreen({super.key, this.deviceId = ''});

  @override
  State<SchedulesListScreen> createState() => _SchedulesListScreenState();
}

class _SchedulesListScreenState extends State<SchedulesListScreen> {
  // Sample static data representing schedules
  final List<Map<String, dynamic>> _schedules = [
    {
      'title': 'School Hours Schedule',
      'description': 'Mon-Fri morning school attendance rule',
      'geofence': 'St. Xavier School Zone',
      'time': '08:00 AM - 03:00 PM',
      'days': ['M', 'T', 'W', 'T', 'F'],
      'priority': 'MEDIUM',
      'isActive': true,
      'dateRange': 'Sep 01, 2026 - Jun 30, 2027',
    },
    {
      'title': 'Tuition & Coaching',
      'description': 'Evening coaching class monitoring',
      'geofence': 'Allen Institute Campus',
      'time': '04:30 PM - 07:00 PM',
      'days': ['M', 'W', 'F'],
      'priority': 'HIGH',
      'isActive': true,
      'dateRange': 'Aug 15, 2026 - Dec 20, 2026',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Schedule Rules'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _schedules.length,
        itemBuilder: (context, index) {
          final item = _schedules[index];
          return _buildScheduleCard(item, index);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        onPressed: () {
          AppRouter.pushCreateSchedule(context, deviceId: widget.deviceId);
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Schedule',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildScheduleCard(Map<String, dynamic> item, int index) {
    final bool isActive = item['isActive'];
    final String priority = item['priority'];

    Color priorityColor;
    if (priority == 'HIGH') {
      priorityColor = AppColors.danger;
    } else if (priority == 'MEDIUM') {
      priorityColor = AppColors.warning;
    } else {
      priorityColor = AppColors.info;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline(context)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow(context),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Title & Active Switch
            Row(
              children: [
                Expanded(
                  child: Text(
                    item['title'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                ),
                Switch.adaptive(
                  value: isActive,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    setState(() => _schedules[index]['isActive'] = val);
                  },
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              item['description'],
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary(context),
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Time & Location Info
            Row(
              children: [
                Icon(
                  Icons.access_time_filled_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  item['time'],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: priorityColor.withOpacity(0.4)),
                  ),
                  child: Text(
                    priority,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: priorityColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Icon(
                  Icons.location_on_rounded,
                  size: 16,
                  color: AppColors.textTertiary(context),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item['geofence'],
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Days & Dates
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                      .asMap()
                      .entries
                      .map((entry) {
                        final isSelected =
                            (item['days'] as List).contains(entry.value) &&
                            entry.key < 5;
                        return Container(
                          margin: const EdgeInsets.only(right: 4),
                          width: 24,
                          height: 24,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.surfaceVariant(context),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            entry.value,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textTertiary(context),
                            ),
                          ),
                        );
                      })
                      .toList(),
                ),
                Text(
                  item['dateRange'],
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textTertiary(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
