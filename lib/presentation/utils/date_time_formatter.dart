// lib/presentation/utils/date_time_formatter.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimeFormatter {
  DateTimeFormatter._();

  static DateTime? parseUtcToLocal(String? isoString) {
    if (isoString == null || isoString.isEmpty) return null;
    try {
      final normalized = isoString.endsWith('Z') || isoString.contains('+')
          ? isoString
          : '${isoString}Z';
      return DateTime.parse(normalized).toUtc().toLocal();
    } catch (e) {
      return null;
    }
  }

  /// Format TimeOfDay to 12-hour AM/PM string ("10:30 AM")
  static String formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return '--:--';
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('h:mm a').format(dt);
  }

  /// Format ISO timestamp to 12-hour AM/PM string ("10:30 AM")
  static String toTimeAmPm(String? isoTimestamp) {
    final dt = parseUtcToLocal(isoTimestamp);
    if (dt == null) return '--:--';
    return DateFormat('h:mm a').format(dt);
  }

  /// Format timestamp to "HH:mm:ss"
  static String formatTime(DateTime? dateTime) {
    if (dateTime == null) return '--:--:--';
    return DateFormat('HH:mm:ss').format(dateTime);
  }

  /// Format timestamp to "dd/MM/yyyy HH:mm"
  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '--/--/---- --:--';
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  /// Format timestamp to "dd MMM, yyyy"
  static String formatDate(DateTime? dateTime) {
    if (dateTime == null) return '-- --- ----';
    return DateFormat('dd MMM, yyyy').format(dateTime);
  }

  /// Format timestamp to compact "d/M" (e.g., 25/8)
  static String formatCompactDate(DateTime? dateTime) {
    if (dateTime == null) return '--/--';
    return '${dateTime.day}/${dateTime.month}';
  }

  /// Format relative time (e.g., "5m ago", "2h ago")
  static String formatRelativeTime(DateTime? dateTime) {
    if (dateTime == null) return 'Never';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return formatDateTime(dateTime);
    }
  }

  /// Compact time for feed rows, takes the raw ISO string.
  /// Today: "now", "5m ago", "2h ago". Yesterday: "9:30 PM". Older: "14 Oct".
  static String formatFeedTime(String? iso) {
    final dt = parseUtcToLocal(iso);
    if (dt == null) return '';
    if (isToday(dt)) {
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      return '${diff.inHours}h ago';
    }
    if (isYesterday(dt)) return DateFormat('h:mm a').format(dt);
    return DateFormat('d MMM').format(dt);
  }

  /// Checks if a timestamp falls within the live threshold
  static bool isLive(
    DateTime? timestamp, {
    Duration threshold = const Duration(seconds: 60),
  }) {
    if (timestamp == null) return false;
    return DateTime.now().difference(timestamp) < threshold;
  }

  /// Converts a duration in seconds to a short human-readable label.
  /// e.g. 30 → '30s', 90 → '1m', 7200 → '2h'
  static String formatInterval(int seconds) {
    if (seconds < 60) return '${seconds}s';
    if (seconds < 3600) return '${seconds ~/ 60}m';
    return '${seconds ~/ 3600}h';
  }

  /// Parse ISO string to DateTime safely
  static DateTime? parseIsoString(String? isoString) {
    if (isoString == null) return null;
    try {
      return DateTime.parse(isoString).toLocal();
    } catch (e) {
      return null;
    }
  }

  static String toFullDateTime(String? isoTimestamp) {
    final dt = parseUtcToLocal(isoTimestamp);
    return formatFullDateTime(dt);
  }

  static String formatFullDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    return DateFormat('d MMM, h:mm a').format(dateTime);
  }

  static String toIsoString(DateTime dateTime) {
    return dateTime.toUtc().toIso8601String();
  }

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static bool isToday(DateTime dateTime) => isSameDay(dateTime, DateTime.now());

  static bool isYesterday(DateTime dateTime) =>
      isSameDay(dateTime, DateTime.now().subtract(const Duration(days: 1)));

  /// "09:00" or "09:00:00" -> "9:00 AM". Returns the input if unparseable.
  // TODO(logic): drop once ScheduleEntity exposes TimeOfDay.
  static String formatTimeString(String? value) {
    if (value == null || value.isEmpty) return '--:--';
    final parts = value.split(':');
    final hour = parts.length >= 2 ? int.tryParse(parts[0]) : null;
    final minute = parts.length >= 2 ? int.tryParse(parts[1]) : null;
    if (hour == null || minute == null) return value;
    return formatTimeOfDay(TimeOfDay(hour: hour, minute: minute));
  }

  /// "12 Oct – 30 Nov", or "From 12 Oct" with no end date.
  /// Adds the year when a date is outside the current year.
  // TODO(logic): drop once ScheduleEntity exposes DateTime.
  static String formatDateRange(String start, String? end) {
    final hasEnd = end != null && end.isNotEmpty;
    final from = DateTime.tryParse(start);
    final to = hasEnd ? DateTime.tryParse(end) : null;
    if (from == null) return hasEnd ? '$start – $end' : start;
    final year = DateTime.now().year;
    final withYear = from.year != year || (to != null && to.year != year);
    final fmt = DateFormat(withYear ? 'd MMM yyyy' : 'd MMM');
    return to == null
        ? 'From ${fmt.format(from)}'
        : '${fmt.format(from)} – ${fmt.format(to)}';
  }
}
