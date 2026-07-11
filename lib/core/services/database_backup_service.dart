import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:masrofy/core/services/database_helper.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';

class DatabaseBackupService {
  static const String _dbName = 'masrofy.db';

  /// Creates a backup of the current database and shares it
  static Future<void> createAndShareBackup() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, _dbName);
      final dbFile = File(path);

      if (!await dbFile.exists()) {
        throw Exception('Database file not found');
      }

      // Create a temporary file for the backup with a timestamp
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateFormat(
        'yyyyMMdd_HHmmss',
        'en',
      ).format(DateTime.now());
      final backupFileName = 'masrofy_backup_$timestamp.db';
      final backupPath = join(tempDir.path, backupFileName);

      // Copy the database file
      await dbFile.copy(backupPath);

      // Share the file
      final xFile = XFile(backupPath);
      await SharePlus.instance.share(
        ShareParams(
          files: [xFile],
          text: 'Masrofy Database Backup',
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Restoration using FilePicker
  static Future<bool> pickAndRestoreBackup() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType
            .any, // .db files might not be recognized on all platforms if we use FileType.custom
      );

      if (result != null && result.files.single.path != null) {
        String sourcePath = result.files.single.path!;

        // Basic validation: check if it ends with .db
        if (!sourcePath.endsWith('.db')) {
          throw Exception('Selected file is not a database file (.db)');
        }

        await restoreBackup(sourcePath);
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  /// Restores the database from a file
  static Future<void> restoreBackup(String sourcePath) async {
    try {
      final dbPath = await getDatabasesPath();
      final targetPath = join(dbPath, _dbName);

      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        throw Exception('Source backup file not found');
      }

      // 1. Close the database connection
      await DatabaseHelper.instance.close();

      // 2. Overwrite the database file
      await sourceFile.copy(targetPath);

      // 3. Re-initialize the database (optional, will happen on next access)
      await DatabaseHelper.instance.database;
    } catch (e) {
      rethrow;
    }
  }
}
