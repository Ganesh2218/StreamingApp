import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
// import '../../core/constants/app_constants.dart';
import '../../core/widgets/live_badge.dart';
import '../../core/widgets/viewer_count_widget.dart';
import '../../core/widgets/network_quality_widget.dart';
import '../../core/widgets/streaming_timer.dart';
import '../../data/models/stream_model.dart';
import '../../core/services/agora_service.dart';
import 'host_live_controller.dart';

/// TikTok-style Host Live Screen with full camera preview and floating controls.
class HostLiveScreen extends GetView<HostLiveController> {
  const HostLiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Edge-to-edge UI
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    return WillPopScope(
      onWillPop: () async {
        controller.endLive();
        return false;
      },
      child: GestureDetector(
        onTap: () => controller.onScreenTap(),
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Full-screen Camera View
              const _LocalCameraView(),

              // 2. Multi-layered gradient overlay for text readability
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.5),
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                      stops: const [0.0, 0.2, 0.7, 1.0],
                    ),
                  ),
                ),
              ),

              // 3. UI Overlays (Toggleable)
              Obx(() => AnimatedOpacity(
                    opacity: controller.showControls.value ? 1.0 : 0.0,
                    duration: AppTheme.animDurationFast,
                    child: IgnorePointer(
                      ignoring: !controller.showControls.value,
                      child: const _TopOverlay(),
                    ),
                  )),

              Obx(() => AnimatedOpacity(
                    opacity: controller.showControls.value ? 1.0 : 0.0,
                    duration: AppTheme.animDurationFast,
                    child: IgnorePointer(
                      ignoring: !controller.showControls.value,
                      child: const _RightControls(),
                    ),
                  )),

              Obx(() => AnimatedOpacity(
                    opacity: controller.showControls.value ? 1.0 : 0.0,
                    duration: AppTheme.animDurationFast,
                    child: IgnorePointer(
                      ignoring: !controller.showControls.value,
                      child: const _BottomControls(),
                    ),
                  )),

              // 4. Loading indicator / Placeholder
              Obx(() => controller.streamStatus.value == StreamStatus.offline && !controller.isStarted.value
                  ? Positioned.fill(
                      child: Container(
                        color: Colors.black87,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(color: AppTheme.primaryColor),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => controller.startLive(),
                                child: const Text('Start Stream'),
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink()),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocalCameraView extends GetView<HostLiveController> {
  const _LocalCameraView();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.agora.isInitialized.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        );
      }

      if (!controller.localVideoEnabled.value) {
        return const _PreviewPlaceholder();
      }

      return AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: controller.agora.engine,
          canvas: const VideoCanvas(uid: 0),
        ),
      );
    });
  }
}

class _PreviewPlaceholder extends GetView<HostLiveController> {
  const _PreviewPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.darkBg,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.darkCard,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  blurRadius: 40,
                  spreadRadius: 10,
                )
              ],
            ),
            child: Icon(
              Icons.videocam_off_rounded,
              color: Colors.white.withOpacity(0.2),
              size: 64,
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
              begin: const Offset(1, 1),
              end: const Offset(1.05, 1.05),
              duration: const Duration(seconds: 1, milliseconds: 500)),
          const SizedBox(height: 24),
          const Text(
            'Camera is Blocked',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Enable your camera to start streaming',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () => controller.toggleCamera(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: const Text(
                'Turn On Camera',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Leave Stream',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          )
        ],
      ),
    );
  }
}

class _TopOverlay extends GetView<HostLiveController> {
  const _TopOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 16,
      right: 16,
      child: Row(
        children: [
          // Stream Info / Timer
          const LiveBadge(),
          const SizedBox(width: 8),
          Obx(() => StreamingTimer(elapsed: controller.elapsedDisplay.value)),

          const Spacer(),

          // Stats
          Obx(() => ViewerCountWidget(count: controller.viewerCount.value)),
          const SizedBox(width: 8),
          Obx(() => NetworkQualityWidget(quality: controller.networkQuality.value)),

          const SizedBox(width: 12),

          // Close button
          GestureDetector(
            onTap: () => controller.endLive(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.black38,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RightControls extends GetView<HostLiveController> {
  const _RightControls();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 250, // Floating above the bottom info
      child: Column(
        children: [
          _CircleControl(
            icon: Icons.flip_camera_android_rounded,
            label: 'Flip',
            onTap: () => controller.switchCamera(),
          ),
          const SizedBox(height: 20),
          Obx(() => _CircleControl(
                icon: controller.localVideoEnabled.value
                    ? Icons.videocam_rounded
                    : Icons.videocam_off_rounded,
                label: 'Video',
                active: controller.localVideoEnabled.value,
                onTap: () => controller.toggleCamera(),
              )),
          const SizedBox(height: 20),
          Obx(() => _CircleControl(
                icon: controller.localAudioEnabled.value
                    ? Icons.mic_rounded
                    : Icons.mic_off_rounded,
                label: 'Mic',
                active: controller.localAudioEnabled.value,
                onTap: () => controller.toggleMic(),
              )),
          const SizedBox(height: 20),
          _CircleControl(
            icon: Icons.share_rounded,
            label: 'Share',
            onTap: () => controller.shareStream(),
          ),
        ],
      ),
    );
  }
}

class _BottomControls extends GetView<HostLiveController> {
  const _BottomControls();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Column(
        children: [
          // 1. RTMP Status Chip
          Obx(() => _RtmpStatusChip(
                status: controller.rtmpPushStatus,
                platform: controller.stream?.platform.name.capitalizeFirst ?? 'Stream',
              )),
          const SizedBox(height: 12),

          // 2. Stream Details + End Button
          Container(
            padding: EdgeInsets.fromLTRB(
              16,
              20,
              16,
              MediaQuery.of(context).padding.bottom + 16,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        controller.stream?.title ?? 'Live Stream',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        controller.stream?.description ??
                            'Broadcasting to the world...',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () => controller.endLive(),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.liveRedColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.liveRedColor.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: const Text(
                      'END LIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleControl extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  const _CircleControl({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: active
                  ? Colors.white.withOpacity(0.15)
                  : AppTheme.liveRedColor.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: active
                    ? Colors.white.withOpacity(0.3)
                    : AppTheme.liveRedColor.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _RtmpStatusChip extends StatelessWidget {
  final RtmpPushStatus status;
  final String platform;

  const _RtmpStatusChip({required this.status, required this.platform});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;

    switch (status) {
      case RtmpPushStatus.connecting:
        color = AppTheme.warningColor;
        text = 'Connecting to $platform...';
        break;
      case RtmpPushStatus.connected:
        color = AppTheme.successColor;
        text = '$platform Connected ✓';
        break;
      case RtmpPushStatus.failed:
        color = AppTheme.liveRedColor;
        text = '$platform Failed ✗';
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
