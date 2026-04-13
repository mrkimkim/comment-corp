import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import 'game_screen.dart';
import 'leaderboard_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  static const _celebTypes = [
    ('idol', '아이돌', Icons.star, AppColors.idol, 1,
        '악플 적음, 데미지 낮음'),
    ('youtuber', '유튜버', Icons.play_circle, AppColors.youtuber, 2,
        '악플 보통, 데미지 보통'),
    ('sports', '스포츠', Icons.sports_soccer, AppColors.sports, 3,
        '기본 난이도, 균형 잡힌 플레이'),
    ('actor', '배우', Icons.movie, AppColors.actor, 4,
        '악플 많음, 데미지 높음'),
    ('politician', '정치인', Icons.account_balance, AppColors.politician, 5,
        '악플 폭주, 데미지 치명적'),
  ];

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
              const SizedBox(height: 16),
              _buildLeaderboardButton(context),
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
                  final (type, label, icon, color, difficultyLevel, description) =
                      _celebTypes[index];
                  return _CelebButton(
                    type: type,
                    label: label,
                    icon: icon,
                    color: color,
                    difficultyLevel: difficultyLevel,
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

  Widget _buildLeaderboardButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const LeaderboardScreen(),
            ),
          );
        },
        icon: const Text('\u{1F3C6}', style: TextStyle(fontSize: 18)),
        label: Text(
          '리더보드',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.secondary,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.secondary,
          side: BorderSide(
            color: AppColors.secondary.withValues(alpha: 0.4),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
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
  /// 1~5 scale; 1 = easiest, 5 = hardest
  final int difficultyLevel;
  final String description;
  final VoidCallback onTap;

  const _CelebButton({
    required this.type,
    required this.label,
    required this.icon,
    required this.color,
    required this.difficultyLevel,
    required this.description,
    required this.onTap,
  });

  Color get _difficultyColor {
    if (difficultyLevel <= 1) return AppColors.correct;
    if (difficultyLevel <= 2) return const Color(0xFF4ECDC4);
    if (difficultyLevel <= 3) return const Color(0xFFFF8C42);
    if (difficultyLevel <= 4) return AppColors.wrong;
    return const Color(0xFFD63031);
  }

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
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(5, (i) => Icon(
                            i < difficultyLevel
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            size: 16,
                            color: i < difficultyLevel
                                ? _difficultyColor
                                : AppColors.textHint.withValues(alpha: 0.4),
                          )),
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
