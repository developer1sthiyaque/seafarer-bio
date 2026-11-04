import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

class FileSaveService {
  static Future<File?> saveAndOpen({
    required Uint8List bytes,
    required String fileName,
  }) async {
    try {
      Directory dir;
      if (Platform.isAndroid) {
        // App-specific external dir: /storage/emulated/0/Android/data/<pkg>/files
        dir = (await getExternalStorageDirectory()) ??
            await getApplicationDocumentsDirectory();
      } else {
        dir = await getApplicationDocumentsDirectory();
      }

      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes, flush: true);

      final result = await OpenFilex.open(file.path);
      debugPrint('OpenFilex result: ${result.type} ${result.message}');
      return file;
    } catch (e, st) {
      debugPrint('saveAndOpen failed: $e\n$st');
      rethrow; // let the UI show "Export failed"
    }
  }
}