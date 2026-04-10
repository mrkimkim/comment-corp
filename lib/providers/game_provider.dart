import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/comment.dart';
import '../models/game_state.dart';
import '../services/comment_service.dart';
import '../services/event_service.dart';
import '../services/leaderboard_service.dart';
import '../utils/balance_config.dart';

// Re-export so consumers of game_provider can access audio without an extra import.
export '../services/audio_service.dart' show audioServiceProvider, AudioService, Sfx;

final commentServiceProvider = Provider((_) => CommentService());
final eventServiceProvider = Provider((_) => EventService());
final leaderboardServiceProvider = Provider((_) => LeaderboardService());
final balanceConfigProvider = FutureProvider((_) => BalanceConfig.load());

final gameProvider = NotifierProvider<GameNotifier, GameState>(GameNotifier.new);

class GameNotifier extends Notifier<GameState> {
  Timer? _gameTimer;
  List<Comment> _commentPool = [];
  late BalanceConfig _balance;
  late EventService _eventService;

  @override
  GameState build() => const GameState();

  Future<void> startGame(String celebType) async {
    _balance = await BalanceConfig.load();
    final commentService = ref.read(commentServiceProvider);
    _commentPool = await commentService.loadComments(celebType);
    commentService.resetTracking();

    _eventService = ref.read(eventServiceProvider);
    await _eventService.load();
    _eventService.reset();

    // Pick the first comment for combo 0
    final firstComment = commentService.pickNextComment(
      _commentPool, 0, celebType, _balance,
    );

    state = GameState(
      status: GameStatus.playing,
      celebType: celebType,
      mental: _balance.mentalInitial,
      mentalMax: _balance.mentalInitial,
      totalSeconds: _balance.totalSeconds,
      currentPhase: 1,
      items: {
        'detector': _balance.detectorPerGame,
        'freeze': _balance.freezePerGame,
        'boost': _balance.boostPerGame,
        'skip': _balance.shieldPerGame,
      },
      currentComment: firstComment,
    );

    _startTimers();
  }

  void _startTimers() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (state.status != GameStatus.playing) return;

      var mental = state.mental;
      var feverTimer = state.feverTimer;
      var feverActive = state.feverActive;

      // --- Freeze: if active, do NOT advance elapsed ---
      var freezeActive = state.freezeActive;
      var freezeTimer = state.freezeTimer;
      double elapsed;
      if (freezeActive) {
        elapsed = state.elapsed; // timer frozen
        freezeTimer -= 0.1;
        if (freezeTimer <= 0) {
          freezeActive = false;
          freezeTimer = 0;
        }
      } else {
        elapsed = state.elapsed + 0.1;
      }

      // --- Boost timer tick ---
      var boostActive = state.boostActive;
      var boostTimer = state.boostTimer;
      if (boostActive) {
        boostTimer -= 0.1;
        if (boostTimer <= 0) {
          boostActive = false;
          boostTimer = 0;
        }
      }

      // --- Event timer tick ---
      var activeEvent = state.activeEvent;
      var eventTimer = state.eventTimer;
      var clearActiveEvent = false;
      if (activeEvent != null) {
        eventTimer -= 0.1;
        if (eventTimer <= 0) {
          clearActiveEvent = true;
          activeEvent = null;
          eventTimer = 0;
        }
      }

      // --- Check for new event trigger (only if no event active) ---
      String? lastEvent;
      if (activeEvent == null && !clearActiveEvent) {
        final newEvent = _eventService.checkTrigger(elapsed, state.celebType);
        if (newEvent != null) {
          activeEvent = newEvent;
          eventTimer = newEvent.durationSeconds;
          lastEvent = newEvent.name;
        }
      }

      // --- Fever timer tick (no heal) ---
      if (feverActive) {
        feverTimer -= 0.1;
        if (feverTimer <= 0) {
          feverActive = false;
          feverTimer = 0;
        }
      }

      // --- Game over check ---
      if (mental <= 0 || elapsed >= _balance.totalSeconds) {
        _stopTimers();
        state = state.copyWith(
          status: GameStatus.gameOver,
          elapsed: elapsed,
          mental: mental.clamp(0, _balance.mentalInitial),
          feverActive: feverActive,
          feverTimer: feverTimer,
          detectorActive: false,
          freezeActive: false,
          freezeTimer: 0,
          boostActive: false,
          boostTimer: 0,
          clearActiveEvent: true,
          eventTimer: 0,
        );
        return;
      }

      // --- Update current phase based on combo ---
      final newPhase = _balance.getPhaseIndex(state.combo);

      state = state.copyWith(
        elapsed: elapsed,
        mental: mental,
        feverActive: feverActive,
        feverTimer: feverTimer,
        freezeActive: freezeActive,
        freezeTimer: freezeTimer,
        boostActive: boostActive,
        boostTimer: boostTimer,
        activeEvent: activeEvent,
        clearActiveEvent: clearActiveEvent,
        eventTimer: eventTimer,
        lastEvent: lastEvent,
        clearLastEvent: lastEvent == null,
        currentPhase: newPhase,
      );
    });
  }

  /// Pick the next comment based on current combo (dynamic difficulty).
  /// Returns null only if the comment pool is completely empty.
  Comment? _nextComment() {
    if (_commentPool.isEmpty) return null;
    final commentService = ref.read(commentServiceProvider);
    return commentService.pickNextComment(
      _commentPool, state.combo, state.celebType, _balance,
    );
  }

  void swipe({required bool approve}) {
    final comment = state.currentComment;
    if (comment == null || state.status != GameStatus.playing) return;

    final commentService = ref.read(commentServiceProvider);
    final likes = commentService.rollLikes(comment);

    final isCorrect =
        (comment.isToxic && !approve) || (!comment.isToxic && approve);

    final nextComment = _nextComment();

    if (isCorrect) {
      _applyCorrect(comment, likes, nextComment);
    } else {
      _applyWrong(comment, likes, approve, nextComment);
    }
  }

  void _applyCorrect(Comment comment, int likes, Comment? nextComment) {
    final newCombo = state.combo + 1;
    final maxCombo =
        newCombo > state.maxCombo ? newCombo : state.maxCombo;

    final base = comment.isToxic
        ? _balance.toxicCorrectBase
        : _balance.positiveCorrectBase;
    final likesBonus = likes * _balance.likesBonusMultiplier;
    final multiplier = _balance.getComboMultiplier(newCombo);
    final boostMult =
        _isBoostActive() ? _balance.boostMultiplier : 1;
    final points = ((base + likesBonus) * multiplier * boostMult).toInt();

    final mental = state.mental; // 멘탈 회복 없음 — 피버에서만 회복

    var feverActive = state.feverActive;
    var feverTimer = state.feverTimer;
    if (newCombo >= _balance.feverThreshold && !feverActive) {
      feverActive = true;
      feverTimer = _balance.feverDuration;
    }

    // Update phase based on new combo
    final newPhase = _balance.getPhaseIndex(newCombo);

    // Single state update — no flicker
    state = state.copyWith(
      score: state.score + points,
      combo: newCombo,
      maxCombo: maxCombo,
      correctCount: state.correctCount + 1,
      totalProcessed: state.totalProcessed + 1,
      mental: mental,
      feverActive: feverActive,
      feverTimer: feverTimer,
      detectorActive: false,
      currentComment: nextComment,
      clearCurrentComment: nextComment == null,
      currentPhase: newPhase,
      lastResult: comment.isToxic
          ? SwipeResult.correctBlock
          : SwipeResult.correctApprove,
    );
  }

  void _applyWrong(Comment comment, int likes, bool approved, Comment? nextComment) {
    var mental = state.mental;

    if (comment.isToxic && approved) {
      var damage = likes * _balance.toxicDamageCoefficient * comment.damageWeight;
      if (damage < 1) damage = 1;
      mental -= damage;
    }

    final clampedMental = mental.clamp(0.0, _balance.mentalInitial);

    // If mental hit zero, trigger game over immediately
    if (clampedMental <= 0) {
      _stopTimers();
      state = state.copyWith(
        status: GameStatus.gameOver,
        combo: 0,
        currentPhase: 1,
        wrongCount: state.wrongCount + 1,
        totalProcessed: state.totalProcessed + 1,
        mental: 0,
        detectorActive: false,
        currentComment: nextComment,
        clearCurrentComment: nextComment == null,
        lastResult: approved
            ? SwipeResult.wrongApprove
            : SwipeResult.wrongBlock,
      );
      return;
    }

    // Combo reset → Phase 1 (dynamic difficulty drop)
    state = state.copyWith(
      combo: 0,
      currentPhase: 1,
      wrongCount: state.wrongCount + 1,
      totalProcessed: state.totalProcessed + 1,
      mental: clampedMental,
      detectorActive: false,
      currentComment: nextComment,
      clearCurrentComment: nextComment == null,
      lastResult: approved
          ? SwipeResult.wrongApprove
          : SwipeResult.wrongBlock,
    );
  }

  bool _isBoostActive() => state.boostActive;

  void useItem(String itemName) {
    final items = Map<String, int>.from(state.items);
    if ((items[itemName] ?? 0) <= 0) return;
    if (state.status != GameStatus.playing) return;
    items[itemName] = items[itemName]! - 1;

    switch (itemName) {
      case 'detector':
        // 1회성: 현재 카드가 악플/선플인지 즉시 표시
        state = state.copyWith(
          items: items,
          detectorActive: true,
        );
      case 'freeze':
        state = state.copyWith(
          items: items,
          freezeActive: true,
          freezeTimer: _balance.freezeDuration,
        );
      case 'boost':
        state = state.copyWith(
          items: items,
          boostActive: true,
          boostTimer: _balance.boostDuration,
        );
      case 'skip':
        // 스킵: 현재 댓글을 패스하고 다음으로 (패널티 없음)
        final nextComment = _nextComment();
        state = state.copyWith(
          items: items,
          currentComment: nextComment,
          clearCurrentComment: nextComment == null,
        );
      default:
        state = state.copyWith(items: items);
    }
  }

  void _stopTimers() {
    _gameTimer?.cancel();
  }

  void reset() {
    _stopTimers();
    _commentPool = [];
    state = const GameState();
  }
}
