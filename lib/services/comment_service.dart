import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/comment.dart';
import '../utils/balance_config.dart';

class CommentService {
  final Map<String, List<Comment>> _cache = {};
  final _random = Random();

  Future<List<Comment>> loadComments(String celebType) async {
    if (_cache.containsKey(celebType)) return _cache[celebType]!;

    try {
      final jsonStr =
          await rootBundle.loadString('data/comments/$celebType.json');
      final list = json.decode(jsonStr) as List;
      final comments = list.map((e) => Comment.fromJson(e as Map<String, dynamic>)).toList();
      _cache[celebType] = comments;
      return comments;
    } catch (_) {
      final fallback = _generateFallbackComments(celebType);
      _cache[celebType] = fallback;
      return fallback;
    }
  }

  /// Build a pre-shuffled queue for the entire round.
  /// Comments are arranged so difficulty ramps up over phases,
  /// and no comment repeats until the pool is exhausted.
  List<Comment> buildRoundQueue(List<Comment> pool, BalanceConfig balance, String celebType) {
    final modifier = balance.getCelebModifier(celebType);
    final diffOffset = (modifier['difficulty_offset'] as num).toInt();
    final queue = <Comment>[];

    // For each phase, pick comments matching that phase's difficulty/toxic ratio
    for (final phase in balance.phases) {
      final maxDiff = ((phase['max_difficulty'] as int) + diffOffset).clamp(1, 5);
      final toxicRatio = (phase['toxic_ratio'] as num).toDouble();
      final phaseDuration = (phase['end'] as num).toDouble() - (phase['start'] as num).toDouble();
      final interval = (phase['interval'] as num).toDouble() *
          (modifier['speed_multiplier'] as num).toDouble();
      final commentCount = (phaseDuration / interval).ceil();

      final eligible = pool.where((c) => c.difficulty <= maxDiff).toList()..shuffle(_random);

      // Pick without repeats within phase
      final used = <String>{};
      for (var i = 0; i < commentCount; i++) {
        // Decide toxic or positive
        final wantToxic = _random.nextDouble() < toxicRatio;

        // Find a comment that hasn't been used yet and matches toxicity
        Comment? picked;
        for (final c in eligible) {
          if (!used.contains(c.id) && c.isToxic == wantToxic) {
            picked = c;
            break;
          }
        }
        // Fallback: any unused comment
        if (picked == null) {
          for (final c in eligible) {
            if (!used.contains(c.id)) {
              picked = c;
              break;
            }
          }
        }
        // If all exhausted, reshuffle and allow repeats
        if (picked == null) {
          used.clear();
          eligible.shuffle(_random);
          picked = eligible.first;
        }

        used.add(picked.id);
        queue.add(picked);
      }
    }

    return queue;
  }

  int rollLikes(Comment comment) {
    if (comment.likesMax <= comment.likesMin) return comment.likesMin;
    return comment.likesMin +
        _random.nextInt(comment.likesMax - comment.likesMin + 1);
  }

  List<Comment> _generateFallbackComments(String celebType) {
    return [
      for (var i = 0; i < 10; i++)
        Comment(
          id: '${celebType}_fallback_$i',
          celebType: celebType,
          text: i.isEven ? '진짜 최고다 ㅋㅋㅋ' : '왜 이러는지 모르겠다;;',
          type: i.isEven ? 'positive' : 'toxic',
          difficulty: (i % 4) + 1,
          likesMin: 0,
          likesMax: 50,
          damageWeight: 1.0,
          tags: [],
          language: 'ko',
        ),
    ];
  }
}
