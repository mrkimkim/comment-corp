import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_provider.dart';

class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 60),
              Text(
                game.isDead ? 'MENTAL BREAK' : 'TIME UP',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: game.isDead ? Colors.red : const Color(0xFF4ECDC4),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                game.isDead ? '멘탈이 무너졌습니다...' : '수고하셨습니다!',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 48),
              _ScoreCard(
                score: game.score,
                maxCombo: game.maxCombo,
                survivalSeconds: game.elapsed,
                correctCount: game.correctCount,
                wrongCount: game.wrongCount,
                totalProcessed: game.totalProcessed,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(gameProvider.notifier).reset();
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B9D),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    '다시 플레이',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
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
        color: Colors.white,
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
              color: Colors.grey,
            ),
          ),
          Text(
            '$score',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              color: Color(0xFFFF6B9D),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _stat('최대 콤보', '$maxCombo'),
              _stat('생존 시간', '${survivalSeconds.toInt()}초'),
              _stat('정확도', '${accuracy.toStringAsFixed(1)}%'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _stat('처리', '$totalProcessed'),
              _stat('정답', '$correctCount'),
              _stat('오답', '$wrongCount'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D3436),
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
