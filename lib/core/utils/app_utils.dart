import 'package:intl/intl.dart';

class AppUtils {
  AppUtils._();

  static String formatDuration(int totalSeconds) {
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    final s = totalSeconds % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  static String formatViewerCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }

  static bool isValidRtmpUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    return uri.scheme == 'rtmp' || uri.scheme == 'rtmps';
  }

  static bool isValidStreamKey(String key) => key.trim().length >= 4;

  static String buildRtmpUrl(String baseUrl, String streamKey) {
    final base = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
    return '$base$streamKey';
  }

  static String formatTimestamp(DateTime dt) =>
      DateFormat('MMM d, yyyy · h:mm a').format(dt);
}
