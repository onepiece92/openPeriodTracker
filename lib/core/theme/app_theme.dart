import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum CyclePhase { menstrual, follicular, ovulation, luteal }

class AppColors {
  // Phase colors
  static const Color menstrual = Color(0xFFE07088);
  static const Color menstrualBg = Color(0xFFFCE8ED);
  static const Color follicular = Color(0xFF5BA4B5);
  static const Color follicularBg = Color(0xFFE0F0F5);
  static const Color ovulation = Color(0xFF6AB88A);
  static const Color ovulationBg = Color(0xFFE2F3E8);
  static const Color luteal = Color(0xFFA386BF);
  static const Color lutealBg = Color(0xFFEEE4F5);

  // UI colors
  static const Color textPrimary = Color(0xFF2D2440);
  static const Color textSecondary = Color(0xFF6B5F7D);
  static const Color textMuted = Color(0xFF9B8FAD);
  static const Color textLight = Color(0xFF8A7D9C);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFF0E8F5);
  static const Color surfaceBackground = Color(0xFFFAF6FD);
  static const Color inputBorder = Color(0xFFEEE4F0);

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFDF2F6),
      Color(0xFFEDE4F5),
      Color(0xFFE4EDF8),
      Color(0xFFEEF6F2),
    ],
  );

  static Color phaseColor(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstrual:
        return menstrual;
      case CyclePhase.follicular:
        return follicular;
      case CyclePhase.ovulation:
        return ovulation;
      case CyclePhase.luteal:
        return luteal;
    }
  }

  static Color phaseBgColor(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstrual:
        return menstrualBg;
      case CyclePhase.follicular:
        return follicularBg;
      case CyclePhase.ovulation:
        return ovulationBg;
      case CyclePhase.luteal:
        return lutealBg;
    }
  }

  static String phaseName(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstrual:
        return 'Menstrual Phase';
      case CyclePhase.follicular:
        return 'Follicular Phase';
      case CyclePhase.ovulation:
        return 'Ovulation Phase';
      case CyclePhase.luteal:
        return 'Luteal Phase';
    }
  }
}

class AppTextStyles {
  static TextStyle appTitle = GoogleFonts.playfairDisplay(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle sectionTitle = GoogleFonts.playfairDisplay(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle largeNumber = GoogleFonts.playfairDisplay(
    fontSize: 30,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle mediumNumber = GoogleFonts.playfairDisplay(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle body = GoogleFonts.outfit(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static TextStyle label = GoogleFonts.outfit(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
    letterSpacing: 0.8,
  );

  static TextStyle small = GoogleFonts.outfit(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
  );

  static TextStyle button = GoogleFonts.outfit(
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );
}

class AppDecorations {
  static BoxDecoration card = BoxDecoration(
    color: AppColors.cardBackground,
    borderRadius: BorderRadius.circular(18),
    border: Border.all(color: AppColors.cardBorder),
    boxShadow: const [
      BoxShadow(
        color: Color(0x0FA08CB0),
        blurRadius: 12,
        offset: Offset(0, 2),
      ),
    ],
  );
}
