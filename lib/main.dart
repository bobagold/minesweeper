import 'package:flutter/material.dart';

import 'models/game_bloc.dart';
import 'repositories/local_settings.dart';
import 'screens/game_screen.dart';
import 'widgets/bloc_provider.dart';

void main() {
  runApp(MyApp());
}

/// main entry point
class MyApp extends StatelessWidget {
  /// constructor
  MyApp({super.key, this.createBloc});

  /// optional state factory for isolated app tests
  final GameBloc Function()? createBloc;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minesweeper',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: BlocProvider(
        create: createBloc ??
            () => GameBloc(
                  load: loadStateFromSettings,
                  save: saveStateToSettings,
                ),
        builder: (context) => GameScreen(
          title: 'Minesweeper',
          bloc: BlocProvider.of<GameBloc>(context),
        ),
      ),
    );
  }
}
