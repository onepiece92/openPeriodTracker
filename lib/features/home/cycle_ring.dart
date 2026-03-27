import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class CycleRing extends StatefulWidget {
  final int currentDay;
  final int cycleLength;
  final int periodLength;
  final CyclePhase phase;

  const CycleRing({
    super.key,
    required this.currentDay,
    required this.cycleLength,
    required this.periodLength,
    required this.phase,
  });

  @override
  State<CycleRing> createState() => _CycleRingState();
}

class _CycleRingState extends State<CycleRing> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(CycleRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentDay != widget.currentDay) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          width: 200,
          height: 200,
          child: CustomPaint(
            painter: _CycleRingPainter(
              currentDay: widget.currentDay,
              cycleLength: widget.cycleLength,
              periodLength: widget.periodLength,
              phase: widget.phase,
              progress: _animation.value,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${widget.currentDay}',
                    style: AppTextStyles.largeNumber.copyWith(
                      color: AppColors.phaseColor(widget.phase),
                    ),
                  ),
                  Text(
                    'CYCLE DAY',
                    style: AppTextStyles.label,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CycleRingPainter extends CustomPainter {
  final int currentDay;
  final int cycleLength;
  final int periodLength;
  final CyclePhase phase;
  final double progress;

  _CycleRingPainter({
    required this.currentDay,
    required this.cycleLength,
    required this.periodLength,
    required this.phase,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    const strokeWidth = 10.0;
    const startAngle = -pi / 2;

    // Background track
    final bgPaint = Paint()
      ..color = const Color(0xFFF0E8F5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Period arc
    final periodSweep = (periodLength / cycleLength) * 2 * pi;
    final periodPaint = Paint()
      ..color = AppColors.menstrual.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      periodSweep,
      false,
      periodPaint,
    );

    // Fertile arc
    final fertileStart = (cycleLength - 18) / cycleLength;
    final fertileEnd = (cycleLength - 12) / cycleLength;
    final fertileStartAngle = startAngle + fertileStart * 2 * pi;
    final fertileSweep = (fertileEnd - fertileStart) * 2 * pi;
    final fertilePaint = Paint()
      ..color = AppColors.ovulation.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      fertileStartAngle,
      fertileSweep,
      false,
      fertilePaint,
    );

    // Progress arc
    final progressSweep = (currentDay / cycleLength) * 2 * pi * progress;
    final progressPaint = Paint()
      ..color = AppColors.phaseColor(phase)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      progressSweep,
      false,
      progressPaint,
    );

    // Dot indicator at current position
    final dotAngle = startAngle + progressSweep;
    final dotCenter = Offset(
      center.dx + radius * cos(dotAngle),
      center.dy + radius * sin(dotAngle),
    );
    final dotPaint = Paint()
      ..color = AppColors.phaseColor(phase)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(dotCenter, 6, dotPaint);

    final dotBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(dotCenter, 6, dotBorderPaint);
  }

  @override
  bool shouldRepaint(covariant _CycleRingPainter oldDelegate) {
    return oldDelegate.currentDay != currentDay ||
        oldDelegate.progress != progress ||
        oldDelegate.phase != phase;
  }
}
