import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class FilePersist {
  static Future<String> copyToDocuments(String sourcePath) async {
    final source = File(sourcePath);
    if (!await source.exists()) return sourcePath;

    final docs = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(join(docs.path, 'images'));
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    final ext = extension(sourcePath);
    final destPath = join(imagesDir.path, '${const Uuid().v4()}$ext');
    await source.copy(destPath);
    return destPath;
  }
}
