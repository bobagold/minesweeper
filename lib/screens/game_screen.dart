import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import '../models/game.dart';
import '../models/game_bloc.dart';
import '../utils/utils.dart';
import '../widgets/board.dart';
import '../widgets/board_animations.dart';
import '../widgets/score.dart';

/// game screen
class GameScreen extends StatelessWidget {
  /// constructor
  GameScreen({super.key, required this.title, required this.bloc});

  /// bloc
  final GameBloc bloc;

  /// title
  final String title;

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

  @override
  Widget build(BuildContext context) {
    var actions = [
      _buildRestartButton(context),
      Center(child: _score()),
      Center(child: _status()),
      _streamBuilder2(
        initialData1: bloc.initialData.dimension,
        initialData2: bloc.initialData.difficulty,
        stream1: bloc.dimension.stream,
        stream2: bloc.difficulty.stream,
        builder: (context, dimension, difficulty) => PopupMenuButton(
          itemBuilder: (context) {
            return [
              PopupMenuItem(child: Text('board size'), enabled: false),
              PopupMenuItem(
                child: _animatedInput(
                  builder: _buildSliderDimension,
                  animation: ValueNotifier(dimension.toDouble()),
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
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: _isSquare(context) ? actions : null,
      ),
      body: Center(
        child: Builder(
            builder: (context) => _orientationBuilder(
                context, MediaQuery.of(context).orientation)),
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

  Widget _streamBuilder<T>({
    required T initialData,
    required Stream<T> stream,
    required Widget Function(BuildContext, T) builder,
  }) {
    return StreamBuilder<T>(
        key: keyForObject(stream),
        stream: stream,
        initialData: initialData,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? builder(context, snapshot.data!)
              : Placeholder(fallbackWidth: 50, fallbackHeight: 50);
        });
  }

  Widget _streamBuilder2<A, B>({
    required A initialData1,
    required B initialData2,
    required Stream<A> stream1,
    required Stream<B> stream2,
    required Widget Function(BuildContext, A, B) builder,
  }) {
    return _streamBuilder(
      initialData: initialData1,
      stream: stream1,
      builder: (context, snapshot1) => _streamBuilder(
        initialData: initialData2,
        stream: stream2,
        builder: (context, snapshot2) => builder(context, snapshot1, snapshot2),
      ),
    );
  }

  Widget _orientationBuilder(BuildContext context, Orientation orientation) {
    var side = MediaQuery.of(context).size.shortestSide * 0.95;
    var children = [
      if (!_isSquare(context))
        Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('board size'),
          _streamBuilder<int>(
              initialData: bloc.initialData.dimension,
              stream: bloc.dimension.stream,
              builder: (context, dimension) {
                return _buildSliderDimension(
                    context, dimension.toDouble(), _changeDimension);
              }),
          Text('difficulty'),
          _streamBuilder<double>(
              initialData: bloc.initialData.difficulty,
              stream: bloc.difficulty.stream,
              builder: (context, difficulty) {
                return _buildSliderDifficulty(
                    context, difficulty, _changeDifficulty);
              }),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildRestartButton(context),
              _score(),
              _status(),
            ],
          ),
        ]),
      Container(
        height: side,
        width: side,
        child: _streamBuilder<Game>(
            initialData: bloc.initialData,
            stream: bloc.board.stream,
            builder: (context, board) {
              return BoardAnimations(
                state: board.state,
                onDismiss: _newGame,
                child: Board(
                  key: Key('board'),
                  board: board,
                  onTap: _onTap(board),
                  onDoubleTap: _onDoubleTap(board),
                  onLongPress: _onLongPress(board),
                ),
              );
            }),
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

  _onTap(Game board) => board.state == GameState.lost
      ? null
      : (i, j) {
          bloc.board.sink.add(board.move(i, j));
        };

  _onDoubleTap(Game board) => board.state == GameState.lost
      ? null
      : (i, j) {
          bloc.board.sink.add(board.reveal(i, j));
        };

  Widget _status() => _streamBuilder<GameState>(
      initialData: bloc.initialData.state,
      stream: bloc.stateStream,
      builder: (context, state) {
        return Text(state == GameState.win
            ? '❤️'
            : (state == GameState.lost ? '💥' : '🤷🏼‍♀️'));
      });

  Widget _score() => _streamBuilder<int>(
      initialData: bloc.initialData.score,
      stream: bloc.scoreStream,
      builder: (context, score) {
        return Score(score: score);
      });

  void _newGame() {
    bloc.newGameStream.sink.add(null);
  }

  _onLongPress(Game board) => board.state == GameState.lost
      ? null
      : (i, j) {
          bloc.board.sink.add(board.mark(i, j));
        };

  void _changeDifficulty(double value) {
    bloc.difficulty.sink.add(value);
  }

  void _changeDimension(double value) {
    bloc.dimension.sink.add(value.floor());
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
      min: min(difficulty, minDifficulty),
      max: max(difficulty, maxDifficulty),
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
    required Widget Function(
            BuildContext context, double value, ValueChanged<double> onChange)
        builder,
    required ValueNotifier<double> animation,
    required ValueChanged<double> onChange,
  }) =>
      AnimatedBuilder(
        animation: animation,
        builder: (context, _) => builder(context, animation.value, (v) {
          animation.value = v;
          onChange(v);
        }),
      );
}
