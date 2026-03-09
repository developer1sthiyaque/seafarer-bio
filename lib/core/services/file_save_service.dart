import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class FileSaveService {
  static Future<File?> saveAndOpen({
    required Uint8List bytes,
    required String fileName,
  }) async {
    try {
      Directory dir;

      if (Platform.isAndroid) {
        // Using the secondary storage Downloads folder for Android
        dir = Directory('/storage/emulated/0/Download');
        if (!await dir.exists()) {
          dir = await getApplicationDocumentsDirectory();
        }
      } else {
        dir = await getApplicationDocumentsDirectory();
      }

      final filePath = '${dir.path}/$fileName';
      final file = File(filePath);

      await file.writeAsBytes(bytes);

      // Open file after saving
      await OpenFilex.open(file.path);

      return file;
    } catch (e) {
      return null;
    }
  }
}
