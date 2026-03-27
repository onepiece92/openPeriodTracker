import 'dart:convert';

class DailyLogModel {
  final int? id;
  final String date;
  final String? flow;
  final List<String> moods;
  final List<String> symptoms;
  final String? notes;
  final Map<String, String> medicalLog; // key → selected value
  final String createdAt;
  final String updatedAt;

  DailyLogModel({
    this.id,
    required this.date,
    this.flow,
    this.moods = const [],
    this.symptoms = const [],
    this.notes,
    this.medicalLog = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory DailyLogModel.fromMap(Map<String, dynamic> map) {
    List<String> symptomsList = [];
    if (map['symptoms'] != null && (map['symptoms'] as String).isNotEmpty) {
      symptomsList = List<String>.from(jsonDecode(map['symptoms'] as String));
    }

    List<String> moodsList = [];
    if (map['mood'] != null && (map['mood'] as String).isNotEmpty) {
      final moodStr = map['mood'] as String;
      if (moodStr.startsWith('[')) {
        moodsList = List<String>.from(jsonDecode(moodStr));
      } else {
        moodsList = [moodStr];
      }
    }

    Map<String, String> medLog = {};
    if (map['medical_log'] != null && (map['medical_log'] as String).isNotEmpty) {
      medLog = Map<String, String>.from(jsonDecode(map['medical_log'] as String));
    }

    return DailyLogModel(
      id: map['id'] as int?,
      date: map['date'] as String,
      flow: map['flow'] as String?,
      moods: moodsList,
      symptoms: symptomsList,
      notes: map['notes'] as String?,
      medicalLog: medLog,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'date': date,
      'flow': flow,
      'mood': moods.isNotEmpty ? jsonEncode(moods) : null,
      'symptoms': symptoms.isNotEmpty ? jsonEncode(symptoms) : null,
      'notes': notes,
      'medical_log': medicalLog.isNotEmpty ? jsonEncode(medicalLog) : null,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  DailyLogModel copyWith({
    String? flow,
    List<String>? moods,
    List<String>? symptoms,
    String? notes,
    Map<String, String>? medicalLog,
    String? updatedAt,
  }) {
    return DailyLogModel(
      id: id,
      date: date,
      flow: flow ?? this.flow,
      moods: moods ?? this.moods,
      symptoms: symptoms ?? this.symptoms,
      notes: notes ?? this.notes,
      medicalLog: medicalLog ?? this.medicalLog,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get hasData =>
      flow != null ||
      moods.isNotEmpty ||
      symptoms.isNotEmpty ||
      (notes != null && notes!.isNotEmpty) ||
      medicalLog.isNotEmpty;
}
