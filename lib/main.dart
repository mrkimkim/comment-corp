import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'constants/app_colors.dart';
import 'screens/menu_screen.dart';

void main() {
  runApp(const ProviderScope(child: CommentCorpApp()));
}

class CommentCorpApp extends StatelessWidget {
  const CommentCorpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Comment Corporation',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Pretendard',
        useMaterial3: true,
      ),
      home: const MenuScreen(),
    );
  }
}
