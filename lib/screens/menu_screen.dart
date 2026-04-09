import 'package:flutter/material.dart';
import 'game_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  static const _celebTypes = [
    ('idol', '아이돌', Icons.star, Color(0xFFFF6B9D)),
    ('actor', '배우', Icons.movie, Color(0xFF4ECDC4)),
    ('youtuber', '유튜버', Icons.play_circle, Color(0xFFFFE66D)),
    ('sports', '스포츠', Icons.sports_soccer, Color(0xFFFF8C42)),
    ('politician', '정치인', Icons.account_balance, Color(0xFF95E1D3)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 60),
              const Text(
                'Comment\nCorporation',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF2D3436),
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '댓글 주식회사',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 48),
              const Text(
                '셀럽 타입을 선택하세요',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF2D3436),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: _celebTypes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final (type, label, icon, color) = _celebTypes[index];
                    return _CelebButton(
                      type: type,
                      label: label,
                      icon: icon,
                      color: color,
                      onTap: () => _startGame(context, type),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _startGame(BuildContext context, String celebType) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameScreen(celebType: celebType),
      ),
    );
  }
}

class _CelebButton extends StatelessWidget {
  final String type;
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CelebButton({
    required this.type,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2D3436),
                      ),
                    ),
                    Text(
                      type.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
