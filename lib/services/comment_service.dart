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

  /// Tracks recently used comment IDs to avoid immediate repeats.
  final Set<String> _recentIds = {};

  /// Pick the next comment based on the current combo-driven phase.
  ///
  /// [combo] determines which phase (and thus max_difficulty / toxic_ratio)
  /// is active. [celebType] applies celeb-specific difficulty offsets.
  /// [pool] is the full list of comments loaded for this celeb type.
  Comment pickNextComment(
    List<Comment> pool,
    int combo,
    String celebType,
    BalanceConfig balance,
  ) {
    final phase = balance.getPhaseByCombo(combo);
    final modifier = balance.getCelebModifier(celebType);
    final diffOffset = (modifier['difficulty_offset'] as num).toInt();
    final maxDiff = ((phase['max_difficulty'] as int) + diffOffset).clamp(1, 5);
    final toxicRatio = (phase['toxic_ratio'] as num).toDouble();

    final eligible = pool
        .where((c) => c.difficulty <= maxDiff && !c.eventOnly)
        .toList();

    if (eligible.isEmpty) {
      // Absolute fallback — should never happen with well-formed data
      return pool[_random.nextInt(pool.length)];
    }

    // Decide toxic or positive
    final wantToxic = _random.nextDouble() < toxicRatio;

    // Try to find a matching comment that hasn't been used recently
    eligible.shuffle(_random);
    Comment? picked;
    for (final c in eligible) {
      if (!_recentIds.contains(c.id) && c.isToxic == wantToxic) {
        picked = c;
        break;
      }
    }
    // Fallback: any unused comment regardless of toxicity
    if (picked == null) {
      for (final c in eligible) {
        if (!_recentIds.contains(c.id)) {
          picked = c;
          break;
        }
      }
    }
    // If all exhausted, clear history and pick fresh
    if (picked == null) {
      _recentIds.clear();
      eligible.shuffle(_random);
      picked = eligible.first;
    }

    _recentIds.add(picked.id);
    // Keep recent window reasonable (half the pool size)
    if (_recentIds.length > pool.length ~/ 2) {
      _recentIds.remove(_recentIds.first);
    }

    return picked;
  }

  /// Reset tracking state between rounds.
  void resetTracking() {
    _recentIds.clear();
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
