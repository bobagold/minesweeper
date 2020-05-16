import 'dart:math';

import 'package:flutter/material.dart';
import '../models/game.dart';

/// Game board
class Board extends StatelessWidget {
  /// dimension of the board
  final int dimension = 15;

  /// game state
  final Game board;

  /// constructor
  const Board({
    Key key,
    @required this.board,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: _buildLayout);
  }

  Widget _buildLayout(BuildContext context, BoxConstraints constraints) {
    return Table(
        border: TableBorder.all(),
        defaultColumnWidth: FixedColumnWidth(min(
            60,
            0.95 *
                (constraints.maxHeight.isFinite
                    ? constraints.maxHeight
                    : constraints.maxWidth) /
                dimension)),
        children: List.generate(
            dimension,
            (i) => TableRow(
                children: List.generate(dimension, (j) => _buildCell(i, j)))));
  }

  Widget _buildCell(int i, int j) => AspectRatio(
      key: Key('cell${i}x$j'),
      aspectRatio: 1,
      child: Text('', key: Key('secret${board.cells[i][j]}')));
}
