import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/game_state.dart';
import '../providers/game_provider.dart';
import '../widgets/swipe_stack.dart';
import 'result_screen.dart';

class GameScreen extends ConsumerStatefulWidget {
  final String celebType;
  const GameScreen({super.key, required this.celebType});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with TickerProviderStateMixin {
  // Flash overlay
  Color? _flashColor;
  late AnimationController _flashController;
  late Animation<double> _flashOpacity;

  // Mental warning blink
  late AnimationController _mentalBlinkController;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(gameProvider.notifier).startGame(widget.celebType);
    });

    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _flashOpacity = Tween<double>(begin: 0.35, end: 0.0).animate(
      CurvedAnimation(parent: _flashController, curve: Curves.easeOut),
    );

    _mentalBlinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _flashController.dispose();
    _mentalBlinkController.dispose();
    super.dispose();
  }

  void _showFlash(bool isCorrect) {
    setState(() {
      _flashColor = isCorrect ? AppColors.correct : AppColors.wrong;
    });
    _flashController.forward(from: 0);
  }

  int _getCurrentPhase(double elapsed) {
    if (elapsed < 30) return 1;
    if (elapsed < 60) return 2;
    if (elapsed < 90) return 3;
    return 4;
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);

    ref.listen(gameProvider, (prev, next) {
      if (prev?.status != GameStatus.gameOver &&
          next.status == GameStatus.gameOver) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ResultScreen()),
        );
      }

      // Flash on swipe result
      if (next.lastResult != null && prev?.lastResult != next.lastResult) {
        final isCorrect = next.lastResult == SwipeResult.correctBlock ||
            next.lastResult == SwipeResult.correctApprove;
        _showFlash(isCorrect);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Main game content
            Column(
              children: [
                _buildTopBar(game),
                _buildStatsRow(game),
                const SizedBox(height: 8),
                // Active item indicators
                if (game.detectorActive || game.freezeActive || game.boostActive)
                  _buildActiveItemBanner(game),
                Expanded(
                  child: Center(
                    child: SwipeStack(
                      comment: game.currentComment,
                      detectorActive: game.detectorActive,
                      onSwiped: (approve) {
                        ref
                            .read(gameProvider.notifier)
                            .swipe(approve: approve);
                      },
                    ),
                  ),
                ),
                _buildSwipeHint(),
                _buildItemBar(game),
                const SizedBox(height: 16),
              ],
            ),

            // Flash overlay
            if (_flashColor != null)
              AnimatedBuilder(
                animation: _flashController,
                builder: (context, _) {
                  return IgnorePointer(
                    child: Container(
                      color: _flashColor!
                          .withValues(alpha: _flashOpacity.value),
                    ),
                  );
                },
              ),

            // Mental warning overlay
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

            // Pause overlay
            if (game.status == GameStatus.paused) _buildPauseOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(GameState game) {
    final phase = _getCurrentPhase(game.elapsed);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              game.status == GameStatus.paused
                  ? Icons.play_arrow
                  : Icons.pause,
              color: AppColors.textPrimary,
            ),
            onPressed: () => ref.read(gameProvider.notifier).togglePause(),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  '${game.timeRemaining.toInt()}s',
                  style: AppTextStyles.timer,
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: game.timeRemaining / 120,
                    backgroundColor: Colors.grey[300],
                    color: AppColors.secondary,
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Phase indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'P$phase',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${game.score}',
            style: AppTextStyles.scoreLive,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(GameState game) {
    final mentalLow = game.mentalPercent < 0.3;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Mental bar
          Expanded(
            child: Row(
              children: [
                mentalLow
                    ? AnimatedBuilder(
                        animation: _mentalBlinkController,
                        builder: (context, _) {
                          return Icon(
                            Icons.favorite,
                            size: 16,
                            color: Colors.red.withValues(
                              alpha:
                                  0.4 + _mentalBlinkController.value * 0.6,
                            ),
                          );
                        },
                      )
                    : Icon(Icons.favorite,
                        size: 16, color: Colors.pink[300]),
                const SizedBox(width: 4),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: game.mentalPercent,
                      backgroundColor: Colors.grey[300],
                      color: mentalLow ? Colors.red : Colors.pink[300],
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${game.mental.toInt()}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: mentalLow ? Colors.red : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Combo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: game.feverActive
                  ? Colors.orange
                  : (game.combo >= 5 ? Colors.amber : Colors.grey[300]),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (game.feverActive)
                  const Icon(Icons.local_fire_department,
                      size: 14, color: Colors.white),
                Text(
                  game.feverActive
                      ? 'FEVER ${game.combo}x'
                      : '${game.combo}x',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color:
                        game.combo >= 5 ? Colors.white : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeHint() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            children: [
              Icon(Icons.arrow_back, size: 16, color: AppColors.wrong),
              const SizedBox(width: 4),
              Text('차단',
                  style: TextStyle(
                      color: AppColors.wrong, fontSize: 12)),
            ],
          ),
          Row(
            children: [
              Text('승인',
                  style: TextStyle(
                      color: AppColors.correct, fontSize: 12)),
              const SizedBox(width: 4),
              Icon(Icons.arrow_forward, size: 16, color: AppColors.correct),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveItemBanner(GameState game) {
    final active = <(String, IconData, Color, double)>[];
    if (game.detectorActive) {
      active.add(('탐지기', Icons.search, AppColors.secondary, game.detectorTimer));
    }
    if (game.freezeActive) {
      active.add(('프리즈', Icons.ac_unit, const Color(0xFF87CEEB), game.freezeTimer));
    }
    if (game.boostActive) {
      active.add(('부스트 x3', Icons.bolt, AppColors.accent, game.boostTimer));
    }

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

  Widget _buildItemBar(GameState game) {
    final items = [
      ('detector', Icons.search, '탐지기', AppColors.secondary),
      ('freeze', Icons.ac_unit, '프리즈', const Color(0xFF87CEEB)),
      ('boost', Icons.bolt, '부스트', AppColors.accent),
      ('shield', Icons.shield, '쉴드', AppColors.politician),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: items.map((item) {
          final (name, icon, label, color) = item;
          final count = game.items[name] ?? 0;
          final isActive = (name == 'detector' && game.detectorActive) ||
              (name == 'freeze' && game.freezeActive) ||
              (name == 'boost' && game.boostActive);
          return GestureDetector(
            onTap: count > 0 && !isActive
                ? () => ref.read(gameProvider.notifier).useItem(name)
                : null,
            child: Opacity(
              opacity: count > 0 || isActive ? 1.0 : 0.3,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isActive
                          ? color.withValues(alpha: 0.4)
                          : color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: isActive
                          ? Border.all(color: color, width: 2)
                          : null,
                      boxShadow: isActive
                          ? [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 8)]
                          : null,
                    ),
                    child: Icon(icon, color: isActive ? Colors.white : color, size: 22),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isActive ? 'ON' : '$label($count)',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                      color: isActive ? color : null,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPauseOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.6),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'PAUSED',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () =>
                  ref.read(gameProvider.notifier).togglePause(),
              icon: const Icon(Icons.play_arrow),
              label: const Text(
                'Resume',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
