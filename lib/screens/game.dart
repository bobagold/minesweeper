import 'package:flutter/material.dart';
import '../models/game.dart';
import '../widgets/board.dart';

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
  Game board = Game(dimension: _dimension, bombs: [1, 3]);

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

  Widget _orientationBuilder(BuildContext context, Orientation orientation) =>
      orientation == Orientation.portrait
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _status(),
                Board(board: board, onTap: _onTap),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _status(),
                Board(board: board, onTap: _onTap),
              ],
            );

  get _onTap => board.state == GameState.lost
      ? null
      : (i, j) {
          setState(() {
            board = board.move(i, j);
          });
        };

  Widget _status() => Text(board.state == GameState.lost ? '💥' : '🤷🏼‍♀️');

  void _newGame() {
    setState(() {
      board = Game(dimension: _dimension, bombs: [1, 3]);
    });
  }
}
