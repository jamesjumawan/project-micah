import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  String toFormattedDate([String format = 'MMM dd, yyyy']) {
    return DateFormat(format).format(this);
  }

  String toFormattedTime([String format = 'hh:mm a']) {
    return DateFormat(format).format(this);
  }

  String toFormattedDateTime([String format = 'MMM dd, yyyy hh:mm a']) {
    return DateFormat(format).format(this);
  }

  bool isToday() {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool isYesterday() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  bool isTomorrow() {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  String toRelativeTime() {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return toFormattedDate();
    }
  }
}

extension NullableDateTimeExtensions on DateTime? {
  String toFormattedDateOrEmpty([String format = 'MMM dd, yyyy']) {
    return this?.toFormattedDate(format) ?? '';
  }
}
