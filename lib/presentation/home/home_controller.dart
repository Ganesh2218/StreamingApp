import 'package:get/get.dart';
import '../../core/services/storage_service.dart';
import '../../data/models/stream_model.dart';
import '../../data/models/user_model.dart';
import '../../data/datasource/local_stream_datasource.dart';
import '../../data/repositories/stream_repository_impl.dart';
import '../../domain/usecases/stream_usecases.dart';
import '../../core/constants/app_constants.dart';

class HomeController extends GetxController {
  late final StorageService _storage;
  late final LocalStreamDatasource _datasource;
  late final StreamRepositoryImpl _repo;
  late final GetLiveStreamsUseCase _getLiveStreams;

  final isLoading = false.obs;
  final allStreams = <StreamModel>[].obs;
  final filteredStreams = <StreamModel>[].obs;
  final searchQuery = ''.obs;
  final currentUser = Rxn<UserModel>();

  @override
  void onInit() {
    super.onInit();
    _storage = Get.find<StorageService>();
    _datasource = LocalStreamDatasource(_storage);
    _repo = StreamRepositoryImpl(_datasource);
    _getLiveStreams = GetLiveStreamsUseCase(_repo);
    currentUser.value = _storage.getUser();
    loadStreams();

    // Filter reactively as searchQuery changes
    debounce(searchQuery, (_) => _applyFilter(),
        time: const Duration(milliseconds: 300));
  }

  Future<void> loadStreams() async {
    isLoading.value = true;
    final streams = await _getLiveStreams();
    allStreams.value = streams;
    _applyFilter();
    isLoading.value = false;
  }

  void onSearchChanged(String query) => searchQuery.value = query;

  void _applyFilter() {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) {
      filteredStreams.value = allStreams;
    } else {
      filteredStreams.value = allStreams.where((s) {
        return s.title.toLowerCase().contains(q) ||
            s.hostName.toLowerCase().contains(q) ||
            s.description.toLowerCase().contains(q);
      }).toList();
    }
  }

  bool get isHost => currentUser.value?.isHost ?? false;

  List<StreamModel> get featuredStreams =>
      allStreams.where((s) => s.isFeatured && s.isLive).toList();

  void navigateToCreateLive() {
    Get.toNamed(AppConstants.routeCreateLive);
  }

  void navigateToAudienceLive(StreamModel stream) {
    Get.toNamed(AppConstants.routeAudienceLive, arguments: stream);
  }

  Future<void> logout() async {
    await _storage.clearUser();
    Get.offAllNamed(AppConstants.routeAuth);
  }
}
