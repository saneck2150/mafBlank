import 'package:flutter/material.dart';
import 'pages/main_menu_page.dart';
import 'pages/game_page.dart';

void main() => runApp(const MafiaJudgeApp());

class MafiaJudgeApp extends StatelessWidget {
  const MafiaJudgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mafia Judge',
      theme: ThemeData(useMaterial3: true),
      routes: {
        '/':     (_) => const MainMenuPage(),
        '/game': (_) => const GamePage(),
      },
      initialRoute: '/',
    );
  }
}