import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/live_badge.dart';
import '../../core/widgets/viewer_count_widget.dart';
import 'audience_live_controller.dart';

class AudienceLiveScreen extends GetView<AudienceLiveController> {
  const AudienceLiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    final chatCtrl = TextEditingController();

    return WillPopScope(
      onWillPop: () async {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            _RemoteVideoView(controller: controller),

            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppTheme.videoControlsGradient,
                ),
              ),
            ),

            _TopBar(controller: controller),

            _RightReactions(),

            _BottomSection(controller: controller, chatCtrl: chatCtrl),
          ],
        ),
      ),
    );
  }
}

class _RemoteVideoView extends StatelessWidget {
  final AudienceLiveController controller;
  const _RemoteVideoView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.agora.isInitialized.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        );
      }

      final users = controller.remoteUsers;
      if (users.isEmpty) {
        return _WaitingView(
          stream: controller.stream,
          hasEnded: controller.hasEnded.value,
        );
      }
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: controller.agora.engine,
          canvas: VideoCanvas(uid: users.first),
          connection: RtcConnection(
            channelId: controller.stream?.channelName ?? '',
          ),
        ),
      );
    });
  }
}

class _WaitingView extends StatelessWidget {
  final dynamic stream;
  final bool hasEnded;
  const _WaitingView({required this.stream, this.hasEnded = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.darkBg,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        if (hasEnded)
          const Icon(Icons.live_tv_rounded,
              color: AppTheme.textSecondary, size: 56)
        else
          const SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
                color: AppTheme.primaryColor, strokeWidth: 2),
          ),
        const SizedBox(height: 20),
        Text(stream?.hostName ?? 'Host',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text(
            hasEnded
                ? 'Stream has ended'
                : 'Waiting for stream to start…',
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 14)),
        if (hasEnded) ...[
          const SizedBox(height: 24),
          TextButton(
            onPressed: Get.back,
            child: const Text('Close',
                style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ]),
    );
  }
}

class _TopBar extends StatelessWidget {
  final AudienceLiveController controller;
  const _TopBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      left: 16,
      right: 16,
      child: Row(
        children: [
          Flexible(
            flex: 3,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 120),
              child: Row(children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: AppTheme.purpleGradient,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.primaryColor, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  controller.stream?.hostName.isNotEmpty == true
                      ? controller.stream!.hostName[0].toUpperCase()
                      : 'H',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      controller.stream?.hostName ?? 'Host',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13),
                    ),
                    const LiveBadge(compact: true),
                  ],
                ),
              ),
            ]),
          ),
        ),
        const Spacer(),
          Obx(() => ViewerCountWidget(
              count: controller.viewerCount.value, compact: true)),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: Get.back,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms),
    );
  }
}

class _RightReactions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final gifts = ['🎁', '❤️', '🔥', '👏', '💎'];
    return Positioned(
      right: 12,
      bottom: 120,
      child: Column(
        children: gifts
            .map((emoji) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withOpacity(0.2), width: 0.5),
                      ),
                      alignment: Alignment.center,
                      child: Text(emoji, style: const TextStyle(fontSize: 20)),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _BottomSection extends StatelessWidget {
  final AudienceLiveController controller;
  final TextEditingController chatCtrl;
  const _BottomSection(
      {required this.controller, required this.chatCtrl});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.transparent, Colors.black87],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 200,
              child: Obx(() => ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    reverse: true,
                    itemCount: controller.chatMessages.length,
                    itemBuilder: (_, i) {
                      final msg = controller.chatMessages[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                gradient: AppTheme.purpleGradient,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                msg.userName.isNotEmpty
                                    ? msg.userName[0].toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.55),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: RichText(
                                  text: TextSpan(children: [
                                    TextSpan(
                                      text: '${msg.userName}  ',
                                      style: TextStyle(
                                          color: AppTheme.accentColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    TextSpan(
                                      text: msg.message,
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 13),
                                    ),
                                  ]),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.05);
                    },
                  )),
            ),

            Padding(
              padding: EdgeInsets.fromLTRB(
                  16, 8, 16, MediaQuery.of(context).padding.bottom + 16),
              child: Row(children: [
                Expanded(
                  child: TextField(
                    controller: chatCtrl,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Say something…',
                      hintStyle: const TextStyle(
                          color: Color(0xFF6B6B8A), fontSize: 13),
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.6),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (v) {
                      controller.sendChatMessage(v);
                      chatCtrl.clear();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    controller.sendChatMessage(chatCtrl.text);
                    chatCtrl.clear();
                  },
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send_rounded,
                        color: Colors.white, size: 18),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
