import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import 'game_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  static const _celebTypes = [
    ('idol', '아이돌', Icons.star, AppColors.idol, 'Easy',
        'K-POP 아이돌의 댓글을 관리하세요'),
    ('actor', '배우', Icons.movie, AppColors.actor, 'Normal',
        '영화/드라마 배우의 댓글을 관리하세요'),
    ('youtuber', '유튜버', Icons.play_circle, AppColors.youtuber, 'Normal',
        '유튜버/스트리머의 댓글을 관리하세요'),
    ('sports', '스포츠', Icons.sports_soccer, AppColors.sports, 'Normal',
        '스포츠 선수의 댓글을 관리하세요'),
    ('politician', '정치인', Icons.account_balance, AppColors.politician, 'Hard',
        '정치인의 댓글을 관리하세요'),
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
        child: SingleChildScrollView(
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
              _buildHowToPlay(),
              const SizedBox(height: 28),
              const Text(
                '셀럽 타입을 선택하세요',
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: 16),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _celebTypes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final (type, label, icon, color, difficulty, description) =
                      _celebTypes[index];
                  return _CelebButton(
                    type: type,
                    label: label,
                    icon: icon,
                    color: color,
                    difficulty: difficulty,
                    difficultyColor:
                        _difficultyColors[difficulty] ?? AppColors.textHint,
                    description: description,
                    onTap: () => _startGame(context, type),
                  );
                },
              ),
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.25),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.help_outline_rounded,
                  size: 22, color: AppColors.secondary),
              const SizedBox(width: 8),
              Text(
                'How to Play',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.wrong.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.swipe_left_rounded,
                        size: 28, color: AppColors.wrong),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '좌 = 차단',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.wrong,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Container(
                width: 1,
                height: 56,
                color: AppColors.textHint.withValues(alpha: 0.25),
              ),
              Column(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.correct.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.swipe_right_rounded,
                        size: 28, color: AppColors.correct),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '우 = 승인',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.correct,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
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
  final String description;
  final VoidCallback onTap;

  const _CelebButton({
    required this.type,
    required this.label,
    required this.icon,
    required this.color,
    required this.difficulty,
    required this.difficultyColor,
    required this.description,
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
                    Row(
                      children: [
                        Text(label, style: AppTextStyles.bodyLarge),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: difficultyColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            difficulty,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: difficultyColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
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
