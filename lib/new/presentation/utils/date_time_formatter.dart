// lib/presentation/utils/date_time_formatter.dart
import 'package:intl/intl.dart';

class DateTimeFormatter {
  DateTimeFormatter._();

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

  /// Format timestamp to "MMM dd, yyyy"
  static String formatDate(DateTime? dateTime) {
    if (dateTime == null) return '-- --- ----';
    return DateFormat('MMM dd, yyyy').format(dateTime);
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

  /// Parse ISO string to DateTime safely
  static DateTime? parseIsoString(String? isoString) {
    if (isoString == null) return null;
    try {
      return DateTime.parse(isoString).toLocal();
    } catch (e) {
      return null;
    }
  }
}
