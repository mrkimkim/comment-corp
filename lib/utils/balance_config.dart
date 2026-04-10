import 'dart:convert';
import 'package:flutter/services.dart';

class BalanceConfig {
  final Map<String, dynamic> _data;

  BalanceConfig(this._data);

  static BalanceConfig? _instance;
  static final BalanceConfig fallback = BalanceConfig(_defaultBalance);

  static Future<BalanceConfig> load({bool forceReload = false}) async {
    if (_instance != null && !forceReload) return _instance!;
    try {
      final jsonStr = await rootBundle.loadString('data/balance/balance.json');
      _instance = BalanceConfig(json.decode(jsonStr) as Map<String, dynamic>);
    } catch (_) {
      _instance = fallback;
    }
    return _instance!;
  }

  /// Clears the cached instance so the next [load] re-reads balance.json.
  /// Useful after hot-reload or when the JSON changes at runtime.
  static void invalidateCache() {
    _instance = null;
  }

  // Mental
  double get mentalInitial => (_data['mental']['initial'] as num).toDouble();
  double get toxicDamageCoefficient =>
      (_data['mental']['toxic_approve_damage_coefficient'] as num).toDouble();

  // Combo
  int get feverThreshold => _data['combo']['fever_threshold'] as int;
  double get feverDuration =>
      (_data['combo']['fever_duration_seconds'] as num).toDouble();
  List<Map<String, dynamic>> get comboTiers =>
      List<Map<String, dynamic>>.from(_data['combo']['multiplier_tiers'] as List);

  // Score
  int get toxicCorrectBase => _data['score']['toxic_correct_base'] as int;
  int get positiveCorrectBase => _data['score']['positive_correct_base'] as int;
  int get likesBonusMultiplier =>
      _data['score']['likes_bonus_multiplier'] as int;

  // Timer
  int get totalSeconds => _data['timer']['total_seconds'] as int;

  // Phases (combo-based)
  List<Map<String, dynamic>> get phases =>
      List<Map<String, dynamic>>.from(_data['phases'] as List);

  // Celeb modifiers
  Map<String, dynamic> getCelebModifier(String type) =>
      _data['celeb_type_modifiers'][type] as Map<String, dynamic>;

  // Items
  int get detectorPerGame => _data['items']['detector_per_game'] as int;
  int get freezePerGame => _data['items']['freeze_per_game'] as int;
  double get freezeDuration =>
      (_data['items']['freeze_duration_seconds'] as num).toDouble();
  int get boostPerGame => _data['items']['boost_per_game'] as int;
  double get boostDuration =>
      (_data['items']['boost_duration_seconds'] as num).toDouble();
  int get boostMultiplier => _data['items']['boost_multiplier'] as int;
  int get shieldPerGame => _data['items']['shield_per_game'] as int;

  double getComboMultiplier(int combo) {
    double multiplier = 1.0;
    for (final tier in comboTiers) {
      if (combo >= (tier['min_combo'] as int)) {
        multiplier = (tier['multiplier'] as num).toDouble();
      }
    }
    return multiplier;
  }

  /// Returns the phase matching the given combo count.
  /// Phases are sorted by min_combo ascending; the last phase whose
  /// min_combo <= combo wins.
  Map<String, dynamic> getPhaseByCombo(int combo) {
    Map<String, dynamic> matched = phases.first;
    for (final phase in phases) {
      if (combo >= (phase['min_combo'] as int)) {
        matched = phase;
      }
    }
    return matched;
  }

  /// Returns the 1-based phase index for a given combo value.
  int getPhaseIndex(int combo) {
    int index = 1;
    for (var i = 0; i < phases.length; i++) {
      if (combo >= (phases[i]['min_combo'] as int)) {
        index = i + 1;
      }
    }
    return index;
  }

  static const Map<String, dynamic> _defaultBalance = {
    'mental': {
      'initial': 100,
      'toxic_approve_damage_coefficient': 0.3,
    },
    'combo': {
      'fever_threshold': 15,
      'fever_duration_seconds': 8,
      'multiplier_tiers': [
        {'min_combo': 0, 'multiplier': 1.0},
        {'min_combo': 5, 'multiplier': 1.5},
        {'min_combo': 10, 'multiplier': 2.0},
        {'min_combo': 20, 'multiplier': 3.0},
      ],
    },
    'score': {
      'toxic_correct_base': 100,
      'positive_correct_base': 50,
      'likes_bonus_multiplier': 2,
    },
    'timer': {
      'total_seconds': 120,
    },
    'phases': [
      {'min_combo': 0, 'toxic_ratio': 0.30, 'max_difficulty': 1, 'interval': 1.5},
      {'min_combo': 5, 'toxic_ratio': 0.35, 'max_difficulty': 2, 'interval': 1.3},
      {'min_combo': 10, 'toxic_ratio': 0.40, 'max_difficulty': 3, 'interval': 1.0},
      {'min_combo': 20, 'toxic_ratio': 0.50, 'max_difficulty': 4, 'interval': 0.7},
      {'min_combo': 30, 'toxic_ratio': 0.60, 'max_difficulty': 5, 'interval': 0.5},
    ],
    'celeb_type_modifiers': {
      'idol': {'speed_multiplier': 0.8, 'difficulty_offset': -1},
      'actor': {'speed_multiplier': 1.0, 'difficulty_offset': 1},
      'youtuber': {'speed_multiplier': 0.85, 'difficulty_offset': 0},
      'sports': {'speed_multiplier': 1.0, 'difficulty_offset': 0},
      'politician': {'speed_multiplier': 1.3, 'difficulty_offset': 2},
    },
    'items': {
      'detector_per_game': 3,
      'freeze_per_game': 1,
      'freeze_duration_seconds': 5,
      'boost_per_game': 2,
      'boost_duration_seconds': 8,
      'boost_multiplier': 3,
      'shield_per_game': 1,
    },
  };
}
