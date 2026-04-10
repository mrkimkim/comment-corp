import 'dart:async';
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

  // Floating score popup
  late AnimationController _floatingScoreController;
  late Animation<double> _floatingScoreOpacity;
  late Animation<Offset> _floatingScoreOffset;
  int _floatingScoreValue = 0;

  // Final countdown pulse
  late AnimationController _countdownPulseController;

  // Final countdown center number (5..1)
  late AnimationController _centerCountdownController;
  late Animation<double> _centerCountdownOpacity;
  late Animation<double> _centerCountdownScale;
  int _centerCountdownNumber = 0;
  int _lastShownCountdownSecond = -1;

  // Swipe hint auto-hide
  bool _swipeHintVisible = true;
  Timer? _swipeHintTimer;
  bool _hasEverSwiped = false;

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

    // Floating score animation: fade-up over 1 second
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

    // Final countdown pulse (last 10 seconds)
    _countdownPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);

    // Center countdown (5..1): scale-up + fade-out
    _centerCountdownController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _centerCountdownOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _centerCountdownController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );
    _centerCountdownScale = Tween<double>(begin: 0.5, end: 1.5).animate(
      CurvedAnimation(
        parent: _centerCountdownController,
        curve: Curves.easeOut,
      ),
    );

    // Start swipe hint auto-hide timer (5 seconds)
    _swipeHintTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && !_hasEverSwiped) {
        setState(() {
          _swipeHintVisible = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _flashController.dispose();
    _mentalBlinkController.dispose();
    _floatingScoreController.dispose();
    _countdownPulseController.dispose();
    _centerCountdownController.dispose();
    _swipeHintTimer?.cancel();
    super.dispose();
  }

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

  void _triggerCenterCountdown(int second) {
    if (second == _lastShownCountdownSecond) return;
    _lastShownCountdownSecond = second;
    setState(() {
      _centerCountdownNumber = second;
    });
    _centerCountdownController.forward(from: 0);
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

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);

    // Final countdown: trigger center number when <= 5 seconds remain
    final timeRemaining = game.timeRemaining;
    if (timeRemaining <= 5 && timeRemaining > 0 && game.status == GameStatus.playing) {
      final second = timeRemaining.ceil();
      _triggerCenterCountdown(second);
    }

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

        // Floating score popup on correct
        if (isCorrect) {
          final gained = next.score - (prev?.score ?? 0);
          if (gained > 0) {
            _showFloatingScore(gained);
          }
        }

        // Hide swipe hint on first swipe
        if (!_hasEverSwiped) {
          _hasEverSwiped = true;
          setState(() {
            _swipeHintVisible = false;
          });
        }
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
                if (game.freezeActive || game.boostActive)
                  _buildActiveItemBanner(game),
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Combo counter above card
                          _buildComboCounter(game),
                          SwipeStack(
                            comment: game.currentComment,
                            detectorActive: game.detectorActive,
                            onSwiped: (approve) {
                              ref
                                  .read(gameProvider.notifier)
                                  .swipe(approve: approve);
                            },
                          ),
                        ],
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
                // Swipe hint with auto-hide
                AnimatedOpacity(
                  opacity: _swipeHintVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: _swipeHintVisible
                      ? _buildSwipeHint()
                      : const SizedBox.shrink(),
                ),
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

            // Center countdown overlay (5..1)
            if (_centerCountdownController.isAnimating &&
                timeRemaining <= 5 &&
                game.status == GameStatus.playing)
              AnimatedBuilder(
                animation: _centerCountdownController,
                builder: (context, _) {
                  return Center(
                    child: IgnorePointer(
                      child: Opacity(
                        opacity: _centerCountdownOpacity.value,
                        child: Transform.scale(
                          scale: _centerCountdownScale.value,
                          child: Text(
                            '$_centerCountdownNumber',
                            style: const TextStyle(
                              fontSize: 80,
                              fontWeight: FontWeight.w900,
                              color: Colors.red,
                              shadows: [
                                Shadow(
                                  color: Colors.black38,
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
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
    final phaseColor = _getPhaseColor(phase);
    final isCountdown = game.timeRemaining <= 10;

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
                // Timer text with countdown styling
                isCountdown
                    ? AnimatedBuilder(
                        animation: _countdownPulseController,
                        builder: (context, _) {
                          final scale = 1.0 +
                              _countdownPulseController.value * 0.08;
                          return Transform.scale(
                            scale: scale,
                            child: Text(
                              '${game.timeRemaining.toInt()}s',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: Colors.red,
                              ),
                            ),
                          );
                        },
                      )
                    : Text(
                        '${game.timeRemaining.toInt()}s',
                        style: AppTextStyles.timer,
                      ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: game.timeRemaining / 120,
                    backgroundColor: Colors.grey[300],
                    color: phaseColor,
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Phase badge removed — phase is now indicated by timer bar color
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
          // Mental bar (number removed — gauge only)
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
                // Mental number removed to reduce info overload
              ],
            ),
          ),
          // Combo removed from here — now displayed above the card
        ],
      ),
    );
  }

  Widget _buildComboCounter(GameState game) {
    if (game.combo == 0 && !game.feverActive) {
      return const SizedBox(height: 28);
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: game.feverActive
              ? Colors.orange
              : (game.combo >= 5 ? Colors.amber : Colors.grey[300]),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (game.feverActive)
              const Icon(Icons.local_fire_department,
                  size: 16, color: Colors.white),
            Text(
              game.feverActive
                  ? 'FEVER ${game.combo}x'
                  : '${game.combo}x',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color:
                    game.combo >= 5 ? Colors.white : Colors.grey[700],
              ),
            ),
          ],
        ),
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
      ('detector', Icons.visibility, '탐지기', AppColors.secondary),
      ('freeze', Icons.ac_unit, '프리즈', const Color(0xFF87CEEB)),
      ('boost', Icons.bolt, '부스트', const Color(0xFFFF8C42)),
      ('skip', Icons.skip_next, '스킵', const Color(0xFF9B59B6)),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: items.map((item) {
          final (name, icon, label, color) = item;
          final count = game.items[name] ?? 0;
          final isActive =
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
