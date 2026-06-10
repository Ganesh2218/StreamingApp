import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';

class PermissionUtils {
  PermissionUtils._();

  static Future<bool> requestCameraAndMic() async {
    if (kIsWeb) return true;

    final statuses = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    final cameraOk = statuses[Permission.camera]?.isGranted ?? false;
    final micOk = statuses[Permission.microphone]?.isGranted ?? false;

    if (!cameraOk) {
      _showDeniedSnack(
        'Camera Permission Denied',
        'LiveHub needs camera access to broadcast your stream.',
      );
      return false;
    }
    if (!micOk) {
      _showDeniedSnack(
        'Microphone Permission Denied',
        'LiveHub needs microphone access to broadcast audio.',
      );
      return false;
    }
    return true;
  }

  static Future<bool> requestMicrophone() async {
    if (kIsWeb) return true;
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      _showDeniedSnack(
        'Microphone Permission Denied',
        'Grant microphone access to participate in streams.',
      );
      return false;
    }
    return true;
  }

  static Future<void> openSettings() => openAppSettings();

  static void _showDeniedSnack(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
      mainButton: TextButton(
        onPressed: openSettings,
        child: const Text('Settings', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
