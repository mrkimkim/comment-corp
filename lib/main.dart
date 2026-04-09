import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
          seedColor: const Color(0xFFFF6B9D),
          brightness: Brightness.light,
        ),
        fontFamily: 'Pretendard',
        useMaterial3: true,
      ),
      home: const MenuScreen(),
    );
  }
}
