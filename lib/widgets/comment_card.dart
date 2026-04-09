import 'package:flutter/material.dart';
import '../models/comment.dart';

class CommentCard extends StatelessWidget {
  final Comment comment;
  final double dragOffset;
  final bool showIndicator;

  const CommentCard({
    super.key,
    required this.comment,
    this.dragOffset = 0,
    this.showIndicator = false,
  });

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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showIndicator && ratio.abs() > 0.2)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: ratio < 0
                        ? Colors.red.withValues(alpha: 0.8)
                        : Colors.green.withValues(alpha: 0.8),
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
              Row(
                children: [
                  _difficultyBadge(),
                  const SizedBox(width: 8),
                  Text(
                    _likesText(),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                comment.text,
                style: const TextStyle(fontSize: 18, height: 1.4),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 4,
                children: comment.tags.map((tag) {
                  return Chip(
                    label: Text(tag, style: const TextStyle(fontSize: 10)),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _cardColor(double ratio) {
    if (ratio < -0.2) return Color.lerp(Colors.white, Colors.red[50]!, ratio.abs())!;
    if (ratio > 0.2) return Color.lerp(Colors.white, Colors.green[50]!, ratio)!;
    return Colors.white;
  }

  Widget _difficultyBadge() {
    final colors = [Colors.green, Colors.yellow[700]!, Colors.orange, Colors.red];
    final color = colors[(comment.difficulty - 1).clamp(0, 3)];
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

  String _likesText() {
    final avg = ((comment.likesMin + comment.likesMax) / 2).toInt();
    return '♥ $avg';
  }
}
