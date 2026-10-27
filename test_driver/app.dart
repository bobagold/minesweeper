import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:minesweeper/main.dart' as app;
import 'package:minesweeper/models/game.dart';
import 'package:minesweeper/models/game_bloc.dart';

void main() {
  late GameBloc bloc;
  enableFlutterDriverExtension(handler: (command) async {
    if (command == 'reset') {
      var updated = bloc.board.stream.first;
      bloc.board.add(_testGame());
      await updated;
      await WidgetsBinding.instance.endOfFrame;
    } else if (command != 'state') {
      throw ArgumentError.value(command, 'command');
    }
    var game = bloc.initialData;
    return jsonEncode({
      'state': game.state.name,
      'dimension': game.dimension,
      'bombs': game.bombs.toList(),
      'openCells': game.openCells.toList(),
      'markedCells': game.markedCells.toList(),
    });
  });
  runApp(app.MyApp(createBloc: () {
    bloc = GameBloc(load: () async => _testGame(), save: (_) {});
    return bloc;
  }));
}

Game _testGame() => Game(
      dimension: 15,
      bombs: {
        for (var row = 0; row < 15; row++)
          for (var column in [1, 6, 11]) row * 15 + column,
      },
    );
