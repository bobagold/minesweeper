import 'package:flutter/material.dart';

/// Score
@immutable
class Score extends StatelessWidget {
  /// Game board
  final int score;

  /// constructor
  const Score({Key key, this.score}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(key: Key('score'), child: Text('$score'));
  }
}
