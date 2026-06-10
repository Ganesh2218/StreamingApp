import 'package:get/get.dart';
import '../auth/auth_screen.dart';
import '../home/home_screen.dart';
import '../create_live/create_live_screen.dart';
import '../host_live/host_live_screen.dart';
import '../audience_live/audience_live_screen.dart';
import '../bindings/app_bindings.dart';
import '../../core/constants/app_constants.dart';

class AppRoutes {
  AppRoutes._();

  static final routes = <GetPage>[
    GetPage(
      name: AppConstants.routeAuth,
      page: () => const AuthScreen(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
      transitionDuration: AppConstants.animDurationMed,
    ),
    GetPage(
      name: AppConstants.routeHome,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
      transitionDuration: AppConstants.animDurationMed,
    ),
    GetPage(
      name: AppConstants.routeCreateLive,
      page: () => const CreateLiveScreen(),
      binding: CreateLiveBinding(),
      transition: Transition.downToUp,
      transitionDuration: AppConstants.animDurationMed,
    ),
    GetPage(
      name: AppConstants.routeHostLive,
      page: () => const HostLiveScreen(),
      binding: HostLiveBinding(),
      transition: Transition.zoom,
      transitionDuration: AppConstants.animDurationMed,
    ),
    GetPage(
      name: AppConstants.routeAudienceLive,
      page: () => const AudienceLiveScreen(),
      binding: AudienceLiveBinding(),
      transition: Transition.upToDown,
      transitionDuration: AppConstants.animDurationMed,
    ),
  ];
}
