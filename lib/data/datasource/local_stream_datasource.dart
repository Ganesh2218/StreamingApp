import '../../core/services/storage_service.dart';
import '../models/stream_model.dart';
import 'package:uuid/uuid.dart';

/// Local datasource that wraps StorageService with mock seed data
class LocalStreamDatasource {
  final StorageService _storage;
  final _uuid = const Uuid();

  LocalStreamDatasource(this._storage);

  List<StreamModel> getAllStreams() {
    var streams = _storage.getActiveStreams();
    if (streams.isEmpty) {
      // Seed demo live streams for the home feed
      streams = _seedStreams();
      _storage.saveActiveStreams(streams);
    }
    return streams;
  }

  StreamModel? getStreamById(String id) {
    return getAllStreams().firstWhereOrNull((s) => s.id == id);
  }

  void saveStream(StreamModel stream) {
    final streams = getAllStreams();
    final idx = streams.indexWhere((s) => s.id == stream.id);
    if (idx >= 0) {
      streams[idx] = stream;
    } else {
      streams.add(stream);
    }
    _storage.saveActiveStreams(streams);
  }

  void deleteStream(String id) {
    final streams = getAllStreams()..removeWhere((s) => s.id == id);
    _storage.saveActiveStreams(streams);
  }

  // ─── Seed Data ───────────────────────────────────────────
  List<StreamModel> _seedStreams() => [
        StreamModel(
          id: _uuid.v4(),
          title: '🎵 Late Night Vibes – Chill Music Session',
          description: 'Join me for some chill beats and good conversations!',
          channelName: 'music-vibes-${_uuid.v4().substring(0, 8)}',
          hostId: 'host-1',
          hostName: 'Alex Rivera',
          status: StreamStatus.live,
          viewerCount: 1247,
          isFeatured: true,
          startedAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        StreamModel(
          id: _uuid.v4(),
          title: '🎮 Fortnite Battle Royale – Road to 100 Wins',
          description: 'Grinding ranked matches. Drops and subs appreciated!',
          channelName: 'gaming-br-${_uuid.v4().substring(0, 8)}',
          hostId: 'host-2',
          hostName: 'ZeroCoolGG',
          status: StreamStatus.live,
          viewerCount: 3892,
          isFeatured: true,
          startedAt: DateTime.now().subtract(const Duration(minutes: 45)),
        ),
        StreamModel(
          id: _uuid.v4(),
          title: '🍳 Cooking Italian from Scratch – Pasta Night',
          description: 'Learning authentic Italian recipes together!',
          channelName: 'kitchen-pasta-${_uuid.v4().substring(0, 8)}',
          hostId: 'host-3',
          hostName: 'Chef Marco',
          status: StreamStatus.live,
          viewerCount: 584,
          startedAt: DateTime.now().subtract(const Duration(minutes: 20)),
        ),
        StreamModel(
          id: _uuid.v4(),
          title: '💪 Morning HIIT Workout – No Equipment Needed',
          description: '45-minute full body burn. All fitness levels welcome.',
          channelName: 'fitness-hiit-${_uuid.v4().substring(0, 8)}',
          hostId: 'host-4',
          hostName: 'FitWithSara',
          status: StreamStatus.live,
          viewerCount: 2103,
          startedAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        StreamModel(
          id: _uuid.v4(),
          title: '🎨 Digital Art – Character Design Process',
          description: 'Drawing original characters with Procreate.',
          channelName: 'art-design-${_uuid.v4().substring(0, 8)}',
          hostId: 'host-5',
          hostName: 'PixelDreamer',
          status: StreamStatus.live,
          viewerCount: 431,
          startedAt: DateTime.now().subtract(const Duration(minutes: 35)),
        ),
        StreamModel(
          id: _uuid.v4(),
          title: '📱 Flutter Dev – Building a Live App LIVE!',
          description: 'Coding session with Q&A. Beginners welcome!',
          channelName: 'flutter-dev-${_uuid.v4().substring(0, 8)}',
          hostId: 'host-6',
          hostName: 'DartDevPro',
          status: StreamStatus.live,
          viewerCount: 892,
          isFeatured: true,
          startedAt: DateTime.now().subtract(const Duration(minutes: 10)),
        ),
      ];
}

// ignore: avoid_classes_with_only_static_members
extension _IterableFirst<T> on List<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final e in this) {
      if (test(e)) return e;
    }
    return null;
  }
}
