import 'package:flutter/material.dart';

import 'flavors.dart';
import 'screens/game_screen.dart';

void main() {
  runApp(MyApp(flavor: Flavor.prod));
}

/// main entry point
class MyApp extends StatelessWidget {
  /// flavor
  final Flavor flavor;

  /// constructor
  const MyApp({Key key, @required this.flavor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var title = 'Minesweeper${flavor == Flavor.dev ? ' (dev)' : ''}';
    return MaterialApp(
      title: title,
      debugShowCheckedModeBanner: flavor == Flavor.dev,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: GameScreen(title: title),
    );
  }
}
