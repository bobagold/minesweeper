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
  static final int _dimension = 15;
  Game board;

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
    var children = [
      Score(board: board),
      _status(),
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
          numOfBombs: (_dimension * _dimension / 5).round(),
        ));
  }

  get _onLongPress => board.state == GameState.lost
      ? null
      : (i, j) {
          setState(() {
            board = board.mark(i, j);
          });
        };
}
