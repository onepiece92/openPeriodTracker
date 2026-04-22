import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/providers/period_provider.dart';
import '../../core/providers/daily_log_provider.dart';
import '../../core/services/demo_data_service.dart';
import 'step_last_period.dart';
import 'step_cycle_length.dart';
import 'step_period_length.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentStep =
      0; // 0 = welcome, 1 = date, 2 = cycle length, 3 = period length
  DateTime? _lastPeriodDate;
  int _cycleLength = 28;
  int _periodLength = 5;

  void _next() {
    setState(() => _currentStep++);
  }

  bool _generatingDemo = false;

  Future<void> _generateAndGo() async {
    setState(() => _generatingDemo = true);
    await DemoDataService().generate(
      settingsProv: context.read<SettingsProvider>(),
      periodProv: context.read<PeriodProvider>(),
      logProv: context.read<DailyLogProvider>(),
    );
    if (mounted) context.go('/home');
  }

  Future<void> _skip() async {
    if (_lastPeriodDate == null)
      return; // shouldn't happen — skip only shows after date picked

    final dateStr =
        '${_lastPeriodDate!.year.toString().padLeft(4, '0')}-${_lastPeriodDate!.month.toString().padLeft(2, '0')}-${_lastPeriodDate!.day.toString().padLeft(2, '0')}';

    final settings = context.read<SettingsProvider>();
    final periods = context.read<PeriodProvider>();

    await settings.completeOnboarding(
      cycleLength: _cycleLength,
      periodLength: _periodLength,
    );
    periods.updateSettings(_cycleLength, _periodLength);
    await periods.addInitialPeriod(dateStr, _periodLength);

    if (mounted) {
      context.go('/home');
    }
  }

  Future<void> _complete() async {
    if (_lastPeriodDate == null) return;

    final dateStr =
        '${_lastPeriodDate!.year.toString().padLeft(4, '0')}-${_lastPeriodDate!.month.toString().padLeft(2, '0')}-${_lastPeriodDate!.day.toString().padLeft(2, '0')}';

    final settings = context.read<SettingsProvider>();
    final periods = context.read<PeriodProvider>();

    await settings.completeOnboarding(
      cycleLength: _cycleLength,
      periodLength: _periodLength,
    );
    periods.updateSettings(_cycleLength, _periodLength);
    await periods.addInitialPeriod(dateStr, _periodLength);
    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Stack(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.1),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: _buildStep(),
              ),
              // Skip button (visible after welcome)
              if (_currentStep >= 2 && _lastPeriodDate != null)
                Positioned(
                  top: 12,
                  right: 20,
                  child: GestureDetector(
                    onTap: _skip,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Skip',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_currentStep) {
      case 0:
        return _WelcomeStep(
          key: const ValueKey(0),
          onNext: _next,
          onTryDemo: _generatingDemo ? null : _generateAndGo,
          isGenerating: _generatingDemo,
        );
      case 1:
        return StepLastPeriod(
          key: const ValueKey(1),
          selectedDate: _lastPeriodDate,
          onDateSelected: (d) => setState(() => _lastPeriodDate = d),
          onNext: _lastPeriodDate != null ? _next : null,
        );
      case 2:
        return StepCycleLength(
          key: const ValueKey(2),
          value: _cycleLength,
          onChanged: (v) => setState(() => _cycleLength = v),
          onNext: _next,
        );
      case 3:
        return StepPeriodLength(
          key: const ValueKey(3),
          value: _periodLength,
          onChanged: (v) => setState(() => _periodLength = v),
          onComplete: _complete,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _WelcomeStep extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback? onTryDemo;
  final bool isGenerating;

  const _WelcomeStep({
    super.key,
    required this.onNext,
    required this.onTryDemo,
    this.isGenerating = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          const Text('🌙', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 20),
          Text('Luna', style: AppTextStyles.appTitle),
          const SizedBox(height: 8),
          Text(
            'Your cycle companion',
            style: AppTextStyles.body.copyWith(color: AppColors.textLight),
          ),
          const Spacer(flex: 3),

          // Primary CTA
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.luteal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                'Get Started',
                style: AppTextStyles.button.copyWith(color: Colors.white),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Secondary CTA — explore with sample data
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: onTryDemo,
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: AppColors.luteal.withValues(alpha: 0.4),
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                backgroundColor: AppColors.lutealBg.withValues(alpha: 0.5),
              ),
              child: isGenerating
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.luteal,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          size: 16,
                          color: AppColors.luteal,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Explore with sample data',
                          style: AppTextStyles.button.copyWith(
                            color: AppColors.luteal,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 20),

          // Hint note
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💡', style: TextStyle(fontSize: 13)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'You can generate or clear sample data anytime in Profile → Developer Tools.',
                    style: AppTextStyles.small.copyWith(
                      color: AppColors.textMuted,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 36),
        ],
      ),
    );
  }
}
