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
    if (await Permission.photos.isGranted) {
      return true;
    }

    final status = await Permission.photos.request();
    return status.isGranted;
  }

  /// Open App Settings
  static Future<void> openSettings() async {
    await openAppSettings();
  }
}
