import 'package:uuid/uuid.dart';
import '../../domain/repositories/stream_repository.dart';
import '../../data/models/stream_model.dart';
import '../../data/models/user_model.dart';
import '../datasource/local_stream_datasource.dart';

class StreamRepositoryImpl implements StreamRepository {
  final LocalStreamDatasource _local;
  final _uuid = const Uuid();

  StreamRepositoryImpl(this._local);

  @override
  Future<List<StreamModel>> getLiveStreams() async {
    return _local.getAllStreams();
  }

  @override
  Future<StreamModel?> getStreamById(String id) async {
    return _local.getStreamById(id);
  }

  @override
  Future<void> saveStream(StreamModel stream) async {
    _local.saveStream(stream);
  }

  @override
  Future<void> deleteStream(String id) async {
    _local.deleteStream(id);
  }

  @override
  Future<StreamModel> updateStreamStatus(String id, StreamStatus status) async {
    final stream = await getStreamById(id);
    if (stream == null) throw Exception('Stream $id not found');
    final updated = stream.copyWith(
      status: status,
      startedAt: status == StreamStatus.live ? DateTime.now() : stream.startedAt,
      endedAt: status == StreamStatus.ended ? DateTime.now() : stream.endedAt,
    );
    _local.saveStream(updated);
    return updated;
  }

  @override
  Future<void> incrementViewers(String id) async {
    final stream = await getStreamById(id);
    if (stream != null) {
      _local.saveStream(stream.copyWith(viewerCount: stream.viewerCount + 1));
    }
  }

  @override
  Future<void> decrementViewers(String id) async {
    final stream = await getStreamById(id);
    if (stream != null && stream.viewerCount > 0) {
      _local.saveStream(stream.copyWith(viewerCount: stream.viewerCount - 1));
    }
  }
}

class UserRepositoryImpl implements UserRepository {
  final _localUser = <String, UserModel>{};
  UserModel? _currentUser;

  @override
  Future<UserModel?> getCurrentUser() async => _currentUser;

  @override
  Future<void> saveUser(UserModel user) async {
    _currentUser = user;
    _localUser[user.id] = user;
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
  }

  @override
  bool get isLoggedIn => _currentUser != null;
}
