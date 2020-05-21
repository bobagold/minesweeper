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
  static const minDifficulty = 1 / 25;
  static const maxDifficulty = 1 / 5;
  static const difficultyNames = [
    'intern',
    'juniour',
    'middle',
    'seniour',
    'lead',
  ];
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
    var actions = [
      _buildRestartButton(context),
      Center(child: Score(board: board)),
      Center(child: _status()),
      PopupMenuButton(
        itemBuilder: (context) {
          return [
            PopupMenuItem(child: Text('board size'), enabled: false),
            PopupMenuItem(
              child: _animatedInput(
                builder: _buildSliderDimension,
                animation: ValueNotifier(_dimension.toDouble()),
                onChange: _changeDimension,
              ),
            ),
            PopupMenuItem(child: Text('difficulty'), enabled: false),
            PopupMenuItem(
              child: _animatedInput(
                builder: _buildSliderDifficulty,
                animation: ValueNotifier(difficulty),
                onChange: _changeDifficulty,
              ),
            ),
          ];
        },
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: _isSquare(context) ? actions : null,
      ),
      body: Center(
        child: OrientationBuilder(builder: _orientationBuilder),
      ),
    );
  }

  bool _isSquare(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var isSquare = size.longestSide / size.shortestSide < 4 / 3;
    return isSquare;
  }

  Widget _buildRestartButton(BuildContext context) {
    return IconButton(
      key: Key('restart'),
      onPressed: _newGame,
      tooltip: 'New game',
      icon: Icon(Icons.refresh),
    );
  }

  Widget _orientationBuilder(BuildContext context, Orientation orientation) {
    var children = [
      if (!_isSquare(context))
        Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('board size'),
          _buildSliderDimension(
              context, _dimension.toDouble(), _changeDimension),
          Text('difficulty'),
          _buildSliderDifficulty(context, difficulty, _changeDifficulty),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildRestartButton(context),
              Score(board: board),
              _status(),
            ],
          ),
        ]),
      Board(
        key: Key('board'),
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

  Slider _buildSliderDifficulty(
      BuildContext context, double difficulty, ValueChanged<double> onChange) {
    var difficultyLevels = difficultyNames.length - 1;
    var difficultyLevel = (difficultyLevels *
            (difficulty - minDifficulty) /
            (maxDifficulty - minDifficulty))
        .round();
    return Slider(
      value: difficulty,
      min: minDifficulty,
      max: maxDifficulty,
      divisions: difficultyLevels,
      label: difficultyNames[difficultyLevel],
      onChanged: onChange,
    );
  }

  Slider _buildSliderDimension(
      BuildContext context, double dimension, ValueChanged<double> onChange) {
    var dimMin = min(5, dimension);
    var dimMax =
        max(MediaQuery.of(context).size.shortestSide ~/ minCellSize, dimension);
    return Slider(
      min: dimMin.toDouble(),
      max: dimMax.toDouble(),
      divisions: (dimMax - dimMin).toInt(),
      label: 'size: ${dimension.toInt()}',
      value: dimension.toDouble(),
      onChanged: onChange,
    );
  }

  Widget _animatedInput({
    Widget Function(
            BuildContext context, double value, ValueChanged<double> onChange)
        builder,
    ValueNotifier<double> animation,
    ValueChanged<double> onChange,
  }) =>
      AnimatedBuilder(
        animation: animation,
        builder: (context, _) => builder(context, animation.value, (v) {
          animation.value = v;
          onChange(v);
        }),
      );
}
