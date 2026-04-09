import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_state.dart';
import '../providers/game_provider.dart';
import '../widgets/swipe_stack.dart';
import 'result_screen.dart';

class GameScreen extends ConsumerStatefulWidget {
  final String celebType;
  const GameScreen({super.key, required this.celebType});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(gameProvider.notifier).startGame(widget.celebType);
    });
  }

  @override
  void dispose() {
    // Don't reset here — result screen still needs state
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);

    ref.listen(gameProvider, (prev, next) {
      if (prev?.status != GameStatus.gameOver &&
          next.status == GameStatus.gameOver) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ResultScreen()),
        );
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(game),
            _buildStatsRow(game),
            const SizedBox(height: 8),
            Expanded(
              child: Center(
                child: SwipeStack(
                  comment: game.currentComment,
                  onSwiped: (approve) {
                    ref.read(gameProvider.notifier).swipe(approve: approve);
                  },
                ),
              ),
            ),
            _buildSwipeHint(),
            _buildItemBar(game),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(GameState game) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              game.status == GameStatus.paused
                  ? Icons.play_arrow
                  : Icons.pause,
            ),
            onPressed: () => ref.read(gameProvider.notifier).togglePause(),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  '${game.timeRemaining.toInt()}s',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2D3436),
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: game.timeRemaining / 120,
                    backgroundColor: Colors.grey[300],
                    color: const Color(0xFF4ECDC4),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${game.score}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFFFF6B9D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(GameState game) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Mental bar
          Expanded(
            child: Row(
              children: [
                Icon(
                  Icons.favorite,
                  size: 16,
                  color: game.mentalPercent < 0.3 ? Colors.red : Colors.pink[300],
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: game.mentalPercent,
                      backgroundColor: Colors.grey[300],
                      color: game.mentalPercent < 0.3
                          ? Colors.red
                          : Colors.pink[300],
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${game.mental.toInt()}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Combo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: game.feverActive
                  ? Colors.orange
                  : (game.combo >= 5 ? Colors.amber : Colors.grey[300]),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (game.feverActive)
                  const Icon(Icons.local_fire_department,
                      size: 14, color: Colors.white),
                Text(
                  game.feverActive
                      ? 'FEVER ${game.combo}x'
                      : '${game.combo}x',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: game.combo >= 5 ? Colors.white : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeHint() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            children: [
              Icon(Icons.arrow_back, size: 16, color: Colors.red[300]),
              const SizedBox(width: 4),
              Text('차단', style: TextStyle(color: Colors.red[300], fontSize: 12)),
            ],
          ),
          Row(
            children: [
              Text('승인', style: TextStyle(color: Colors.green[400], fontSize: 12)),
              const SizedBox(width: 4),
              Icon(Icons.arrow_forward, size: 16, color: Colors.green[400]),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemBar(GameState game) {
    final items = [
      ('detector', Icons.search, '탐지기', const Color(0xFF4ECDC4)),
      ('freeze', Icons.ac_unit, '프리즈', const Color(0xFF87CEEB)),
      ('boost', Icons.bolt, '부스트', const Color(0xFFFFE66D)),
      ('shield', Icons.shield, '쉴드', const Color(0xFF95E1D3)),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: items.map((item) {
          final (name, icon, label, color) = item;
          final count = game.items[name] ?? 0;
          return GestureDetector(
            onTap: count > 0
                ? () => ref.read(gameProvider.notifier).useItem(name)
                : null,
            child: Opacity(
              opacity: count > 0 ? 1.0 : 0.3,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 22),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$label($count)',
                    style: const TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
