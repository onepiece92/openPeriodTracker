import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import '../models/period_model.dart';
import '../theme/app_theme.dart';

class PeriodProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  List<PeriodModel> _periods = [];
  int _settingsCycleLength = 28;
  int _settingsPeriodLength = 5;

  List<PeriodModel> get periods => _periods;

  void updateSettings(int cycleLength, int periodLength) {
    _settingsCycleLength = cycleLength;
    _settingsPeriodLength = periodLength;
  }

  // --- Computed cycle data (centralized, no duplication) ---

  /// All cycle lengths between consecutive periods (oldest first).
  List<int> get cycleLengths {
    final lengths = <int>[];
    for (int i = 1; i < _periods.length; i++) {
      final prev = DateTime.parse(_periods[i - 1].startDate);
      final curr = DateTime.parse(_periods[i].startDate);
      lengths.add(curr.difference(prev).inDays);
    }
    return lengths;
  }

  /// All period durations (oldest first).
  List<int> get periodDurations {
    return _periods.map((p) => p.durationDays).toList();
  }

  /// Average cycle length computed from logged data.
  /// Falls back to settings only when < 2 periods.
  int get averageCycleLength {
    final cl = cycleLengths;
    if (cl.isEmpty) return _settingsCycleLength;
    return (cl.reduce((a, b) => a + b) / cl.length).round();
  }

  /// Average period duration computed from logged data.
  /// Falls back to settings only when no periods.
  int get averagePeriodLength {
    if (_periods.isEmpty) return _settingsPeriodLength;
    final durations = periodDurations;
    return (durations.reduce((a, b) => a + b) / durations.length).round();
  }

  PeriodModel? get lastPeriod => _periods.isNotEmpty ? _periods.last : null;
  PeriodModel? get firstPeriod => _periods.isNotEmpty ? _periods.first : null;

  /// Current cycle day — actual days since last period start.
  /// No modulo wrapping. If past the expected cycle, shows real day count.
  int get currentCycleDay {
    if (lastPeriod == null) return 1;
    final lastStart = DateTime.parse(lastPeriod!.startDate);
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final diff = todayDate.difference(lastStart).inDays;
    if (diff < 0) return 1;
    return diff + 1;
  }

  /// Next predicted period date (first one after today).
  DateTime? get nextPeriodDate {
    if (lastPeriod == null) return null;
    final lastStart = DateTime.parse(lastPeriod!.startDate);
    final avg = averageCycleLength;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    var next = lastStart.add(Duration(days: avg));
    while (!next.isAfter(todayDate)) {
      next = next.add(Duration(days: avg));
    }
    return next;
  }

  int? get daysUntilNextPeriod {
    final next = nextPeriodDate;
    if (next == null) return null;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    return next.difference(todayDate).inDays;
  }

  /// Fertile window based on computed average cycle.
  bool get isInFertileWindow {
    final avg = averageCycleLength;
    final fertileStart = avg - 18;
    final fertileEnd = avg - 12;
    final day = _cycleDayInCurrent;
    return day >= fertileStart && day <= fertileEnd;
  }

  /// Current phase using computed average period duration (not settings).
  CyclePhase get currentPhase {
    return _phaseForCycleDay(_cycleDayInCurrent);
  }

  /// Phase for any given cycle day position.
  CyclePhase _phaseForCycleDay(int day) {
    final avg = averageCycleLength;
    final avgPeriod = averagePeriodLength;
    if (day <= avgPeriod) return CyclePhase.menstrual;
    if (day <= (avg * 0.46).round()) return CyclePhase.follicular;
    if (day <= (avg * 0.57).round()) return CyclePhase.ovulation;
    return CyclePhase.luteal;
  }

  /// Cycle day within the current cycle, wrapped by avg for phase calc.
  /// Separate from currentCycleDay which shows the raw count.
  int get _cycleDayInCurrent {
    if (lastPeriod == null) return 1;
    final lastStart = DateTime.parse(lastPeriod!.startDate);
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final diff = todayDate.difference(lastStart).inDays;
    if (diff < 0) return 1;
    final avg = averageCycleLength;
    return (diff % avg) + 1;
  }

  // --- Calendar day status ---

  Future<void> loadPeriods() async {
    final db = await _db.database;
    final result = await db.query('periods', orderBy: 'start_date ASC');
    _periods = result.map((m) => PeriodModel.fromMap(m)).toList();
    notifyListeners();
  }

  bool isDateInPeriod(String dateStr) {
    return _periods.any((p) => p.containsDate(dateStr));
  }

  /// Day status for any date — works for past, present, and future.
  /// Predictions project from the nearest anchor period in both directions.
  String getDayStatus(String dateStr) {
    // 1. Check if in a logged period
    if (isDateInPeriod(dateStr)) return 'period';

    // 2. No periods at all → no predictions possible
    if (_periods.isEmpty) return 'normal';

    final date = DateTime.parse(dateStr);
    final avg = averageCycleLength;
    final avgPeriod = averagePeriodLength;

    // 3. Find the nearest period to anchor predictions from
    final anchor = _findNearestPeriod(date);
    final anchorStart = DateTime.parse(anchor.startDate);
    final diff = date.difference(anchorStart).inDays;

    // 4. Calculate which cycle day this date falls on relative to anchor
    // Works in both directions (past and future)
    int cycleDayForDate;
    if (diff >= 0) {
      cycleDayForDate = (diff % avg) + 1;
    } else {
      // Going backward: offset into the previous cycle
      final backOffset = (-diff) % avg;
      cycleDayForDate = backOffset == 0 ? 1 : avg - backOffset + 1;
    }

    // 5. Determine status from cycle day position
    if (cycleDayForDate <= avgPeriod) return 'predicted-period';

    // Ovulation estimated at avg - 14 (luteal phase is ~14 days)
    // Peak fertility: ovulation day and the day before (highest conception probability)
    final ovulationDay = avg - 14;
    final peakStart = ovulationDay - 1; // day before ovulation
    final peakEnd = ovulationDay;       // ovulation day

    final fertileStart = avg - 18;
    final fertileEnd = avg - 12;

    if (peakStart > 0 && cycleDayForDate >= peakStart && cycleDayForDate <= peakEnd) {
      return 'peak';
    }

    if (fertileStart > 0 && cycleDayForDate >= fertileStart && cycleDayForDate <= fertileEnd) {
      return 'fertile';
    }

    return 'normal';
  }

  /// Cycle day (1-indexed) for any arbitrary date.
  int getCycleDayForDate(String dateStr) {
    if (_periods.isEmpty) return 1;
    final date = DateTime.parse(dateStr);
    final avg = averageCycleLength;
    final anchor = _findNearestPeriod(date);
    final anchorStart = DateTime.parse(anchor.startDate);
    final diff = date.difference(anchorStart).inDays;

    if (diff >= 0) {
      return (diff % avg) + 1;
    } else {
      final backOffset = (-diff) % avg;
      return backOffset == 0 ? 1 : avg - backOffset + 1;
    }
  }

  /// Phase for any arbitrary date.
  CyclePhase getPhaseForDate(String dateStr) {
    return _phaseForCycleDay(getCycleDayForDate(dateStr));
  }

  /// Find the period whose start date is closest to the given date.
  PeriodModel _findNearestPeriod(DateTime date) {
    PeriodModel nearest = _periods.first;
    int minDist = (date.difference(DateTime.parse(nearest.startDate)).inDays).abs();
    for (final p in _periods) {
      final dist = (date.difference(DateTime.parse(p.startDate)).inDays).abs();
      if (dist < minDist) {
        minDist = dist;
        nearest = p;
      }
    }
    return nearest;
  }

  // --- Period mutation ---

  Future<void> togglePeriodDay(String dateStr) async {
    if (isDateInPeriod(dateStr)) {
      await _removePeriodDay(dateStr);
    } else {
      await _addPeriodDay(dateStr);
    }
    await loadPeriods();
  }

  Future<void> _addPeriodDay(String dateStr) async {
    final db = await _db.database;
    final date = DateTime.parse(dateStr);
    final prevDay = date.subtract(const Duration(days: 1));
    final nextDay = date.add(const Duration(days: 1));
    final prevStr = _formatDate(prevDay);
    final nextStr = _formatDate(nextDay);

    PeriodModel? prevPeriod;
    PeriodModel? nextPeriod;

    for (final p in _periods) {
      if (p.endDate == prevStr) prevPeriod = p;
      if (p.startDate == nextStr) nextPeriod = p;
    }

    final now = DateTime.now().toIso8601String();

    if (prevPeriod != null && nextPeriod != null) {
      await db.update(
        'periods',
        {'end_date': nextPeriod.endDate, 'updated_at': now},
        where: 'id = ?',
        whereArgs: [prevPeriod.id],
      );
      await db.delete('periods', where: 'id = ?', whereArgs: [nextPeriod.id]);
    } else if (prevPeriod != null) {
      await db.update(
        'periods',
        {'end_date': dateStr, 'updated_at': now},
        where: 'id = ?',
        whereArgs: [prevPeriod.id],
      );
    } else if (nextPeriod != null) {
      await db.update(
        'periods',
        {'start_date': dateStr, 'updated_at': now},
        where: 'id = ?',
        whereArgs: [nextPeriod.id],
      );
    } else {
      await db.insert('periods', {
        'start_date': dateStr,
        'end_date': dateStr,
        'created_at': now,
        'updated_at': now,
      });
    }
  }

  Future<void> _removePeriodDay(String dateStr) async {
    final db = await _db.database;
    final now = DateTime.now().toIso8601String();

    final period = _periods.firstWhere((p) => p.containsDate(dateStr));

    if (period.startDate == period.endDate) {
      await db.delete('periods', where: 'id = ?', whereArgs: [period.id]);
    } else if (period.startDate == dateStr) {
      final nextDay = DateTime.parse(dateStr).add(const Duration(days: 1));
      await db.update(
        'periods',
        {'start_date': _formatDate(nextDay), 'updated_at': now},
        where: 'id = ?',
        whereArgs: [period.id],
      );
    } else if (period.endDate == dateStr) {
      final prevDay = DateTime.parse(dateStr).subtract(const Duration(days: 1));
      await db.update(
        'periods',
        {'end_date': _formatDate(prevDay), 'updated_at': now},
        where: 'id = ?',
        whereArgs: [period.id],
      );
    } else {
      final prevDay = DateTime.parse(dateStr).subtract(const Duration(days: 1));
      final nextDay = DateTime.parse(dateStr).add(const Duration(days: 1));
      await db.update(
        'periods',
        {'end_date': _formatDate(prevDay), 'updated_at': now},
        where: 'id = ?',
        whereArgs: [period.id],
      );
      await db.insert('periods', {
        'start_date': _formatDate(nextDay),
        'end_date': period.endDate,
        'created_at': now,
        'updated_at': now,
      });
    }
  }

  Future<void> addPeriodRange(String startDate, int days) async {
    final db = await _db.database;
    final start = DateTime.parse(startDate);
    final end = start.add(Duration(days: days - 1));
    final now = DateTime.now().toIso8601String();

    final allPeriods = List<PeriodModel>.from(_periods);
    final toDelete = <int>[];
    DateTime mergedStart = start;
    DateTime mergedEnd = end;

    for (final p in allPeriods) {
      final pStart = DateTime.parse(p.startDate);
      final pEnd = DateTime.parse(p.endDate);
      if (pStart.difference(mergedEnd).inDays <= 1 &&
          mergedStart.difference(pEnd).inDays <= 1) {
        if (pStart.isBefore(mergedStart)) mergedStart = pStart;
        if (pEnd.isAfter(mergedEnd)) mergedEnd = pEnd;
        if (p.id != null) toDelete.add(p.id!);
      }
    }

    for (final id in toDelete) {
      await db.delete('periods', where: 'id = ?', whereArgs: [id]);
    }

    await db.insert('periods', {
      'start_date': _formatDate(mergedStart),
      'end_date': _formatDate(mergedEnd),
      'created_at': now,
      'updated_at': now,
    });

    await loadPeriods();
  }

  Future<void> addInitialPeriod(String startDate, int periodLength) async {
    final db = await _db.database;
    final start = DateTime.parse(startDate);
    final end = start.add(Duration(days: periodLength - 1));
    final now = DateTime.now().toIso8601String();
    await db.insert('periods', {
      'start_date': startDate,
      'end_date': _formatDate(end),
      'created_at': now,
      'updated_at': now,
    });
    await loadPeriods();
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
