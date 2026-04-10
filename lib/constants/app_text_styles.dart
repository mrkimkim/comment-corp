import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // Headings
  static const TextStyle heading1 = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
    height: 1.1,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
  );

  // Body
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Labels
  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  // Score
  // NOTE: 점수 표시 시 NumberFormat('#,###')으로 쉼표 포맷 적용 필요.
  // 예: intl 패키지의 NumberFormat 또는 수동 포맷 유틸 사용.
  static const TextStyle scoreDisplay = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w900,
    color: AppColors.primary,
  );

  static const TextStyle scoreLive = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: AppColors.primary,
  );

  // Timer
  static const TextStyle timer = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
  );

  // Grade
  static const TextStyle gradeDisplay = TextStyle(
    fontSize: 72,
    fontWeight: FontWeight.w900,
  );

  // Stat
  static const TextStyle statValue = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle statLabel = TextStyle(
    fontSize: 11,
    color: AppColors.textHint,
  );
}
