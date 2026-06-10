import 'package:get/get.dart';
import '../../core/services/storage_service.dart';
import '../../data/models/user_model.dart';
import '../../core/constants/app_constants.dart';

class AuthController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();

  final isLoading = false.obs;
  final selectedRole = UserRole.audience.obs;
  final nameController = ''.obs;
  final emailController = ''.obs;

  void selectRole(UserRole role) => selectedRole.value = role;

  Future<void> login(String name, String email) async {
    if (name.trim().isEmpty || email.trim().isEmpty) {
      Get.snackbar('Validation Error', 'Please enter your name and email.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 800));
    final user = UserModel(
      id: 'user-${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      email: email.trim().toLowerCase(),
      role: selectedRole.value,
      createdAt: DateTime.now(),
    );
    await _storage.saveUser(user);
    isLoading.value = false;
    Get.offAllNamed(AppConstants.routeHome);
  }

  Future<void> logout() async {
    await _storage.clearUser();
    Get.offAllNamed(AppConstants.routeAuth);
  }
}
