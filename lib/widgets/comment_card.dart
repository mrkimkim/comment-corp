import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/comment.dart';

class CommentCard extends StatelessWidget {
  final Comment comment;
  final double dragOffset;
  final bool showIndicator;
  final bool detectorActive;

  const CommentCard({
    super.key,
    required this.comment,
    this.dragOffset = 0,
    this.showIndicator = false,
    this.detectorActive = false,
  });

  // 한국어 닉네임 풀 — comment id 기반으로 결정적 선택
  static const _nicknamePool = [
    '댓글러',
    '지나가던사람',
    'ㅇㅇ',
    '순수한팬',
    '사이다좋아',
    '찐팬임',
    '궁금한사람',
    '조용한독자',
    '해바라기',
    '밤하늘별',
    '댓글요정',
    '솔직한사람',
    '웃음가득',
    '눈팅족',
    '열정맨',
    '무념무상',
    '커피한잔',
    '바다소리',
    '하루하루',
    '소소한행복',
  ];

  String get _nickname {
    final hash = comment.id.hashCode.abs();
    final name = _nicknamePool[hash % _nicknamePool.length];
    final suffix = hash % 1000;
    return '$name$suffix';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final ratio = (dragOffset / (screenWidth * 0.4)).clamp(-1.0, 1.0);

    return Transform.translate(
      offset: Offset(dragOffset, 0),
      child: Transform.rotate(
        angle: ratio * 0.15,
        child: Container(
          width: screenWidth * 0.90,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _cardColor(ratio),
            borderRadius: BorderRadius.circular(16),
            border: detectorActive
                ? Border.all(
                    color: comment.isToxic ? Colors.red : AppColors.correct,
                    width: 3,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: detectorActive
                    ? (comment.isToxic
                        ? Colors.red.withValues(alpha: 0.3)
                        : AppColors.correct.withValues(alpha: 0.3))
                    : Colors.black.withValues(alpha: 0.06),
                blurRadius: detectorActive ? 15 : 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Detector reveal: 악플/선플 즉시 표시
              if (detectorActive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: comment.isToxic
                        ? Colors.red
                        : AppColors.correct,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    comment.isToxic ? '🚨 악플!' : '✅ 선플!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
              // Swipe indicator with icon (dual encoding for color-blind accessibility)
              if (showIndicator && ratio.abs() > 0.2)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: ratio < 0
                        ? AppColors.wrong.withValues(alpha: 0.8)
                        : AppColors.correct.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        ratio < 0 ? Icons.close : Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        ratio < 0 ? 'BLOCK' : 'APPROVE',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              if (showIndicator && ratio.abs() > 0.2)
                const SizedBox(height: 12),
              // Comment text -- primary content, top position, large size
              Text(
                comment.text,
                style: const TextStyle(
                  fontSize: 20,
                  height: 1.4,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              // Profile & meta row -- bottom, de-emphasized
              Row(
                children: [
                  // Avatar placeholder
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.person,
                        size: 16, color: Colors.grey[500]),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _nickname,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _cardColor(double ratio) {
    if (ratio < -0.2) {
      return Color.lerp(
          Colors.white, Colors.red[50]!, min(ratio.abs(), 1.0))!;
    }
    if (ratio > 0.2) {
      return Color.lerp(
          Colors.white, Colors.green[50]!, min(ratio, 1.0))!;
    }
    return Colors.white;
  }
}
