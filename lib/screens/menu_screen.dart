import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import 'game_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  static const _celebTypes = [
    ('idol', '아이돌', Icons.star, AppColors.idol, 'Easy'),
    ('actor', '배우', Icons.movie, AppColors.actor, 'Normal'),
    ('youtuber', '유튜버', Icons.play_circle, AppColors.youtuber, 'Normal'),
    ('sports', '스포츠', Icons.sports_soccer, AppColors.sports, 'Normal'),
    ('politician', '정치인', Icons.account_balance, AppColors.politician, 'Hard'),
  ];

  static const _difficultyColors = {
    'Easy': AppColors.correct,
    'Normal': Color(0xFFFF8C42),
    'Hard': AppColors.wrong,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 48),
              const Text(
                'Comment\nCorporation',
                textAlign: TextAlign.center,
                style: AppTextStyles.heading1,
              ),
              const SizedBox(height: 8),
              const Text(
                '댓글 주식회사',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 6),
              Text(
                '악성 댓글을 차단하고, 좋은 댓글을 승인하세요!',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.textHint,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              const Text(
                '셀럽 타입을 선택하세요',
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: _celebTypes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final (type, label, icon, color, difficulty) =
                        _celebTypes[index];
                    return _CelebButton(
                      type: type,
                      label: label,
                      icon: icon,
                      color: color,
                      difficulty: difficulty,
                      difficultyColor:
                          _difficultyColors[difficulty] ?? AppColors.textHint,
                      onTap: () => _startGame(context, type),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              _buildHowToPlay(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHowToPlay() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Text(
            'How to Play',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                children: [
                  Icon(Icons.arrow_back, size: 18, color: AppColors.wrong),
                  const SizedBox(width: 6),
                  Text(
                    '좌 = 차단',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.wrong,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Container(
                width: 1,
                height: 20,
                color: AppColors.textHint.withValues(alpha: 0.3),
              ),
              Row(
                children: [
                  Text(
                    '우 = 승인',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.correct,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.arrow_forward, size: 18, color: AppColors.correct),
                ],
              ),
            ],
          ),
        ],
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
  final String difficulty;
  final Color difficultyColor;
  final VoidCallback onTap;

  const _CelebButton({
    required this.type,
    required this.label,
    required this.icon,
    required this.color,
    required this.difficulty,
    required this.difficultyColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardBackground,
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
                    Text(label, style: AppTextStyles.bodyLarge),
                    Text(
                      type.toUpperCase(),
                      style: AppTextStyles.label,
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: difficultyColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  difficulty,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: difficultyColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios,
                  size: 16, color: AppColors.textHint),
            ],
          ),
        ),
      ),
    );
  }
}
