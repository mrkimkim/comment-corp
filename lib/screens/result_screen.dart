import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../providers/game_provider.dart';

class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({super.key});

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen>
    with TickerProviderStateMixin {
  // --- Grade helper (static-like) ---
  static (String grade, Color color) _getGrade(int score) {
    if (score >= 50000) return ('S', AppColors.gradeS);
    if (score >= 30000) return ('A', AppColors.gradeA);
    if (score >= 15000) return ('B', AppColors.gradeB);
    if (score >= 5000) return ('C', AppColors.gradeC);
    return ('D', AppColors.gradeD);
  }

  // ---- Animation controllers ----

  /// 1. Score count-up  (0 → finalScore over 1.5s)
  late final AnimationController _scoreController;
  late final Animation<int> _scoreAnimation;

  /// 2. Grade badge bounce-in (scale 0→1, elasticOut, 500ms)
  late final AnimationController _gradeController;
  late final Animation<double> _gradeScale;

  /// 3. Stat rows slide-in (6 items, staggered 300ms each)
  late final AnimationController _statsController;

  /// 4. "NEW BEST!" banner bounce-in
  late final AnimationController _newBestController;
  late final Animation<double> _newBestScale;

  /// 5. Buttons fade-in
  late final AnimationController _buttonsController;
  late final Animation<double> _buttonsOpacity;

  /// 6. S-grade shimmer
  late final AnimationController _shimmerController;

  /// Whether this result is a new personal best.
  /// For now we always show it as false; the flag is ready for GameState
  /// integration once best-score persistence is added.
  final bool _isNewBest = false;

  // Cache final score so animations refer to a constant value.
  late final int _finalScore;

  @override
  void initState() {
    super.initState();

    final game = ref.read(gameProvider);
    _finalScore = game.score;

    // ---- 1. Score count-up (1.5s) ----
    _scoreController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _scoreAnimation = IntTween(begin: 0, end: _finalScore).animate(
      CurvedAnimation(parent: _scoreController, curve: Curves.easeOutCubic),
    );

    // ---- 2. Grade badge (500ms, starts after score + 300ms delay) ----
    _gradeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _gradeScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _gradeController, curve: Curves.elasticOut),
    );

    // ---- 3. Stats stagger controller ----
    //  Total duration = wait-for-grade(500ms) + 6 items * 300ms = 2300ms
    //  We normalise the 6 slots within a single controller.
    _statsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2100), // 6 * 350ms
    );

    // ---- 4. NEW BEST banner (bounce-in 500ms) ----
    _newBestController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _newBestScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _newBestController, curve: Curves.elasticOut),
    );

    // ---- 5. Buttons fade-in (400ms) ----
    _buttonsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _buttonsOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _buttonsController, curve: Curves.easeIn),
    );

    // ---- 6. S-grade shimmer (repeating) ----
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // ---- Kick off the orchestrated sequence ----
    _runSequence();
  }

  Future<void> _runSequence() async {
    // Step 1: score count-up
    _scoreController.forward();
    await _scoreController.animateTo(1.0);
    if (!mounted) return;

    // Step 2: 300ms pause then grade badge bounce-in
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _gradeController.forward();

    // If S-grade, start shimmer loop
    final (grade, _) = _getGrade(_finalScore);
    if (grade == 'S') {
      _shimmerController.repeat();
    }

    // Step 3: after grade animation finishes, stagger stats
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    _statsController.forward();

    // NEW BEST banner (show right after grade if applicable)
    if (_isNewBest) {
      _newBestController.forward();
    }

    // Step 4: after all stats revealed, 500ms then buttons
    await _statsController.animateTo(1.0);
    if (!mounted) return;
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    _buttonsController.forward();
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _gradeController.dispose();
    _statsController.dispose();
    _newBestController.dispose();
    _buttonsController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  // --- Helpers for staggered stat animations ---

  /// Returns an interval [begin, end] within [0,1] for the i-th stat (0-5).
  Animation<double> _statOpacity(int index) {
    const itemCount = 6;
    const itemDuration = 0.25; // fraction of total controller
    final start = (index / itemCount).clamp(0.0, 1.0);
    final end = (start + itemDuration).clamp(0.0, 1.0);
    return Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _statsController,
        curve: Interval(start, end, curve: Curves.easeOut),
      ),
    );
  }

  Animation<Offset> _statSlide(int index) {
    const itemCount = 6;
    const itemDuration = 0.25;
    final start = (index / itemCount).clamp(0.0, 1.0);
    final end = (start + itemDuration).clamp(0.0, 1.0);
    return Tween<Offset>(
      begin: const Offset(-0.3, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _statsController,
        curve: Interval(start, end, curve: Curves.easeOut),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final (grade, gradeColor) = _getGrade(_finalScore);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 48),

              // --- NEW BEST! banner ---
              if (_isNewBest)
                ScaleTransition(
                  scale: _newBestScale,
                  child: const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                      '\u{1F389} NEW BEST!',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.gradeS,
                      ),
                    ),
                  ),
                ),

              // --- Title ---
              Text(
                game.isDead ? 'MENTAL BREAK' : 'TIME UP',
                style: AppTextStyles.heading2.copyWith(
                  color: game.isDead ? AppColors.wrong : AppColors.secondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                game.isDead ? '멘탈이 무너졌습니다...' : '수고하셨습니다!',
                style: AppTextStyles.label,
              ),
              const SizedBox(height: 32),

              // --- Grade badge with bounce-in ---
              ScaleTransition(
                scale: _gradeScale,
                child: _GradeBadge(
                  grade: grade,
                  color: gradeColor,
                  shimmerController:
                      grade == 'S' ? _shimmerController : null,
                ),
              ),
              const SizedBox(height: 24),

              // --- Score card with count-up + near-miss + staggered stats ---
              _AnimatedScoreCard(
                scoreAnimation: _scoreAnimation,
                finalScore: _finalScore,
                maxCombo: game.maxCombo,
                survivalSeconds: game.elapsed,
                correctCount: game.correctCount,
                wrongCount: game.wrongCount,
                totalProcessed: game.totalProcessed,
                statOpacity: _statOpacity,
                statSlide: _statSlide,
              ),

              const Spacer(),

              // --- Buttons with delayed fade-in ---
              FadeTransition(
                opacity: _buttonsOpacity,
                child: Column(
                  children: [
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
                            color:
                                AppColors.textHint.withValues(alpha: 0.5),
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
                  ],
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

// =============================================================================
// Grade Badge with optional golden shimmer for S-grade
// =============================================================================

class _GradeBadge extends StatelessWidget {
  final String grade;
  final Color color;
  final AnimationController? shimmerController;

  const _GradeBadge({
    required this.grade,
    required this.color,
    this.shimmerController,
  });

  @override
  Widget build(BuildContext context) {
    Widget badge = Container(
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

    // S-grade golden shimmer overlay
    if (shimmerController != null) {
      badge = AnimatedBuilder(
        animation: shimmerController!,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              child!,
              // Rotating glow ring
              SizedBox(
                width: 110,
                height: 110,
                child: CustomPaint(
                  painter: _ShimmerPainter(
                    progress: shimmerController!.value,
                    color: AppColors.gradeS,
                  ),
                ),
              ),
            ],
          );
        },
        child: badge,
      );
    }

    return badge;
  }
}

/// Draws a rotating golden shimmer arc around the S-grade badge.
class _ShimmerPainter extends CustomPainter {
  final double progress;
  final Color color;

  _ShimmerPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: math.pi * 2,
        colors: [
          color.withValues(alpha: 0),
          color.withValues(alpha: 0.6),
          color.withValues(alpha: 0),
        ],
        stops: const [0.0, 0.5, 1.0],
        transform: GradientRotation(progress * math.pi * 2),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawOval(rect.deflate(1.5), paint);
  }

  @override
  bool shouldRepaint(_ShimmerPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// =============================================================================
// Score Card with count-up animation, near-miss, and staggered stats
// =============================================================================

class _AnimatedScoreCard extends StatelessWidget {
  final Animation<int> scoreAnimation;
  final int finalScore;
  final int maxCombo;
  final double survivalSeconds;
  final int correctCount;
  final int wrongCount;
  final int totalProcessed;
  final Animation<double> Function(int index) statOpacity;
  final Animation<Offset> Function(int index) statSlide;

  const _AnimatedScoreCard({
    required this.scoreAnimation,
    required this.finalScore,
    required this.maxCombo,
    required this.survivalSeconds,
    required this.correctCount,
    required this.wrongCount,
    required this.totalProcessed,
    required this.statOpacity,
    required this.statSlide,
  });

  static int? _pointsToNextGrade(int score) {
    if (score >= 50000) return null;
    if (score >= 30000) return 50000 - score;
    if (score >= 15000) return 30000 - score;
    if (score >= 5000) return 15000 - score;
    return 5000 - score;
  }

  static String _nextGradeLabel(int score) {
    if (score >= 30000) return 'S';
    if (score >= 15000) return 'A';
    if (score >= 5000) return 'B';
    return 'C';
  }

  @override
  Widget build(BuildContext context) {
    final accuracy =
        totalProcessed > 0 ? (correctCount / totalProcessed * 100) : 0;

    final pointsToNext = _pointsToNextGrade(finalScore);
    final nextGrade = _nextGradeLabel(finalScore);

    // Stat definitions in display order
    final stats = <_StatDef>[
      _StatDef(Icons.flash_on, '최대 콤보', '$maxCombo'),
      _StatDef(Icons.timer, '생존 시간', '${survivalSeconds.toInt()}초'),
      _StatDef(
          Icons.gps_fixed, '정확도', '${accuracy.toStringAsFixed(1)}%'),
      _StatDef(Icons.inbox, '처리', '$totalProcessed'),
      _StatDef(Icons.check_circle_outline, '정답', '$correctCount'),
      _StatDef(Icons.cancel_outlined, '오답', '$wrongCount'),
    ];

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
          // Count-up score
          AnimatedBuilder(
            animation: scoreAnimation,
            builder: (context, child) {
              return Text(
                '${scoreAnimation.value}',
                style: AppTextStyles.scoreDisplay,
              );
            },
          ),

          // Near-miss text
          const SizedBox(height: 6),
          pointsToNext != null
              ? Text(
                  '$nextGrade등급까지 ${_formatNumber(pointsToNext)}점!',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                )
              : const Text(
                  '최고 등급 달성!',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gradeS,
                  ),
                ),

          const SizedBox(height: 24),

          // First row of stats (indices 0, 1, 2)
          Row(
            children: [
              for (int i = 0; i < 3; i++)
                Expanded(
                  child: SlideTransition(
                    position: statSlide(i),
                    child: FadeTransition(
                      opacity: statOpacity(i),
                      child: _statWidget(
                        stats[i].icon,
                        stats[i].label,
                        stats[i].value,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Second row of stats (indices 3, 4, 5)
          Row(
            children: [
              for (int i = 3; i < 6; i++)
                Expanded(
                  child: SlideTransition(
                    position: statSlide(i),
                    child: FadeTransition(
                      opacity: statOpacity(i),
                      child: _statWidget(
                        stats[i].icon,
                        stats[i].label,
                        stats[i].value,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statWidget(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 18, color: AppColors.textHint),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.statValue),
        Text(label, style: AppTextStyles.statLabel),
      ],
    );
  }

  static String _formatNumber(int n) {
    if (n < 1000) return '$n';
    final str = n.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}

class _StatDef {
  final IconData icon;
  final String label;
  final String value;

  const _StatDef(this.icon, this.label, this.value);
}
