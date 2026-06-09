/// Agora engine configuration helpers
/// ─────────────────────────────────────────────────────────────────────
/// HOW TO CONFIGURE:
///  1. Go to https://console.agora.io and create a project.
///  2. Copy the App ID and paste it into AppConstants.agoraAppId.
///  3. For token-based auth, deploy a token server and update
///     AgoraConfig.tokenServerUrl.
///  4. For RTMP/CDN restreaming, enable Media Push in your Agora project
///     console (Project Settings → Extensions → Media Push).
/// ─────────────────────────────────────────────────────────────────────
class AgoraConfig {
  AgoraConfig._();

  /// Token-server base URL (replace with your own)
  /// e.g. 'https://yourserver.com/rtc'
  static const String tokenServerUrl = '';

  /// Channel profile – live broadcasting (0 = communication, 1 = live)
  static const int channelProfile = 1;

  /// Client role – broadcaster = 1, audience = 2
  static const int roleBroadcaster = 1;
  static const int roleAudience = 2;

  /// Audience latency level
  /// 1 = Low latency (interactive), 2 = Ultra-low latency
  static const int audienceLatencyLevel = 1;

  /// Video dimensions
  static const int videoWidth = 1280;
  static const int videoHeight = 720;
  static const int frameRate = 15;
  static const int bitrate = 0; // 0 = standard for selected profile

  /// Remote user timeout (seconds) before considering disconnected
  static const int remoteUserTimeout = 30;
}
