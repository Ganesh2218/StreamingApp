import '../../data/models/stream_model.dart';
import '../../data/models/user_model.dart';
import '../repositories/stream_repository.dart';

class GetLiveStreamsUseCase {
  final StreamRepository _repo;
  GetLiveStreamsUseCase(this._repo);
  Future<List<StreamModel>> call() => _repo.getLiveStreams();
}

class GetStreamByIdUseCase {
  final StreamRepository _repo;
  GetStreamByIdUseCase(this._repo);
  Future<StreamModel?> call(String id) => _repo.getStreamById(id);
}

class SaveStreamUseCase {
  final StreamRepository _repo;
  SaveStreamUseCase(this._repo);
  Future<void> call(StreamModel stream) => _repo.saveStream(stream);
}

class DeleteStreamUseCase {
  final StreamRepository _repo;
  DeleteStreamUseCase(this._repo);
  Future<void> call(String id) => _repo.deleteStream(id);
}

class UpdateStreamStatusUseCase {
  final StreamRepository _repo;
  UpdateStreamStatusUseCase(this._repo);
  Future<StreamModel> call(String id, StreamStatus status) =>
      _repo.updateStreamStatus(id, status);
}

class IncrementViewersUseCase {
  final StreamRepository _repo;
  IncrementViewersUseCase(this._repo);
  Future<void> call(String id) => _repo.incrementViewers(id);
}

class DecrementViewersUseCase {
  final StreamRepository _repo;
  DecrementViewersUseCase(this._repo);
  Future<void> call(String id) => _repo.decrementViewers(id);
}
