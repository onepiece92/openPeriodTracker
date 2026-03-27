import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class StepCycleLength extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final VoidCallback onNext;

  const StepCycleLength({
    super.key,
    required this.value,
    required this.onChanged,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          Text(
            'Average Cycle Length',
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 22),
          ),
          const SizedBox(height: 8),
          Text(
            'From the first day of one period\nto the first day of the next',
            style: AppTextStyles.body,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StepperButton(
                icon: Icons.remove,
                onTap: value > 20 ? () => onChanged(value - 1) : null,
              ),
              const SizedBox(width: 32),
              Column(
                children: [
                  Text('$value', style: AppTextStyles.largeNumber.copyWith(fontSize: 48)),
                  Text('days', style: AppTextStyles.body),
                ],
              ),
              const SizedBox(width: 32),
              _StepperButton(
                icon: Icons.add,
                onTap: value < 45 ? () => onChanged(value + 1) : null,
              ),
            ],
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Text('Next', style: AppTextStyles.button.copyWith(color: Colors.white)),
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _StepperButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: enabled ? Colors.white : AppColors.cardBorder,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: enabled
              ? const [
                  BoxShadow(color: Color(0x0FA08CB0), blurRadius: 8, offset: Offset(0, 2)),
                ]
              : null,
        ),
        child: Icon(
          icon,
          color: enabled ? AppColors.textPrimary : AppColors.textMuted,
        ),
      ),
    );
  }
}
