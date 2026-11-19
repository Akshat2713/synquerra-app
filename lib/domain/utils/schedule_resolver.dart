import '../entities/schedule/schedule_entity.dart';

enum ScheduleStatus { upcoming, ongoing, completed }

class ResolvedSchedule {
  final ScheduleEntity schedule;
  final DateTime start;
  final DateTime end;
  final ScheduleStatus status;
  const ResolvedSchedule(this.schedule, this.start, this.end, this.status);
}

class ScheduleResolver {
  ScheduleResolver._();

  /// Today's occurrences (including a cross-midnight one started yesterday),
  /// sorted by start time. [now] is injected so this is unit-testable.
  static List<ResolvedSchedule> forDay(
    List<ScheduleEntity> schedules,
    DateTime now,
  ) {
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final result = <ResolvedSchedule>[];

    for (final s in schedules) {
      if (!s.isActive) continue;

      for (final day in [if (s.crossesMidnight) yesterday, today]) {
        if (!_occursOn(s, day)) continue;

        final start = _at(day, s.startTime);
        var end = _at(day, s.endTime);
        if (s.crossesMidnight || !end.isAfter(start)) {
          end = DateTime(
            end.year,
            end.month,
            end.day + 1,
            end.hour,
            end.minute,
          );
        }

        // Keep only occurrences that overlap today.
        if (!end.isAfter(today) || !start.isBefore(tomorrow)) continue;

        result.add(ResolvedSchedule(s, start, end, _statusAt(now, start, end)));
      }
    }

    result.sort((a, b) => a.start.compareTo(b.start));
    return result;
  }

  static ScheduleStatus _statusAt(DateTime now, DateTime start, DateTime end) {
    if (now.isBefore(start)) return ScheduleStatus.upcoming;
    if (now.isBefore(end)) return ScheduleStatus.ongoing;
    return ScheduleStatus.completed;
  }

  static bool _occursOn(ScheduleEntity s, DateTime day) {
    final from = DateTime.tryParse(s.startDate);
    if (from != null && day.isBefore(_dateOnly(from))) return false;

    final to = s.endDate == null ? null : DateTime.tryParse(s.endDate!);
    if (to != null && day.isAfter(_dateOnly(to))) return false;

    if (s.customDates.isNotEmpty) {
      return s.customDates.any((d) {
        final p = DateTime.tryParse(d);
        return p != null && _dateOnly(p) == day;
      });
    }

    if (s.daysOfWeek.isNotEmpty) {
      return s.daysOfWeek.contains(day.weekday % 7); // 0=Sun..6=Sat
    }
    return true; // no days listed = daily
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Parses "HH:mm".
  static DateTime _at(DateTime day, String hhmm) {
    final p = hhmm.split(':');
    return DateTime(
      day.year,
      day.month,
      day.day,
      int.tryParse(p[0]) ?? 0,
      p.length > 1 ? int.tryParse(p[1]) ?? 0 : 0,
    );
  }
}
