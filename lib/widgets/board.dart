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

  /// onTap
  final Function(int, int) onDoubleTap;

  /// onTap
  final Function(int, int) onLongPress;

  /// constructor
  Board({
    Key key,
    @required this.board,
    @required this.onTap,
    @required this.onDoubleTap,
    @required this.onLongPress,
  })  : dimension = board.dimension,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: _buildLayout);
  }

  Widget _buildLayout(BuildContext context, BoxConstraints constraints) {
    return Table(
        key: Key('boardTable'),
        border: TableBorder.all(width: 0, color: Colors.grey[600]),
        defaultColumnWidth: FixedColumnWidth(0.95 *
            (constraints.maxHeight.isFinite
                ? constraints.maxHeight
                : constraints.maxWidth) /
            dimension),
        children: List.generate(
            dimension,
            (i) => TableRow(
                children: List.generate(dimension, (j) => _buildCell(i, j)))));
  }

  Widget _buildCell(int i, int j) {
    return AspectRatio(
      key: Key('cell${i}x$j'),
      aspectRatio: 1,
      child: _buildCellContents(
        i: i,
        j: j,
        onTap: onTap != null ? () => onTap(i, j) : null,
        onDoubleTap: onDoubleTap != null ? () => onDoubleTap(i, j) : null,
        onLongPress: onLongPress != null ? () => onLongPress(i, j) : null,
      ),
    );
  }

  Widget _buildCellContents({
    int i,
    int j,
    VoidCallback onTap,
    VoidCallback onDoubleTap,
    VoidCallback onLongPress,
  }) {
    var value = board.cells[i][j];
    var isMarked = board.isMarked(i, j);
    var isOpen = board.isOpen(i, j);
    var isVisible = board.isVisible(i, j);
    Widget text = Text(
      _text(
        value: value,
        isOpen: isOpen,
        isMarked: isMarked,
        isVisible: isVisible,
      ),
      key: Key('secret$value'),
    );
    text = Align(child: text);
    // hack for integration test to tap when everything is open
    if (board.state == GameState.win && i == 0 && j == 0) {
      text =
          Stack(children: [text, InkWell(key: Key('safeTap'), onTap: () {})]);
    }
    var tapKey = '${value < 10 ? 'safe' : 'bomb'}${isMarked ? 'Un' : ''}Tap';
    return isOpen
        ? InkWell(
            onDoubleTap: onDoubleTap,
            child: text,
          )
        : Material(
            elevation: 100 / dimension,
            color: Colors.lightBlue[200],
            child: InkWell(
              key: Key(tapKey),
              onTap: isMarked ? null : onTap,
              onLongPress: onLongPress,
              child: text,
            ),
          );
  }

  String _text({int value, bool isOpen, bool isMarked, bool isVisible}) =>
      isMarked ? '🚩' : (isVisible ? '💣' : (isOpen ? _openText(value) : ' '));

  String _openText(int v) => v == 10 ? '💥' : (v == 0 ? '' : '$v');
}
