import 'comment.dart';

enum GameStatus { ready, playing, gameOver }

enum SwipeResult { correctBlock, correctApprove, wrongBlock, wrongApprove }

/// Represents a game event that can occur during gameplay.
class GameEvent {
  final String id;
  final String name;
  final double durationSeconds;
  final double? speedMultiplier;
  final double? toxicRatioOverride;

  const GameEvent({
    required this.id,
    required this.name,
    required this.durationSeconds,
    this.speedMultiplier,
    this.toxicRatioOverride,
  });
}

class GameState {
  final GameStatus status;
  final String celebType;
  final double mental;
  final int score;
  final int combo;
  final int maxCombo;
  final double elapsed;
  final int totalProcessed;
  final int correctCount;
  final int wrongCount;
  final bool feverActive;
  final double feverTimer;
  final Map<String, int> items;
  final Comment? currentComment;
  final SwipeResult? lastResult;

  // Item active states and timers
  final bool detectorActive;
  final double detectorTimer;
  final bool freezeActive;
  final double freezeTimer;
  final bool boostActive;
  final double boostTimer;

  // Event system
  final GameEvent? activeEvent;
  final double eventTimer;

  /// Name of the most recently triggered event (for UI notification).
  final String? lastEvent;

  const GameState({
    this.status = GameStatus.ready,
    this.celebType = 'idol',
    this.mental = 100,
    this.score = 0,
    this.combo = 0,
    this.maxCombo = 0,
    this.elapsed = 0,
    this.totalProcessed = 0,
    this.correctCount = 0,
    this.wrongCount = 0,
    this.feverActive = false,
    this.feverTimer = 0,
    this.items = const {},
    this.currentComment,
    this.lastResult,
    this.detectorActive = false,
    this.detectorTimer = 0,
    this.freezeActive = false,
    this.freezeTimer = 0,
    this.boostActive = false,
    this.boostTimer = 0,
    this.activeEvent,
    this.eventTimer = 0,
    this.lastEvent,
  });

  bool get isDead => mental <= 0;
  bool get isTimeUp => elapsed >= 120;
  double get mentalPercent => (mental / 100).clamp(0, 1);
  double get timeRemaining => (120 - elapsed).clamp(0, 120);

  GameState copyWith({
    GameStatus? status,
    String? celebType,
    double? mental,
    int? score,
    int? combo,
    int? maxCombo,
    double? elapsed,
    int? totalProcessed,
    int? correctCount,
    int? wrongCount,
    bool? feverActive,
    double? feverTimer,
    Map<String, int>? items,
    Comment? currentComment,
    SwipeResult? lastResult,
    bool? detectorActive,
    double? detectorTimer,
    bool? freezeActive,
    double? freezeTimer,
    bool? boostActive,
    double? boostTimer,
    GameEvent? activeEvent,
    double? eventTimer,
    bool clearActiveEvent = false,
    String? lastEvent,
    bool clearLastEvent = false,
  }) {
    return GameState(
      status: status ?? this.status,
      celebType: celebType ?? this.celebType,
      mental: mental ?? this.mental,
      score: score ?? this.score,
      combo: combo ?? this.combo,
      maxCombo: maxCombo ?? this.maxCombo,
      elapsed: elapsed ?? this.elapsed,
      totalProcessed: totalProcessed ?? this.totalProcessed,
      correctCount: correctCount ?? this.correctCount,
      wrongCount: wrongCount ?? this.wrongCount,
      feverActive: feverActive ?? this.feverActive,
      feverTimer: feverTimer ?? this.feverTimer,
      items: items ?? this.items,
      currentComment: currentComment ?? this.currentComment,
      lastResult: lastResult ?? this.lastResult,
      detectorActive: detectorActive ?? this.detectorActive,
      detectorTimer: detectorTimer ?? this.detectorTimer,
      freezeActive: freezeActive ?? this.freezeActive,
      freezeTimer: freezeTimer ?? this.freezeTimer,
      boostActive: boostActive ?? this.boostActive,
      boostTimer: boostTimer ?? this.boostTimer,
      activeEvent: clearActiveEvent ? null : (activeEvent ?? this.activeEvent),
      eventTimer: eventTimer ?? this.eventTimer,
      lastEvent: clearLastEvent ? null : (lastEvent ?? this.lastEvent),
    );
  }
}
