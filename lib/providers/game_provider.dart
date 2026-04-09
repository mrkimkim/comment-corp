import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/comment.dart';
import '../models/game_state.dart';
import '../services/comment_service.dart';
import '../services/event_service.dart';
import '../utils/balance_config.dart';

final commentServiceProvider = Provider((_) => CommentService());
final eventServiceProvider = Provider((_) => EventService());
final balanceConfigProvider = FutureProvider((_) => BalanceConfig.load());

final gameProvider = NotifierProvider<GameNotifier, GameState>(GameNotifier.new);

class GameNotifier extends Notifier<GameState> {
  Timer? _gameTimer;
  Timer? _commentTimer;
  List<Comment> _comments = [];
  late BalanceConfig _balance;
  late EventService _eventService;

  @override
  GameState build() => const GameState();

  Future<void> startGame(String celebType) async {
    _balance = await BalanceConfig.load();
    final commentService = ref.read(commentServiceProvider);
    _comments = await commentService.loadComments(celebType);

    _eventService = ref.read(eventServiceProvider);
    await _eventService.load();
    _eventService.reset();

    state = GameState(
      status: GameStatus.playing,
      celebType: celebType,
      mental: _balance.mentalInitial,
      items: {
        'detector': _balance.detectorPerGame,
        'freeze': _balance.freezePerGame,
        'boost': _balance.boostPerGame,
        'shield': _balance.shieldPerGame,
      },
    );

    _startTimers();
    _spawnComment();
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

      // --- Detector timer tick ---
      var detectorActive = state.detectorActive;
      var detectorTimer = state.detectorTimer;
      if (detectorActive) {
        detectorTimer -= 0.1;
        if (detectorTimer <= 0) {
          detectorActive = false;
          detectorTimer = 0;
        }
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
      if (activeEvent == null && !clearActiveEvent) {
        final newEvent = _eventService.checkTrigger(elapsed, state.celebType);
        if (newEvent != null) {
          activeEvent = newEvent;
          eventTimer = newEvent.durationSeconds;
          // Respawn comment to apply new speed/toxic settings immediately
          _spawnComment();
        }
      }

      // --- Fever heal ---
      if (feverActive) {
        mental = (mental + _balance.feverHealPerSecond * 0.1).clamp(0, 100);
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
          mental: mental.clamp(0, 100),
          feverActive: feverActive,
          feverTimer: feverTimer,
          detectorActive: false,
          detectorTimer: 0,
          freezeActive: false,
          freezeTimer: 0,
          boostActive: false,
          boostTimer: 0,
          clearActiveEvent: true,
          eventTimer: 0,
        );
        return;
      }

      state = state.copyWith(
        elapsed: elapsed,
        mental: mental,
        feverActive: feverActive,
        feverTimer: feverTimer,
        detectorActive: detectorActive,
        detectorTimer: detectorTimer,
        freezeActive: freezeActive,
        freezeTimer: freezeTimer,
        boostActive: boostActive,
        boostTimer: boostTimer,
        activeEvent: activeEvent,
        clearActiveEvent: clearActiveEvent,
        eventTimer: eventTimer,
      );
    });
  }

  void _spawnComment() {
    _commentTimer?.cancel();

    final phase = _balance.getPhase(state.elapsed);
    if (phase == null || state.status != GameStatus.playing) return;

    final modifier = _balance.getCelebModifier(state.celebType);

    // Apply event speed multiplier override if active
    final eventSpeedMult = state.activeEvent?.speedMultiplier;
    final baseInterval =
        (phase['interval'] as num).toDouble() *
        (modifier['speed_multiplier'] as num).toDouble();
    final interval = eventSpeedMult != null
        ? baseInterval * eventSpeedMult
        : baseInterval;

    _commentTimer = Timer(Duration(milliseconds: (interval * 1000).toInt()), () {
      if (state.status != GameStatus.playing) return;

      final commentService = ref.read(commentServiceProvider);
      final phase = _balance.getPhase(state.elapsed);
      if (phase == null) return;

      final modifier = _balance.getCelebModifier(state.celebType);

      // Apply event toxic ratio override if active
      final toxicRatio = state.activeEvent?.toxicRatioOverride ??
          (phase['toxic_ratio'] as num).toDouble();

      final comment = commentService.pickComment(
        pool: _comments,
        toxicRatio: toxicRatio,
        maxDifficulty: phase['max_difficulty'] as int,
        difficultyOffset: (modifier['difficulty_offset'] as num).toInt(),
      );

      state = state.copyWith(currentComment: comment);
      _spawnComment();
    });
  }

  void swipe({required bool approve}) {
    final comment = state.currentComment;
    if (comment == null || state.status != GameStatus.playing) return;

    final commentService = ref.read(commentServiceProvider);
    final likes = commentService.rollLikes(comment);

    final isCorrect =
        (comment.isToxic && !approve) || (!comment.isToxic && approve);

    if (isCorrect) {
      _handleCorrect(comment, likes);
    } else {
      _handleWrong(comment, likes, approve);
    }

    state = state.copyWith(
      totalProcessed: state.totalProcessed + 1,
      currentComment: null,
    );
  }

  void _handleCorrect(Comment comment, int likes) {
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

    var mental = state.mental;
    if (!comment.isToxic) {
      mental = (mental + _balance.positiveHeal).clamp(0, 100);
    }

    var feverActive = state.feverActive;
    var feverTimer = state.feverTimer;
    if (newCombo >= _balance.feverThreshold && !feverActive) {
      feverActive = true;
      feverTimer = _balance.feverDuration;
    }

    state = state.copyWith(
      score: state.score + points,
      combo: newCombo,
      maxCombo: maxCombo,
      correctCount: state.correctCount + 1,
      mental: mental,
      feverActive: feverActive,
      feverTimer: feverTimer,
      lastResult: comment.isToxic
          ? SwipeResult.correctBlock
          : SwipeResult.correctApprove,
    );
  }

  void _handleWrong(Comment comment, int likes, bool approved) {
    var mental = state.mental;

    if (comment.isToxic && approved) {
      var damage = likes * _balance.toxicDamageCoefficient;
      if (damage < 1) damage = 1;

      final items = Map<String, int>.from(state.items);
      if ((items['shield'] ?? 0) > 0) {
        items['shield'] = items['shield']! - 1;
        damage = 0;
        state = state.copyWith(items: items);
      }
      mental -= damage;
    }

    state = state.copyWith(
      combo: 0,
      wrongCount: state.wrongCount + 1,
      mental: mental.clamp(0, 100),
      lastResult: approved
          ? SwipeResult.wrongApprove
          : SwipeResult.wrongBlock,
    );
  }

  bool _isBoostActive() => state.boostActive;

  void useItem(String itemName) {
    final items = Map<String, int>.from(state.items);
    if ((items[itemName] ?? 0) <= 0) return;
    items[itemName] = items[itemName]! - 1;

    switch (itemName) {
      case 'detector':
        state = state.copyWith(
          items: items,
          detectorActive: true,
          detectorTimer: _balance.detectorDuration,
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
      case 'shield':
        // Shield is consumed passively in _handleWrong; just decrement count.
        state = state.copyWith(items: items);
      default:
        state = state.copyWith(items: items);
    }
  }

  void togglePause() {
    if (state.status == GameStatus.playing) {
      _gameTimer?.cancel();
      _commentTimer?.cancel();
      state = state.copyWith(status: GameStatus.paused);
    } else if (state.status == GameStatus.paused) {
      _startTimers();
      _spawnComment();
      state = state.copyWith(status: GameStatus.playing);
    }
  }

  void _stopTimers() {
    _gameTimer?.cancel();
    _commentTimer?.cancel();
  }

  void reset() {
    _stopTimers();
    state = const GameState();
  }
}
