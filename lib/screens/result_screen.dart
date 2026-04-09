import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../providers/game_provider.dart';

class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key});

  static (String grade, Color color) _getGrade(int score) {
    if (score >= 50000) return ('S', AppColors.gradeS);
    if (score >= 30000) return ('A', AppColors.gradeA);
    if (score >= 15000) return ('B', AppColors.gradeB);
    if (score >= 5000) return ('C', AppColors.gradeC);
    return ('D', AppColors.gradeD);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final (grade, gradeColor) = _getGrade(game.score);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 48),
              Text(
                game.isDead ? 'MENTAL BREAK' : 'TIME UP',
                style: AppTextStyles.heading2.copyWith(
                  color:
                      game.isDead ? AppColors.wrong : AppColors.secondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                game.isDead ? '멘탈이 무너졌습니다...' : '수고하셨습니다!',
                style: AppTextStyles.label,
              ),
              const SizedBox(height: 32),
              // Grade badge
              _GradeBadge(grade: grade, color: gradeColor),
              const SizedBox(height: 24),
              _ScoreCard(
                score: game.score,
                maxCombo: game.maxCombo,
                survivalSeconds: game.elapsed,
                correctCount: game.correctCount,
                wrongCount: game.wrongCount,
                totalProcessed: game.totalProcessed,
              ),
              const Spacer(),
              // Replay button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(gameProvider.notifier).reset();
                    Navigator.of(context)
                        .popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    '다시 플레이',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Menu button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton(
                  onPressed: () {
                    ref.read(gameProvider.notifier).reset();
                    Navigator.of(context)
                        .popUntil((route) => route.isFirst);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: BorderSide(
                      color: AppColors.textHint.withValues(alpha: 0.5),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    '메뉴로',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _GradeBadge extends StatelessWidget {
  final String grade;
  final Color color;

  const _GradeBadge({required this.grade, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color, width: 3),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Text(
          grade,
          style: AppTextStyles.gradeDisplay.copyWith(color: color),
        ),
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final int score;
  final int maxCombo;
  final double survivalSeconds;
  final int correctCount;
  final int wrongCount;
  final int totalProcessed;

  const _ScoreCard({
    required this.score,
    required this.maxCombo,
    required this.survivalSeconds,
    required this.correctCount,
    required this.wrongCount,
    required this.totalProcessed,
  });

  @override
  Widget build(BuildContext context) {
    final accuracy =
        totalProcessed > 0 ? (correctCount / totalProcessed * 100) : 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'SCORE',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textHint,
            ),
          ),
          Text('$score', style: AppTextStyles.scoreDisplay),
          const SizedBox(height: 24),
          Row(
            children: [
              _stat(Icons.flash_on, '최대 콤보', '$maxCombo'),
              _stat(Icons.timer, '생존 시간',
                  '${survivalSeconds.toInt()}초'),
              _stat(Icons.gps_fixed, '정확도',
                  '${accuracy.toStringAsFixed(1)}%'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _stat(Icons.inbox, '처리', '$totalProcessed'),
              _stat(Icons.check_circle_outline, '정답',
                  '$correctCount'),
              _stat(Icons.cancel_outlined, '오답', '$wrongCount'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(IconData icon, String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18, color: AppColors.textHint),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.statValue),
          Text(label, style: AppTextStyles.statLabel),
        ],
      ),
    );
  }
}
