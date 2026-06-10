import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:get/get.dart';
import '../constants/app_constants.dart';

/// Connection state of the Agora channel.
enum AgoraConnectionStatus {
  idle,
  connecting,
  connected,
  reconnecting,
  failed,
  disconnected,
}

/// State of the RTMP push to an external platform (YouTube, Facebook, etc.).
enum RtmpPushStatus {
  idle,
  connecting,
  connected,
  failed,
  stopped,
}

/// Wraps the Agora engine: joining as host/audience, camera/mic controls,
/// and RTMP restreaming. Exposes reactive state for the UI.
class AgoraService extends GetxService {
  RtcEngine? _engine;
  RtcEngine get engine => _engine!;

  final connectionStatus = AgoraConnectionStatus.idle.obs;
  final rtmpStatus = RtmpPushStatus.idle.obs;
  final rtmpErrorCode = 0.obs;
  final localVideoEnabled = true.obs;
  final localAudioEnabled = true.obs;
  final isFrontCamera = true.obs;
  final remoteUsers = <int>[].obs;
  final networkQuality = 0.obs;
  final viewerCount = 0.obs;
  final isInitialized = false.obs;

  Function(int uid, int elapsed)? onUserJoined;
  Function(int uid, UserOfflineReasonType reason)? onUserOffline;
  Function(RtmpStreamPublishState state, dynamic error)?
      onRtmpStatusChanged;

  /// Creates and initializes the Agora engine. Called once at app start.
  Future<AgoraService> init() async {
    await _createEngine();
    isInitialized.value = true;
    return this;
  }

  Future<void> _createEngine() async {
    _engine = createAgoraRtcEngine();
    await _engine!.initialize(
      RtcEngineContext(
        appId: AppConstants.agoraAppId,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ),
    );
    _registerEventHandlers();
  }

  /// Listens to Agora events and updates the reactive state above.
  void _registerEventHandlers() {
    _engine!.registerEventHandler(
      RtcEngineEventHandler(
        onError: (err, msg) {
          Get.log('[Agora] Error: $err – $msg');
          if (err == ErrorCodeType.errJoinChannelRejected ||
              err == ErrorCodeType.errInvalidToken) {
            connectionStatus.value = AgoraConnectionStatus.failed;
          }
        },
        onConnectionStateChanged: (connection, state, reason) {
          switch (state) {
            case ConnectionStateType.connectionStateConnecting:
              connectionStatus.value = AgoraConnectionStatus.connecting;
              break;
            case ConnectionStateType.connectionStateConnected:
              connectionStatus.value = AgoraConnectionStatus.connected;
              break;
            case ConnectionStateType.connectionStateReconnecting:
              connectionStatus.value = AgoraConnectionStatus.reconnecting;
              break;
            case ConnectionStateType.connectionStateFailed:
              connectionStatus.value = AgoraConnectionStatus.failed;
              break;
            case ConnectionStateType.connectionStateDisconnected:
              connectionStatus.value = AgoraConnectionStatus.disconnected;
              break;
          }
        },
        onJoinChannelSuccess: (connection, elapsed) {
          Get.log('[Agora] Joined channel: ${connection.channelId}');
          connectionStatus.value = AgoraConnectionStatus.connected;
        },
        onLeaveChannel: (connection, stats) {
          Get.log('[Agora] Left channel');
          connectionStatus.value = AgoraConnectionStatus.idle;
          remoteUsers.clear();
          viewerCount.value = 0;
        },
        onUserJoined: (connection, remoteUid, elapsed) {
          Get.log('[Agora] Remote user joined: $remoteUid');
          if (!remoteUsers.contains(remoteUid)) {
            remoteUsers.add(remoteUid);
            viewerCount.value = remoteUsers.length;
          }
          onUserJoined?.call(remoteUid, elapsed);
        },
        onUserOffline: (connection, remoteUid, reason) {
          Get.log('[Agora] Remote user left: $remoteUid');
          remoteUsers.remove(remoteUid);
          viewerCount.value = remoteUsers.length;
          onUserOffline?.call(remoteUid, reason);
        },
        onNetworkQuality: (connection, remoteUid, txQuality, rxQuality) {
          if (remoteUid == 0) {
            networkQuality.value = txQuality.index;
          }
        },
        onRtmpStreamingStateChanged: (url, state, errCode) {
          Get.log('[Agora] RTMP state: $state err: $errCode url: $url');
          switch (state) {
            case RtmpStreamPublishState.rtmpStreamPublishStateConnecting:
              rtmpStatus.value = RtmpPushStatus.connecting;
              break;
            case RtmpStreamPublishState.rtmpStreamPublishStateRunning:
              rtmpStatus.value = RtmpPushStatus.connected;
              break;
            case RtmpStreamPublishState.rtmpStreamPublishStateFailure:
              rtmpStatus.value = RtmpPushStatus.failed;
              rtmpErrorCode.value = errCode.index;
              break;
            case RtmpStreamPublishState.rtmpStreamPublishStateIdle:
              rtmpStatus.value = RtmpPushStatus.idle;
              break;
            default:
              rtmpStatus.value = RtmpPushStatus.idle;
          }
          onRtmpStatusChanged?.call(state, errCode);
        },
      ),
    );
  }

  /// Host joins the channel: publishes camera and mic to viewers.
  Future<void> joinAsBroadcaster(String channelName,
      {String token = ''}) async {
    if (!isInitialized.value) await init();
    connectionStatus.value = AgoraConnectionStatus.connecting;

    await _engine!.enableVideo();
    await _engine!.enableAudio();

    await _engine!.setVideoEncoderConfiguration(
      const VideoEncoderConfiguration(
        dimensions: VideoDimensions(width: 1280, height: 720),
        frameRate: 15,
        bitrate: 0,
      ),
    );

    await _engine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);

    await _engine!.joinChannel(
      token: token.isEmpty ? AppConstants.agoraToken : token,
      channelId: channelName,
      uid: 0,
      options: const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        publishCameraTrack: true,
        publishMicrophoneTrack: true,
      ),
    );

    await _engine!.startPreview();
  }

  /// Audience joins the channel: watches the host without publishing.
  Future<void> joinAsAudience(String channelName,
      {String token = ''}) async {
    if (!isInitialized.value) await init();
    connectionStatus.value = AgoraConnectionStatus.connecting;

    await _engine!.enableVideo();
    await _engine!.setClientRole(role: ClientRoleType.clientRoleAudience);

    await _engine!.joinChannel(
      token: token.isEmpty ? AppConstants.agoraToken : token,
      channelId: channelName,
      uid: 0,
      options: const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleAudience,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        publishCameraTrack: false,
        publishMicrophoneTrack: false,
      ),
    );
  }

  /// Leaves the channel and stops the camera preview.
  Future<void> leaveChannel() async {
    await _engine?.stopPreview();
    await _engine?.leaveChannel();
    connectionStatus.value = AgoraConnectionStatus.idle;
  }

  Future<void> toggleCamera() async {
    localVideoEnabled.value = !localVideoEnabled.value;
    await _engine?.muteLocalVideoStream(!localVideoEnabled.value);
  }

  Future<void> switchCamera() async {
    await _engine?.switchCamera();
    isFrontCamera.value = !isFrontCamera.value;
  }

  Future<void> toggleMic() async {
    localAudioEnabled.value = !localAudioEnabled.value;
    await _engine?.muteLocalAudioStream(!localAudioEnabled.value);
  }

  /// Starts pushing the live stream to an external RTMP URL (needs Media Push).
  Future<void> startRtmpPush(String rtmpUrl) async {
    rtmpStatus.value = RtmpPushStatus.connecting;
    try {
      await _engine?.startRtmpStreamWithoutTranscoding(rtmpUrl);
    } catch (e) {
      Get.log('[Agora] startRtmpPush error: $e');
      rtmpStatus.value = RtmpPushStatus.failed;
    }
  }

  /// Stops the RTMP push to the given URL.
  Future<void> stopRtmpPush(String rtmpUrl) async {
    try {
      await _engine?.stopRtmpStream(rtmpUrl);
      rtmpStatus.value = RtmpPushStatus.stopped;
    } catch (e) {
      Get.log('[Agora] stopRtmpPush error: $e');
    }
  }

  @override
  void onClose() {
    leaveChannel();
    _engine?.release();
    _engine = null;
    super.onClose();
  }
}
