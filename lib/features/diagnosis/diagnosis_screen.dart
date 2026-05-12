import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/period_provider.dart';
import '../../core/providers/daily_log_provider.dart';
import '../../core/providers/settings_provider.dart';
import '../../services/ai_diagnosis_provider.dart';
import '../../services/lstm_service.dart';
import 'diet_tab.dart';

class DiagnosisScreen extends StatefulWidget {
  const DiagnosisScreen({super.key});

  @override
  State<DiagnosisScreen> createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends State<DiagnosisScreen> {
  int _activeTab = 0; // 0 = Diagnosis, 1 = Diet
  String _location = '';
  String _region = '';
  bool _loadingLocation = false;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    setState(() => _loadingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _location = 'Location denied';
          _region = 'global';
          _loadingLocation = false;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
        ),
      );
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          _location = [
            place.locality,
            place.country,
          ].where((s) => s != null && s.isNotEmpty).join(', ');
          _region = _detectRegion(place.isoCountryCode ?? '');
        });
      }
    } catch (_) {
      setState(() {
        _location = 'Location unavailable';
        _region = 'global';
      });
    }
    setState(() => _loadingLocation = false);
  }

  String _detectRegion(String countryCode) {
    const southAsian = {'IN', 'PK', 'BD', 'LK', 'NP', 'BT', 'MV'};
    const eastAsian = {'CN', 'JP', 'KR', 'TW', 'MN'};
    const southeastAsian = {
      'TH',
      'VN',
      'PH',
      'ID',
      'MY',
      'SG',
      'MM',
      'KH',
      'LA',
    };
    const middleEastern = {
      'SA',
      'AE',
      'QA',
      'KW',
      'BH',
      'OM',
      'IR',
      'IQ',
      'JO',
      'LB',
      'TR',
    };
    const african = {
      'NG',
      'KE',
      'GH',
      'ZA',
      'ET',
      'TZ',
      'UG',
      'EG',
      'MA',
      'DZ',
    };
    const latinAmerican = {
      'MX',
      'BR',
      'AR',
      'CO',
      'PE',
      'CL',
      'VE',
      'EC',
      'BO',
      'PY',
    };
    const european = {
      'GB',
      'DE',
      'FR',
      'IT',
      'ES',
      'PT',
      'NL',
      'BE',
      'SE',
      'NO',
      'DK',
      'FI',
      'PL',
      'AT',
      'CH',
      'IE',
      'GR',
      'CZ',
      'RO',
      'HU',
    };

    final cc = countryCode.toUpperCase();
    if (southAsian.contains(cc)) return 'south_asian';
    if (eastAsian.contains(cc)) return 'east_asian';
    if (southeastAsian.contains(cc)) return 'southeast_asian';
    if (middleEastern.contains(cc)) return 'middle_eastern';
    if (african.contains(cc)) return 'african';
    if (latinAmerican.contains(cc)) return 'latin_american';
    if (european.contains(cc)) return 'european';
    if (cc == 'US' || cc == 'CA' || cc == 'AU' || cc == 'NZ') return 'western';
    return 'global';
  }

  @override
  Widget build(BuildContext context) {
    final periodProvider = context.watch<PeriodProvider>();
    final logProvider = context.watch<DailyLogProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final periods = periodProvider.periods;
    final avgCycle = periodProvider.averageCycleLength;
    final logs = logProvider.allLogs;
    final phase = periodProvider.currentPhase;

    final cycleLengths = periodProvider.cycleLengths;
    final hasEnoughData = cycleLengths.length >= 2;

    return SafeArea(
      child: Column(
        children: [
          // Header with location
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Diagnosis', style: AppTextStyles.appTitle),
                      const SizedBox(height: 4),
                      Text(
                        'Cycle health insights',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
                // Location badge
                GestureDetector(
                  onTap: _loadingLocation ? null : _fetchLocation,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.follicularBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.follicular.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: _loadingLocation
                              ? AppColors.textMuted
                              : AppColors.follicular,
                        ),
                        const SizedBox(width: 4),
                        _loadingLocation
                            ? SizedBox(
                                width: 10,
                                height: 10,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  valueColor: AlwaysStoppedAnimation(
                                    AppColors.follicular,
                                  ),
                                ),
                              )
                            : Text(
                                _location.isNotEmpty
                                    ? _location
                                    : 'Locating...',
                                style: AppTextStyles.small.copyWith(
                                  color: AppColors.follicular,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Tab switcher
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  _TabPill(
                    label: '🩺 Diagnosis',
                    isActive: _activeTab == 0,
                    onTap: () => setState(() => _activeTab = 0),
                  ),
                  _TabPill(
                    label: '🥗 Diet & Nutrition',
                    isActive: _activeTab == 1,
                    onTap: () => setState(() => _activeTab = 1),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Tab content
          Expanded(
            child: _activeTab == 0
                ? _buildDiagnosisTab(
                    periodProvider: periodProvider,
                    settingsProvider: settingsProvider,
                    periods: periods,
                    logs: logs,
                    avgCycle: avgCycle,
                    cycleLengths: cycleLengths,
                    hasEnoughData: hasEnoughData,
                  )
                : DietTab(
                    phase: phase,
                    region: _region,
                    location: _location,
                    periodProvider: periodProvider,
                    logProvider: logProvider,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosisTab({
    required PeriodProvider periodProvider,
    required SettingsProvider settingsProvider,
    required List periods,
    required Map logs,
    required int avgCycle,
    required List<int> cycleLengths,
    required bool hasEnoughData,
  }) {
    // Symptom frequency
    final symptomCounts = <String, int>{};
    for (final log in logs.values) {
      final dl = log as dynamic;
      for (final s in dl.symptoms) {
        symptomCounts[s as String] = (symptomCounts[s] ?? 0) + 1;
      }
    }
    final sortedSymptoms = symptomCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Mood frequency
    final moodCounts = <String, int>{};
    for (final log in logs.values) {
      final dl = log as dynamic;
      for (final m in dl.moods) {
        moodCounts[m as String] = (moodCounts[m] ?? 0) + 1;
      }
    }
    final sortedMoods = moodCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final totalMoodLogs = moodCounts.values.fold(0, (a, b) => a + b);

    // Flow distribution
    final flowCounts = <String, int>{'light': 0, 'medium': 0, 'heavy': 0};
    for (final log in logs.values) {
      final dl = log as dynamic;
      if (dl.flow != null && flowCounts.containsKey(dl.flow)) {
        flowCounts[dl.flow as String] = flowCounts[dl.flow]! + 1;
      }
    }
    final totalFlowLogs = flowCounts.values.fold(0, (a, b) => a + b);

    final avgPeriodDuration = periodProvider.averagePeriodLength.toDouble();

    String? cycleTrend;
    if (cycleLengths.length >= 3) {
      final firstHalf = cycleLengths.sublist(0, cycleLengths.length ~/ 2);
      final secondHalf = cycleLengths.sublist(cycleLengths.length ~/ 2);
      final firstAvg = firstHalf.reduce((a, b) => a + b) / firstHalf.length;
      final secondAvg = secondHalf.reduce((a, b) => a + b) / secondHalf.length;
      final diff = secondAvg - firstAvg;
      if (diff > 2) {
        cycleTrend = 'lengthening';
      } else if (diff < -2) {
        cycleTrend = 'shortening';
      } else {
        cycleTrend = 'stable';
      }
    }

    final healthScore = _calculateHealthScore(
      cycleLengths: cycleLengths,
      avgCycle: avgCycle,
      avgPeriodDuration: avgPeriodDuration,
      hasEnoughData: hasEnoughData,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!hasEnoughData && logs.isEmpty)
            _buildEmptyState()
          else ...[
            if (hasEnoughData) ...[
              _HealthScoreCard(score: healthScore),
              const SizedBox(height: 16),
            ],

            _AiSection(
              periods: periods,
              logs: logs,
              settingsCycleLength: settingsProvider.cycleLength,
              settingsPeriodLength: settingsProvider.periodLength,
              hasEnoughData: hasEnoughData,
            ),

            if (hasEnoughData) ...[
              Text('CYCLE CHECKS', style: AppTextStyles.label),
              const SizedBox(height: 8),

              _DiagnosisCard(
                icon: _getRegularityIcon(cycleLengths),
                title: 'Cycle Regularity',
                status: _getRegularityStatus(cycleLengths),
                statusColor: _getRegularityColor(cycleLengths),
                description: _getRegularityDescription(cycleLengths, avgCycle),
              ),
              const SizedBox(height: 8),

              _DiagnosisCard(
                icon: avgCycle >= 21 && avgCycle <= 35 ? '✅' : '⚠️',
                title: 'Cycle Length',
                status: avgCycle >= 21 && avgCycle <= 35
                    ? 'Normal'
                    : 'Atypical',
                statusColor: avgCycle >= 21 && avgCycle <= 35
                    ? AppColors.ovulation
                    : AppColors.menstrual,
                description: avgCycle >= 21 && avgCycle <= 35
                    ? 'Your average cycle of $avgCycle days falls within the normal range (21–35 days).'
                    : 'Your average cycle of $avgCycle days is outside the typical range (21–35 days). Consider discussing with your healthcare provider.',
              ),
              const SizedBox(height: 8),

              _buildPeriodDurationCard(periods),
              const SizedBox(height: 8),

              if (cycleTrend != null)
                _DiagnosisCard(
                  icon: cycleTrend == 'stable' ? '✅' : '📈',
                  title: 'Cycle Trend',
                  status: cycleTrend == 'stable'
                      ? 'Stable'
                      : cycleTrend == 'lengthening'
                      ? 'Lengthening'
                      : 'Shortening',
                  statusColor: cycleTrend == 'stable'
                      ? AppColors.ovulation
                      : const Color(0xFFD4A340),
                  description: _cycleTrendDescription(cycleTrend, cycleLengths),
                ),
              const SizedBox(height: 20),
            ],

            if (sortedSymptoms.isNotEmpty) ...[
              Text('SYMPTOM PATTERNS', style: AppTextStyles.label),
              const SizedBox(height: 8),
              _SymptomAnalysisCard(symptoms: sortedSymptoms),
              const SizedBox(height: 20),
            ],

            if (sortedMoods.isNotEmpty) ...[
              Text('MOOD PATTERNS', style: AppTextStyles.label),
              const SizedBox(height: 8),
              _MoodAnalysisCard(moods: sortedMoods, totalLogs: totalMoodLogs),
              const SizedBox(height: 20),
            ],

            if (totalFlowLogs > 0) ...[
              Text('FLOW ANALYSIS', style: AppTextStyles.label),
              const SizedBox(height: 8),
              _FlowAnalysisCard(
                flowCounts: flowCounts,
                totalLogs: totalFlowLogs,
              ),
              const SizedBox(height: 20),
            ],

            if (hasEnoughData) ...[
              Text('CONSIDER DISCUSSING', style: AppTextStyles.label),
              const SizedBox(height: 8),
              _buildDoctorSuggestions(
                cycleLengths: cycleLengths,
                avgCycle: avgCycle,
                avgPeriodDuration: avgPeriodDuration,
                symptomCounts: symptomCounts,
                flowCounts: flowCounts,
                totalFlowLogs: totalFlowLogs,
              ),
              const SizedBox(height: 20),
            ],

            // AI Prompt for diagnosis
            Text('ASK AI FOR MORE', style: AppTextStyles.label),
            const SizedBox(height: 8),
            _AiDiagnosisPromptCard(
              periodProvider: periodProvider,
              logProvider: context.watch<DailyLogProvider>(),
              settingsProvider: settingsProvider,
            ),
            const SizedBox(height: 20),

            _buildDisclaimer(),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: AppDecorations.card,
      child: Column(
        children: [
          const Text('📊', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text('Not enough data yet', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 8),
          Text(
            'Log periods, moods, symptoms, and flow so Luna can analyze your cycle patterns and provide health insights.',
            style: AppTextStyles.body,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodDurationCard(List periods) {
    if (periods.isEmpty) return const SizedBox.shrink();
    final avgDuration =
        periods.map((p) => p.durationDays as int).reduce((a, b) => a + b) /
        periods.length;
    final normal = avgDuration >= 2 && avgDuration <= 7;
    return _DiagnosisCard(
      icon: normal ? '✅' : '⚠️',
      title: 'Period Duration',
      status: normal ? 'Normal' : 'Atypical',
      statusColor: normal ? AppColors.ovulation : AppColors.menstrual,
      description: normal
          ? 'Your average period lasts ${avgDuration.round()} days, within the normal range (2–7 days).'
          : 'Your average period lasts ${avgDuration.round()} days, outside the typical range (2–7 days). Worth mentioning to your doctor.',
    );
  }

  String _cycleTrendDescription(String trend, List<int> lengths) {
    final recent = lengths.last;
    if (trend == 'stable') {
      return 'Your cycle lengths have remained consistent. Most recent cycle was $recent days.';
    } else if (trend == 'lengthening') {
      return 'Your cycles appear to be getting longer over time. Most recent was $recent days. Minor shifts are normal, but consistent lengthening is worth tracking.';
    } else {
      return 'Your cycles appear to be getting shorter over time. Most recent was $recent days. This can be normal, but mention it at your next checkup if it continues.';
    }
  }

  Widget _buildDoctorSuggestions({
    required List<int> cycleLengths,
    required int avgCycle,
    required double avgPeriodDuration,
    required Map<String, int> symptomCounts,
    required Map<String, int> flowCounts,
    required int totalFlowLogs,
  }) {
    final suggestions = <_DoctorSuggestion>[];

    // Irregular cycles
    final variation = _getVariation(cycleLengths);
    if (variation > 7) {
      suggestions.add(
        _DoctorSuggestion(
          icon: '🔄',
          text:
              'Irregular cycles (${variation}d variation) — could indicate hormonal changes, PCOS, thyroid issues, or stress.',
        ),
      );
    }

    // Very short or long cycles
    if (avgCycle < 21) {
      suggestions.add(
        _DoctorSuggestion(
          icon: '⏱️',
          text:
              'Short cycles (<21 days) — may indicate anovulation or luteal phase deficiency.',
        ),
      );
    } else if (avgCycle > 35) {
      suggestions.add(
        _DoctorSuggestion(
          icon: '⏱️',
          text:
              'Long cycles (>35 days) — could be related to PCOS, stress, or thyroid function.',
        ),
      );
    }

    // Heavy flow dominance
    if (totalFlowLogs >= 3) {
      final heavyPct = (flowCounts['heavy']! / totalFlowLogs * 100).round();
      if (heavyPct >= 60) {
        suggestions.add(
          _DoctorSuggestion(
            icon: '💧',
            text:
                'Heavy flow logged $heavyPct% of the time — if you soak through pads/tampons hourly, discuss with your provider.',
          ),
        );
      }
    }

    // Long periods
    if (avgPeriodDuration > 7) {
      suggestions.add(
        _DoctorSuggestion(
          icon: '📅',
          text:
              'Periods averaging ${avgPeriodDuration.round()} days — periods longer than 7 days may warrant evaluation.',
        ),
      );
    }

    // Frequent severe symptoms
    final crampCount = symptomCounts['Cramps'] ?? 0;
    final totalLogs = cycleLengths.isNotEmpty
        ? cycleLengths.reduce((a, b) => a + b)
        : 0;
    if (crampCount > 0 && totalLogs > 0 && crampCount / totalLogs > 0.5) {
      suggestions.add(
        _DoctorSuggestion(
          icon: '🩹',
          text:
              'Frequent cramps — logged in over half your cycle days. Severe menstrual pain may indicate endometriosis or fibroids.',
        ),
      );
    }

    if (suggestions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: AppDecorations.card,
        child: Row(
          children: [
            const Text('🎉', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'No red flags based on your logged data. Keep tracking to build a more complete picture!',
                style: AppTextStyles.body.copyWith(height: 1.4),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.menstrual.withValues(alpha: 0.2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0FA08CB0),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🩺', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Worth mentioning at your next visit',
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...suggestions.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.icon, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      s.text,
                      style: AppTextStyles.body.copyWith(height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.follicularBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.follicular.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ℹ️', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'These insights are based on your logged data and general guidelines. They are not medical advice. Always consult a healthcare professional for concerns.',
              style: AppTextStyles.small.copyWith(
                color: AppColors.follicular,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Regularity helpers ---

  String _getRegularityIcon(List<int> lengths) {
    final variation = _getVariation(lengths);
    if (variation <= 3) return '✅';
    if (variation <= 7) return '🔶';
    return '⚠️';
  }

  String _getRegularityStatus(List<int> lengths) {
    final variation = _getVariation(lengths);
    if (variation <= 3) return 'Regular';
    if (variation <= 7) return 'Slightly Irregular';
    return 'Irregular';
  }

  Color _getRegularityColor(List<int> lengths) {
    final variation = _getVariation(lengths);
    if (variation <= 3) return AppColors.ovulation;
    if (variation <= 7) return const Color(0xFFD4A340);
    return AppColors.menstrual;
  }

  String _getRegularityDescription(List<int> lengths, int avg) {
    final variation = _getVariation(lengths);
    if (variation <= 3) {
      return 'Your cycles vary by only $variation days. This is considered very regular — great sign!';
    }
    if (variation <= 7) {
      return 'Your cycles vary by $variation days. Some variation is normal, especially with stress or lifestyle changes.';
    }
    return 'Your cycles vary by $variation days. Higher variation can be common, but if persistent, consider talking to your healthcare provider.';
  }

  int _getVariation(List<int> lengths) {
    if (lengths.isEmpty) return 0;
    final max = lengths.reduce((a, b) => a > b ? a : b);
    final min = lengths.reduce((a, b) => a < b ? a : b);
    return max - min;
  }

  int _calculateHealthScore({
    required List<int> cycleLengths,
    required int avgCycle,
    required double avgPeriodDuration,
    required bool hasEnoughData,
  }) {
    if (!hasEnoughData) return 0;

    var score = 100;

    // Regularity (-0 to -30)
    final variation = _getVariation(cycleLengths);
    if (variation > 7) {
      score -= 30;
    } else if (variation > 3) {
      score -= 15;
    }

    // Cycle length (-0 to -20)
    if (avgCycle < 21 || avgCycle > 35) {
      score -= 20;
    } else if (avgCycle < 24 || avgCycle > 32) {
      score -= 5;
    }

    // Period duration (-0 to -15)
    if (avgPeriodDuration > 7 || avgPeriodDuration < 2) {
      score -= 15;
    }

    // Trend penalty (-0 to -10)
    if (cycleLengths.length >= 3) {
      final firstHalf = cycleLengths.sublist(0, cycleLengths.length ~/ 2);
      final secondHalf = cycleLengths.sublist(cycleLengths.length ~/ 2);
      final firstAvg = firstHalf.reduce((a, b) => a + b) / firstHalf.length;
      final secondAvg = secondHalf.reduce((a, b) => a + b) / secondHalf.length;
      if ((secondAvg - firstAvg).abs() > 3) score -= 10;
    }

    return score.clamp(0, 100);
  }
}

// --- Widgets ---

class _HealthScoreCard extends StatelessWidget {
  final int score;

  const _HealthScoreCard({required this.score});

  Color get _scoreColor {
    if (score >= 80) return AppColors.ovulation;
    if (score >= 60) return const Color(0xFFD4A340);
    return AppColors.menstrual;
  }

  String get _scoreLabel {
    if (score >= 80) return 'Healthy';
    if (score >= 60) return 'Fair';
    return 'Needs Attention';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _scoreColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _scoreColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            height: 72,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 6,
                  backgroundColor: _scoreColor.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation(_scoreColor),
                  strokeCap: StrokeCap.round,
                ),
                Text(
                  '$score',
                  style: AppTextStyles.mediumNumber.copyWith(
                    color: _scoreColor,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cycle Health Score',
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _scoreColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _scoreLabel,
                    style: AppTextStyles.small.copyWith(
                      color: _scoreColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Based on regularity, cycle length, period duration, and trends.',
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.textMuted,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DiagnosisCard extends StatelessWidget {
  final String icon;
  final String title;
  final String status;
  final Color statusColor;
  final String description;

  const _DiagnosisCard({
    required this.icon,
    required this.title,
    required this.status,
    required this.statusColor,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  status,
                  style: AppTextStyles.small.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(description, style: AppTextStyles.body.copyWith(height: 1.4)),
        ],
      ),
    );
  }
}

class _SymptomAnalysisCard extends StatelessWidget {
  final List<MapEntry<String, int>> symptoms;

  const _SymptomAnalysisCard({required this.symptoms});

  @override
  Widget build(BuildContext context) {
    final max = symptoms.first.value;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Most Logged Symptoms',
            style: AppTextStyles.button.copyWith(
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 14),
          ...symptoms.take(5).map((entry) {
            final pct = entry.value / max;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 100,
                    child: Text(
                      entry.key,
                      style: AppTextStyles.body.copyWith(fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 8,
                        backgroundColor: AppColors.cardBorder,
                        valueColor: const AlwaysStoppedAnimation(
                          Color(0xFF5BA4A4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 24,
                    child: Text(
                      '${entry.value}',
                      style: AppTextStyles.small.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            );
          }),
          if (symptoms.length > 5)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '+ ${symptoms.length - 5} more symptoms tracked',
                style: AppTextStyles.small.copyWith(color: AppColors.textMuted),
              ),
            ),
        ],
      ),
    );
  }
}

class _MoodAnalysisCard extends StatelessWidget {
  final List<MapEntry<String, int>> moods;
  final int totalLogs;

  const _MoodAnalysisCard({required this.moods, required this.totalLogs});

  static const moodEmojis = {
    'Happy': '😊',
    'Tired': '😴',
    'Sad': '😢',
    'Irritable': '😤',
    'Loving': '🥰',
    'Anxious': '😰',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mood Distribution',
            style: AppTextStyles.button.copyWith(
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 14),
          // Mood bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 24,
              child: Row(
                children: moods.map((entry) {
                  final pct = entry.value / totalLogs;
                  return Expanded(
                    flex: (pct * 100).round().clamp(1, 100),
                    child: Container(color: _moodColor(entry.key)),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Legend
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: moods.map((entry) {
              final pct = (entry.value / totalLogs * 100).round();
              final emoji = moodEmojis[entry.key] ?? '•';
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _moodColor(entry.key),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$emoji $pct%',
                    style: AppTextStyles.small.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
          if (moods.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Most common mood: ${moodEmojis[moods.first.key] ?? ''} ${moods.first.key} (${moods.first.value} logs)',
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _moodColor(String mood) {
    switch (mood) {
      case 'Happy':
        return AppColors.ovulation;
      case 'Tired':
        return AppColors.follicular;
      case 'Sad':
        return const Color(0xFF7B9ED9);
      case 'Irritable':
        return AppColors.menstrual;
      case 'Loving':
        return const Color(0xFFE88FB4);
      case 'Anxious':
        return AppColors.luteal;
      default:
        return AppColors.textMuted;
    }
  }
}

class _FlowAnalysisCard extends StatelessWidget {
  final Map<String, int> flowCounts;
  final int totalLogs;

  const _FlowAnalysisCard({required this.flowCounts, required this.totalLogs});

  @override
  Widget build(BuildContext context) {
    final lightPct = (flowCounts['light']! / totalLogs * 100).round();
    final mediumPct = (flowCounts['medium']! / totalLogs * 100).round();
    final heavyPct = (flowCounts['heavy']! / totalLogs * 100).round();

    // Determine dominant flow
    String dominantFlow;
    if (heavyPct >= mediumPct && heavyPct >= lightPct) {
      dominantFlow = 'heavy';
    } else if (mediumPct >= lightPct) {
      dominantFlow = 'medium';
    } else {
      dominantFlow = 'light';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Flow Distribution',
            style: AppTextStyles.button.copyWith(
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _FlowBar(label: 'Light', pct: lightPct, drops: 1),
              const SizedBox(width: 12),
              _FlowBar(label: 'Medium', pct: mediumPct, drops: 2),
              const SizedBox(width: 12),
              _FlowBar(label: 'Heavy', pct: heavyPct, drops: 3),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Predominantly $dominantFlow flow ($totalLogs days logged)',
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _FlowBar extends StatelessWidget {
  final String label;
  final int pct;
  final int drops;

  const _FlowBar({required this.label, required this.pct, required this.drops});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '$pct%',
            style: AppTextStyles.mediumNumber.copyWith(
              fontSize: 18,
              color: AppColors.menstrual,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              color: AppColors.menstrualBg,
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: pct / 100,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: AppColors.menstrual.withValues(
                    alpha: 0.3 + (drops * 0.23),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              drops,
              (_) => const Icon(
                Icons.water_drop,
                size: 10,
                color: AppColors.menstrual,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.small),
        ],
      ),
    );
  }
}

class _DoctorSuggestion {
  final String icon;
  final String text;
  const _DoctorSuggestion({required this.icon, required this.text});
}

// --- Tab Pill ---

class _TabPill extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabPill({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive
                ? const [
                    BoxShadow(
                      color: Color(0x0FA08CB0),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: isActive ? AppColors.textPrimary : AppColors.textMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}



class _AiDiagnosisPromptCard extends StatefulWidget {
  final PeriodProvider periodProvider;
  final DailyLogProvider logProvider;
  final SettingsProvider settingsProvider;

  const _AiDiagnosisPromptCard({
    required this.periodProvider,
    required this.logProvider,
    required this.settingsProvider,
  });

  @override
  State<_AiDiagnosisPromptCard> createState() => _AiDiagnosisPromptCardState();
}

class _AiDiagnosisPromptCardState extends State<_AiDiagnosisPromptCard> {
  bool _expanded = false;
  bool _copied = false;

  String _buildPrompt() {
    final pp = widget.periodProvider;
    final sp = widget.settingsProvider;
    final logs = widget.logProvider.allLogs;
    final cl = pp.cycleLengths;
    final avgCycle = pp.averageCycleLength;
    final avgPeriod = pp.averagePeriodLength;
    final age = sp.userAge;
    final phase = pp.currentPhase;
    final cycleDay = pp.currentCycleDay;

    // Cycle stats
    final shortest = cl.isNotEmpty ? cl.reduce((a, b) => a < b ? a : b) : null;
    final longest = cl.isNotEmpty ? cl.reduce((a, b) => a > b ? a : b) : null;
    final variation = shortest != null ? longest! - shortest : 0;

    // Trend
    String trend = 'not enough data';
    if (cl.length >= 3) {
      final first = cl.sublist(0, cl.length ~/ 2);
      final second = cl.sublist(cl.length ~/ 2);
      final diff =
          (second.reduce((a, b) => a + b) / second.length) -
          (first.reduce((a, b) => a + b) / first.length);
      if (diff > 2) {
        trend = 'getting longer';
      } else if (diff < -2) {
        trend = 'getting shorter';
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
            .take(5)
            .map((e) => '${e.key} (${e.value}x)')
            .join(', ');

    // Moods
    final moodCounts = <String, int>{};
    for (final log in logs.values) {
      for (final m in log.moods) {
        moodCounts[m] = (moodCounts[m] ?? 0) + 1;
      }
    }
    final topMoods =
        (moodCounts.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value)))
            .take(5)
            .map((e) => '${e.key} (${e.value}x)')
            .join(', ');

    // Flow
    int light = 0, medium = 0, heavy = 0;
    for (final log in logs.values) {
      if (log.flow == 'light') light++;
      if (log.flow == 'medium') medium++;
      if (log.flow == 'heavy') heavy++;
    }
    final totalFlow = light + medium + heavy;

    // Period durations
    final durations = pp.periodDurations;
    final shortestP = durations.isNotEmpty
        ? durations.reduce((a, b) => a < b ? a : b)
        : null;
    final longestP = durations.isNotEmpty
        ? durations.reduce((a, b) => a > b ? a : b)
        : null;

    // Medical checklist
    final medAgg = <String, Map<String, int>>{};
    int medDays = 0;
    for (final log in logs.values) {
      if (log.medicalLog.isEmpty) continue;
      medDays++;
      for (final e in log.medicalLog.entries) {
        medAgg.putIfAbsent(e.key, () => {});
        medAgg[e.key]![e.value] = (medAgg[e.key]![e.value] ?? 0) + 1;
      }
    }
    final medSummary = StringBuffer();
    for (final entry in medAgg.entries) {
      final sorted = entry.value.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final total = sorted.fold<int>(0, (s, e) => s + e.value);
      final line = sorted
          .map((e) => '${e.key}: ${(e.value / total * 100).round()}%')
          .join(', ');
      medSummary.writeln('- ${_label(entry.key)}: $line');
    }

    return '''I'm tracking my menstrual cycle and need a detailed health analysis. Here is my complete data:

PERSONAL:
${age != null ? '- Age: $age years old' : '- Age: not provided'}
- Cycle day today: Day $cycleDay
- Current phase: ${AppColors.phaseName(phase)}

CYCLE DATA (${pp.periods.length} periods tracked):
- Average cycle length: $avgCycle days
- Cycle range: ${shortest ?? '?'}–${longest ?? '?'} days
- Cycle variation: ${variation}d (${variation <= 3
        ? 'regular'
        : variation <= 7
        ? 'slightly irregular'
        : 'irregular'})
- Cycle trend: $trend
- Average period duration: $avgPeriod days
- Period range: ${shortestP ?? '?'}–${longestP ?? '?'} days
- All cycle lengths: ${cl.isNotEmpty ? cl.join(', ') : 'N/A'}

SYMPTOMS (frequency over tracking period):
${topSymptoms.isNotEmpty ? topSymptoms : 'None logged'}

MOODS (frequency):
${topMoods.isNotEmpty ? topMoods : 'None logged'}

FLOW PATTERN:
${totalFlow > 0 ? 'Light ${(light / totalFlow * 100).round()}%, Medium ${(medium / totalFlow * 100).round()}%, Heavy ${(heavy / totalFlow * 100).round()}% (over $totalFlow logged days)' : 'Not logged'}

MEDICAL CHECKLIST ($medDays days logged):
${medSummary.toString().trimRight().isNotEmpty ? medSummary.toString().trimRight() : 'Not logged yet'}

Please analyze this data and provide:
1. Overall cycle health assessment — is my cycle regular, healthy, or showing any concerning patterns?
2. What my symptom patterns might indicate (nutrient deficiencies, hormonal imbalances, conditions to be aware of)
3. How my mood patterns relate to my cycle phases — and what I can do about negative mood patterns
4. Whether my flow pattern is normal or warrants attention
5. ${age != null ? 'Age-specific considerations for a $age-year-old' : 'General reproductive health considerations'}
6. Red flags — anything in this data that I should bring up with my gynecologist
7. Specific lifestyle, supplement, and dietary recommendations based on MY data (not generic)
8. What additional data I should track to get better insights

Be specific, reference my actual numbers, and explain the reasoning. Flag anything that warrants medical attention but don't diagnose — suggest what to ask my doctor about.''';
  }

  String _label(String key) {
    const map = {
      'pain_level': 'Pain Level',
      'discharge_color': 'Discharge Color',
      'discharge_consistency': 'Discharge Type',
      'weight': 'Weight',
      'skin': 'Skin',
      'hair': 'Hair',
      'sleep': 'Sleep',
      'libido': 'Libido',
      'digestion': 'Digestion',
      'breast': 'Breast',
      'energy': 'Energy',
    };
    return map[key] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    final prompt = _buildPrompt();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.menstrual.withValues(alpha: 0.06),
            AppColors.luteal.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.menstrual.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🩺', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Get AI Health Analysis',
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Copy this prompt to Gemini, ChatGPT, or Claude',
                      style: AppTextStyles.small.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: prompt));
                  setState(() => _copied = true);
                  Future.delayed(const Duration(seconds: 2), () {
                    if (mounted) setState(() => _copied = false);
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _copied ? AppColors.ovulation : AppColors.menstrual,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _copied ? Icons.check : Icons.copy,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _copied ? 'Copied!' : 'Copy',
                        style: AppTextStyles.small.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Row(
              children: [
                Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  size: 16,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  _expanded ? 'Hide prompt preview' : 'Preview prompt',
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (_expanded) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Text(
                prompt,
                style: AppTextStyles.body.copyWith(
                  fontSize: 10,
                  height: 1.4,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}


// --- AI Section ---

class _AiSection extends StatelessWidget {
  final List periods;
  final Map logs;
  final int settingsCycleLength;
  final int settingsPeriodLength;
  final bool hasEnoughData;

  const _AiSection({
    required this.periods,
    required this.logs,
    required this.settingsCycleLength,
    required this.settingsPeriodLength,
    required this.hasEnoughData,
  });

  @override
  Widget build(BuildContext context) {
    final aiProvider = context.watch<AiDiagnosisProvider>();
    final periodProvider = context.watch<PeriodProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final prediction = aiProvider.prediction;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // LSTM Prediction Card
        if (hasEnoughData) ...[
          Text('AI PREDICTIONS', style: AppTextStyles.label),
          const SizedBox(height: 8),
          _LstmPredictionCard(
            prediction: prediction,
            onPredict: () => aiProvider.runPrediction(
              periods: List.from(periods),
              settingsCycleLength: settingsCycleLength,
              settingsPeriodLength: settingsPeriodLength,
            ),
          ),
          const SizedBox(height: 16),
        ],

        // On-device AI Health Summary
        Text('AI HEALTH SUMMARY', style: AppTextStyles.label),
        const SizedBox(height: 8),
        _OnDeviceSummaryCard(
          periodProvider: periodProvider,
          settingsProvider: settingsProvider,
          logs: logs,
          prediction: prediction,
          hasEnoughData: hasEnoughData,
        ),

        // Ollama enhanced (collapsible)
        _OllamaEnhancedSection(
          aiProvider: aiProvider,
          periods: periods,
          logs: logs,
          settingsCycleLength: settingsCycleLength,
          settingsPeriodLength: settingsPeriodLength,
          hasEnoughData: hasEnoughData,
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

// --- On-device rule-based summary ---

class _OnDeviceSummaryCard extends StatelessWidget {
  final PeriodProvider periodProvider;
  final SettingsProvider settingsProvider;
  final Map logs;
  final CyclePrediction? prediction;
  final bool hasEnoughData;

  const _OnDeviceSummaryCard({
    required this.periodProvider,
    required this.settingsProvider,
    required this.logs,
    required this.prediction,
    required this.hasEnoughData,
  });

  @override
  Widget build(BuildContext context) {
    final paragraphs = _generateSummary();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.luteal.withValues(alpha: 0.2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0FA08CB0),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.lutealBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 20,
                  color: AppColors.luteal,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Health Summary',
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.ovulation,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'On-device analysis',
                          style: AppTextStyles.small.copyWith(
                            color: AppColors.ovulation,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...paragraphs.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.emoji, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.title,
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          p.body,
                          style: AppTextStyles.body.copyWith(
                            fontSize: 11,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<_SummaryParagraph> _generateSummary() {
    final result = <_SummaryParagraph>[];
    final phase = periodProvider.currentPhase;
    final cycleDay = periodProvider.currentCycleDay;
    final avgCycle = periodProvider.averageCycleLength;
    final avgPeriod = periodProvider.averagePeriodLength;
    final cl = periodProvider.cycleLengths;
    final age = settingsProvider.userAge;

    // 1. Overall assessment
    if (hasEnoughData) {
      final variation = cl.isNotEmpty
          ? cl.reduce((a, b) => a > b ? a : b) -
                cl.reduce((a, b) => a < b ? a : b)
          : 0;
      final regular = variation <= 3;
      final normalLength = avgCycle >= 21 && avgCycle <= 35;
      final normalPeriod = avgPeriod >= 2 && avgPeriod <= 7;

      if (regular && normalLength && normalPeriod) {
        result.add(
          _SummaryParagraph(
            emoji: '💚',
            title: 'Overall: Looking good',
            body:
                'Your cycle is regular ($avgCycle-day average, ${variation}d variation) with a $avgPeriod-day period. This is well within healthy ranges.',
          ),
        );
      } else {
        final issues = <String>[];
        if (!regular) issues.add('${variation}d cycle variation');
        if (!normalLength) issues.add('$avgCycle-day cycles');
        if (!normalPeriod) issues.add('$avgPeriod-day periods');
        result.add(
          _SummaryParagraph(
            emoji: '🔶',
            title: 'Overall: Worth monitoring',
            body:
                'Some patterns to watch: ${issues.join(', ')}. This may be normal for your body, but track closely.',
          ),
        );
      }
    } else {
      result.add(
        _SummaryParagraph(
          emoji: '📊',
          title: 'Building your profile',
          body:
              'Luna needs more data for a complete analysis. Keep logging — insights improve with every cycle tracked.',
        ),
      );
    }

    // 2. Current phase insight
    result.add(
      _SummaryParagraph(
        emoji: _phaseEmoji(phase),
        title: 'Right now: ${AppColors.phaseName(phase)}',
        body: _phaseBody(phase, cycleDay, avgCycle),
      ),
    );

    // 3. Prediction insight
    if (prediction != null) {
      result.add(
        _SummaryParagraph(
          emoji: '🔮',
          title: 'Prediction',
          body:
              'Based on your ${cl.length} logged cycles, your next cycle is estimated at ${prediction!.nextCycleLength.round()} days with a ${prediction!.nextPeriodDuration.round()}-day period. ${prediction!.fromModel ? 'LSTM model' : 'Statistical model'} confidence.',
        ),
      );
    }

    // 4. Symptom insight
    final symptomCounts = <String, int>{};
    for (final log in logs.values) {
      final dl = log as dynamic;
      for (final s in dl.symptoms) {
        symptomCounts[s as String] = (symptomCounts[s] ?? 0) + 1;
      }
    }
    if (symptomCounts.isNotEmpty) {
      final sorted = symptomCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final top3 = sorted.take(3).map((e) => e.key).join(', ');
      result.add(
        _SummaryParagraph(
          emoji: '🩹',
          title: 'Top symptoms: $top3',
          body: _symptomAdvice(sorted.first.key),
        ),
      );
    }

    // 5. Mood insight
    final moodCounts = <String, int>{};
    for (final log in logs.values) {
      final dl = log as dynamic;
      for (final m in dl.moods) {
        moodCounts[m as String] = (moodCounts[m] ?? 0) + 1;
      }
    }
    if (moodCounts.isNotEmpty) {
      final sorted = moodCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final dominant = sorted.first.key;
      result.add(
        _SummaryParagraph(
          emoji: '🧠',
          title: 'Dominant mood: $dominant',
          body: _moodAdvice(dominant),
        ),
      );
    }

    // 6. Flow insight
    int light = 0, medium = 0, heavy = 0;
    for (final log in logs.values) {
      final dl = log as dynamic;
      if (dl.flow == 'light') light++;
      if (dl.flow == 'medium') medium++;
      if (dl.flow == 'heavy') heavy++;
    }
    final totalFlow = light + medium + heavy;
    if (totalFlow >= 3) {
      final heavyPct = (heavy / totalFlow * 100).round();
      if (heavyPct >= 50) {
        result.add(
          _SummaryParagraph(
            emoji: '💧',
            title: 'Heavy flow pattern',
            body:
                'Heavy flow logged $heavyPct% of the time. Ensure adequate iron intake — spinach, lentils, red meat. Consider a ferritin check if you feel consistently fatigued.',
          ),
        );
      } else {
        result.add(
          _SummaryParagraph(
            emoji: '💧',
            title: 'Flow balance',
            body:
                'Your flow pattern: Light ${(light / totalFlow * 100).round()}%, Medium ${(medium / totalFlow * 100).round()}%, Heavy $heavyPct%. This distribution looks balanced.',
          ),
        );
      }
    }

    // 7. Medical checklist insights
    final medCounts = <String, Map<String, int>>{};
    for (final log in logs.values) {
      final dl = log as dynamic;
      if (dl.medicalLog == null) continue;
      final medMap = dl.medicalLog as Map<String, String>;
      for (final e in medMap.entries) {
        medCounts.putIfAbsent(e.key, () => {});
        medCounts[e.key]![e.value] = (medCounts[e.key]![e.value] ?? 0) + 1;
      }
    }
    if (medCounts.isNotEmpty) {
      final flags = <String>[];
      // Check for warning patterns
      final pain = medCounts['pain_level'];
      if (pain != null) {
        final severe = (pain['Severe'] ?? 0) + (pain['Unbearable'] ?? 0);
        final total = pain.values.fold<int>(0, (s, v) => s + v);
        if (severe > 0 && severe / total > 0.25)
          flags.add('severe pain ${(severe / total * 100).round()}%');
      }
      final sleep = medCounts['sleep'];
      if (sleep != null) {
        final poor = (sleep['Poor'] ?? 0) + (sleep['Insomnia'] ?? 0);
        final total = sleep.values.fold<int>(0, (s, v) => s + v);
        if (poor > 0 && poor / total > 0.4)
          flags.add('sleep issues ${(poor / total * 100).round()}%');
      }
      final energy = medCounts['energy'];
      if (energy != null) {
        final low = (energy['Low'] ?? 0) + (energy['Exhausted'] ?? 0);
        final total = energy.values.fold<int>(0, (s, v) => s + v);
        if (low > 0 && low / total > 0.4)
          flags.add('low energy ${(low / total * 100).round()}%');
      }
      final skin = medCounts['skin'];
      if (skin != null && (skin['Acne'] ?? 0) > 0) {
        final total = skin.values.fold<int>(0, (s, v) => s + v);
        if ((skin['Acne']! / total) > 0.3) flags.add('hormonal acne');
      }

      if (flags.isNotEmpty) {
        result.add(
          _SummaryParagraph(
            emoji: '🩺',
            title: 'Medical checklist flags',
            body:
                'Your checklist data shows: ${flags.join(', ')}. These patterns are worth mentioning at your next doctor visit.',
          ),
        );
      } else {
        result.add(
          _SummaryParagraph(
            emoji: '🩺',
            title: 'Medical checklist',
            body:
                'No concerning patterns in your checklist data. Keep logging for a more complete picture.',
          ),
        );
      }
    }

    // 8. Age insight
    if (age != null) {
      result.add(
        _SummaryParagraph(
          emoji: _ageEmoji(age),
          title: 'Age context ($age)',
          body: _ageAdvice(age, avgCycle),
        ),
      );
    }

    return result;
  }

  String _phaseEmoji(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstrual:
        return '🩸';
      case CyclePhase.follicular:
        return '🌱';
      case CyclePhase.ovulation:
        return '⭐';
      case CyclePhase.luteal:
        return '🌙';
    }
  }

  String _phaseBody(CyclePhase phase, int day, int avgCycle) {
    switch (phase) {
      case CyclePhase.menstrual:
        return 'Day $day — your body is shedding the uterine lining. Focus on rest, iron-rich foods, and warmth. Gentle movement like walking or yoga is ideal.';
      case CyclePhase.follicular:
        return 'Day $day — estrogen is rising, bringing energy and clarity. Great time to start new projects, try challenging workouts, and eat light fresh foods.';
      case CyclePhase.ovulation:
        return 'Day $day — you\'re at peak energy and fertility. Communication skills are sharpest. High-intensity exercise feels natural. Stay hydrated.';
      case CyclePhase.luteal:
        return 'Day $day of $avgCycle — progesterone is dominant. Cravings are normal — honor them with complex carbs. Prioritize sleep and stress management.';
    }
  }

  String _symptomAdvice(String topSymptom) {
    switch (topSymptom) {
      case 'Cramps':
        return 'Frequent cramps suggest magnesium may help — try 200-400mg glycinate daily, especially in your luteal phase. Heat pads and ginger tea provide immediate relief.';
      case 'Headache':
        return 'Cycle-related headaches often stem from estrogen drops. Stay hydrated, maintain stable blood sugar, and consider magnesium + B2 supplementation.';
      case 'Fatigue':
        return 'Persistent fatigue may indicate low iron or B12. Track your energy levels across your cycle — if fatigue persists beyond your period, consider a blood panel.';
      case 'Bloating':
        return 'Bloating peaks in the luteal phase due to progesterone. Reduce sodium, eat potassium-rich foods (bananas, avocado), and try peppermint tea.';
      case 'Back pain':
        return 'Prostaglandins that cause cramps also affect your lower back. Gentle stretching, heat, and anti-inflammatory foods (omega-3, turmeric) help.';
      case 'Acne':
        return 'Hormonal acne often flares in the luteal phase when androgens rise. Zinc supplements, reduced dairy, and consistent skincare can help.';
      case 'Nausea':
        return 'Cycle-related nausea is linked to prostaglandins and hormonal shifts. Ginger, small frequent meals, and vitamin B6 are effective remedies.';
      case 'Breast tenderness':
        return 'Breast tenderness in the luteal phase is caused by progesterone. Evening primrose oil, reducing caffeine, and vitamin E may provide relief.';
      default:
        return 'Track this symptom across cycles to identify patterns. Consistent logging helps identify triggers and effective remedies.';
    }
  }

  String _moodAdvice(String mood) {
    switch (mood) {
      case 'Tired':
        return 'Fatigue correlates strongly with your menstrual and late luteal phases. Prioritize 8+ hours of sleep, and consider iron levels if it persists throughout your cycle.';
      case 'Anxious':
        return 'Anxiety often peaks in the luteal phase when progesterone drops. Magnesium, L-theanine, and breathing exercises can help. Reduce caffeine in the second half of your cycle.';
      case 'Sad':
        return 'Mood dips are common premenstrually. Omega-3 fatty acids, vitamin D, and regular exercise have strong evidence for mood support. Talk to someone if it feels overwhelming.';
      case 'Irritable':
        return 'Irritability in the luteal phase is linked to serotonin fluctuations. Complex carbs boost serotonin naturally. B6 supplements and regular exercise also help.';
      case 'Happy':
        return 'Great to see positive moods! Happiness peaks around ovulation when estrogen and energy are highest. Maintain this with regular exercise and social connection.';
      case 'Stressed':
        return 'Chronic stress disrupts cortisol which can affect cycle regularity. Adaptogenic herbs (ashwagandha), meditation, and boundary-setting are key.';
      case 'Energetic':
        return 'High energy is characteristic of your follicular and ovulation phases. Channel it into challenging workouts and creative projects.';
      default:
        return 'Tracking moods alongside your cycle reveals powerful patterns. Most women find mood shifts predictable once mapped to their cycle phases.';
    }
  }

  String _ageEmoji(int age) {
    if (age < 18) return '🌱';
    if (age < 25) return '🌸';
    if (age < 35) return '💐';
    if (age < 45) return '🌻';
    return '🍂';
  }

  String _ageAdvice(int age, int avgCycle) {
    if (age < 20)
      return 'At $age, your cycle may still be establishing regularity. This is normal — it can take several years after menarche. Focus on nutrition, especially iron and calcium.';
    if (age < 30)
      return 'At $age, your $avgCycle-day cycle reflects peak reproductive years. This is when tracking is most valuable for understanding your unique patterns and planning ahead.';
    if (age < 40)
      return 'At $age, your cycle should be well-established. Any new irregularities are worth noting. Fertility awareness is especially relevant — folate is important regardless of plans.';
    if (age < 50)
      return 'At $age, perimenopause may begin influencing your cycle. Shorter cycles, heavier flow, or skipped periods can emerge. Share your tracking data with your provider.';
    return 'At $age, cycle changes are expected. Tracking helps distinguish normal perimenopause from issues that need attention. Calcium and vitamin D are priorities now.';
  }
}

class _SummaryParagraph {
  final String emoji;
  final String title;
  final String body;
  const _SummaryParagraph({
    required this.emoji,
    required this.title,
    required this.body,
  });
}

// --- Ollama enhanced (collapsible) ---

class _OllamaEnhancedSection extends StatefulWidget {
  final AiDiagnosisProvider aiProvider;
  final List periods;
  final Map logs;
  final int settingsCycleLength;
  final int settingsPeriodLength;
  final bool hasEnoughData;

  const _OllamaEnhancedSection({
    required this.aiProvider,
    required this.periods,
    required this.logs,
    required this.settingsCycleLength,
    required this.settingsPeriodLength,
    required this.hasEnoughData,
  });

  @override
  State<_OllamaEnhancedSection> createState() => _OllamaEnhancedSectionState();
}

class _OllamaEnhancedSectionState extends State<_OllamaEnhancedSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _expanded ? Icons.expand_less : Icons.expand_more,
                size: 16,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 4),
              Text(
                _expanded ? 'Hide Ollama LLM' : 'Enhanced: Use Ollama LLM',
                style: AppTextStyles.small.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
        if (_expanded) ...[
          const SizedBox(height: 8),
          _OllamaDiagnosisCard(
            status: widget.aiProvider.status,
            ollamaAvailable: widget.aiProvider.ollamaAvailable,
            diagnosis: widget.aiProvider.aiDiagnosis,
            errorMessage: widget.aiProvider.errorMessage,
            ollamaModel: widget.aiProvider.ollamaModel,
            onRun: widget.hasEnoughData
                ? () => widget.aiProvider.runFullDiagnosis(
                    periods: List.from(widget.periods),
                    logs: Map.from(widget.logs),
                    settingsCycleLength: widget.settingsCycleLength,
                    settingsPeriodLength: widget.settingsPeriodLength,
                  )
                : null,
            onCheckConnection: () => widget.aiProvider.checkOllama(),
            onConfigureHost: (host) =>
                widget.aiProvider.configureOllama(host: host),
          ),
        ],
      ],
    );
  }
}

class _LstmPredictionCard extends StatelessWidget {
  final CyclePrediction? prediction;
  final VoidCallback onPredict;

  const _LstmPredictionCard({
    required this.prediction,
    required this.onPredict,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.luteal.withValues(alpha: 0.2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0FA08CB0),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.lutealBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.psychology,
                  size: 20,
                  color: AppColors.luteal,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cycle Predictor',
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      prediction?.fromModel == true
                          ? 'LSTM Model'
                          : 'Statistical Model',
                      style: AppTextStyles.small.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (prediction == null)
                GestureDetector(
                  onTap: onPredict,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.luteal,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Predict',
                      style: AppTextStyles.small.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (prediction != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _PredictionTile(
                    label: 'Next Cycle',
                    value: '${prediction!.nextCycleLength.round()}',
                    unit: 'days',
                    icon: Icons.loop_rounded,
                    color: AppColors.follicular,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _PredictionTile(
                    label: 'Next Period',
                    value: '${prediction!.nextPeriodDuration.round()}',
                    unit: 'days',
                    icon: Icons.water_drop_rounded,
                    color: AppColors.menstrual,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: onPredict,
              child: Center(
                child: Text(
                  'Tap to re-predict',
                  style: AppTextStyles.small.copyWith(color: AppColors.luteal),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PredictionTile extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;

  const _PredictionTile({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.small),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    value,
                    style: AppTextStyles.mediumNumber.copyWith(
                      fontSize: 20,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(unit, style: AppTextStyles.small),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OllamaDiagnosisCard extends StatefulWidget {
  final AiStatus status;
  final bool ollamaAvailable;
  final String diagnosis;
  final String errorMessage;
  final String ollamaModel;
  final VoidCallback? onRun;
  final VoidCallback onCheckConnection;
  final ValueChanged<String> onConfigureHost;

  const _OllamaDiagnosisCard({
    required this.status,
    required this.ollamaAvailable,
    required this.diagnosis,
    required this.errorMessage,
    required this.ollamaModel,
    required this.onRun,
    required this.onCheckConnection,
    required this.onConfigureHost,
  });

  @override
  State<_OllamaDiagnosisCard> createState() => _OllamaDiagnosisCardState();
}

class _OllamaDiagnosisCardState extends State<_OllamaDiagnosisCard> {
  bool _showHostInput = false;
  final _hostController = TextEditingController(text: 'http://localhost:11434');

  @override
  void dispose() {
    _hostController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: widget.ollamaAvailable
              ? AppColors.ovulation.withValues(alpha: 0.2)
              : AppColors.cardBorder,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0FA08CB0),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: widget.ollamaAvailable
                      ? AppColors.ovulationBg
                      : AppColors.cardBorder.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.auto_awesome,
                  size: 20,
                  color: widget.ollamaAvailable
                      ? AppColors.ovulation
                      : AppColors.textMuted,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Health Summary',
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: widget.ollamaAvailable
                                ? AppColors.ovulation
                                : AppColors.textMuted,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.ollamaAvailable
                              ? 'Ollama connected (${widget.ollamaModel})'
                              : 'Ollama not connected',
                          style: AppTextStyles.small.copyWith(
                            color: widget.ollamaAvailable
                                ? AppColors.ovulation
                                : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _showHostInput = !_showHostInput),
                child: Icon(
                  Icons.settings,
                  size: 18,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),

          // Host configuration
          if (_showHostInput) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _hostController,
                    style: AppTextStyles.body.copyWith(fontSize: 12),
                    decoration: InputDecoration(
                      hintText: 'http://localhost:11434',
                      hintStyle: AppTextStyles.small.copyWith(
                        color: AppColors.textMuted,
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: AppColors.inputBorder,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: AppColors.inputBorder,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    widget.onConfigureHost(_hostController.text.trim());
                    widget.onCheckConnection();
                    setState(() => _showHostInput = false);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.follicular,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Connect',
                      style: AppTextStyles.small.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 14),

          // Content area
          if (widget.status == AiStatus.idle && widget.diagnosis.isEmpty) ...[
            // Not yet run
            if (!widget.ollamaAvailable)
              _buildConnectionPrompt()
            else
              _buildRunButton(),
          ] else if (widget.status == AiStatus.checking) ...[
            _buildLoadingRow('Checking Ollama connection...'),
          ] else if (widget.status == AiStatus.loading) ...[
            _buildLoadingRow('Preparing diagnosis...'),
          ] else if (widget.status == AiStatus.streaming ||
              widget.status == AiStatus.done) ...[
            // Streaming or completed response
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceBackground,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.diagnosis,
                    style: AppTextStyles.body.copyWith(height: 1.5),
                  ),
                  if (widget.status == AiStatus.streaming) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(AppColors.luteal),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (widget.status == AiStatus.done) ...[
              const SizedBox(height: 8),
              Center(
                child: GestureDetector(
                  onTap: widget.onRun,
                  child: Text(
                    'Regenerate',
                    style: AppTextStyles.small.copyWith(
                      color: AppColors.luteal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ] else if (widget.status == AiStatus.error) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.menstrualBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 16,
                        color: AppColors.menstrual,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.errorMessage,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.menstrual,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: widget.onCheckConnection,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.menstrual),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Retry',
                            style: AppTextStyles.small.copyWith(
                              color: AppColors.menstrual,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => setState(() => _showHostInput = true),
                        child: Text(
                          'Change host',
                          style: AppTextStyles.small.copyWith(
                            color: AppColors.textMuted,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConnectionPrompt() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceBackground,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Text(
                'Connect to Ollama for AI-powered health summaries',
                style: AppTextStyles.body.copyWith(fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: widget.onCheckConnection,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.follicular,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Check Connection',
                    style: AppTextStyles.small.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRunButton() {
    return Center(
      child: GestureDetector(
        onTap: widget.onRun,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.luteal, AppColors.follicular],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.auto_awesome, size: 18, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                'Generate AI Diagnosis',
                style: AppTextStyles.button.copyWith(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingRow(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(AppColors.luteal),
            ),
          ),
          const SizedBox(width: 10),
          Text(text, style: AppTextStyles.body.copyWith(fontSize: 12)),
        ],
      ),
    );
  }
}
