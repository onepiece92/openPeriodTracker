import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/providers/period_provider.dart';
import '../../core/providers/daily_log_provider.dart';
import '../../core/widgets/flow_selector.dart';
import '../../core/widgets/mood_selector.dart';
import '../../core/widgets/symptom_chips.dart';
import 'doctor_checklist.dart';

class LogBottomSheet extends StatelessWidget {
  final String date;

  const LogBottomSheet({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final periodProvider = context.watch<PeriodProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final logProvider = context.watch<DailyLogProvider>();
    final log = logProvider.getLog(date);
    final isPeriodDay = periodProvider.isDateInPeriod(date);
    final parsedDate = DateTime.parse(date);
    final suggestedDays = settingsProvider.periodLength;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.surfaceBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: Color(0xFFEFE8F5))),
      ),
      child: Column(
        children: [
          // Drag handle
          const SizedBox(height: 10),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFD8CCE5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('EEEE, MMMM d').format(parsedDate),
                        style: AppTextStyles.sectionTitle,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.phaseColor(periodProvider.getPhaseForDate(date)).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Day ${periodProvider.getCycleDayForDate(date)} of ${periodProvider.averageCycleLength}',
                              style: AppTextStyles.small.copyWith(
                                color: AppColors.phaseColor(periodProvider.getPhaseForDate(date)),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            AppColors.phaseName(periodProvider.getPhaseForDate(date)),
                            style: AppTextStyles.small.copyWith(color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textMuted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Scrollable content
          Expanded(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.only(left: 20, right: 20, bottom: 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Period day toggle
                      GestureDetector(
                        onTap: () => _togglePeriod(
                          context, isPeriodDay, date, periodProvider,
                          settingsProvider, logProvider,
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: isPeriodDay ? AppColors.menstrual : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.menstrual),
                          ),
                          child: Center(
                            child: Text(
                              isPeriodDay ? '🩸 Remove Period Day' : '🩸 Mark as Period Day',
                              style: AppTextStyles.button.copyWith(
                                color: isPeriodDay ? Colors.white : AppColors.menstrual,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Suggest marking X days
                      if (!isPeriodDay && suggestedDays > 1)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: GestureDetector(
                            onTap: () => periodProvider.addPeriodRange(date, suggestedDays),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              decoration: BoxDecoration(
                                color: AppColors.menstrualBg,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.menstrual.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.auto_fix_high, size: 16, color: AppColors.menstrual),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Mark $suggestedDays days as period',
                                    style: AppTextStyles.body.copyWith(
                                      color: AppColors.menstrual,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),

                      // Flow
                      Text('FLOW', style: AppTextStyles.label),
                      const SizedBox(height: 8),
                      FlowSelector(
                        selected: log?.flow,
                        onChanged: (flow) {
                          logProvider.updateLog(date, flow: flow, clearFlow: flow == null);
                        },
                      ),
                      const SizedBox(height: 24),

                      // Mood
                      Text('MOOD', style: AppTextStyles.label),
                      const SizedBox(height: 8),
                      MoodSelector(
                        selected: log?.moods ?? [],
                        onChanged: (moods) {
                          logProvider.updateLog(date, moods: moods, clearMoods: moods.isEmpty);
                        },
                      ),
                      const SizedBox(height: 24),

                      // Symptoms
                      Text('SYMPTOMS', style: AppTextStyles.label),
                      const SizedBox(height: 8),
                      SymptomChips(
                        selected: log?.symptoms ?? [],
                        onChanged: (symptoms) {
                          logProvider.updateLog(date, symptoms: symptoms);
                        },
                      ),
                      const SizedBox(height: 24),

                      // Notes
                      Text('NOTES', style: AppTextStyles.label),
                      const SizedBox(height: 8),
                      TextField(
                        controller: TextEditingController(text: log?.notes ?? ''),
                        maxLines: 3,
                        style: AppTextStyles.body,
                        decoration: InputDecoration(
                          hintText: _getRotatingHint(parsedDate),
                          hintStyle: AppTextStyles.body.copyWith(color: AppColors.textMuted),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.all(14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: AppColors.inputBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: AppColors.inputBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: AppColors.luteal),
                          ),
                        ),
                        onChanged: (text) {
                          logProvider.updateLog(date, notes: text);
                        },
                      ),
                      const SizedBox(height: 24),

                      // Doctor's checklist
                      _DoctorSection(
                        values: log?.medicalLog ?? {},
                        onChanged: (medLog) {
                          logProvider.updateLog(date, medicalLog: medLog);
                        },
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),

                // // Sticky bottom period toggle button
                // Positioned(
                //   left: 20,
                //   right: 20,
                //   bottom: 16,
                //   child: GestureDetector(
                //     onTap: () => _togglePeriod(
                //       context, isPeriodDay, date, periodProvider,
                //       settingsProvider, logProvider,
                //     ),
                //     child: Container(
                //       padding: const EdgeInsets.symmetric(vertical: 14),
                //       decoration: BoxDecoration(
                //         color: isPeriodDay ? Colors.white : AppColors.menstrual,
                //         borderRadius: BorderRadius.circular(16),
                //         border: Border.all(color: AppColors.menstrual),
                //         boxShadow: [
                //           BoxShadow(
                //             color: AppColors.menstrual.withValues(alpha: 0.25),
                //             blurRadius: 12,
                //             offset: const Offset(0, -2),
                //           ),
                //         ],
                //       ),
                //       child: Row(
                //         mainAxisAlignment: MainAxisAlignment.center,
                //         children: [
                //           Icon(
                //             isPeriodDay ? Icons.remove_circle_outline : Icons.water_drop,
                //             size: 18,
                //             color: isPeriodDay ? AppColors.menstrual : Colors.white,
                //           ),
                //           const SizedBox(width: 8),
                //           Text(
                //             isPeriodDay ? 'Remove Period Day' : 'Mark as Period Day',
                //             style: AppTextStyles.button.copyWith(
                //               color: isPeriodDay ? AppColors.menstrual : Colors.white,
                //               fontSize: 14,
                //             ),
                //           ),
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _togglePeriod(
    BuildContext context,
    bool isPeriodDay,
    String date,
    PeriodProvider periodProvider,
    SettingsProvider settingsProvider,
    DailyLogProvider logProvider,
  ) {
    final wasNotPeriod = !isPeriodDay;
    periodProvider.togglePeriodDay(date);
    if (wasNotPeriod) {
      final defFlow = settingsProvider.defaultFlow;
      final defMoods = settingsProvider.defaultMoods;
      if (defFlow != null || defMoods.isNotEmpty) {
        logProvider.updateLog(
          date,
          flow: defFlow,
          moods: defMoods.isNotEmpty ? defMoods : null,
        );
      }
    }
  }

  String _getRotatingHint(DateTime date) {
    const hints = [
      'How painful are your cramps today?',
      'Notice any changes in discharge color?',
      'How is your energy level today?',
      'Any skin changes — acne, dryness, glow?',
      'How did you sleep last night?',
      'Any cravings or appetite changes?',
      'Notice any body hair changes?',
      'How is your mood compared to yesterday?',
      'Any breast tenderness or changes?',
      'Did you exercise today? How did it feel?',
      'Any bloating or digestive changes?',
      'How much water did you drink today?',
    ];
    return hints[date.day % hints.length];
  }
}

// --- Doctor's Checklist Section ---

class _DoctorSection extends StatefulWidget {
  final Map<String, String> values;
  final ValueChanged<Map<String, String>> onChanged;

  const _DoctorSection({required this.values, required this.onChanged});

  @override
  State<_DoctorSection> createState() => _DoctorSectionState();
}

class _DoctorSectionState extends State<_DoctorSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final answeredCount = widget.values.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            decoration: BoxDecoration(
              color: answeredCount > 0
                  ? AppColors.ovulationBg
                  : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: answeredCount > 0
                    ? AppColors.ovulation.withValues(alpha: 0.3)
                    : AppColors.cardBorder,
              ),
            ),
            child: Row(
              children: [
                const Text('🩺', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Doctor's Checklist",
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        answeredCount > 0
                            ? '$answeredCount answers logged'
                            : 'Track what your doctor would ask',
                        style: AppTextStyles.small.copyWith(
                          color: answeredCount > 0
                              ? AppColors.ovulation
                              : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  color: AppColors.textMuted,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        if (_expanded) ...[
          const SizedBox(height: 12),
          DoctorChecklist(
            values: widget.values,
            onChanged: widget.onChanged,
          ),
        ],
      ],
    );
  }
}
