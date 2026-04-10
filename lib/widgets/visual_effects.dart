import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

// =============================================================================
// Visual-effects-only palette (game_screen 통합 전까지 여기서만 사용)
// =============================================================================
const Color _comboAmber = Color(0xFFFFA000);
const Color _comboOrange = Color(0xFFFF8C42);
const Color _comboRed = Color(0xFFE74C3C);
const Color _feverGold = Color(0xFFFFD700);
const Color _feverOrange = Color(0xFFFF9800);
const Color _dangerRed = Color(0xFFE74C3C);
const Color _vignetteDark = Color(0xFF1A1A1A);
const Color _phaseBannerBg = Color(0xCC000000);
const Color _eventBannerBg = Color(0xFF2D3436);

// =============================================================================
// 1. FloatingScoreText
// =============================================================================

/// Displays a score label (e.g. "+150") that floats upward 60 px and fades out.
///
/// Usage: place inside a Stack at the desired position. The widget removes
/// itself visually after [duration] by becoming fully transparent.
///
/// ```dart
/// // game_screen 의 Stack 안에서 사용:
/// FloatingScoreText(
///   score: '+150',
///   color: AppColors.correct,
///   combo: currentCombo,
///   position: Offset(tapX, tapY),
///   onComplete: () => setState(() => _floatingTexts.remove(key)),
/// )
/// ```
///
/// * [score]  – the score string to display, e.g. "+150".
/// * [color]  – text color, defaults to [AppColors.correct].
/// * [combo]  – current combo; when >= 5 the font size scales up.
/// * [position] – the origin Offset (top-left) inside the parent Stack.
/// * [duration] – total animation time (default 800 ms).
/// * [onComplete] – called when the animation finishes so the parent can
///   remove the widget from the tree.
class FloatingScoreText extends StatefulWidget {
  final String score;
  final Color color;
  final int combo;
  final Offset position;
  final Duration duration;
  final VoidCallback? onComplete;

  const FloatingScoreText({
    super.key,
    required this.score,
    this.color = AppColors.correct,
    this.combo = 0,
    this.position = Offset.zero,
    this.duration = const Duration(milliseconds: 800),
    this.onComplete,
  });

  @override
  State<FloatingScoreText> createState() => _FloatingScoreTextState();
}

class _FloatingScoreTextState extends State<FloatingScoreText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _offsetY;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _offsetY = Tween<double>(begin: 0, end: -60).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _opacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Base size is 16; scale up for combo >= 5.
    final double baseFontSize = 16;
    final double fontSize;
    if (widget.combo >= 20) {
      fontSize = baseFontSize + 10;
    } else if (widget.combo >= 10) {
      fontSize = baseFontSize + 6;
    } else if (widget.combo >= 5) {
      fontSize = baseFontSize + 3;
    } else {
      fontSize = baseFontSize;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: widget.position.dx,
          top: widget.position.dy + _offsetY.value,
          child: IgnorePointer(
            child: Opacity(
              opacity: _opacity.value,
              child: Text(
                widget.score,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w900,
                  color: widget.color,
                  shadows: const [
                    Shadow(
                      color: Colors.black26,
                      offset: Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// =============================================================================
// 2. ComboIndicator
// =============================================================================

/// Shows combo count with 5-level visual escalation.
///
/// ```dart
/// // game_screen HUD 영역에 배치:
/// ComboIndicator(
///   combo: game.combo,
///   feverActive: game.isFever,
/// )
/// ```
///
/// * 0..4  — grey text, no effects.
/// * 5..9  — amber text + subtle pulse.
/// * 10..14 — orange + strong pulse + size increase.
/// * 15..19 — red + shake + pre-fever glow.
/// * 20+   — FEVER: orange background + fire icon + continuous pulse.
class ComboIndicator extends StatefulWidget {
  final int combo;
  final bool feverActive;

  const ComboIndicator({
    super.key,
    required this.combo,
    required this.feverActive,
  });

  @override
  State<ComboIndicator> createState() => _ComboIndicatorState();
}

class _ComboIndicatorState extends State<ComboIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int combo = widget.combo;
    final bool fever = widget.feverActive;

    // Determine the visual level.
    final _ComboLevel level;
    if (fever || combo >= 20) {
      level = _ComboLevel.fever;
    } else if (combo >= 15) {
      level = _ComboLevel.preFever;
    } else if (combo >= 10) {
      level = _ComboLevel.heating;
    } else if (combo >= 5) {
      level = _ComboLevel.warmup;
    } else {
      level = _ComboLevel.base;
    }

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, _) {
        final double pulse = _pulseController.value; // 0..1

        // --- Colour ---
        Color textColor;
        Color bgColor;
        switch (level) {
          case _ComboLevel.base:
            textColor = Colors.grey.shade700;
            bgColor = Colors.grey.shade300;
          case _ComboLevel.warmup:
            textColor = Colors.white;
            bgColor = Color.lerp(
                _comboAmber,
                _comboAmber.withValues(alpha: 0.8),
                pulse)!;
          case _ComboLevel.heating:
            textColor = Colors.white;
            bgColor = Color.lerp(
                _comboOrange,
                _comboOrange.withValues(alpha: 0.75),
                pulse)!;
          case _ComboLevel.preFever:
            textColor = Colors.white;
            bgColor = Color.lerp(
                _comboRed,
                _comboRed.withValues(alpha: 0.75),
                pulse)!;
          case _ComboLevel.fever:
            textColor = Colors.white;
            bgColor = Color.lerp(
                _feverOrange,
                _feverGold,
                pulse)!;
        }

        // --- Scale ---
        double scale = 1.0;
        if (level == _ComboLevel.heating) {
          scale = 1.0 + pulse * 0.08;
        } else if (level == _ComboLevel.preFever) {
          scale = 1.05 + pulse * 0.1;
        } else if (level == _ComboLevel.fever) {
          scale = 1.1 + pulse * 0.08;
        } else if (level == _ComboLevel.warmup) {
          scale = 1.0 + pulse * 0.04;
        }

        // --- Shake offset (pre-fever only) ---
        double shakeX = 0;
        if (level == _ComboLevel.preFever) {
          shakeX = math.sin(pulse * math.pi * 4) * 2;
        }

        // --- Glow ---
        List<BoxShadow>? shadows;
        if (level == _ComboLevel.preFever) {
          shadows = [
            BoxShadow(
              color: _comboRed.withValues(alpha: 0.3 + pulse * 0.3),
              blurRadius: 8 + pulse * 6,
              spreadRadius: 1,
            ),
          ];
        } else if (level == _ComboLevel.fever) {
          shadows = [
            BoxShadow(
              color: _feverGold.withValues(alpha: 0.4 + pulse * 0.3),
              blurRadius: 10 + pulse * 8,
              spreadRadius: 2,
            ),
          ];
        }

        final label = fever
            ? 'FEVER ${combo}x'
            : '${combo}x';

        return Transform.translate(
          offset: Offset(shakeX, 0),
          child: Transform.scale(
            scale: scale,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
                boxShadow: shadows,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (level == _ComboLevel.fever)
                    const Padding(
                      padding: EdgeInsets.only(right: 3),
                      child: Text('🔥', style: TextStyle(fontSize: 13)),
                    ),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

enum _ComboLevel { base, warmup, heating, preFever, fever }

// =============================================================================
// 3. FeverOverlay
// =============================================================================

/// Full-screen overlay for fever mode.
///
/// ```dart
/// // game_screen 의 Stack 최상단에 배치:
/// Positioned.fill(
///   child: FeverOverlay(feverActive: game.isFever),
/// )
/// ```
///
/// * On enter  — golden flash (300 ms).
/// * While active — pulsing golden border glow.
/// * On exit   — flash out (200 ms).
///
/// Wrapped in [IgnorePointer] so it never blocks touch.
///
/// Pass [feverActive] = true / false to trigger transitions.
class FeverOverlay extends StatefulWidget {
  final bool feverActive;

  const FeverOverlay({super.key, required this.feverActive});

  @override
  State<FeverOverlay> createState() => _FeverOverlayState();
}

class _FeverOverlayState extends State<FeverOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _flashController;
  late final Animation<double> _flashOpacity;

  late final AnimationController _glowController;

  bool _wasActive = false;

  @override
  void initState() {
    super.initState();

    // Flash: used for both enter and exit.
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _flashOpacity = Tween<double>(begin: 0.45, end: 0.0).animate(
      CurvedAnimation(parent: _flashController, curve: Curves.easeOut),
    );

    // Glow: repeating pulse during fever.
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    if (widget.feverActive) {
      _enterFever();
    }
  }

  @override
  void didUpdateWidget(covariant FeverOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.feverActive && !_wasActive) {
      _enterFever();
    } else if (!widget.feverActive && _wasActive) {
      _exitFever();
    }
  }

  void _enterFever() {
    _wasActive = true;
    _flashController.duration = const Duration(milliseconds: 300);
    _flashController.forward(from: 0);
    _glowController.repeat(reverse: true);
  }

  void _exitFever() {
    _wasActive = false;
    _glowController.stop();
    _flashController.duration = const Duration(milliseconds: 200);
    _flashController.forward(from: 0);
  }

  @override
  void dispose() {
    _flashController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If not active and controller is dismissed, render nothing.
    if (!widget.feverActive &&
        !_flashController.isAnimating &&
        !_glowController.isAnimating) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      child: Stack(
        children: [
          // --- Flash overlay ---
          AnimatedBuilder(
            animation: _flashController,
            builder: (context, _) {
              if (_flashOpacity.value <= 0.001) {
                return const SizedBox.shrink();
              }
              return Container(
                color: _feverGold
                    .withValues(alpha: _flashOpacity.value),
              );
            },
          ),

          // --- Glow border ---
          if (widget.feverActive)
            AnimatedBuilder(
              animation: _glowController,
              builder: (context, _) {
                final double t = _glowController.value;
                final double opacity = 0.15 + t * 0.2;
                final double spread = 15 + t * 10;
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _feverGold.withValues(alpha: opacity + 0.15),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _feverGold.withValues(alpha: opacity),
                        blurRadius: spread,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

// =============================================================================
// 4. MentalWarning
// =============================================================================

/// Multi-stage mental health warning overlay.
///
/// ```dart
/// // game_screen 의 Stack 최상단(FeverOverlay 위 또는 아래):
/// Positioned.fill(
///   child: MentalWarning(
///     mentalPercent: game.mentalHp / game.maxMentalHp,
///   ),
/// )
/// ```
///
/// * > 50 %   — nothing.
/// * <= 50 %  — vignette 10 %.
/// * <= 30 %  — red border blink + vignette 20 %.
/// * <= 15 %  — desaturation + stronger red pulse + vignette 30 %.
///
/// [mentalPercent] should be 0.0 .. 1.0.
class MentalWarning extends StatefulWidget {
  final double mentalPercent;

  const MentalWarning({super.key, required this.mentalPercent});

  @override
  State<MentalWarning> createState() => _MentalWarningState();
}

class _MentalWarningState extends State<MentalWarning>
    with SingleTickerProviderStateMixin {
  late final AnimationController _blinkController;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double mp = widget.mentalPercent;

    // Above 50 % — no warning.
    if (mp > 0.5) return const SizedBox.shrink();

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _blinkController,
        builder: (context, _) {
          final double t = _blinkController.value; // 0..1

          // -- Determine warning level --
          final bool danger = mp <= 0.15;
          final bool critical = mp <= 0.30;

          // -- Vignette intensity --
          double vignetteOpacity;
          if (danger) {
            vignetteOpacity = 0.30;
          } else if (critical) {
            vignetteOpacity = 0.20;
          } else {
            vignetteOpacity = 0.10;
          }

          // -- Red border --
          double borderOpacity = 0;
          double borderWidth = 0;
          if (danger) {
            borderOpacity = 0.25 + t * 0.45;
            borderWidth = 5;
          } else if (critical) {
            borderOpacity = 0.1 + t * 0.3;
            borderWidth = 4;
          }

          // -- Desaturation layer (15 % and below) --
          final double desaturation = danger ? 0.25 + t * 0.15 : 0.0;

          return Stack(
            children: [
              // Vignette
              Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.0,
                    colors: [
                      Colors.transparent,
                      _vignetteDark
                          .withValues(alpha: vignetteOpacity),
                    ],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),

              // Red border blink
              if (borderWidth > 0)
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _dangerRed
                          .withValues(alpha: borderOpacity),
                      width: borderWidth,
                    ),
                  ),
                ),

              // Desaturation overlay
              if (desaturation > 0)
                ColorFiltered(
                  colorFilter: ColorFilter.matrix(<double>[
                    // Lerp toward greyscale using luminosity weights.
                    1 - desaturation * 0.7, desaturation * 0.59, desaturation * 0.11, 0, 0,
                    desaturation * 0.3, 1 - desaturation * 0.41, desaturation * 0.11, 0, 0,
                    desaturation * 0.3, desaturation * 0.59, 1 - desaturation * 0.89, 0, 0,
                    0, 0, 0, 1, 0,
                  ]),
                  child: const SizedBox.expand(),
                ),
            ],
          );
        },
      ),
    );
  }
}

// =============================================================================
// 5. PhaseTransitionBanner
// =============================================================================

/// Shows a phase name (e.g. "PHASE 2") via scale-in, hold for 1 s, then
/// fade-out.
///
/// ```dart
/// // game_screen 에서 페이즈 전환 시 Stack 에 추가:
/// if (showPhaseBanner)
///   Positioned.fill(
///     child: PhaseTransitionBanner(
///       phase: 'PHASE 2',
///       onComplete: () => setState(() => showPhaseBanner = false),
///     ),
///   )
/// ```
///
/// Set [phase] to trigger the animation. The widget auto-hides once complete.
/// [onComplete] fires when fully done.
class PhaseTransitionBanner extends StatefulWidget {
  final String phase;
  final VoidCallback? onComplete;

  const PhaseTransitionBanner({
    super.key,
    required this.phase,
    this.onComplete,
  });

  @override
  State<PhaseTransitionBanner> createState() => _PhaseTransitionBannerState();
}

class _PhaseTransitionBannerState extends State<PhaseTransitionBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  // Total = scaleIn 300ms + hold 1000ms + fadeOut 400ms = 1700ms
  static const _totalMs = 1700;
  static const _scaleInEnd = 300.0 / _totalMs;
  static const _holdEnd = 1300.0 / _totalMs;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _totalMs),
    );

    // Scale: 0 -> 1.15 -> 1.0 during scaleIn, then stay 1.0
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.15)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: _scaleInEnd * 100,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.15, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: (_holdEnd - _scaleInEnd) * 20, // quick settle
      ),
      TweenSequenceItem(
        tween: ConstantTween(1.0),
        weight: (1.0 - _holdEnd) * 100 + (_holdEnd - _scaleInEnd) * 80,
      ),
    ]).animate(_controller);

    // Opacity: 1.0 during scaleIn+hold, fade to 0 after hold
    _opacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: ConstantTween(1.0),
        weight: _holdEnd * 100,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: (1.0 - _holdEnd) * 100,
      ),
    ]).animate(_controller);

    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          if (_opacity.value <= 0.001) return const SizedBox.shrink();
          return Container(
            color: _phaseBannerBg
                .withValues(alpha: 0.5 * _opacity.value),
            child: Center(
              child: Opacity(
                opacity: _opacity.value,
                child: Transform.scale(
                  scale: _scale.value,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    decoration: BoxDecoration(
                      color: _phaseBannerBg,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      widget.phase,
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 6,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// =============================================================================
// 6. EventNotification
// =============================================================================

/// Slides down from the top, stays for 2 s, then slides back up.
///
/// ```dart
/// // game_screen Stack 최상단에서 이벤트 발생 시:
/// if (pendingEvent != null)
///   EventNotification(
///     eventName: pendingEvent!.name,
///     eventDescription: pendingEvent!.description,
///     onDismissed: () => setState(() => pendingEvent = null),
///   )
/// ```
///
/// * [eventName]  – e.g. "실검 등장"
/// * [eventDescription] – e.g. "속도 UP!"
/// * [onDismissed] – fires when fully hidden.
class EventNotification extends StatefulWidget {
  final String eventName;
  final String eventDescription;
  final VoidCallback? onDismissed;

  const EventNotification({
    super.key,
    required this.eventName,
    required this.eventDescription,
    this.onDismissed,
  });

  @override
  State<EventNotification> createState() => _EventNotificationState();
}

class _EventNotificationState extends State<EventNotification>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _opacityAnimation;

  // slideIn 300ms + hold 2000ms + slideOut 300ms = 2600ms
  static const _totalMs = 2600;
  static const _inEnd = 300.0 / _totalMs;
  static const _holdEnd = 2300.0 / _totalMs;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _totalMs),
    );

    _slideAnimation = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween(
          begin: const Offset(0, -1.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: _inEnd * 100,
      ),
      TweenSequenceItem(
        tween: ConstantTween(Offset.zero),
        weight: (_holdEnd - _inEnd) * 100,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: Offset.zero,
          end: const Offset(0, -1.0),
        ).chain(CurveTween(curve: Curves.easeInCubic)),
        weight: (1.0 - _holdEnd) * 100,
      ),
    ]).animate(_controller);

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0),
        weight: _inEnd * 100,
      ),
      TweenSequenceItem(
        tween: ConstantTween(1.0),
        weight: (_holdEnd - _inEnd) * 100,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0),
        weight: (1.0 - _holdEnd) * 100,
      ),
    ]).animate(_controller);

    _controller.forward().then((_) {
      widget.onDismissed?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        if (_opacityAnimation.value <= 0.001) return const SizedBox.shrink();
        return Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SlideTransition(
            position: _slideAnimation,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: SafeArea(
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: _eventBannerBg,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.eventName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.eventDescription,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
