import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../providers/game_provider.dart';

// ---------------------------------------------------------------------------
// Riverpod provider: fetches leaderboard for a given celebType
// ---------------------------------------------------------------------------

final leaderboardProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>(
  (ref, celebType) async {
    final service = ref.read(leaderboardServiceProvider);
    return service.getLeaderboard(celebType);
  },
);

// ---------------------------------------------------------------------------
// LeaderboardScreen
// ---------------------------------------------------------------------------

class LeaderboardScreen extends ConsumerStatefulWidget {
  final String initialCelebType;

  const LeaderboardScreen({
    super.key,
    this.initialCelebType = 'idol',
  });

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  static const _celebTabs = [
    ('idol', '아이돌', Icons.star, AppColors.idol),
    ('actor', '배우', Icons.movie, AppColors.actor),
    ('youtuber', '유튜버', Icons.play_circle, AppColors.youtuber),
    ('sports', '스포츠', Icons.sports_soccer, AppColors.sports),
    ('politician', '정치인', Icons.account_balance, AppColors.politician),
  ];

  static const _goldColor = Color(0xFFFFD700);
  static const _silverColor = Color(0xFFC0C0C0);
  static const _bronzeColor = Color(0xFFCD7F32);

  static final _numberFormat = NumberFormat('#,##0');

  late String _selectedType;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialCelebType;
  }

  void _selectType(String type) {
    if (type == _selectedType) return;
    setState(() => _selectedType = type);
    // Invalidate cached data so it refetches
    ref.invalidate(leaderboardProvider(_selectedType));
  }

  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(leaderboardProvider(_selectedType));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // --- AppBar ---
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 22),
                    color: AppColors.textPrimary,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Expanded(
                    child: Text(
                      '리더보드',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.heading2,
                    ),
                  ),
                  // Spacer to balance the back button
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // --- Tab bar (horizontal scroll) ---
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _celebTabs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final (type, label, icon, color) = _celebTabs[index];
                  final isSelected = type == _selectedType;
                  return _TabChip(
                    label: label,
                    icon: icon,
                    color: color,
                    isSelected: isSelected,
                    onTap: () => _selectType(type),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // --- Content ---
            Expanded(
              child: asyncData.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (_, __) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.cloud_off_rounded,
                            size: 48, color: AppColors.textHint),
                        const SizedBox(height: 12),
                        Text(
                          '리더보드를 불러올 수 없습니다',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (entries) {
                  if (entries.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.emoji_events_outlined,
                                size: 48, color: AppColors.textHint),
                            const SizedBox(height: 12),
                            Text(
                              '아직 기록이 없습니다',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () async {
                      ref.invalidate(leaderboardProvider(_selectedType));
                      // Wait for the new data to arrive
                      await ref.read(
                        leaderboardProvider(_selectedType).future,
                      );
                    },
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      itemCount: entries.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final entry = entries[index];
                        final rank = index + 1;
                        return _LeaderboardRow(
                          rank: rank,
                          displayName:
                              (entry['display_name'] as String?) ??
                                  'Anonymous',
                          score: (entry['score'] as num?)?.toInt() ?? 0,
                          maxCombo:
                              (entry['max_combo'] as num?)?.toInt() ?? 0,
                          numberFormat: _numberFormat,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab chip widget
// ---------------------------------------------------------------------------

class _TabChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : AppColors.textHint.withValues(alpha: 0.3),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 16,
                color: isSelected ? color : AppColors.textHint),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? color : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Leaderboard row
// ---------------------------------------------------------------------------

class _LeaderboardRow extends StatelessWidget {
  final int rank;
  final String displayName;
  final int score;
  final int maxCombo;
  final NumberFormat numberFormat;

  const _LeaderboardRow({
    required this.rank,
    required this.displayName,
    required this.score,
    required this.maxCombo,
    required this.numberFormat,
  });

  Color? get _rankColor {
    switch (rank) {
      case 1:
        return _LeaderboardScreenState._goldColor;
      case 2:
        return _LeaderboardScreenState._silverColor;
      case 3:
        return _LeaderboardScreenState._bronzeColor;
      default:
        return null;
    }
  }

  IconData? get _rankIcon {
    if (rank <= 3) return Icons.emoji_events_rounded;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final medalColor = _rankColor;
    final isMedalist = medalColor != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: isMedalist
            ? Border.all(color: medalColor.withValues(alpha: 0.4), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 40,
            child: isMedalist
                ? Icon(_rankIcon, color: medalColor, size: 24)
                : Text(
                    '#$rank',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textHint,
                    ),
                  ),
          ),
          const SizedBox(width: 12),

          // Name
          Expanded(
            child: Text(
              displayName,
              style: AppTextStyles.bodySmall.copyWith(
                color: isMedalist ? medalColor : AppColors.textPrimary,
                fontWeight: isMedalist ? FontWeight.w800 : FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Score
          Text(
            '${numberFormat.format(score)}점',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isMedalist ? medalColor : AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 12),

          // Max combo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.comboAmber.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${maxCombo}x',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.comboAmber,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
