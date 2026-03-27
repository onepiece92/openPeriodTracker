import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import '../models/settings_model.dart';

class SettingsProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  SettingsModel? _settings;
  bool _isLoading = true;

  bool get isLoading => _isLoading;
  bool get isOnboarded => _settings?.onboarded == true;
  SettingsModel? get settings => _settings;
  int get cycleLength => _settings?.cycleLength ?? 28;
  int get periodLength => _settings?.periodLength ?? 5;
  String? get defaultFlow => _settings?.defaultFlow;
  List<String> get defaultMoods => _settings?.defaultMoods ?? [];
  String? get userName => _settings?.userName;
  String? get userNickname => _settings?.userNickname;
  String? get userBirthday => _settings?.userBirthday;
  int? get userAge => _settings?.age;
  String get displayName => _settings?.userNickname ?? _settings?.userName ?? 'Luna User';

  Future<void> loadSettings() async {
    final db = await _db.database;
    final result = await db.query('settings', where: 'id = ?', whereArgs: [1]);
    if (result.isNotEmpty) {
      _settings = SettingsModel.fromMap(result.first);
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> completeOnboarding({
    required int cycleLength,
    required int periodLength,
  }) async {
    final db = await _db.database;
    final now = DateTime.now().toIso8601String();
    _settings = SettingsModel(
      id: 1,
      cycleLength: cycleLength,
      periodLength: periodLength,
      onboarded: true,
      createdAt: now,
    );
    await db.insert('settings', _settings!.toMap());
    notifyListeners();
  }

  Future<void> updateCycleLength(int length) async {
    if (_settings == null) return;
    final db = await _db.database;
    _settings = _settings!.copyWith(cycleLength: length);
    await db.update('settings', {'cycle_length': length}, where: 'id = ?', whereArgs: [1]);
    notifyListeners();
  }

  Future<void> updatePeriodLength(int length) async {
    if (_settings == null) return;
    final db = await _db.database;
    _settings = _settings!.copyWith(periodLength: length);
    await db.update('settings', {'period_length': length}, where: 'id = ?', whereArgs: [1]);
    notifyListeners();
  }

  Future<void> updateDefaultFlow(String? flow) async {
    if (_settings == null) return;
    final db = await _db.database;
    _settings = _settings!.copyWith(
      defaultFlow: flow,
      clearDefaultFlow: flow == null,
    );
    await db.update(
      'settings',
      {'default_flow': flow},
      where: 'id = ?',
      whereArgs: [1],
    );
    notifyListeners();
  }

  Future<void> updateDefaultMoods(List<String> moods) async {
    if (_settings == null) return;
    final db = await _db.database;
    _settings = _settings!.copyWith(defaultMoods: moods);
    await db.update(
      'settings',
      {'default_moods': moods.isNotEmpty ? jsonEncode(moods) : null},
      where: 'id = ?',
      whereArgs: [1],
    );
    notifyListeners();
  }

  Future<void> updateUserInfo({String? name, String? nickname, String? birthday}) async {
    if (_settings == null) return;
    final db = await _db.database;
    final updates = <String, dynamic>{};
    if (name != null) updates['user_name'] = name.isEmpty ? null : name;
    if (nickname != null) updates['user_nickname'] = nickname.isEmpty ? null : nickname;
    if (birthday != null) updates['user_birthday'] = birthday.isEmpty ? null : birthday;

    if (updates.isNotEmpty) {
      await db.update('settings', updates, where: 'id = ?', whereArgs: [1]);
      _settings = _settings!.copyWith(
        userName: name ?? _settings!.userName,
        userNickname: nickname ?? _settings!.userNickname,
        userBirthday: birthday ?? _settings!.userBirthday,
        clearUserName: name != null && name.isEmpty,
        clearUserNickname: nickname != null && nickname.isEmpty,
        clearUserBirthday: birthday != null && birthday.isEmpty,
      );
      notifyListeners();
    }
  }

  /// Skip onboarding — create settings with defaults, no initial period.
  Future<void> skipOnboarding() async {
    final db = await _db.database;
    final now = DateTime.now().toIso8601String();
    _settings = SettingsModel(
      id: 1,
      cycleLength: 28,
      periodLength: 5,
      onboarded: true,
      createdAt: now,
    );
    await db.insert('settings', _settings!.toMap());
    notifyListeners();
  }

  Future<void> resetApp() async {
    await _db.clearAllTables();
    _settings = null;
    notifyListeners();
  }
}
