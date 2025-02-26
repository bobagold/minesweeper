import 'package:flutter/material.dart';

/// Score
@immutable
class Score extends StatelessWidget {
  /// Game board
  final int score;

  /// constructor
  const Score({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(key: Key('score'), child: Text('$score'));
  }
}
