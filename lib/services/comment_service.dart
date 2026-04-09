import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/comment.dart';

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

  Comment pickComment({
    required List<Comment> pool,
    required double toxicRatio,
    required int maxDifficulty,
    required int difficultyOffset,
  }) {
    final isToxic = _random.nextDouble() < toxicRatio;
    final effectiveMaxDiff = (maxDifficulty + difficultyOffset).clamp(1, 4);

    var filtered = pool
        .where((c) => c.isToxic == isToxic && c.difficulty <= effectiveMaxDiff)
        .toList();

    if (filtered.isEmpty) {
      filtered = pool.where((c) => c.difficulty <= effectiveMaxDiff).toList();
    }
    if (filtered.isEmpty) filtered = pool;

    return filtered[_random.nextInt(filtered.length)];
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
