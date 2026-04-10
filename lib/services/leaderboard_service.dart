import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardService {
  final _firestore = FirebaseFirestore.instance;

  /// 점수 제출 (직접 Firestore에 쓰기 — 나중에 Cloud Functions로 전환 가능)
  Future<void> submitScore({
    required String celebType,
    required int score,
    required int maxCombo,
    required double survivalSeconds,
    String? displayName,
  }) async {
    try {
      await _firestore
          .collection('leaderboards')
          .doc(celebType)
          .collection('scores')
          .add({
        'score': score,
        'max_combo': maxCombo,
        'survival_seconds': survivalSeconds,
        'display_name': displayName ?? 'Anonymous',
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // 네트워크 실패 시 무시 — 게임 경험 방해 금지
    }
  }

  /// 리더보드 조회
  Future<List<Map<String, dynamic>>> getLeaderboard(
    String celebType, {
    int limit = 100,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('leaderboards')
          .doc(celebType)
          .collection('scores')
          .orderBy('score', descending: true)
          .limit(limit)
          .get();
      return snapshot.docs.map((d) => d.data()).toList();
    } catch (_) {
      return [];
    }
  }
}
