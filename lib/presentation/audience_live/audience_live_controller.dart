import 'package:get/get.dart';
import '../../core/services/agora_service.dart';
import '../../core/services/storage_service.dart';
import '../../data/models/stream_model.dart';

/// Drives the audience screen: joins the host's channel, tracks viewer
/// count, and detects when the stream ends.
class AudienceLiveController extends GetxController {
  late final AgoraService _agora;
  late final StorageService _storage;

  StreamModel? stream;

  final isConnected = false.obs;
  final isFullscreen = false.obs;
  final showControls = true.obs;
  final chatMessages = <_ChatMessage>[].obs;
  final viewerCount = 0.obs;

  // True once the host has joined and then left, i.e. the stream ended.
  final hasEnded = false.obs;
  bool _hadHost = false;

  AgoraService get agora => _agora;
  RxList<int> get remoteUsers => _agora.remoteUsers;

  @override
  void onInit() {
    super.onInit();
    _agora = Get.find<AgoraService>();
    _storage = Get.find<StorageService>();
    stream = Get.arguments as StreamModel?;

    ever(_agora.viewerCount, (v) => viewerCount.value = v);

    // Watch the host: present means live, gone after present means ended.
    ever(_agora.remoteUsers, (List<int> users) {
      if (users.isNotEmpty) {
        _hadHost = true;
        hasEnded.value = false;
      } else if (_hadHost) {
        hasEnded.value = true;
      }
    });

    _joinChannel();
    _seedChatMessages();
  }

  /// Joins the host's channel as a viewer.
  Future<void> _joinChannel() async {
    if (stream == null) return;
    try {
      await _agora.joinAsAudience(stream!.channelName);
      isConnected.value = true;
    } catch (e) {
      Get.snackbar('Connection Error', 'Could not join stream: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void toggleFullscreen() => isFullscreen.value = !isFullscreen.value;
  void toggleControls() => showControls.value = !showControls.value;

  void sendChatMessage(String text) {
    if (text.trim().isEmpty) return;
    final user = _storage.getUser();
    chatMessages.insert(
      0,
      _ChatMessage(
        userId: user?.id ?? 'me',
        userName: user?.name ?? 'You',
        message: text.trim(),
        timestamp: DateTime.now(),
      ),
    );
  }

  void _seedChatMessages() {
    chatMessages.addAll([
      _ChatMessage(userId: '1', userName: 'JohnDoe', message: '🔥 This is amazing!', timestamp: DateTime.now().subtract(const Duration(seconds: 10))),
      _ChatMessage(userId: '2', userName: 'StreamFan99', message: 'Hello from NYC 👋', timestamp: DateTime.now().subtract(const Duration(seconds: 20))),
      _ChatMessage(userId: '3', userName: 'LiveLover', message: 'First time watching, love it!', timestamp: DateTime.now().subtract(const Duration(seconds: 30))),
      _ChatMessage(userId: '4', userName: 'ProViewer', message: '❤️❤️❤️', timestamp: DateTime.now().subtract(const Duration(seconds: 45))),
      _ChatMessage(userId: '5', userName: 'CoolWatcher', message: 'Quality is perfect 👍', timestamp: DateTime.now().subtract(const Duration(minutes: 1))),
    ]);
  }

  @override
  void onClose() {
    _agora.leaveChannel();
    super.onClose();
  }
}

class _ChatMessage {
  final String userId;
  final String userName;
  final String message;
  final DateTime timestamp;
  _ChatMessage({
    required this.userId,
    required this.userName,
    required this.message,
    required this.timestamp,
  });
}
