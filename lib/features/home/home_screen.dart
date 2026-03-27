import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/providers/period_provider.dart';
import '../../core/widgets/phase_card.dart';
import 'birthday_overlay.dart';
import '../calendar/calendar_view.dart';
import '../logging/log_bottom_sheet.dart';
import 'doctor_view.dart';
import '../insights/insights_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _activeTab = 0;
  bool _birthdayShown = false;
  bool _showBirthday = false;

  @override
  Widget build(BuildContext context) {
    final periodProvider = context.watch<PeriodProvider>();
    final settingsProvider = context.watch<SettingsProvider>();

    // Keep period provider in sync with settings
    periodProvider.updateSettings(
      settingsProvider.cycleLength,
      settingsProvider.periodLength,
    );

    final phase = periodProvider.currentPhase;
    final cycleDay = periodProvider.currentCycleDay;
    final avgCycle = periodProvider.averageCycleLength;

    // Check birthday
    if (!_birthdayShown && settingsProvider.userBirthday != null) {
      final bday = DateTime.parse(settingsProvider.userBirthday!);
      final now = DateTime.now();
      if (bday.month == now.month && bday.day == now.day) {
        _birthdayShown = true;
        _showBirthday = true;
      }
    }

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Luna', style: AppTextStyles.appTitle),
                        Text(
                          'Hi, ${settingsProvider.displayName}',
                          style: AppTextStyles.body.copyWith(color: AppColors.textLight),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          DateFormat('MMM d').format(DateTime.now()),
                          style: AppTextStyles.mediumNumber.copyWith(fontSize: 18),
                        ),
                        Text(
                          DateFormat('EEEE').format(DateTime.now()),
                          style: AppTextStyles.small.copyWith(color: AppColors.textLight),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Phase card
                PhaseCard(
                  phase: phase,
                  currentDay: cycleDay,
                  cycleLength: avgCycle,
                ),
                const SizedBox(height: 16),

                // Phase timeline strip
                _PhaseTimeline(
                  currentDay: cycleDay,
                  cycleLength: avgCycle,
                  periodLength: periodProvider.averagePeriodLength,
                  phase: phase,
                  daysUntilNextPeriod: periodProvider.daysUntilNextPeriod,
                  isInFertileWindow: periodProvider.isInFertileWindow,
                ),
                const SizedBox(height: 20),

                // Tab switcher
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      _TabButton(
                        label: '📅 Calendar',
                        isActive: _activeTab == 0,
                        onTap: () => setState(() => _activeTab = 0),
                      ),
                      _TabButton(
                        label: '🩺 Doctor',
                        isActive: _activeTab == 1,
                        onTap: () => setState(() => _activeTab = 1),
                      ),
                      _TabButton(
                        label: '✨ Insights',
                        isActive: _activeTab == 2,
                        onTap: () => setState(() => _activeTab = 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Tab content
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _buildTabContent(),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),

      // Log Today FAB
      Positioned(
        right: 20,
        bottom: 20,
        child: GestureDetector(
          onTap: () {
            final today = DateTime.now();
            final ds = '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              useRootNavigator: true,
              backgroundColor: Colors.transparent,
              builder: (_) => LogBottomSheet(date: ds),
            );
          },
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.luteal, AppColors.follicular]),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.luteal.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
        ),
      ),

      // Birthday overlay
      if (_showBirthday)
        BirthdayOverlay(
          name: settingsProvider.displayName,
          age: settingsProvider.userAge ?? 0,
          onDismiss: () => setState(() => _showBirthday = false),
        ),
      ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_activeTab) {
      case 0:
        return const CalendarView(key: ValueKey('calendar'));
      case 1:
        return const DoctorView(key: ValueKey('doctor'));
      case 2:
        return const InsightsView(key: ValueKey('insights'));
      default:
        return const SizedBox.shrink();
    }
  }

}

class _PhaseTimeline extends StatelessWidget {
  final int currentDay;
  final int cycleLength;
  final int periodLength;
  final CyclePhase phase;
  final int? daysUntilNextPeriod;
  final bool isInFertileWindow;

  const _PhaseTimeline({
    required this.currentDay,
    required this.cycleLength,
    required this.periodLength,
    required this.phase,
    required this.daysUntilNextPeriod,
    required this.isInFertileWindow,
  });

  @override
  Widget build(BuildContext context) {
    final ovulationDay = cycleLength - 14;
    final follicularEnd = (cycleLength * 0.46).round();

    // Phase segments as fractions of the cycle
    final menstrualFrac = periodLength / cycleLength;
    final follicularFrac = (follicularEnd - periodLength) / cycleLength;
    final ovulationFrac = (ovulationDay - follicularEnd) / cycleLength;
    final lutealFrac = 1.0 - menstrualFrac - follicularFrac - ovulationFrac;

    // Current position (clamped for display)
    final progress = ((currentDay - 1) / cycleLength).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info row
          Row(
            children: [
              _InfoChip(
                icon: Icons.calendar_today,
                label: 'Day $currentDay',
                color: AppColors.phaseColor(phase),
              ),
              const SizedBox(width: 8),
              if (daysUntilNextPeriod != null)
                _InfoChip(
                  icon: Icons.water_drop,
                  label: '$daysUntilNextPeriod d to period',
                  color: AppColors.menstrual,
                ),
              const SizedBox(width: 8),
              _InfoChip(
                icon: Icons.favorite,
                label: isInFertileWindow ? 'Fertile' : 'Not fertile',
                color: isInFertileWindow ? AppColors.ovulation : AppColors.textMuted,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Timeline bar
          SizedBox(
            height: 14,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final indicatorLeft = (progress * constraints.maxWidth)
                    .clamp(0.0, constraints.maxWidth - 6);
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Phase segments
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Row(
                        children: [
                          _segment(menstrualFrac, AppColors.menstrual.withValues(alpha: 0.35)),
                          _segment(follicularFrac, AppColors.follicular.withValues(alpha: 0.35)),
                          _segment(ovulationFrac, AppColors.ovulation.withValues(alpha: 0.35)),
                          _segment(lutealFrac, AppColors.luteal.withValues(alpha: 0.35)),
                        ],
                      ),
                    ),
                    // Current position indicator
                    Positioned(
                      left: indicatorLeft,
                      top: -2,
                      child: Container(
                        width: 6,
                        height: 18,
                        decoration: BoxDecoration(
                          color: AppColors.phaseColor(phase),
                          borderRadius: BorderRadius.circular(3),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.phaseColor(phase).withValues(alpha: 0.5),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Phase labels
          Row(
            children: [
              _phaseLabel(menstrualFrac, '🩸', AppColors.menstrual),
              _phaseLabel(follicularFrac, '🌱', AppColors.follicular),
              _phaseLabel(ovulationFrac, '⭐', AppColors.ovulation),
              _phaseLabel(lutealFrac, '🌙', AppColors.luteal),
            ],
          ),
        ],
      ),
    );
  }

  Widget _segment(double fraction, Color color) {
    return Expanded(
      flex: (fraction * 100).round().clamp(1, 100),
      child: Container(color: color),
    );
  }

  Widget _phaseLabel(double fraction, String emoji, Color color) {
    return Expanded(
      flex: (fraction * 100).round().clamp(1, 100),
      child: Center(
        child: Text(emoji, style: const TextStyle(fontSize: 10)),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.small.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
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
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            boxShadow: isActive
                ? const [
                    BoxShadow(color: Color(0x0FA08CB0), blurRadius: 8, offset: Offset(0, 2)),
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
