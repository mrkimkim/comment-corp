import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/game_state.dart';
import '../providers/game_provider.dart';
import '../widgets/swipe_stack.dart';
import '../widgets/visual_effects.dart';
import 'result_screen.dart';

final _scoreFormatter = NumberFormat('#,##0');

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

  /// General-purpose pulse (timer bar last-10s, mental icon blink)
  late final AnimationController _pulseController;

  /// Floating score popup (+points)
  late final AnimationController _floatingScoreController;
  late final Animation<double> _floatingScoreOpacity;
  late final Animation<Offset> _floatingScoreOffset;
  int _floatingScoreValue = 0;

  // ── Visual-effects state ─────────────────────────────────────────

  /// Pending event notification name.
  String? _pendingEventName;

  /// Pending event notification description.
  String _pendingEventDescription = '';

  @override
  void initState() {
    super.initState();

    // Kick off the game & start BGM
    Future.microtask(() {
      ref.read(gameProvider.notifier).startGame(widget.celebType);
      ref.read(audioServiceProvider).playBgm(widget.celebType);
    });

    // ── Flash (400ms fade-out) ──
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _flashOpacity = Tween<double>(begin: 0.35, end: 0.0).animate(
      CurvedAnimation(parent: _flashController, curve: Curves.easeOut),
    );

    // ── Pulse (loop, used for timer bar + mental icon) ──
    _pulseController = AnimationController(
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
    // Stop BGM when leaving the game screen (safety net)
    try {
      ref.read(audioServiceProvider).stopBgm();
    } catch (_) {
      // ref may already be invalid during dispose — ignore.
    }
    _flashController.dispose();
    _pulseController.dispose();
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

  /// Build a short description for an active event based on its effects.
  String _describeEvent(GameEvent event) {
    final parts = <String>[];
    if (event.speedMultiplier != null) {
      parts.add('속도 변화!');
    }
    if (event.toxicRatioOverride != null) {
      final pct = (event.toxicRatioOverride! * 100).toInt();
      parts.add('악플 비율 $pct%');
    }
    if (parts.isEmpty) return '${event.durationSeconds.toInt()}초간 지속';
    return parts.join(' / ');
  }

  Color _getTimerColor(double timeRemaining) {
    if (timeRemaining <= 10) return const Color(0xFFC0392B); // last 10s red
    if (timeRemaining <= 30) return const Color(0xFFFF7675); // last 30s orange-red
    return AppColors.secondary; // default mint
  }

  // ── Build ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final audio = ref.read(audioServiceProvider);

    // ── Listeners ──
    ref.listen(gameProvider, (prev, next) {
      if (!mounted) return;

      // ── SFX: Game over ──
      if (prev?.status != GameStatus.gameOver &&
          next.status == GameStatus.gameOver) {
        audio.stopBgm();
        audio.playSfx(Sfx.gameOver);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ResultScreen()),
        );
        return;
      }

      // Flash + floating score + SFX on every swipe (detect by totalProcessed change)
      if (next.totalProcessed > (prev?.totalProcessed ?? 0) &&
          next.lastResult != null) {
        final isCorrect = next.lastResult == SwipeResult.correctBlock ||
            next.lastResult == SwipeResult.correctApprove;
        _showFlash(isCorrect);

        // ── SFX: Swipe result ──
        audio.playSfx(isCorrect ? Sfx.swipeCorrect : Sfx.swipeWrong);

        // Floating score popup on correct
        if (isCorrect) {
          final gained = next.score - (prev?.score ?? 0);
          if (gained > 0) {
            _showFloatingScore(gained);
          }
        }
      }

      // ── SFX: Combo tick (combo >= 5) ──
      if (next.combo >= 5 && next.combo != (prev?.combo ?? 0)) {
        audio.playSfx(Sfx.comboTick);
      }

      // (fever removed — combo only)

      // ── Event notification ──
      if (next.lastEvent != null && next.lastEvent != prev?.lastEvent) {
        final desc = next.activeEvent != null
            ? _describeEvent(next.activeEvent!)
            : '이벤트 발생!';
        setState(() {
          _pendingEventName = next.lastEvent;
          _pendingEventDescription = desc;
        });
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

            // ── Mental warning (3-stage: 50%/30%/15%) ──
            if (game.status == GameStatus.playing)
              Positioned.fill(
                child: MentalWarning(
                  mentalPercent: game.mentalPercent,
                ),
              ),

            // ── Event notification ──
            if (_pendingEventName != null)
              EventNotification(
                eventName: _pendingEventName!,
                eventDescription: _pendingEventDescription,
                onDismissed: () =>
                    setState(() => _pendingEventName = null),
              ),
          ],
        ),
      ),
    );
  }

  // ── Timer bar (full-width, 6px, phase color, pulse on last 10s) ──

  Widget _buildTimerBar(GameState game) {
    final timerColor = _getTimerColor(game.timeRemaining);
    final progress = (game.timeRemaining / game.totalSeconds).clamp(0.0, 1.0);
    final isLastTen = game.timeRemaining <= 10;

    Widget bar = ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: LinearProgressIndicator(
        value: progress,
        backgroundColor: Colors.grey[300],
        color: timerColor,
        minHeight: 6,
      ),
    );

    // Pulse animation in the last 10 seconds.
    if (isLastTen && game.status == GameStatus.playing) {
      bar = AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final opacity = 0.6 + _pulseController.value * 0.4;
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
    final mentalMax = game.mentalMax.toInt();

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
                        animation: _pulseController,
                        builder: (context, _) {
                          return Icon(
                            Icons.favorite,
                            size: 18,
                            color: Colors.red.withValues(
                              alpha:
                                  0.4 + _pulseController.value * 0.6,
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

          // ── Right: Combo (5-level escalation) ──
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (game.combo > 0)
                  ComboIndicator(
                    combo: game.combo,
                    feverActive: false,
                  ),
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
          final isActive = (name == 'detector' && game.detectorActive) ||
              (name == 'freeze' && game.freezeActive) ||
              (name == 'boost' && game.boostActive);
          final isDepleted = count <= 0 && !isActive;

          return GestureDetector(
            onTap: count > 0 && !isActive
                ? () {
                    ref.read(audioServiceProvider).playSfx(Sfx.itemUse);
                    ref.read(gameProvider.notifier).useItem(name);
                  }
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
