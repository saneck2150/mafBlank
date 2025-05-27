import 'package:flutter/material.dart';

class MainMenuPage extends StatelessWidget {
  const MainMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Классическая мафия')),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Создать новую игру'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle: const TextStyle(fontSize: 18),
          ),
          onPressed: () => Navigator.pushReplacementNamed(context, '/game'),
        ),
      ),
    );
  }
}