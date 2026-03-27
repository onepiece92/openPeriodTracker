import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class CyclePrediction {
  final double nextCycleLength;
  final double nextPeriodDuration;
  final bool fromModel; // true = LSTM, false = statistical fallback

  CyclePrediction({
    required this.nextCycleLength,
    required this.nextPeriodDuration,
    required this.fromModel,
  });

  Map<String, dynamic> toMap() => {
        'nextCycleLength': nextCycleLength.round(),
        'nextPeriodDuration': nextPeriodDuration.round(),
        'fromModel': fromModel,
      };
}

class LstmService {
  Interpreter? _interpreter;
  Map<String, dynamic>? _normParams;
  bool _isLoaded = false;
  bool _modelAvailable = false;

  bool get isLoaded => _isLoaded;
  bool get hasModel => _modelAvailable;

  /// Initialize the service — load model + normalization params.
  Future<void> initialize() async {
    await _loadNormParams();
    await _loadModel();
    _isLoaded = true;
  }

  Future<void> _loadNormParams() async {
    try {
      final jsonStr =
          await rootBundle.loadString('assets/models/norm_params.json');
      _normParams = jsonDecode(jsonStr);
    } catch (e) {
      // Use defaults
      _normParams = {
        'x_mean': [28.0, 5.0],
        'x_std': [4.0, 1.5],
        'y_mean': [28.0, 5.0],
        'y_std': [4.0, 1.5],
        'sequence_length': 6,
      };
    }
  }

  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('models/cycle_predictor.tflite');
      _modelAvailable = true;
    } catch (_) {
      _modelAvailable = false;
      // Model not available — will use statistical fallback
    }
  }

  /// Predict next cycle length and period duration.
  ///
  /// [cycleLengths] — list of past cycle lengths in days (oldest first).
  /// [periodDurations] — list of past period durations in days (oldest first).
  ///
  /// Both lists should have the same length. Uses last N entries per sequence_length.
  CyclePrediction? predict({
    required List<int> cycleLengths,
    required List<int> periodDurations,
  }) {
    if (cycleLengths.isEmpty || periodDurations.isEmpty) return null;
    if (cycleLengths.length != periodDurations.length) return null;

    // If model is available, try LSTM prediction
    if (_modelAvailable && _interpreter != null && _normParams != null) {
      final result = _predictWithModel(cycleLengths, periodDurations);
      if (result != null) return result;
    }

    // Fallback to statistical prediction
    return _predictStatistical(cycleLengths, periodDurations);
  }

  CyclePrediction? _predictWithModel(
      List<int> cycleLengths, List<int> periodDurations) {
    try {
      final seqLen = (_normParams!['sequence_length'] as num).toInt();
      final xMean = List<double>.from(_normParams!['x_mean']);
      final xStd = List<double>.from(_normParams!['x_std']);
      final yMean = List<double>.from(_normParams!['y_mean']);
      final yStd = List<double>.from(_normParams!['y_std']);

      // Pad or trim to sequence length
      List<List<double>> sequence = [];
      final len = cycleLengths.length;

      if (len >= seqLen) {
        // Use last seqLen entries
        for (int i = len - seqLen; i < len; i++) {
          sequence.add([
            (cycleLengths[i].toDouble() - xMean[0]) / xStd[0],
            (periodDurations[i].toDouble() - xMean[1]) / xStd[1],
          ]);
        }
      } else {
        // Pad with mean values (normalized to 0)
        for (int i = 0; i < seqLen - len; i++) {
          sequence.add([0.0, 0.0]);
        }
        for (int i = 0; i < len; i++) {
          sequence.add([
            (cycleLengths[i].toDouble() - xMean[0]) / xStd[0],
            (periodDurations[i].toDouble() - xMean[1]) / xStd[1],
          ]);
        }
      }

      // Shape: [1, seqLen, 2]
      final input = [sequence];
      // Output shape: [1, 2]
      final output = List.filled(1, List.filled(2, 0.0));

      _interpreter!.run(input, output);

      // Denormalize
      final predCycle = output[0][0] * yStd[0] + yMean[0];
      final predPeriod = output[0][1] * yStd[1] + yMean[1];

      return CyclePrediction(
        nextCycleLength: predCycle > 0 ? predCycle : 1.0,
        nextPeriodDuration: predPeriod > 0 ? predPeriod : 1.0,
        fromModel: true,
      );
    } catch (_) {
      return null;
    }
  }

  /// Weighted moving average fallback.
  /// More recent cycles get higher weight.
  CyclePrediction _predictStatistical(
      List<int> cycleLengths, List<int> periodDurations) {
    final cycleP = _weightedMovingAverage(cycleLengths);
    final periodP = _weightedMovingAverage(periodDurations);

    return CyclePrediction(
      nextCycleLength: cycleP > 0 ? cycleP : 1.0,
      nextPeriodDuration: periodP > 0 ? periodP : 1.0,
      fromModel: false,
    );
  }

  double _weightedMovingAverage(List<int> values) {
    if (values.isEmpty) return 28.0;
    if (values.length == 1) return values.first.toDouble();

    // Use last 6 values max, with exponentially increasing weights
    final n = values.length > 6 ? 6 : values.length;
    final recent = values.sublist(values.length - n);

    double weightSum = 0;
    double valueSum = 0;
    for (int i = 0; i < recent.length; i++) {
      final weight = (i + 1).toDouble(); // 1, 2, 3, ... n
      weightSum += weight;
      valueSum += recent[i] * weight;
    }
    return valueSum / weightSum;
  }

  void dispose() {
    _interpreter?.close();
  }
}
