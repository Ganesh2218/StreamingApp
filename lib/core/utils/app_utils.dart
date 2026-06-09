import 'package:intl/intl.dart';

/// General formatting utilities
class AppUtils {
  AppUtils._();

  /// Format raw seconds into HH:MM:SS or MM:SS
  static String formatDuration(int totalSeconds) {
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    final s = totalSeconds % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  /// Compact number format: 1400 → 1.4K, 1_200_000 → 1.2M
  static String formatViewerCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }

  /// Validate an RTMP URL format
  static bool isValidRtmpUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    return uri.scheme == 'rtmp' || uri.scheme == 'rtmps';
  }

  /// Validate that a stream key is non-empty
  static bool isValidStreamKey(String key) => key.trim().length >= 4;

  /// Build a full RTMP push URL from base + stream key
  static String buildRtmpUrl(String baseUrl, String streamKey) {
    final base = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
    return '$base$streamKey';
  }

  /// Return a human-readable timestamp
  static String formatTimestamp(DateTime dt) =>
      DateFormat('MMM d, yyyy · h:mm a').format(dt);
}
