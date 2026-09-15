import 'package:finalproject/models/waterloop.dart';

extension WaterLoopStatus on WaterLoop {
  static const onlineTimeout = Duration(seconds: 8);

  bool get isOnline {
    final readingTime = lastSeen;
    if (status != 'online' || readingTime == null) return false;
    return DateTime.now().difference(readingTime) <= onlineTimeout;
  }

  String get connectionLabel => isOnline ? 'Online' : 'Offline';

  String get lastReadingLabel {
    final readingTime = lastSeen;
    if (readingTime == null) return 'No readings yet';

    final elapsed = DateTime.now().difference(readingTime);
    if (elapsed.inSeconds < 10) return 'Last reading: just now';
    if (elapsed.inMinutes < 1) {
      return 'Last reading: ${elapsed.inSeconds}s ago';
    }
    if (elapsed.inHours < 1) {
      return 'Last reading: ${elapsed.inMinutes}m ago';
    }
    if (elapsed.inDays < 1) {
      return 'Last reading: ${elapsed.inHours}h ago';
    }

    final day = readingTime.day.toString().padLeft(2, '0');
    final month = readingTime.month.toString().padLeft(2, '0');
    final hour = readingTime.hour.toString().padLeft(2, '0');
    final minute = readingTime.minute.toString().padLeft(2, '0');
    return 'Last reading: $day/$month/${readingTime.year} $hour:$minute';
  }
}
