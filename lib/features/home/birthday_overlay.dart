import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class BirthdayOverlay extends StatefulWidget {
  final String name;
  final int age;
  final VoidCallback onDismiss;

  const BirthdayOverlay({
    super.key,
    required this.name,
    required this.age,
    required this.onDismiss,
  });

  @override
  State<BirthdayOverlay> createState() => _BirthdayOverlayState();
}

class _BirthdayOverlayState extends State<BirthdayOverlay>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _confettiController;
  late AnimationController _scaleController;
  late Animation<double> _fadeIn;
  late Animation<double> _cardScale;
  final List<_ConfettiPiece> _confetti = [];
  final _rng = Random();

  static const _quotes = [
    'Another year of strength, grace, and resilience.',
    'You deserve all the love you give to others.',
    'This is your year to bloom.',
    'Celebrate yourself — you are amazing.',
    'May this year bring you peace and joy.',
    'Here\'s to another year of being wonderfully you.',
  ];

  static const _tips = [
    'Birthday tip: Treat yourself to a warm bath with magnesium salts tonight.',
    'Birthday treat: Dark chocolate is rich in magnesium — enjoy guilt-free!',
    'Birthday self-care: Take 10 minutes for deep breathing today.',
    'Birthday gift to yourself: An extra hour of sleep tonight.',
  ];

  @override
  void initState() {
    super.initState();

    // Generate confetti pieces
    for (int i = 0; i < 60; i++) {
      _confetti.add(_ConfettiPiece(
        x: _rng.nextDouble(),
        delay: _rng.nextDouble() * 0.6,
        speed: 0.3 + _rng.nextDouble() * 0.7,
        size: 4 + _rng.nextDouble() * 8,
        color: [
          AppColors.menstrual,
          AppColors.follicular,
          AppColors.ovulation,
          AppColors.luteal,
          const Color(0xFFE88FB4),
          const Color(0xFFF5D76E),
          const Color(0xFF7B9ED9),
        ][_rng.nextInt(7)],
        rotation: _rng.nextDouble() * pi * 2,
        wobble: _rng.nextDouble() * 2 - 1,
        shape: _rng.nextInt(3), // 0=circle, 1=rect, 2=star
      ));
    }

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeIn = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _cardScale = CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut);

    _confettiController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _scaleController.forward();
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _confettiController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quote = _quotes[_rng.nextInt(_quotes.length)];
    final tip = _tips[_rng.nextInt(_tips.length)];
    final size = MediaQuery.of(context).size;

    return FadeTransition(
      opacity: _fadeIn,
      child: Material(
        color: Colors.black.withValues(alpha: 0.5),
        child: Stack(
          children: [
            // Confetti layer
            AnimatedBuilder(
              animation: _confettiController,
              builder: (context, _) {
                return CustomPaint(
                  size: size,
                  painter: _ConfettiPainter(
                    pieces: _confetti,
                    progress: _confettiController.value,
                  ),
                );
              },
            ),

            // Card
            Center(
              child: ScaleTransition(
                scale: _cardScale,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.luteal.withValues(alpha: 0.3),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Cake emoji with glow
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.luteal.withValues(alpha: 0.15),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: const Center(
                          child: Text('🎂', style: TextStyle(fontSize: 48)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Happy Birthday
                      Text(
                        'Happy Birthday!',
                        style: AppTextStyles.appTitle.copyWith(
                          fontSize: 24,
                          color: AppColors.luteal,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.name,
                        style: AppTextStyles.sectionTitle.copyWith(
                          fontSize: 18,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.menstrualBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '🎉 ${widget.age} years young!',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.menstrual,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Quote
                      Text(
                        '"$quote"',
                        style: AppTextStyles.body.copyWith(
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),

                      // Wellness tip
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.ovulationBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Text('💝', style: TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                tip,
                                style: AppTextStyles.small.copyWith(
                                  color: AppColors.ovulation,
                                  fontWeight: FontWeight.w600,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Dismiss button
                      GestureDetector(
                        onTap: widget.onDismiss,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.luteal, AppColors.menstrual],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              'Thank you! 🌙',
                              style: AppTextStyles.button.copyWith(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Confetti data ---

class _ConfettiPiece {
  final double x;
  final double delay;
  final double speed;
  final double size;
  final Color color;
  final double rotation;
  final double wobble;
  final int shape;

  _ConfettiPiece({
    required this.x,
    required this.delay,
    required this.speed,
    required this.size,
    required this.color,
    required this.rotation,
    required this.wobble,
    required this.shape,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiPiece> pieces;
  final double progress;

  _ConfettiPainter({required this.pieces, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in pieces) {
      final t = ((progress - p.delay) / p.speed).clamp(0.0, 1.0);
      if (t <= 0) continue;

      final x = p.x * size.width + sin(t * pi * 3 + p.wobble) * 30;
      final y = t * size.height * 1.2 - 50;
      final opacity = t < 0.8 ? 1.0 : (1.0 - t) * 5;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.rotation + t * pi * 2);

      final paint = Paint()..color = p.color.withValues(alpha: opacity.clamp(0.0, 1.0));

      if (p.shape == 0) {
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      } else if (p.shape == 1) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6),
            Radius.circular(1),
          ),
          paint,
        );
      } else {
        // Small star shape
        final path = Path();
        for (int i = 0; i < 5; i++) {
          final angle = (i * 4 * pi / 5) - pi / 2;
          final r = i % 2 == 0 ? p.size / 2 : p.size / 4;
          final px = cos(angle) * r;
          final py = sin(angle) * r;
          if (i == 0) {
            path.moveTo(px, py);
          } else {
            path.lineTo(px, py);
          }
        }
        path.close();
        canvas.drawPath(path, paint);
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => old.progress != progress;
}
