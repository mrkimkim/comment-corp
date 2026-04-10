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
}

/// Lightweight fire-and-forget SFX player.
///
/// All public methods are **crash-safe** -- errors are silently swallowed so
/// that missing/corrupt audio files never break gameplay.
class AudioService {
  AudioService();

  final AudioPlayer _player = AudioPlayer();

  /// Play a sound effect by [Sfx] enum.
  ///
  /// Fire-and-forget: callers don't need to await the result.
  /// On any error the call is silently ignored.
  Future<void> playSfx(Sfx sfx) async {
    try {
      // Stop any currently playing SFX so sounds don't pile up.
      await _player.stop();
      await _player.play(AssetSource('audio/sfx/${sfx.fileName}.mp3'));
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

  /// Release the underlying player resources.
  void dispose() {
    try {
      _player.dispose();
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
