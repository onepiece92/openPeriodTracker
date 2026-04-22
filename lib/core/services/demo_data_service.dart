import 'dart:convert';
import 'dart:math';
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../providers/settings_provider.dart';
import '../providers/period_provider.dart';
import '../providers/daily_log_provider.dart';

/// Generates a realistic year of period, mood, symptom, and medical log data.
/// Can be called from onboarding or from Profile > Developer Tools.
class DemoDataService {
  static final DemoDataService _instance = DemoDataService._internal();
  factory DemoDataService() => _instance;
  DemoDataService._internal();

  Future<void> generate({
    required SettingsProvider settingsProv,
    required PeriodProvider periodProv,
    required DailyLogProvider logProv,
  }) async {
    final db = await DatabaseHelper().database;
    final rng = Random(DateTime.now().millisecondsSinceEpoch);

    // Clear everything
    await db.delete('settings');
    await db.delete('periods');
    await db.delete('daily_logs');

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final oneYearAgo = today.subtract(const Duration(days: 365));

    // Randomize base parameters
    final baseCycleLength = 24 + rng.nextInt(10); // 24–33
    final basePeriodLength = 3 + rng.nextInt(4); // 3–6

    // Save settings
    await db.insert('settings', {
      'id': 1,
      'cycle_length': baseCycleLength,
      'period_length': basePeriodLength,
      'onboarded': 1,
      'default_flow': null,
      'default_moods': null,
      'created_at': oneYearAgo.toIso8601String(),
    });

    // Generate periods with natural variation
    var cursor = oneYearAgo;
    final periods = <Map<String, dynamic>>[];

    while (cursor.isBefore(today)) {
      // Vary cycle length: base ± 0–4 days
      final cycleVariation = rng.nextInt(5) * (rng.nextBool() ? 1 : -1);
      final thisCycleLength = (baseCycleLength + cycleVariation).clamp(20, 40);

      // Vary period length: base ± 0–2 days
      final periodVariation = rng.nextInt(3) * (rng.nextBool() ? 1 : -1);
      final thisPeriodLength = (basePeriodLength + periodVariation).clamp(2, 8);

      final periodStart = cursor;
      final periodEnd = periodStart.add(Duration(days: thisPeriodLength - 1));

      if (periodEnd.isAfter(today)) break;

      final nowStr = DateTime.now().toIso8601String();
      periods.add({
        'start_date': _fmt(periodStart),
        'end_date': _fmt(periodEnd),
        'created_at': nowStr,
        'updated_at': nowStr,
      });

      // Generate daily logs for period days
      for (int d = 0; d < thisPeriodLength; d++) {
        final logDate = periodStart.add(Duration(days: d));
        if (logDate.isAfter(today)) break;

        // Flow: heavier in the middle
        String flow;
        final pos = d / thisPeriodLength;
        if (pos < 0.2) {
          flow = rng.nextBool() ? 'light' : 'medium';
        } else if (pos < 0.6) {
          flow = rng.nextBool() ? 'heavy' : 'medium';
        } else {
          flow = rng.nextBool() ? 'light' : 'medium';
        }

        // Moods during period — weighted toward tired/sad/irritable
        final periodMoods = [
          'Tired',
          'Sad',
          'Irritable',
          'Anxious',
          'Sensitive',
          'Sleepy',
        ];
        final positiveMoods = ['Happy', 'Calm', 'Loving', 'Grateful'];
        final selectedMoods = <String>[];
        final moodCount = 1 + rng.nextInt(3);
        final moodPool = rng.nextDouble() < 0.7 ? periodMoods : positiveMoods;
        for (int m = 0; m < moodCount; m++) {
          final mood = moodPool[rng.nextInt(moodPool.length)];
          if (!selectedMoods.contains(mood)) selectedMoods.add(mood);
        }

        // Symptoms during period
        final allSymptoms = [
          'Cramps',
          'Headache',
          'Bloating',
          'Back pain',
          'Breast tenderness',
          'Acne',
          'Nausea',
          'Fatigue',
        ];
        final selectedSymptoms = <String>[];
        final symptomCount = rng.nextInt(4); // 0–3 symptoms
        for (int s = 0; s < symptomCount; s++) {
          final sym = allSymptoms[rng.nextInt(allSymptoms.length)];
          if (!selectedSymptoms.contains(sym)) selectedSymptoms.add(sym);
        }

        // Medical checklist (~60% of period days)
        String? medicalJson;
        if (rng.nextDouble() < 0.6) {
          medicalJson = jsonEncode(
            _genMedical(rng, isPeriod: true, periodPos: pos),
          );
        }

        await db.insert('daily_logs', {
          'date': _fmt(logDate),
          'flow': flow,
          'mood': selectedMoods.isNotEmpty ? jsonEncode(selectedMoods) : null,
          'symptoms':
              selectedSymptoms.isNotEmpty ? jsonEncode(selectedSymptoms) : null,
          'notes': null,
          'medical_log': medicalJson,
          'created_at': nowStr,
          'updated_at': nowStr,
        });
      }

      // Also generate some non-period day logs (random days in follicular/luteal)
      final nonPeriodLogCount = 2 + rng.nextInt(5); // 2–6 random logs per cycle
      for (int n = 0; n < nonPeriodLogCount; n++) {
        final dayOffset =
            thisPeriodLength + rng.nextInt(thisCycleLength - thisPeriodLength);
        final logDate = periodStart.add(Duration(days: dayOffset));
        if (logDate.isAfter(today)) continue;

        final allMoods = [
          'Happy',
          'Tired',
          'Calm',
          'Energetic',
          'Stressed',
          'Loving',
          'Anxious',
          'Confident',
          'Meh',
          'Peaceful',
        ];
        final selectedMoods = <String>[];
        final moodCount = 1 + rng.nextInt(2);
        for (int m = 0; m < moodCount; m++) {
          final mood = allMoods[rng.nextInt(allMoods.length)];
          if (!selectedMoods.contains(mood)) selectedMoods.add(mood);
        }

        // Lighter symptoms outside period
        final nonPeriodSymptoms = ['Headache', 'Bloating', 'Acne', 'Fatigue'];
        final selectedSymptoms = <String>[];
        if (rng.nextDouble() < 0.3) {
          selectedSymptoms.add(
            nonPeriodSymptoms[rng.nextInt(nonPeriodSymptoms.length)],
          );
        }

        // Medical checklist (~30% of non-period days)
        String? medicalJson;
        if (rng.nextDouble() < 0.3) {
          medicalJson = jsonEncode(
            _genMedical(rng, isPeriod: false, periodPos: 0),
          );
        }

        await db.insert(
          'daily_logs',
          {
            'date': _fmt(logDate),
            'flow': null,
            'mood':
                selectedMoods.isNotEmpty ? jsonEncode(selectedMoods) : null,
            'symptoms':
                selectedSymptoms.isNotEmpty
                    ? jsonEncode(selectedSymptoms)
                    : null,
            'notes': null,
            'medical_log': medicalJson,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }

      cursor = periodStart.add(Duration(days: thisCycleLength));
    }

    // Insert all periods
    for (final p in periods) {
      await db.insert('periods', p);
    }

    // Reload providers
    await settingsProv.loadSettings();
    await periodProv.loadPeriods();
    await logProv.loadLogs();
    periodProv.updateSettings(baseCycleLength, basePeriodLength);
  }

  // ─── Private helpers ───────────────────────────────────────────────────────

  Map<String, String> _genMedical(
    Random rng, {
    required bool isPeriod,
    required double periodPos,
  }) {
    final med = <String, String>{};

    // Pain — heavier during period middle
    if (isPeriod) {
      final painOpts = periodPos < 0.2
          ? ['Mild', 'Moderate']
          : periodPos < 0.6
          ? ['Moderate', 'Severe', 'Moderate']
          : ['Mild', 'None', 'Mild'];
      med['pain_level'] = painOpts[rng.nextInt(painOpts.length)];
    } else {
      med['pain_level'] = rng.nextDouble() < 0.8 ? 'None' : 'Mild';
    }

    // Discharge color
    if (isPeriod) {
      med['discharge_color'] = ['Red', 'Brown', 'Pink'][rng.nextInt(3)];
    } else {
      med['discharge_color'] = [
        'Clear',
        'White',
        'Clear',
        'Creamy',
      ][rng.nextInt(4)];
    }

    // Sleep — worse during period
    if (isPeriod) {
      med['sleep'] = ['Poor', 'Good', 'Poor', 'Good', 'Great'][rng.nextInt(5)];
    } else {
      med['sleep'] = ['Good', 'Great', 'Good', 'Great', 'Poor'][rng.nextInt(5)];
    }

    // Energy
    if (isPeriod) {
      med['energy'] = ['Low', 'Normal', 'Low', 'Exhausted'][rng.nextInt(4)];
    } else {
      med['energy'] = ['Normal', 'High', 'Normal', 'Low'][rng.nextInt(4)];
    }

    // Skin — ~30% chance of acne
    if (rng.nextDouble() < 0.3) {
      med['skin'] = ['Acne', 'Oily', 'Clear'][rng.nextInt(3)];
    } else {
      med['skin'] = ['Clear', 'Glow', 'Clear'][rng.nextInt(3)];
    }

    // Weight
    if (isPeriod) {
      med['weight'] = ['Bloated', 'Stable', 'Bloated'][rng.nextInt(3)];
    } else {
      med['weight'] = ['Stable', 'Stable', 'Gained'][rng.nextInt(3)];
    }

    // Digestion — ~40% of days
    if (rng.nextDouble() < 0.4) {
      if (isPeriod) {
        med['digestion'] = [
          'Cravings',
          'Normal',
          'Constipated',
          'Nausea',
        ][rng.nextInt(4)];
      } else {
        med['digestion'] = ['Normal', 'Normal', 'Cravings'][rng.nextInt(3)];
      }
    }

    // Libido — ~30% of days
    if (rng.nextDouble() < 0.3) {
      med['libido'] = isPeriod
          ? ['Low', 'None', 'Low'][rng.nextInt(3)]
          : ['Normal', 'High', 'Normal', 'Low'][rng.nextInt(4)];
    }

    // Breast — during period
    if (isPeriod && rng.nextDouble() < 0.4) {
      med['breast'] = ['Tender', 'Swollen', 'Normal'][rng.nextInt(3)];
    }

    // Hair — rare
    if (rng.nextDouble() < 0.1) {
      med['hair'] = ['Normal', 'Oily', 'Normal'][rng.nextInt(3)];
    }

    return med;
  }

  String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
