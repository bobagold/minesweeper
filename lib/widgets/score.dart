import 'package:flutter/material.dart';
import '../models/game.dart';

/// Score
@immutable
class Score extends StatelessWidget {
  /// Game board
  final Game board;

  /// constructor
  const Score({Key key, this.board}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(key: Key('score'), child: Text('${board.score}'));
  }
}
