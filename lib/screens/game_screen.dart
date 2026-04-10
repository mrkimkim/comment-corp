import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/game_state.dart';
import '../providers/game_provider.dart';
import '../widgets/swipe_stack.dart';
import 'result_screen.dart';

final _scoreFormatter = NumberFormat('#,###');

class GameScreen extends ConsumerStatefulWidget {
  final String celebType;
  const GameScreen({super.key, required this.celebType});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with TickerProviderStateMixin {
  // ── Animation controllers (3 total) ──────────────────────────────

  /// Flash overlay (correct = green, wrong = red)
  Color? _flashColor;
  late final AnimationController _flashController;
  late final Animation<double> _flashOpacity;

  /// Mental warning red border blink
  late final AnimationController _mentalBlinkController;

  /// Floating score popup (+points)
  late final AnimationController _floatingScoreController;
  late final Animation<double> _floatingScoreOpacity;
  late final Animation<Offset> _floatingScoreOffset;
  int _floatingScoreValue = 0;

  @override
  void initState() {
    super.initState();

    // Kick off the game
    Future.microtask(() {
      ref.read(gameProvider.notifier).startGame(widget.celebType);
    });

    // ── Flash (400ms fade-out) ──
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _flashOpacity = Tween<double>(begin: 0.35, end: 0.0).animate(
      CurvedAnimation(parent: _flashController, curve: Curves.easeOut),
    );

    // ── Mental blink (loop) ──
    _mentalBlinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    // ── Floating score (1s fade-up) ──
    _floatingScoreController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _floatingScoreOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _floatingScoreController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );
    _floatingScoreOffset = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -60),
    ).animate(
      CurvedAnimation(
        parent: _floatingScoreController,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _flashController.dispose();
    _mentalBlinkController.dispose();
    _floatingScoreController.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────

  void _showFlash(bool isCorrect) {
    setState(() {
      _flashColor = isCorrect ? AppColors.correct : AppColors.wrong;
    });
    _flashController.forward(from: 0);
  }

  void _showFloatingScore(int points) {
    setState(() {
      _floatingScoreValue = points;
    });
    _floatingScoreController.forward(from: 0);
  }

  int _getCurrentPhase(double elapsed) {
    if (elapsed < 30) return 1;
    if (elapsed < 60) return 2;
    if (elapsed < 90) return 3;
    if (elapsed < 110) return 4;
    return 5;
  }

  Color _getPhaseColor(int phase) {
    switch (phase) {
      case 1:
        return AppColors.secondary; // mint
      case 2:
        return const Color(0xFFFFE66D); // yellow
      case 3:
        return const Color(0xFFFF8C42); // orange
      case 4:
        return const Color(0xFFFF7675); // red
      case 5:
        return const Color(0xFFC0392B); // deep red
      default:
        return AppColors.secondary;
    }
  }

  // ── Build ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);

    // ── Listeners ──
    ref.listen(gameProvider, (prev, next) {
      if (!mounted) return;

      // Navigate to result screen on game over
      if (prev?.status != GameStatus.gameOver &&
          next.status == GameStatus.gameOver) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ResultScreen()),
        );
        return;
      }

      // Flash + floating score on every swipe (detect by totalProcessed change)
      if (next.totalProcessed > (prev?.totalProcessed ?? 0) &&
          next.lastResult != null) {
        final isCorrect = next.lastResult == SwipeResult.correctBlock ||
            next.lastResult == SwipeResult.correctApprove;
        _showFlash(isCorrect);

        // Floating score popup on correct
        if (isCorrect) {
          final gained = next.score - (prev?.score ?? 0);
          if (gained > 0) {
            _showFloatingScore(gained);
          }
        }
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // ── Main layout ──
            Column(
              children: [
                _buildTimerBar(game),
                _buildHudRow(game),
                const SizedBox(height: 4),
                if (game.freezeActive || game.boostActive)
                  _buildActiveItemBanner(game),
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SwipeStack(
                        comment: game.currentComment,
                        detectorActive: game.detectorActive,
                        onSwiped: (approve) {
                          ref
                              .read(gameProvider.notifier)
                              .swipe(approve: approve);
                        },
                      ),
                      // Floating score popup
                      if (_floatingScoreController.isAnimating)
                        AnimatedBuilder(
                          animation: _floatingScoreController,
                          builder: (context, _) {
                            return Transform.translate(
                              offset: _floatingScoreOffset.value,
                              child: Opacity(
                                opacity: _floatingScoreOpacity.value,
                                child: Text(
                                  '+$_floatingScoreValue',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.correct,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black26,
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
                _buildItemBar(game),
                const SizedBox(height: 16),
              ],
            ),

            // ── Flash overlay ──
            if (_flashColor != null)
              AnimatedBuilder(
                animation: _flashController,
                builder: (context, _) {
                  return IgnorePointer(
                    child: Container(
                      color:
                          _flashColor!.withValues(alpha: _flashOpacity.value),
                    ),
                  );
                },
              ),

            // ── Mental warning border blink (<30%) ──
            if (game.mentalPercent < 0.3 &&
                game.status == GameStatus.playing)
              AnimatedBuilder(
                animation: _mentalBlinkController,
                builder: (context, _) {
                  return IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.red.withValues(
                            alpha: _mentalBlinkController.value * 0.3,
                          ),
                          width: 4,
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  // ── Timer bar (full-width, 6px, phase color, pulse on last 10s) ──

  Widget _buildTimerBar(GameState game) {
    final phase = _getCurrentPhase(game.elapsed);
    final phaseColor = _getPhaseColor(phase);
    final progress = (game.timeRemaining / 120).clamp(0.0, 1.0);
    final isLastTen = game.timeRemaining <= 10;

    Widget bar = ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: LinearProgressIndicator(
        value: progress,
        backgroundColor: Colors.grey[300],
        color: phaseColor,
        minHeight: 6,
      ),
    );

    // Pulse animation in the last 10 seconds using the mentalBlinkController
    // to avoid adding another AnimationController.
    if (isLastTen && game.status == GameStatus.playing) {
      bar = AnimatedBuilder(
        animation: _mentalBlinkController,
        builder: (context, child) {
          final opacity = 0.6 + _mentalBlinkController.value * 0.4;
          return Opacity(opacity: opacity, child: child);
        },
        child: bar,
      );
    }

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
      child: bar,
    );
  }

  // ── HUD row: mental | score | combo ──

  Widget _buildHudRow(GameState game) {
    final mentalLow = game.mentalPercent < 0.3;
    final mentalCurrent = game.mental.toInt();
    const mentalMax = 100;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // ── Left: Mental (heart icon + number) ──
          Expanded(
            child: Row(
              children: [
                mentalLow
                    ? AnimatedBuilder(
                        animation: _mentalBlinkController,
                        builder: (context, _) {
                          return Icon(
                            Icons.favorite,
                            size: 18,
                            color: Colors.red.withValues(
                              alpha:
                                  0.4 + _mentalBlinkController.value * 0.6,
                            ),
                          );
                        },
                      )
                    : Icon(Icons.favorite, size: 18, color: Colors.pink[300]),
                const SizedBox(width: 4),
                Text(
                  '$mentalCurrent/$mentalMax',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: mentalLow ? FontWeight.w900 : FontWeight.w700,
                    color: mentalLow ? Colors.red : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          // ── Center: Score ──
          Text(
            _scoreFormatter.format(game.score),
            style: AppTextStyles.scoreLive,
          ),

          // ── Right: Combo ──
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (game.combo > 0 || game.feverActive) ...[
                  if (game.feverActive)
                    const Padding(
                      padding: EdgeInsets.only(right: 2),
                      child: Text('\u{1F525}', style: TextStyle(fontSize: 14)),
                    ),
                  Text(
                    '${game.combo}x',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: game.feverActive
                          ? Colors.orange
                          : (game.combo >= 5
                              ? AppColors.comboAmber
                              : AppColors.textSecondary),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Active item banner (freeze / boost) ──

  Widget _buildActiveItemBanner(GameState game) {
    final active = <(String, IconData, Color, double)>[];
    if (game.freezeActive) {
      active.add(
          ('프리즈', Icons.ac_unit, const Color(0xFF87CEEB), game.freezeTimer));
    }
    if (game.boostActive) {
      active.add(
          ('부스트 x3', Icons.bolt, AppColors.accent, game.boostTimer));
    }

    if (active.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: active.first.$3.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: active.first.$3.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: active.map((item) {
          final (label, icon, color, timer) = item;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 4),
                Text(
                  '$label ${timer.toStringAsFixed(1)}s',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Item bar (4 items, 56px tap targets, X overlay when depleted) ──

  Widget _buildItemBar(GameState game) {
    const items = [
      ('detector', Icons.visibility, '탐지기', AppColors.secondary),
      ('freeze', Icons.ac_unit, '프리즈', Color(0xFF87CEEB)),
      ('boost', Icons.bolt, '부스트', Color(0xFFFF8C42)),
      ('skip', Icons.skip_next, '스킵', Color(0xFF9B59B6)),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: items.map((item) {
          final (name, icon, label, color) = item;
          final count = game.items[name] ?? 0;
          final isActive = (name == 'freeze' && game.freezeActive) ||
              (name == 'boost' && game.boostActive);
          final isDepleted = count <= 0 && !isActive;

          return GestureDetector(
            onTap: count > 0 && !isActive
                ? () => ref.read(gameProvider.notifier).useItem(name)
                : null,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 56,
                  height: 56,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: isActive
                              ? color.withValues(alpha: 0.4)
                              : color.withValues(alpha: isDepleted ? 0.08 : 0.2),
                          borderRadius: BorderRadius.circular(14),
                          border: isActive
                              ? Border.all(color: color, width: 2)
                              : null,
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.4),
                                    blurRadius: 8,
                                  ),
                                ]
                              : null,
                        ),
                        child: Icon(
                          icon,
                          color: isActive
                              ? Colors.white
                              : (isDepleted
                                  ? color.withValues(alpha: 0.3)
                                  : color),
                          size: 24,
                        ),
                      ),
                      // X mark overlay for depleted items
                      if (isDepleted)
                        Icon(
                          Icons.close,
                          size: 28,
                          color: Colors.grey.withValues(alpha: 0.5),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isActive ? 'ON' : '$label($count)',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight:
                        isActive ? FontWeight.w800 : FontWeight.w500,
                    color: isActive
                        ? color
                        : (isDepleted ? Colors.grey : null),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
