import 'dart:convert';

class SettingsModel {
  final int id;
  final int cycleLength;
  final int periodLength;
  final bool onboarded;
  final String? defaultFlow;
  final List<String> defaultMoods;
  final String? userName;
  final String? userNickname;
  final String? userBirthday; // ISO 8601 date YYYY-MM-DD
  final String createdAt;

  SettingsModel({
    this.id = 1,
    required this.cycleLength,
    required this.periodLength,
    required this.onboarded,
    this.defaultFlow,
    this.defaultMoods = const [],
    this.userName,
    this.userNickname,
    this.userBirthday,
    required this.createdAt,
  });

  factory SettingsModel.fromMap(Map<String, dynamic> map) {
    List<String> moodsList = [];
    if (map['default_moods'] != null && (map['default_moods'] as String).isNotEmpty) {
      moodsList = List<String>.from(jsonDecode(map['default_moods'] as String));
    }
    return SettingsModel(
      id: map['id'] as int,
      cycleLength: map['cycle_length'] as int,
      periodLength: map['period_length'] as int,
      onboarded: (map['onboarded'] as int) == 1,
      defaultFlow: map['default_flow'] as String?,
      defaultMoods: moodsList,
      userName: map['user_name'] as String?,
      userNickname: map['user_nickname'] as String?,
      userBirthday: map['user_birthday'] as String?,
      createdAt: map['created_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cycle_length': cycleLength,
      'period_length': periodLength,
      'onboarded': onboarded ? 1 : 0,
      'default_flow': defaultFlow,
      'default_moods': defaultMoods.isNotEmpty ? jsonEncode(defaultMoods) : null,
      'user_name': userName,
      'user_nickname': userNickname,
      'user_birthday': userBirthday,
      'created_at': createdAt,
    };
  }

  int? get age {
    if (userBirthday == null) return null;
    final bday = DateTime.parse(userBirthday!);
    final now = DateTime.now();
    int age = now.year - bday.year;
    if (now.month < bday.month || (now.month == bday.month && now.day < bday.day)) {
      age--;
    }
    return age;
  }

  SettingsModel copyWith({
    int? cycleLength,
    int? periodLength,
    bool? onboarded,
    String? defaultFlow,
    List<String>? defaultMoods,
    String? userName,
    String? userNickname,
    String? userBirthday,
    bool clearDefaultFlow = false,
    bool clearUserName = false,
    bool clearUserNickname = false,
    bool clearUserBirthday = false,
  }) {
    return SettingsModel(
      id: id,
      cycleLength: cycleLength ?? this.cycleLength,
      periodLength: periodLength ?? this.periodLength,
      onboarded: onboarded ?? this.onboarded,
      defaultFlow: clearDefaultFlow ? null : (defaultFlow ?? this.defaultFlow),
      defaultMoods: defaultMoods ?? this.defaultMoods,
      userName: clearUserName ? null : (userName ?? this.userName),
      userNickname: clearUserNickname ? null : (userNickname ?? this.userNickname),
      userBirthday: clearUserBirthday ? null : (userBirthday ?? this.userBirthday),
      createdAt: createdAt,
    );
  }
}
