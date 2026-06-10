import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../core/services/agora_service.dart';
import '../../core/utils/permission_utils.dart';
import '../../data/models/stream_model.dart';
import '../../core/utils/app_utils.dart';

/// Drives the host screen: starting/ending the live stream, RTMP push,
/// and camera/mic controls.
class HostLiveController extends GetxController {
  late final AgoraService _agora;

  StreamModel? stream;

  final streamStatus = StreamStatus.offline.obs;
  final isStarted = false.obs;
  final showControls = true.obs;
  final viewerCount = 0.obs;
  final networkQuality = 0.obs;
  final rtmpStatusText = ''.obs;
  final errorMessage = ''.obs;
  final elapsedDisplay = '00:00'.obs;

  RxBool get localVideoEnabled => _agora.localVideoEnabled;
  RxBool get localAudioEnabled => _agora.localAudioEnabled;
  RxBool get isFrontCamera => _agora.isFrontCamera;
  AgoraConnectionStatus get connectionStatus => _agora.connectionStatus.value;
  RtmpPushStatus get rtmpPushStatus => _agora.rtmpStatus.value;
  AgoraService get agora => _agora;

  final _timer = StopWatchTimer(mode: StopWatchMode.countUp);
  Timer? _controlsTimer;

  @override
  void onInit() {
    super.onInit();
    _agora = Get.find<AgoraService>();
    stream = Get.arguments as StreamModel?;

    ever(_agora.viewerCount, (v) => viewerCount.value = v);
    ever(_agora.networkQuality, (q) => networkQuality.value = q);
    ever(_agora.rtmpStatus, (s) => _onRtmpStatus(s));
    ever(_agora.connectionStatus, (s) => _onConnectionStatus(s));

    _timer.rawTime.listen((ms) {
      elapsedDisplay.value = AppUtils.formatDuration(ms ~/ 1000);
    });
  }

  /// Requests permissions and joins the channel as the host.
  Future<void> startLive() async {
    if (stream == null) return;

    final hasPermissions = await PermissionUtils.requestCameraAndMic();
    if (!hasPermissions) return;

    streamStatus.value = StreamStatus.connecting;
    isStarted.value = true;
    WakelockPlus.enable();

    try {
      await _agora.joinAsBroadcaster(stream!.channelName);
      _startControlsTimer();
    } catch (e) {
      streamStatus.value = StreamStatus.offline;
      isStarted.value = false;
      _showError('Failed to start stream: $e');
    }
  }

  /// Confirms, stops RTMP, leaves the channel, and exits the screen.
  Future<void> endLive() async {
    if (!isStarted.value) {
      Get.back();
      return;
    }

    final confirm = await Get.dialog<bool>(
      _EndLiveDialog(),
      barrierDismissible: false,
    );
    if (confirm != true) return;

    if (stream?.fullRtmpUrl.isNotEmpty == true) {
      await _agora.stopRtmpPush(stream!.fullRtmpUrl);
    }

    await _agora.leaveChannel();
    _timer.onStopTimer();
    _timer.onResetTimer();
    WakelockPlus.disable();
    _controlsTimer?.cancel();
    streamStatus.value = StreamStatus.ended;
    isStarted.value = false;

    await Future.delayed(const Duration(milliseconds: 800));
    Get.back();
  }

  /// Starts RTMP restreaming if the host configured an RTMP URL + key.
  Future<void> _startRtmpIfConfigured() async {
    final url = stream?.fullRtmpUrl ?? '';
    if (url.isEmpty) return;

    if (!AppUtils.isValidRtmpUrl(url)) {
      _showError('Invalid RTMP URL: $url');
      return;
    }
    streamStatus.value = StreamStatus.rtmpConnecting;
    await _agora.startRtmpPush(url);
  }

  Future<void> toggleCamera() => _agora.toggleCamera();
  Future<void> toggleMic() => _agora.toggleMic();
  Future<void> switchCamera() => _agora.switchCamera();

  void onScreenTap() {
    showControls.value = true;
    _resetControlsTimer();
  }

  void _startControlsTimer() {
    _controlsTimer = Timer(const Duration(seconds: 4), () {
      showControls.value = false;
    });
  }

  void _resetControlsTimer() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 4), () {
      showControls.value = false;
    });
  }

  void shareStream() {
    if (stream == null) return;
    final msg =
        '🔴 Watching "${stream!.title}" LIVE on LiveHub!\nJoin channel: ${stream!.channelName}';
    Get.snackbar('Share Stream', msg, snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4));
  }

  void _onConnectionStatus(AgoraConnectionStatus s) {
    switch (s) {
      case AgoraConnectionStatus.connecting:
        streamStatus.value = StreamStatus.connecting;
        break;
      case AgoraConnectionStatus.connected:
        streamStatus.value = StreamStatus.live;
        _timer.onStartTimer();
        // Once Agora is live, push to the external RTMP platform.
        _startRtmpIfConfigured();
        break;
      case AgoraConnectionStatus.reconnecting:
        streamStatus.value = StreamStatus.connecting;
        break;
      case AgoraConnectionStatus.failed:
        streamStatus.value = StreamStatus.offline;
        _showError('Connection failed. Check your network.');
        break;
      default:
        break;
    }
  }

  void _onRtmpStatus(RtmpPushStatus s) {
    switch (s) {
      case RtmpPushStatus.connecting:
        rtmpStatusText.value = 'RTMP Connecting…';
        streamStatus.value = StreamStatus.rtmpConnecting;
        break;
      case RtmpPushStatus.connected:
        rtmpStatusText.value = 'RTMP Connected ✓';
        streamStatus.value = StreamStatus.rtmpConnected;
        break;
      case RtmpPushStatus.failed:
        rtmpStatusText.value = 'RTMP Failed ✗';
        streamStatus.value = StreamStatus.rtmpFailed;
        _showError(
            'RTMP push failed (code ${_agora.rtmpErrorCode.value}). Check your stream key.');
        break;
      case RtmpPushStatus.stopped:
        rtmpStatusText.value = 'RTMP Stopped';
        break;
      default:
        rtmpStatusText.value = '';
    }
  }

  void _showError(String msg) {
    Get.snackbar('⚠ Stream Error', msg,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5));
  }

  @override
  void onClose() {
    _agora.leaveChannel();
    _timer.dispose();
    _controlsTimer?.cancel();
    WakelockPlus.disable();
    super.onClose();
  }
}

/// Confirmation dialog for ending the live stream
class _EndLiveDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('End Stream?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      content: const Text(
        'This will stop your live stream and disconnect all viewers.',
        style: TextStyle(color: Color(0xFFB0B0CC)),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: const Text('Cancel',
              style: TextStyle(color: Color(0xFF6B6B8A))),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF2D55),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () => Get.back(result: true),
          child: const Text('End Live',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}
