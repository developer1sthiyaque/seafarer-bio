import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Mocks for the platform boundaries the export flow crosses, so no test ever
/// writes to a real user directory, asks for a real permission, or hands a file
/// to the OS to open.

const MethodChannel _pathProviderChannel =
    MethodChannel('plugins.flutter.io/path_provider');
const MethodChannel _openFileChannel = MethodChannel('open_file');
const MethodChannel _permissionHandlerChannel =
    MethodChannel('flutter.baseflow.com/permissions/methods');
const MethodChannel _imagePickerChannel =
    MethodChannel('plugins.flutter.io/image_picker');

TestDefaultBinaryMessenger get _messenger =>
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

/// Records every platform call intercepted, so tests can assert that a flow was
/// actually triggered rather than guessing from UI side effects.
class PlatformCallLog {
  final List<MethodCall> calls = <MethodCall>[];

  List<String> get methodNames => calls.map((c) => c.method).toList();

  bool contains(String method) => methodNames.contains(method);

  void clear() => calls.clear();
}

/// Points `path_provider` at a throwaway directory.
///
/// Returns the log of intercepted calls. Pass [failWith] to simulate the
/// platform refusing — useful to prove a flow *started* without letting it run
/// on to writing a file and opening it.
PlatformCallLog mockPathProvider(Directory directory, {Object? failWith}) {
  final log = PlatformCallLog();
  _messenger.setMockMethodCallHandler(_pathProviderChannel, (call) async {
    log.calls.add(call);
    if (failWith != null) throw failWith;
    return directory.path;
  });
  return log;
}

/// Stubs `open_filex` so nothing is handed to the host OS.
///
/// Note: `OpenFilex.open` only uses this channel on iOS/Android; on desktop
/// hosts it shells out via `Process.start`. Tests therefore must not let a
/// successful save reach the open step — see [mockPathProvider]'s `failWith`.
PlatformCallLog mockOpenFilex() {
  final log = PlatformCallLog();
  _messenger.setMockMethodCallHandler(_openFileChannel, (call) async {
    log.calls.add(call);
    return '{"type":"done","message":"done"}';
  });
  return log;
}

/// Grants (or denies) every permission request without touching the platform.
PlatformCallLog mockPermissionHandler({bool granted = true}) {
  final log = PlatformCallLog();
  // 1 == PermissionStatus.granted, 2 == PermissionStatus.denied
  final status = granted ? 1 : 2;
  _messenger.setMockMethodCallHandler(_permissionHandlerChannel, (call) async {
    log.calls.add(call);
    switch (call.method) {
      case 'requestPermissions':
        final permissions = (call.arguments as List).cast<int>();
        return {for (final p in permissions) p: status};
      case 'checkPermissionStatus':
        return status;
      case 'checkServiceStatus':
        return 1;
      case 'shouldShowRequestPermissionRationale':
        return false;
      default:
        return null;
    }
  });
  return log;
}

/// Makes the image picker return [imagePath], or nothing when it is null.
PlatformCallLog mockImagePicker({String? imagePath}) {
  final log = PlatformCallLog();
  _messenger.setMockMethodCallHandler(_imagePickerChannel, (call) async {
    log.calls.add(call);
    return imagePath;
  });
  return log;
}

/// Detaches every handler installed above.
void clearPlatformMocks() {
  for (final channel in const [
    _pathProviderChannel,
    _openFileChannel,
    _permissionHandlerChannel,
    _imagePickerChannel,
  ]) {
    _messenger.setMockMethodCallHandler(channel, null);
  }
}
