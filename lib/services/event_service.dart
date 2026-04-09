import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/game_state.dart';

/// Loads and manages game events from events.json.
class EventService {
  List<Map<String, dynamic>> _events = [];
  final _random = Random();

  /// Event trigger times: around 30s, 60s, 90s (with +/- 5s jitter).
  List<double> _triggerTimes = [];
  int _nextTriggerIndex = 0;

  Future<void> load() async {
    try {
      final jsonStr = await rootBundle.loadString('data/events/events.json');
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      _events = List<Map<String, dynamic>>.from(data['events'] as List);
    } catch (_) {
      _events = [];
    }
    _generateTriggerTimes();
  }

  void _generateTriggerTimes() {
    const baseTimes = [30.0, 60.0, 90.0];
    _triggerTimes = baseTimes.map((t) {
      final jitter = (_random.nextDouble() * 10) - 5; // -5 to +5 seconds
      return (t + jitter).clamp(10.0, 115.0);
    }).toList()
      ..sort();
    _nextTriggerIndex = 0;
  }

  /// Reset trigger state for a new game.
  void reset() {
    _generateTriggerTimes();
  }

  /// Check if an event should trigger at the given elapsed time for the
  /// given celeb type. Returns a [GameEvent] if triggered, null otherwise.
  GameEvent? checkTrigger(double elapsed, String celebType) {
    if (_nextTriggerIndex >= _triggerTimes.length) return null;
    if (elapsed < _triggerTimes[_nextTriggerIndex]) return null;

    _nextTriggerIndex++;

    // Filter events that apply to this celeb type or "all"
    final applicable = _events.where((e) {
      final appliesTo = List<String>.from(e['applies_to'] as List);
      return appliesTo.contains('all') || appliesTo.contains(celebType);
    }).toList();

    if (applicable.isEmpty) return null;

    final chosen = applicable[_random.nextInt(applicable.length)];
    return GameEvent(
      id: chosen['id'] as String,
      name: chosen['name'] as String,
      durationSeconds: (chosen['duration_seconds'] as num).toDouble(),
      speedMultiplier: chosen['speed_multiplier'] != null
          ? (chosen['speed_multiplier'] as num).toDouble()
          : null,
      toxicRatioOverride: chosen['toxic_ratio_override'] != null
          ? (chosen['toxic_ratio_override'] as num).toDouble()
          : null,
    );
  }
}
