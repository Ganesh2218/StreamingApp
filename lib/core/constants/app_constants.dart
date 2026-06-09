/// App-wide constants for LiveHub streaming platform
class AppConstants {
  AppConstants._();

  // ─── App Info ───────────────────────────────────────────────
  static const String appName = 'LiveHub';
  static const String appVersion = '1.0.0';
  static const String packageName = 'com.livehub';

  // ─── Agora ──────────────────────────────────────────────────
  /// Replace with your actual Agora App ID from console.agora.io
  static const String agoraAppId = '70fcbedcbdc24418b24636289d80bbf2';

  /// Set to empty string '' to disable token auth (testing only).
  /// In production always use a token server.
  static const String agoraToken = '';

  // ─── Storage Keys ────────────────────────────────────────────
  static const String keyUser = 'livehub_user';
  static const String keyStreams = 'livehub_streams';
  static const String keyThemeMode = 'livehub_theme_mode';
  static const String keyStreamConfigs = 'livehub_stream_configs';

  // ─── Route Names ────────────────────────────────────────────
  static const String routeSplash = '/';
  static const String routeAuth = '/auth';
  static const String routeHome = '/home';
  static const String routeCreateLive = '/create-live';
  static const String routeHostLive = '/host-live';
  static const String routeAudienceLive = '/audience-live';

  // ─── UI ──────────────────────────────────────────────────────
  static const double borderRadiusSm = 8.0;
  static const double borderRadiusMd = 12.0;
  static const double borderRadiusLg = 20.0;
  static const double borderRadiusXl = 32.0;

  static const Duration animDurationFast = Duration(milliseconds: 200);
  static const Duration animDurationMed = Duration(milliseconds: 350);
  static const Duration animDurationSlow = Duration(milliseconds: 600);

  // ─── Stream Defaults ─────────────────────────────────────────
  static const int defaultVideoWidth = 1280;
  static const int defaultVideoHeight = 720;
  static const int defaultFrameRate = 30;
  static const int defaultBitrate = 3000; // kbps

  // ─── RTMP Presets ────────────────────────────────────────────
  static const String youtubeLiveRtmpBase = 'rtmp://a.rtmp.youtube.com/live2/';
  static const String facebookLiveRtmpBase =
      'rtmps://live-api-s.facebook.com:443/rtmp/';
}
