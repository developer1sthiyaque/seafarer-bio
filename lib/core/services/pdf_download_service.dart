import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class PdfDownloadService {
  static Future<File?> downloadAndSavePdf({
    required String url,
    required String fileName,
  }) async {
    try {
      Directory dir;

      if (Platform.isAndroid) {
        dir = Directory('/storage/emulated/0/Download');
      } else {
        dir = await getApplicationDocumentsDirectory();
      }

      final filePath = '${dir.path}/$fileName';

      await Dio().download(url, filePath);

      final file = File(filePath);

      // Open PDF after download
      await OpenFilex.open(file.path);

      return file;
    } catch (e) {
      print('PDF Download Error: $e');
      return null;
    }
  }
}
