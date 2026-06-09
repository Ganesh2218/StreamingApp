import '../../data/models/stream_model.dart';
import '../../data/models/user_model.dart';

/// Abstract repository contract – domain depends on this, not on data impl
abstract class StreamRepository {
  /// Fetch all currently live streams
  Future<List<StreamModel>> getLiveStreams();

  /// Get a single stream by ID
  Future<StreamModel?> getStreamById(String id);

  /// Persist a new or updated stream config
  Future<void> saveStream(StreamModel stream);

  /// Remove a stream config
  Future<void> deleteStream(String id);

  /// Update stream live status
  Future<StreamModel> updateStreamStatus(String id, StreamStatus status);

  /// Increment viewer count
  Future<void> incrementViewers(String id);

  /// Decrement viewer count
  Future<void> decrementViewers(String id);
}

/// Abstract repository contract for user operations
abstract class UserRepository {
  Future<UserModel?> getCurrentUser();
  Future<void> saveUser(UserModel user);
  Future<void> logout();
  bool get isLoggedIn;
}
