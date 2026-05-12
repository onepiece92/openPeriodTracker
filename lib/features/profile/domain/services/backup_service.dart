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
        final decoded = jsonDecode(jsonString);
        if (decoded is! Map<String, dynamic>) {
          throw const FormatException('Backup root must be a JSON object.');
        }
        final backupData = decoded;

        final periods = _validatedRows(
          backupData,
          'periods',
          required: const ['start_date', 'end_date', 'created_at', 'updated_at'],
          dateFields: const ['start_date', 'end_date'],
        );
        final dailyLogs = _validatedRows(
          backupData,
          'daily_logs',
          required: const ['date', 'created_at', 'updated_at'],
          dateFields: const ['date'],
        );
        final settings = backupData.containsKey('settings')
            ? _validatedRows(
                backupData,
                'settings',
                required: const [
                  'cycle_length',
                  'period_length',
                  'onboarded',
                  'created_at',
                ],
                dateFields: const [],
              )
            : const <Map<String, dynamic>>[];

        final db = await DatabaseHelper().database;

        await db.transaction((txn) async {
          // Clear current data completely
          await txn.delete('settings');
          await txn.delete('periods');
          await txn.delete('daily_logs');

          for (final s in settings) {
            await txn.insert('settings', s);
          }
          for (final p in periods) {
            await txn.insert('periods', p);
          }
          for (final log in dailyLogs) {
            await txn.insert('daily_logs', log);
          }
        });

        return true;
      }
      return false; // User canceled
    } catch (e) {
      throw Exception('Failed to import data: $e');
    }
  }

  /// Validates that `backupData[table]` is a list of objects with the required
  /// fields present and non-null, and that any declared date fields parse as
  /// ISO8601. Throws FormatException with a row-specific message on failure.
  List<Map<String, dynamic>> _validatedRows(
    Map<String, dynamic> backupData,
    String table, {
    required List<String> required,
    required List<String> dateFields,
  }) {
    if (!backupData.containsKey(table)) {
      throw FormatException('Invalid backup: missing "$table" table.');
    }
    final raw = backupData[table];
    if (raw is! List) {
      throw FormatException('Invalid backup: "$table" must be a list.');
    }
    final rows = <Map<String, dynamic>>[];
    for (var i = 0; i < raw.length; i++) {
      final item = raw[i];
      if (item is! Map) {
        throw FormatException('Invalid backup: $table[$i] is not an object.');
      }
      final row = Map<String, dynamic>.from(item);
      for (final field in required) {
        if (row[field] == null) {
          throw FormatException(
            'Invalid backup: $table[$i] missing "$field".',
          );
        }
      }
      for (final field in dateFields) {
        final value = row[field];
        if (value is! String || DateTime.tryParse(value) == null) {
          throw FormatException(
            'Invalid backup: $table[$i] has invalid date "$field".',
          );
        }
      }
      rows.add(row);
    }
    return rows;
  }
}
