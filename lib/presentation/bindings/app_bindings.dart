import 'package:get/get.dart';
import '../auth/auth_controller.dart';
import '../home/home_controller.dart';
import '../create_live/create_live_controller.dart';
import '../host_live/host_live_controller.dart';
import '../audience_live/audience_live_controller.dart';
import '../../core/services/agora_service.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController());
  }
}

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
  }
}

class CreateLiveBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateLiveController>(() => CreateLiveController());
  }
}

class HostLiveBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AgoraService>()) {
      Get.put<AgoraService>(AgoraService(), permanent: true);
    }
    Get.lazyPut<HostLiveController>(() => HostLiveController());
  }
}

class AudienceLiveBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AgoraService>()) {
      Get.put<AgoraService>(AgoraService(), permanent: true);
    }
    Get.lazyPut<AudienceLiveController>(() => AudienceLiveController());
  }
}
