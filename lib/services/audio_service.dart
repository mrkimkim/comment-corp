import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// All available SFX names.
enum Sfx {
  swipeCorrect('swipe_correct'),
  swipeWrong('swipe_wrong'),
  comboTick('combo_tick'),
  feverStart('fever_start'),
  itemUse('item_use'),
  gameOver('game_over'),
  newRecord('new_record');

  const Sfx(this.fileName);

  /// File name without extension (matches `assets/audio/sfx/<name>.mp3`).
  final String fileName;

  /// Full asset filename including extension.
  String get filename => '$fileName.mp3';
}

/// Lightweight fire-and-forget SFX player backed by a round-robin pool.
///
/// A pool of [_poolSize] [AudioPlayer] instances ensures that rapid successive
/// SFX calls (e.g. 5+ fast swipes) never block each other.  Each call picks
/// the next player in the ring, stops it if still busy, and starts the new
/// sound immediately.
///
/// All public methods are **crash-safe** -- errors are silently swallowed so
/// that missing/corrupt audio files never break gameplay.
class AudioService {
  static const _poolSize = 6;

  AudioService() {
    for (var i = 0; i < _poolSize; i++) {
      _sfxPool.add(AudioPlayer());
    }
  }

  /// Round-robin SFX player pool.
  final List<AudioPlayer> _sfxPool = [];
  int _currentIndex = 0;

  /// Dedicated BGM player (created lazily).
  AudioPlayer? _bgmPlayer;

  // ---------------------------------------------------------------------------
  // SFX
  // ---------------------------------------------------------------------------

  /// Play a sound effect by [Sfx] enum.
  ///
  /// Fire-and-forget: callers don't need to await the result.
  /// On any error the call is silently ignored.
  Future<void> playSfx(Sfx sfx) async {
    try {
      final player = _sfxPool[_currentIndex % _poolSize];
      _currentIndex++;
      await player.stop(); // stop previous sound on this slot immediately
      await player.play(AssetSource('audio/sfx/${sfx.filename}'));
    } catch (_) {
      // Swallow all errors -- audio must never crash the game.
    }
  }

  /// Convenience overload that accepts a raw file-name string.
  ///
  /// Returns silently if the name doesn't match any [Sfx] value.
  Future<void> playSfxByName(String name) async {
    try {
      final sfx = Sfx.values.firstWhere((s) => s.fileName == name);
      await playSfx(sfx);
    } catch (_) {
      // Unknown name or playback error -- ignore.
    }
  }

  // ---------------------------------------------------------------------------
  // BGM
  // ---------------------------------------------------------------------------

  /// Start looping background music for the given [celebType].
  ///
  /// Stops any currently playing BGM first.  The player is created lazily on
  /// the first call and reused afterwards.
  Future<void> playBgm(String celebType) async {
    try {
      await _bgmPlayer?.stop();
      _bgmPlayer ??= AudioPlayer();
      await _bgmPlayer!.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer!.play(AssetSource('audio/bgm/bgm_$celebType.mp3'));
    } catch (_) {
      // Swallow all errors -- audio must never crash the game.
    }
  }

  /// Stop background music if playing.
  Future<void> stopBgm() async {
    try {
      await _bgmPlayer?.stop();
    } catch (_) {
      // Best-effort stop.
    }
  }

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  /// Release all underlying player resources.
  void dispose() {
    for (final player in _sfxPool) {
      try {
        player.dispose();
      } catch (_) {
        // Best-effort cleanup.
      }
    }
    try {
      _bgmPlayer?.dispose();
    } catch (_) {
      // Best-effort cleanup.
    }
  }
}

/// Riverpod provider for [AudioService].
///
/// The service is created once and disposed automatically when the provider
/// scope is torn down.
final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  ref.onDispose(service.dispose);
  return service;
});
