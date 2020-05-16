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
  final Game board = Game(15, []);

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
        onPressed: null,
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
                Board(board: board),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Board(board: board),
              ],
            );
}
