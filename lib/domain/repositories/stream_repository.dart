import '../../data/models/stream_model.dart';
import '../../data/models/user_model.dart';

abstract class StreamRepository {
  Future<List<StreamModel>> getLiveStreams();

  Future<StreamModel?> getStreamById(String id);

  Future<void> saveStream(StreamModel stream);

  Future<void> deleteStream(String id);

  Future<StreamModel> updateStreamStatus(String id, StreamStatus status);

  Future<void> incrementViewers(String id);

  Future<void> decrementViewers(String id);
}

abstract class UserRepository {
  Future<UserModel?> getCurrentUser();
  Future<void> saveUser(UserModel user);
  Future<void> logout();
  bool get isLoggedIn;
}
