import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/database/database_helper.dart';

class BackupService {
  static final BackupService _instance = BackupService._internal();
  factory BackupService() => _instance;
  BackupService._internal();

  /// Exports all data to a JSON file and prompts the native Share Sheet.
  Future<void> exportDataToJSON() async {
    try {
      final db = await DatabaseHelper().database;

      List<Map<String, dynamic>> settings = await db.query('settings');
      List<Map<String, dynamic>> periods = await db.query('periods');
      List<Map<String, dynamic>> dailyLogs = await db.query('daily_logs');

      final backupData = {
        'version': 1,
        'timestamp': DateTime.now().toIso8601String(),
        'settings': settings,
        'periods': periods,
        'daily_logs': dailyLogs,
      };

      final jsonString = jsonEncode(backupData);

      // Save to temporary directory
      final directory = await getTemporaryDirectory();
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      final backupFile = File(
        '${directory.path}/luna_backup_${DateTime.now().millisecondsSinceEpoch}.json',
      );
      await backupFile.writeAsString(jsonString);

      // Trigger native share sheet
      await Share.shareXFiles([
        XFile(backupFile.path),
      ], subject: 'Luna Backup Data');
    } catch (e) {
      throw Exception('Failed to export data: $e');
    }
  }

  /// Prompts the user to pick a JSON file, validates it, and replaces the local database.
  Future<bool> importDataFromJSON() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        File backupFile = File(result.files.single.path!);
        String jsonString = await backupFile.readAsString();
        Map<String, dynamic> backupData = jsonDecode(jsonString);

        if (!backupData.containsKey('periods') ||
            !backupData.containsKey('daily_logs')) {
          throw const FormatException(
            'Invalid backup file format. Missing tables.',
          );
        }

        final db = await DatabaseHelper().database;

        await db.transaction((txn) async {
          // Clear current data completely
          await txn.delete('settings');
          await txn.delete('periods');
          await txn.delete('daily_logs');

          // Restore Settings
          if (backupData.containsKey('settings')) {
            List<dynamic> settingsItems = backupData['settings'];
            for (var settingItem in settingsItems) {
              await txn.insert(
                'settings',
                Map<String, dynamic>.from(settingItem),
              );
            }
          }

          // Restore Periods
          List<dynamic> periods = backupData['periods'];
          for (var p in periods) {
            await txn.insert('periods', Map<String, dynamic>.from(p));
          }

          // Restore Daily Logs
          List<dynamic> dailyLogs = backupData['daily_logs'];
          for (var log in dailyLogs) {
            await txn.insert('daily_logs', Map<String, dynamic>.from(log));
          }
        });

        return true;
      }
      return false; // User canceled
    } catch (e) {
      throw Exception('Failed to import data: $e');
    }
  }
}
