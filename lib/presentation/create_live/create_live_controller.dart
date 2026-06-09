import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/models/stream_model.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/storage_service.dart';
import '../../core/utils/app_utils.dart';
import 'package:uuid/uuid.dart';

class CreateLiveController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();

  final titleController = TextEditingController();
  final descController = TextEditingController();
  final channelController = TextEditingController();
  final rtmpUrlController = TextEditingController();
  final streamKeyController = TextEditingController();

  final selectedPlatform = StreamPlatform.youtube.obs;
  final isLoading = false.obs;
  final showStreamKey = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Auto-fill RTMP URL when platform changes
    ever(selectedPlatform, (p) {
      switch (p) {
        case StreamPlatform.youtube:
          rtmpUrlController.text = AppConstants.youtubeLiveRtmpBase;
          break;
        case StreamPlatform.facebook:
          rtmpUrlController.text = AppConstants.facebookLiveRtmpBase;
          break;
        case StreamPlatform.custom:
          rtmpUrlController.text = '';
          break;
      }
    });
    rtmpUrlController.text = AppConstants.youtubeLiveRtmpBase;
    // Auto-generate a channel name
    channelController.text = 'livehub-${const Uuid().v4().substring(0, 8)}';
  }

  void selectPlatform(StreamPlatform p) => selectedPlatform.value = p;
  void toggleShowKey() => showStreamKey.value = !showStreamKey.value;

  Future<void> startLive(GlobalKey<FormState> formKey) async {
    if (!formKey.currentState!.validate()) return;

    final rtmpUrl = rtmpUrlController.text.trim();
    final streamKey = streamKeyController.text.trim();

    if (rtmpUrl.isNotEmpty && !AppUtils.isValidRtmpUrl(rtmpUrl)) {
      Get.snackbar('Invalid RTMP URL',
          'URL must start with rtmp:// or rtmps://',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 600));

    final user = _storage.getUser();
    final stream = StreamModel(
      id: const Uuid().v4(),
      title: titleController.text.trim(),
      description: descController.text.trim(),
      channelName: channelController.text.trim(),
      rtmpServerUrl: rtmpUrl,
      streamKey: streamKey,
      platform: selectedPlatform.value,
      hostId: user?.id ?? 'guest',
      hostName: user?.name ?? 'Host',
      status: StreamStatus.connecting,
    );

    await _storage.saveStreamConfig(stream);
    isLoading.value = false;
    Get.toNamed(AppConstants.routeHostLive, arguments: stream);
  }

  @override
  void onClose() {
    titleController.dispose();
    descController.dispose();
    channelController.dispose();
    rtmpUrlController.dispose();
    streamKeyController.dispose();
    super.onClose();
  }
}
