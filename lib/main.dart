import 'package:flutter/material.dart';

import 'screens/game_screen.dart';

void main() {
  runApp(MyApp());
}

/// main entry point
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minesweeper',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: GameScreen(title: 'Minesweeper'),
    );
  }
}
