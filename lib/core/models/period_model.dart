class PeriodModel {
  final int? id;
  final String startDate;
  final String endDate;
  final String createdAt;
  final String updatedAt;

  PeriodModel({
    this.id,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PeriodModel.fromMap(Map<String, dynamic> map) {
    return PeriodModel(
      id: map['id'] as int?,
      startDate: map['start_date'] as String,
      endDate: map['end_date'] as String,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'start_date': startDate,
      'end_date': endDate,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  int get durationDays {
    final start = DateTime.parse(startDate);
    final end = DateTime.parse(endDate);
    return end.difference(start).inDays + 1;
  }

  bool containsDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    final start = DateTime.parse(startDate);
    final end = DateTime.parse(endDate);
    return !date.isBefore(start) && !date.isAfter(end);
  }

  PeriodModel copyWith({
    int? id,
    String? startDate,
    String? endDate,
    String? updatedAt,
  }) {
    return PeriodModel(
      id: id ?? this.id,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
