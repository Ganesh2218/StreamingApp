import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'core/constants/app_constants.dart';
import 'core/services/agora_service.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'presentation/routes/app_routes.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // ── Boot services in order ───────────────────────────────────
    final storage = StorageService();
    await storage.init();
    Get.put<StorageService>(storage, permanent: true);

    // Pre-warm Agora engine (with error handling for Web safety)
    try {
      final agora = AgoraService();
      await agora.init();
      Get.put<AgoraService>(agora, permanent: true);
    } catch (e) {
      debugPrint('[Main] Agora pre-warm failed: $e');
      // We don't crash the whole app if Agora fails to pre-warm; 
      // the controller can try again later or show an error.
    }

    runApp(const LiveHubApp());
  } catch (e, stack) {
    debugPrint('[Main] Fatal initialization error: $e');
    debugPrint(stack.toString());
    // Fallback app to show the error if everything fails
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(child: Text('Fatal Error: $e')),
      ),
    ));
  }
}

class LiveHubApp extends StatelessWidget {
  const LiveHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = Get.find<StorageService>();
    final initialRoute =
        storage.isLoggedIn ? AppConstants.routeHome : AppConstants.routeAuth;

    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // ── Themes ──────────────────────────────────────────────
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: storage.isDarkMode ? ThemeMode.dark : ThemeMode.light,

      // ── Navigation ──────────────────────────────────────────
      initialRoute: initialRoute,
      getPages: AppRoutes.routes,
      defaultTransition: Transition.fadeIn,

      // ── Localisation (placeholder) ───────────────────────────
      locale: const Locale('en', 'US'),
      fallbackLocale: const Locale('en', 'US'),

      // ── Builder: apply edge-to-edge + safe area ──────────────
      builder: (context, child) {
        return MediaQuery(
          data:
              MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
          child: child!,
        );
      },
    );
  }
}
