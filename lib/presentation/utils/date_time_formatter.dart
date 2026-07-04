// lib/presentation/utils/date_time_formatter.dart
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

  static String toTimeAmPm(String? isoTimestamp) {
    final dt = parseUtcToLocal(isoTimestamp);
    if (dt == null) return '--:--';
    return DateFormat('h:mm a').format(dt);
  }

  static String toFullDateTime(String? isoTimestamp) {
    final dt = parseUtcToLocal(isoTimestamp);
    if (dt == null) return 'N/A';
    return DateFormat('d MMM, h:mm a').format(dt);
  }

  static String formatFullDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    return DateFormat('d MMM, h:mm a').format(dateTime);
  }

  static String toIsoString(DateTime dateTime) {
    return dateTime.toUtc().toIso8601String();
  }
}
