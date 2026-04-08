import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/providers/period_provider.dart';
import '../../core/providers/daily_log_provider.dart';
import '../../core/services/share_service.dart';
import '../../core/widgets/phase_card.dart';
import 'birthday_overlay.dart';

class HomeScreen extends StatefulWidget {
  final Widget child;

  const HomeScreen({super.key, required this.child});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _birthdayShown = false;
  bool _showBirthday = false;
  bool _dismissedWarning = false;

  @override
  Widget build(BuildContext context) {
    final periodProvider = context.watch<PeriodProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final dailyLogProvider = context.watch<DailyLogProvider>();

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
            decoration: const BoxDecoration(
              gradient: AppColors.backgroundGradient,
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (periodProvider.daysUntilNextPeriod != null &&
                        periodProvider.daysUntilNextPeriod! < 0 &&
                        !_dismissedWarning)
                      Container(
                        margin: const EdgeInsets.only(top: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Hi ${settingsProvider.displayName}, your period is delayed by ${periodProvider.daysUntilNextPeriod!.abs()} days.',
                                style: AppTextStyles.body.copyWith(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.redAccent),
                              onPressed: () => setState(() => _dismissedWarning = true),
                            ),
                          ],
                        ),
                      ),
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
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.textLight,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  DateFormat('MMM d').format(DateTime.now()),
                                  style: AppTextStyles.mediumNumber.copyWith(
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  DateFormat('EEEE').format(DateTime.now()),
                                  style: AppTextStyles.small.copyWith(
                                    color: AppColors.textLight,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () {
                                ShareService.shareStatus(
                                  periodProvider,
                                  dailyLogProvider,
                                );
                              },
                              icon: const Icon(
                                Icons.ios_share_rounded,
                                color: AppColors.textPrimary,
                              ),
                              tooltip: 'Share Status',
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
                    Builder(
                      builder: (context) {
                        final String location = GoRouterState.of(
                          context,
                        ).uri.path;
                        return Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              _TabButton(
                                label: '📅 Calendar',
                                isActive: location == '/home',
                                onTap: () => context.go('/home'),
                              ),
                              _TabButton(
                                label: '🩺 Doctor',
                                isActive: location == '/home/doctor',
                                onTap: () => context.go('/home/doctor'),
                              ),
                              _TabButton(
                                label: '✨ Insights',
                                isActive: location == '/home/insights',
                                onTap: () => context.go('/home/insights'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Tab content
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: widget.child,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
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
                  label: daysUntilNextPeriod! < 0
                      ? '${daysUntilNextPeriod!.abs()} d late'
                      : '$daysUntilNextPeriod d to period',
                  color: daysUntilNextPeriod! < 0
                      ? Colors.redAccent
                      : AppColors.menstrual,
                ),
              const SizedBox(width: 8),
              _InfoChip(
                icon: Icons.favorite,
                label: isInFertileWindow ? 'Fertile' : 'Not fertile',
                color: isInFertileWindow
                    ? AppColors.ovulation
                    : AppColors.textMuted,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Timeline bar
          SizedBox(
            height: 14,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final indicatorLeft = (progress * constraints.maxWidth).clamp(
                  0.0,
                  constraints.maxWidth - 6,
                );
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Phase segments
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Row(
                        children: [
                          _segment(
                            menstrualFrac,
                            AppColors.menstrual.withValues(alpha: 0.35),
                          ),
                          _segment(
                            follicularFrac,
                            AppColors.follicular.withValues(alpha: 0.35),
                          ),
                          _segment(
                            ovulationFrac,
                            AppColors.ovulation.withValues(alpha: 0.35),
                          ),
                          _segment(
                            lutealFrac,
                            AppColors.luteal.withValues(alpha: 0.35),
                          ),
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
                              color: AppColors.phaseColor(
                                phase,
                              ).withValues(alpha: 0.5),
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
      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 10))),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

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
