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

  // Stable random nickname based on comment id
  String get _nickname {
    final hash = comment.id.hashCode.abs();
    final number = hash % 9000 + 1000;
    return '익명_$number';
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
          width: screenWidth * 0.85,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _cardColor(ratio),
            borderRadius: BorderRadius.circular(16),
            border: detectorActive && comment.isToxic
                ? Border.all(color: Colors.red, width: 3)
                : null,
            boxShadow: [
              BoxShadow(
                color: detectorActive && comment.isToxic
                    ? Colors.red.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.1),
                blurRadius: detectorActive && comment.isToxic ? 15 : 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                  child: Text(
                    ratio < 0 ? 'BLOCK' : 'APPROVE',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              if (showIndicator && ratio.abs() > 0.2)
                const SizedBox(height: 12),
              // Profile row
              Row(
                children: [
                  // Avatar placeholder
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.person,
                        size: 20, color: Colors.grey[500]),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _nickname,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            _difficultyBadge(),
                            const SizedBox(width: 8),
                            _likesWidget(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                comment.text,
                style: const TextStyle(
                  fontSize: 18,
                  height: 1.4,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
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

  Widget _difficultyBadge() {
    final colors = [
      AppColors.correct,
      Colors.yellow[700]!,
      Colors.orange,
      AppColors.wrong,
      const Color(0xFF8B0000),
    ];
    final color = colors[(comment.difficulty - 1).clamp(0, 4)];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'Lv.${comment.difficulty}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _likesWidget() {
    final avg = ((comment.likesMin + comment.likesMax) / 2).toInt();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.favorite, size: 12, color: AppColors.primary),
        const SizedBox(width: 3),
        Text(
          '$avg',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
