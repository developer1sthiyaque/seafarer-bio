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
    var status = await Permission.photos.status;
    if (status.isGranted) {
      return true;
    }

    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }

    // Otherwise, try to request it
    status = await Permission.photos.request();

    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }
    return status.isGranted;
  }

  /// Open App Settings
  static Future<void> openSettings() async {
    await openAppSettings();
  }
}
