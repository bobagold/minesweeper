import 'dart:math';

import 'package:flutter/material.dart';
import '../models/game.dart';
import '../widgets/board.dart';
import '../widgets/score.dart';

/// game screen
class MyHomePage extends StatefulWidget {
  /// constructor
  MyHomePage({Key key, this.title}) : super(key: key);

  /// title
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const minCellSize = 30;
  int _dimension = 15;
  Game board;
  double difficulty = 1 / 5;

  @override
  void initState() {
    board = _newGameBoard();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: OrientationBuilder(builder: _orientationBuilder),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _newGame,
        tooltip: 'New game',
        child: Icon(Icons.play_arrow),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget _orientationBuilder(BuildContext context, Orientation orientation) {
    var dimMin = 5;
    var dimMax = MediaQuery.of(context).size.shortestSide ~/ minCellSize;
    var children = [
      Column(children: [
        Text('board size'),
        Slider(
          min: min(dimMin, _dimension).toDouble(),
          max: max(dimMax, _dimension).toDouble(),
          divisions: dimMax - dimMin,
          label: 'board size',
          value: _dimension.toDouble(),
          onChanged: _changeDimension,
        ),
        Text('difficulty'),
        Slider(
          value: difficulty,
          min: 1 / 25,
          max: 1 / 5,
          divisions: 5,
          label: 'difficulty',
          onChanged: _changeDifficulty,
        ),
        Score(board: board),
        _status(),
      ]),
      Board(
        board: board,
        onTap: _onTap,
        onLongPress: _onLongPress,
      ),
    ];
    return orientation == Orientation.portrait
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: children,
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: children,
          );
  }

  get _onTap => board.state == GameState.lost
      ? null
      : (i, j) {
          setState(() {
            board = board.move(i, j);
          });
        };

  Widget _status() => Text(board.state == GameState.win
      ? '❤️'
      : (board.state == GameState.lost ? '💥' : '🤷🏼‍♀️'));

  void _newGame() {
    setState(() {
      board = _newGameBoard();
    });
  }

  Game _newGameBoard() {
    return Game(
        dimension: _dimension,
        bombs: Game.random(
          dimension: _dimension,
          numOfBombs: (_dimension * _dimension * difficulty).round(),
        ));
  }

  get _onLongPress => board.state == GameState.lost
      ? null
      : (i, j) {
          setState(() {
            board = board.mark(i, j);
          });
        };

  void _changeDifficulty(double value) {
    setState(() {
      difficulty = value;
      board = _newGameBoard();
    });
  }

  void _changeDimension(double value) {
    setState(() {
      _dimension = value.floor();
      board = _newGameBoard();
    });
  }
}
