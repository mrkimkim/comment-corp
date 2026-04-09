import 'comment.dart';

enum GameStatus { ready, playing, paused, gameOver }

enum SwipeResult { correctBlock, correctApprove, wrongBlock, wrongApprove }

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
    );
  }
}
