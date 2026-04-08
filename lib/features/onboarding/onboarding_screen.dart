import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/providers/period_provider.dart';
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
        return _WelcomeStep(key: const ValueKey(0), onNext: _next);
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

  const _WelcomeStep({super.key, required this.onNext});

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
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}
