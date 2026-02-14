import 'dart:developer';

import 'package:permission_handler/permission_handler.dart';

class AppPermissionService {
  /// Storage Permission (Mainly for Android)
  static Future<bool> requestStoragePermission() async {
    if (await Permission.storage.isGranted) {
      return true;
    }

    final status = await Permission.storage.request();
    return status.isGranted;
  }

  /// Photos (If you ever save to gallery)
  static Future<bool> requestPhotosPermission() async {
    var status = await Permission.storage.status;
    log("STATUS1: ${status.name}");

    if (status.isDenied) {
      status = await Permission.storage.request();
      log("STATUS2: ${status.name}");
    }


    return status.isGranted;
  }


  /// Open App Settings
  static Future<void> openSettings() async {
    await openAppSettings();
  }
}
