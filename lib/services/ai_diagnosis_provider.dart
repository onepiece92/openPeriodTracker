import 'package:flutter/foundation.dart';
import 'ollama_service.dart';
import 'lstm_service.dart';
import '../core/models/period_model.dart';
import '../core/models/daily_log_model.dart';

enum AiStatus { idle, checking, loading, streaming, done, error }

class AiDiagnosisProvider extends ChangeNotifier {
  final OllamaService _ollama = OllamaService();
  final LstmService _lstm = LstmService();

  AiStatus _status = AiStatus.idle;
  bool _ollamaAvailable = false;
  bool _lstmReady = false;
  CyclePrediction? _prediction;
  String _aiDiagnosis = '';
  String _errorMessage = '';
  String _ollamaModel = '';

  AiStatus get status => _status;
  bool get ollamaAvailable => _ollamaAvailable;
  bool get lstmReady => _lstmReady;
  CyclePrediction? get prediction => _prediction;
  String get aiDiagnosis => _aiDiagnosis;
  String get errorMessage => _errorMessage;
  String get ollamaModel => _ollamaModel;
  OllamaService get ollama => _ollama;

  /// Initialize LSTM service on app start.
  Future<void> initialize() async {
    await _lstm.initialize();
    _lstmReady = _lstm.isLoaded;
    notifyListeners();
  }

  /// Check Ollama connection and get model info.
  Future<void> checkOllama() async {
    _status = AiStatus.checking;
    notifyListeners();

    _ollamaAvailable = await _ollama.isAvailable();
    if (_ollamaAvailable) {
      _ollamaModel = _ollama.model;
    }

    _status = AiStatus.idle;
    notifyListeners();
  }

  /// Configure Ollama host/model.
  void configureOllama({String? host, String? model}) {
    _ollama.configure(host: host, model: model);
    _ollamaAvailable = false;
    notifyListeners();
  }

  /// Run LSTM prediction from period data.
  void runPrediction({
    required List<PeriodModel> periods,
    required int settingsCycleLength,
    required int settingsPeriodLength,
  }) {
    if (periods.length < 2) {
      _prediction = null;
      notifyListeners();
      return;
    }

    // Build cycle lengths and period durations
    final cycleLengths = <int>[];
    final periodDurations = <int>[];

    for (int i = 0; i < periods.length; i++) {
      periodDurations.add(periods[i].durationDays);
      if (i > 0) {
        final prev = DateTime.parse(periods[i - 1].startDate);
        final curr = DateTime.parse(periods[i].startDate);
        cycleLengths.add(curr.difference(prev).inDays);
      }
    }

    // Need at least 1 cycle length to predict
    if (cycleLengths.isEmpty) {
      _prediction = null;
      notifyListeners();
      return;
    }

    // If we have more period durations than cycle lengths, trim to match
    final trimmedDurations = periodDurations.length > cycleLengths.length
        ? periodDurations.sublist(periodDurations.length - cycleLengths.length)
        : periodDurations;

    _prediction = _lstm.predict(
      cycleLengths: cycleLengths,
      periodDurations: trimmedDurations,
    );
    notifyListeners();
  }

  /// Run full AI diagnosis — LSTM prediction + Ollama text generation.
  Future<void> runFullDiagnosis({
    required List<PeriodModel> periods,
    required Map<String, DailyLogModel> logs,
    required int settingsCycleLength,
    required int settingsPeriodLength,
  }) async {
    _status = AiStatus.loading;
    _aiDiagnosis = '';
    _errorMessage = '';
    notifyListeners();

    // 1. Run LSTM prediction
    runPrediction(
      periods: periods,
      settingsCycleLength: settingsCycleLength,
      settingsPeriodLength: settingsPeriodLength,
    );

    // 2. Build data payload for Ollama
    final cycleData = _buildCycleData(
      periods: periods,
      logs: logs,
      settingsCycleLength: settingsCycleLength,
    );

    // 3. Check Ollama
    if (!_ollamaAvailable) {
      await checkOllama();
    }

    if (!_ollamaAvailable) {
      _status = AiStatus.error;
      _errorMessage =
          'Ollama not reachable at ${_ollama.host}. Make sure Ollama is running.';
      notifyListeners();
      return;
    }

    // 4. Stream diagnosis from Ollama
    _status = AiStatus.streaming;
    notifyListeners();

    try {
      await for (final token in _ollama.streamDiagnosis(cycleData: cycleData)) {
        _aiDiagnosis += token;
        notifyListeners();
      }

      if (_aiDiagnosis.isEmpty) {
        _status = AiStatus.error;
        _errorMessage = 'Ollama returned an empty response. Try again.';
      } else {
        _status = AiStatus.done;
      }
    } catch (e) {
      _status = AiStatus.error;
      _errorMessage = 'Error streaming from Ollama: $e';
    }

    notifyListeners();
  }

  Map<String, dynamic> _buildCycleData({
    required List<PeriodModel> periods,
    required Map<String, DailyLogModel> logs,
    required int settingsCycleLength,
  }) {
    // Cycle lengths
    final cycleLengths = <int>[];
    for (int i = 1; i < periods.length; i++) {
      final prev = DateTime.parse(periods[i - 1].startDate);
      final curr = DateTime.parse(periods[i].startDate);
      cycleLengths.add(curr.difference(prev).inDays);
    }

    final avgCycle = cycleLengths.isNotEmpty
        ? (cycleLengths.reduce((a, b) => a + b) / cycleLengths.length).round()
        : settingsCycleLength;

    final avgDuration = periods.isNotEmpty
        ? (periods.map((p) => p.durationDays).reduce((a, b) => a + b) /
                  periods.length)
              .round()
        : 5;

    final variation = cycleLengths.isNotEmpty
        ? cycleLengths.reduce((a, b) => a > b ? a : b) -
              cycleLengths.reduce((a, b) => a < b ? a : b)
        : 0;

    // Trend
    String trend = 'not enough data';
    if (cycleLengths.length >= 3) {
      final firstHalf = cycleLengths.sublist(0, cycleLengths.length ~/ 2);
      final secondHalf = cycleLengths.sublist(cycleLengths.length ~/ 2);
      final firstAvg = firstHalf.reduce((a, b) => a + b) / firstHalf.length;
      final secondAvg = secondHalf.reduce((a, b) => a + b) / secondHalf.length;
      final diff = secondAvg - firstAvg;
      if (diff > 2) {
        trend = 'lengthening';
      } else if (diff < -2) {
        trend = 'shortening';
      } else {
        trend = 'stable';
      }
    }

    // Symptoms
    final symptomCounts = <String, int>{};
    for (final log in logs.values) {
      for (final s in log.symptoms) {
        symptomCounts[s] = (symptomCounts[s] ?? 0) + 1;
      }
    }
    final topSymptoms =
        (symptomCounts.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value)))
            .take(3)
            .map((e) => '${e.key} (${e.value}x)')
            .join(', ');

    // Mood
    final moodCounts = <String, int>{};
    for (final log in logs.values) {
      for (final m in log.moods) {
        moodCounts[m] = (moodCounts[m] ?? 0) + 1;
      }
    }
    final topMood = moodCounts.isNotEmpty
        ? (moodCounts.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value)))
              .first
              .key
        : 'none logged';

    // Flow
    int lightCount = 0, mediumCount = 0, heavyCount = 0;
    for (final log in logs.values) {
      if (log.flow == 'light') lightCount++;
      if (log.flow == 'medium') mediumCount++;
      if (log.flow == 'heavy') heavyCount++;
    }
    final totalFlow = lightCount + mediumCount + heavyCount;

    return {
      'avgCycleLength': avgCycle,
      'avgPeriodDuration': avgDuration,
      'periodsLogged': periods.length,
      'cycleVariation': variation,
      'cycleTrend': trend,
      'topSymptoms': topSymptoms.isNotEmpty ? topSymptoms : 'none logged',
      'topMood': topMood,
      'flowLight': totalFlow > 0 ? (lightCount / totalFlow * 100).round() : 0,
      'flowMedium': totalFlow > 0 ? (mediumCount / totalFlow * 100).round() : 0,
      'flowHeavy': totalFlow > 0 ? (heavyCount / totalFlow * 100).round() : 0,
      if (_prediction != null) 'predictions': _prediction!.toMap(),
      'medicalChecklist': _buildMedicalSummary(logs),
    };
  }

  String _buildMedicalSummary(Map<String, dynamic> logs) {
    final agg = <String, Map<String, int>>{};
    int days = 0;
    for (final log in logs.values) {
      final dl = log as dynamic;
      if (dl.medicalLog == null || (dl.medicalLog as Map).isEmpty) continue;
      days++;
      final medMap = dl.medicalLog as Map<String, String>;
      for (final e in medMap.entries) {
        agg.putIfAbsent(e.key, () => {});
        agg[e.key]![e.value] = (agg[e.key]![e.value] ?? 0) + 1;
      }
    }
    if (agg.isEmpty) return 'none logged';
    final buf = StringBuffer();
    const labels = {
      'pain_level': 'Pain',
      'discharge_color': 'Discharge',
      'skin': 'Skin',
      'hair': 'Hair',
      'sleep': 'Sleep',
      'energy': 'Energy',
      'weight': 'Weight',
      'libido': 'Libido',
      'digestion': 'Digestion',
      'breast': 'Breast',
    };
    for (final entry in agg.entries) {
      final sorted = entry.value.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final total = sorted.fold<int>(0, (s, e) => s + e.value);
      final top = sorted.first;
      buf.write(
        '${labels[entry.key] ?? entry.key}: ${top.key} ${(top.value / total * 100).round()}%; ',
      );
    }
    return '$days days — ${buf.toString().trimRight()}';
  }

  void reset() {
    _status = AiStatus.idle;
    _aiDiagnosis = '';
    _prediction = null;
    _errorMessage = '';
    notifyListeners();
  }

  @override
  void dispose() {
    _lstm.dispose();
    super.dispose();
  }
}
