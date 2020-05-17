import 'dart:math';

import 'package:flutter/material.dart';
import '../models/game.dart';

/// Game board
class Board extends StatelessWidget {
  /// dimension of the board
  final int dimension;

  /// game state
  final Game board;

  /// onTap
  final Function(int, int) onTap;

  /// constructor
  Board({
    Key key,
    @required this.board,
    @required this.onTap,
  })  : dimension = board.dimension,
        super(key: key);

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
      child: InkWell(
          onTap: onTap != null ? () => onTap(i, j) : null,
          child: _buildCellContents(i, j)));

  Container _buildCellContents(int i, int j) {
    var value = board.cells[i][j];
    var isOpen = _open(i, j);
    return Container(
      decoration:
          BoxDecoration(color: isOpen ? Colors.white : Colors.grey[300]),
      child: Text(
        _text(value: value, isOpen: isOpen),
        key: Key('secret$value'),
      ),
    );
  }

  String _text({int value, bool isOpen}) => isOpen ? _openText(value) : ' ';

  String _openText(int v) => v == 10 ? '💥' : (v == 0 ? '' : '$v');

  bool _open(int i, int j) => board.openCells.contains(i * dimension + j);
}
