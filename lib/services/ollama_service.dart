import 'dart:convert';
import 'package:http/http.dart' as http;

class OllamaService {
  static const String _defaultHost = 'http://localhost:11434';
  static const String _defaultModel = 'llama3.2';
  static const Duration _timeout = Duration(seconds: 30);

  String _host;
  String _model;

  OllamaService({String? host, String? model})
    : _host = host ?? _defaultHost,
      _model = model ?? _defaultModel;

  String get host => _host;
  String get model => _model;

  void configure({String? host, String? model}) {
    if (host != null) _host = host;
    if (model != null) _model = model;
  }

  /// Check if Ollama is reachable and the model is available.
  Future<bool> isAvailable() async {
    try {
      final response = await http
          .get(Uri.parse('$_host/api/tags'))
          .timeout(_timeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final models =
            (data['models'] as List?)
                ?.map((m) => m['name'] as String)
                .toList() ??
            [];
        // Check if our model (or a variant) is available
        return models.any((m) => m.startsWith(_model));
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Get available models from Ollama.
  Future<List<String>> getModels() async {
    try {
      final response = await http
          .get(Uri.parse('$_host/api/tags'))
          .timeout(_timeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['models'] as List?)
                ?.map((m) => m['name'] as String)
                .toList() ??
            [];
      }
    } catch (_) {}
    return [];
  }

  /// Generate a diagnosis response from cycle data.
  /// Returns the generated text, or null on failure.
  Future<String?> generateDiagnosis({
    required Map<String, dynamic> cycleData,
  }) async {
    final prompt = _buildDiagnosisPrompt(cycleData);

    try {
      final response = await http
          .post(
            Uri.parse('$_host/api/generate'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'model': _model,
              'prompt': prompt,
              'stream': false,
              'options': {'temperature': 0.3, 'num_predict': 512},
            }),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'] as String?;
      }
    } catch (_) {}
    return null;
  }

  /// Stream a diagnosis response token by token.
  Stream<String> streamDiagnosis({
    required Map<String, dynamic> cycleData,
  }) async* {
    final prompt = _buildDiagnosisPrompt(cycleData);

    try {
      final request = http.Request('POST', Uri.parse('$_host/api/generate'));
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode({
        'model': _model,
        'prompt': prompt,
        'stream': true,
        'options': {'temperature': 0.3, 'num_predict': 512},
      });

      final streamedResponse = await http.Client()
          .send(request)
          .timeout(const Duration(seconds: 60));

      await for (final chunk in streamedResponse.stream.transform(
        utf8.decoder,
      )) {
        // Each chunk may contain multiple JSON objects separated by newlines
        for (final line in chunk.split('\n')) {
          if (line.trim().isEmpty) continue;
          try {
            final data = jsonDecode(line);
            final token = data['response'] as String?;
            if (token != null && token.isNotEmpty) {
              yield token;
            }
            if (data['done'] == true) return;
          } catch (_) {}
        }
      }
    } catch (_) {
      // Stream error — caller handles gracefully
    }
  }

  String _buildDiagnosisPrompt(Map<String, dynamic> data) {
    return '''You are a women's health assistant embedded in a period tracking app called Luna.
Analyze the following cycle data and provide a brief, empathetic health summary.

CYCLE DATA:
- Average cycle length: ${data['avgCycleLength']} days
- Average period duration: ${data['avgPeriodDuration']} days
- Number of periods logged: ${data['periodsLogged']}
- Cycle variation (max - min): ${data['cycleVariation']} days
- Cycle trend: ${data['cycleTrend']}
- Most common symptoms: ${data['topSymptoms']}
- Most common mood: ${data['topMood']}
- Flow pattern: Light ${data['flowLight']}%, Medium ${data['flowMedium']}%, Heavy ${data['flowHeavy']}%
${data['predictions'] != null ? '- LSTM predicted next cycle: ${data['predictions']['nextCycleLength']} days' : ''}
${data['predictions'] != null ? '- LSTM predicted next period duration: ${data['predictions']['nextPeriodDuration']} days' : ''}
- Medical checklist: ${data['medicalChecklist']}

RULES:
1. Be concise — max 3-4 short paragraphs
2. Start with a brief overall assessment
3. Mention any patterns worth noting (symptoms, moods correlated with cycle phase)
4. If anything seems atypical, gently suggest consulting a healthcare provider
5. End with one actionable wellness tip for their current phase
6. Do NOT diagnose medical conditions — only flag patterns
7. Be warm and supportive in tone
8. Use plain language, no medical jargon

RESPONSE:''';
  }
}
