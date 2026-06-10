class AppConstants {
  AppConstants._();

  static const String appName = 'LiveHub';
  static const String appVersion = '1.0.0';
  static const String packageName = 'com.livehub';

  /// Agora App ID from console.agora.io.
  static const String agoraAppId = 'd03337784ffe4bac8a1b53646e3153fa';

  /// Temp token bound to [testChannelName], used for testing.
  static const String agoraToken =
      '007eJxTYLjs3Btjym/JFs5m9H9u0sfqt9LZS475xHaen7+4OeNTKYMCQ4qBsbGxubmFSVpaqklSYrJFomGSqbGZiVmqsaGpcVri1w8aWQ2BjAxyU/8zMEIhiM/NUJJaXJKckZiXl5rDwAAAAh4iYQ==';

  /// Fixed channel host and audience join while testing with the temp token.
  static const String testChannelName = 'testchannel';

  /// When true, Create Live pre-fills [testChannelName] instead of a random one.
  static const bool useTestChannel = true;

  static const String keyUser = 'livehub_user';
  static const String keyStreams = 'livehub_streams';
  static const String keyThemeMode = 'livehub_theme_mode';
  static const String keyStreamConfigs = 'livehub_stream_configs';

  static const String routeSplash = '/';
  static const String routeAuth = '/auth';
  static const String routeHome = '/home';
  static const String routeCreateLive = '/create-live';
  static const String routeHostLive = '/host-live';
  static const String routeAudienceLive = '/audience-live';

  static const double borderRadiusSm = 8.0;
  static const double borderRadiusMd = 12.0;
  static const double borderRadiusLg = 20.0;
  static const double borderRadiusXl = 32.0;

  static const Duration animDurationFast = Duration(milliseconds: 200);
  static const Duration animDurationMed = Duration(milliseconds: 350);
  static const Duration animDurationSlow = Duration(milliseconds: 600);

  static const int defaultVideoWidth = 1280;
  static const int defaultVideoHeight = 720;
  static const int defaultFrameRate = 30;
  static const int defaultBitrate = 3000;

  static const String youtubeLiveRtmpBase = 'rtmp://a.rtmp.youtube.com/live2/';
  static const String facebookLiveRtmpBase =
      'rtmps://live-api-s.facebook.com:443/rtmp/';
}
