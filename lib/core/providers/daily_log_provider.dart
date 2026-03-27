import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import '../models/daily_log_model.dart';

class DailyLogProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  Map<String, DailyLogModel> _logs = {};

  Future<void> loadLogs() async {
    final db = await _db.database;
    final result = await db.query('daily_logs');
    _logs = {for (final m in result) m['date'] as String: DailyLogModel.fromMap(m)};
    notifyListeners();
  }

  Map<String, DailyLogModel> get allLogs => _logs;
  DailyLogModel? getLog(String date) => _logs[date];
  bool hasLog(String date) => _logs.containsKey(date) && _logs[date]!.hasData;

  Future<void> updateLog(
    String date, {
    String? flow,
    List<String>? moods,
    List<String>? symptoms,
    String? notes,
    Map<String, String>? medicalLog,
    bool clearFlow = false,
    bool clearMoods = false,
  }) async {
    final db = await _db.database;
    final now = DateTime.now().toIso8601String();
    final existing = _logs[date];

    if (existing != null) {
      final updatedMap = <String, dynamic>{
        'updated_at': now,
      };
      if (flow != null || clearFlow) updatedMap['flow'] = flow;
      if (moods != null || clearMoods) {
        updatedMap['mood'] = moods != null && moods.isNotEmpty ? jsonEncode(moods) : null;
      }
      if (symptoms != null) {
        updatedMap['symptoms'] = symptoms.isNotEmpty ? jsonEncode(symptoms) : null;
      }
      if (notes != null) updatedMap['notes'] = notes.isNotEmpty ? notes : null;
      if (medicalLog != null) {
        updatedMap['medical_log'] = medicalLog.isNotEmpty ? jsonEncode(medicalLog) : null;
      }

      await db.update('daily_logs', updatedMap, where: 'date = ?', whereArgs: [date]);
    } else {
      final newLog = DailyLogModel(
        date: date,
        flow: flow,
        moods: moods ?? [],
        symptoms: symptoms ?? [],
        notes: notes,
        medicalLog: medicalLog ?? {},
        createdAt: now,
        updatedAt: now,
      );
      await db.insert('daily_logs', newLog.toMap());
    }

    // Reload the specific log
    final result = await db.query('daily_logs', where: 'date = ?', whereArgs: [date]);
    if (result.isNotEmpty) {
      _logs[date] = DailyLogModel.fromMap(result.first);
    }
    notifyListeners();
  }
}
