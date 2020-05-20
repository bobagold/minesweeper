import 'dart:collection';

import 'dart:math';

/// state of the game process
enum GameState {
  /// lost
  lost,

  /// win
  win,

  /// still playing
  playing,
}

/// game state
class Game {
  /// state
  final GameState state;

  /// dimension
  final int dimension;

  /// plain array with coordinates of bombs
  final List<int> bombs;

  /// open cells - plain array
  final List<int> openCells;

  /// marked cells - plain array
  final List<int> markedCells;

  List<List<int>> _cells;

  Game._({
    this.dimension,
    this.bombs,
    List<List<int>> cells,
    this.state,
    this.openCells,
    this.markedCells,
  }) : _cells = cells;

  /// constructor
  Game({
    this.dimension,
    this.bombs,
    this.openCells = const [],
    this.markedCells = const [],
  }) : state = GameState.playing {
    _cells = List.generate(
        dimension,
        (i) =>
            List.generate(dimension, (j) => (_b(i, j) == 1 ? 10 : _cnt(i, j))));
  }

  /// cells with numbers of bombs or 10 if it is a bomb
  List<List<int>> get cells => _cells;

  /// calculate score
  int get score =>
      state == GameState.win ? 0 : bombs.length - markedCells.length;

  int _b(int i, int j) => bombs.contains(i * dimension + j) ? 1 : 0;

  int _cnt(int i, int j) {
    var s = 0;
    for (var v = -1; v < 2; v++) {
      for (var h = -1; h < 2; h++) {
        var ni = i + v;
        var nj = j + h;
        if ((v != 0 || h != 0) &&
            ni >= 0 &&
            nj >= 0 &&
            ni < dimension &&
            nj < dimension) {
          s += _b(ni, nj);
        }
      }
    }
    return s;
  }

  /// move (open a cell)
  Game move(int i, int j) {
    var newState = state;
    var newOpen = List.of(openCells);
    if (_b(i, j) == 1) {
      newState = GameState.lost;
    }
    newOpen.add(i * dimension + j);
    if (cells[i][j] == 0) {
      _openAdjustmentCells(
          Queue.from([
            [i, j]
          ]),
          newOpen);
    }
    var setOfNewOpen = Set.of(newOpen);
    var setOfBombs = Set.of(bombs);
    if (newState == GameState.playing &&
        setOfNewOpen.intersection(setOfBombs).length == 0 &&
        setOfNewOpen.union(setOfBombs).length == dimension * dimension) {
      newState = GameState.win;
    }
    return Game._(
      dimension: dimension,
      bombs: bombs,
      cells: cells,
      state: newState,
      openCells: newOpen,
      markedCells: markedCells,
    );
  }

  void _openAdjustmentCells(
      Queue stackOfZeroAdjustmentCells, List<int> newOpen) {
    while (stackOfZeroAdjustmentCells.length > 0) {
      var currentCell = stackOfZeroAdjustmentCells.removeFirst();
      var i = currentCell[0];
      var j = currentCell[1];
      for (var v = -1; v < 2; v++) {
        for (var h = -1; h < 2; h++) {
          var ni = i + v;
          var nj = j + h;
          if ((v != 0 || h != 0) &&
              ni >= 0 &&
              nj >= 0 &&
              ni < dimension &&
              nj < dimension) {
            var adjustmentCell = cells[ni][nj];
            if (!newOpen.contains(ni * dimension + nj)) {
              if (adjustmentCell == 0) {
//                print('open=$newOpen; current=$currentCell; ni=$ni; nj=$nj');
                stackOfZeroAdjustmentCells.addLast([ni, nj]);
              }
              newOpen.add(ni * dimension + nj);
            }
          }
        }
      }
    }
  }

  /// mark the field
  Game mark(int i, int j) {
    var newMarked = Set.of(markedCells);
    if (newMarked.contains(i * dimension + j)) {
      newMarked.remove(i * dimension + j);
    } else {
      newMarked.add(i * dimension + j);
    }
    var newState = state;
    if (newState == GameState.playing) {
      var setOfBombs = Set.of(bombs);
      if (newMarked.intersection(setOfBombs).length ==
          newMarked.union(setOfBombs).length) {
        newState = GameState.win;
      }
    }
    return Game._(
      dimension: dimension,
      bombs: bombs,
      cells: cells,
      state: newState,
      openCells: openCells,
      markedCells: newMarked.toList(),
    );
  }

  /// randomise bombs
  static List<int> random({int dimension, int numOfBombs}) {
    var list = List.generate(dimension * dimension, (i) => i);
    var random = Random();
    var ret = <int>[];
    var length = list.length;
    for (var i = 0; i < numOfBombs; i++) {
      var pos = random.nextInt(length - i);
      ret.add(list[pos]);
      list[pos] = list[length - i - 1];
    }
    return ret;
  }

  /// should the cell be shown to user
  bool isOpen(int i, int j) {
    return state == GameState.win && !bombs.contains(i * dimension + j) ||
        !isMarked(i, j) && _open(i, j) ||
        state == GameState.lost && bombs.contains(i * dimension + j);
  }

  bool _open(int i, int j) => openCells.contains(i * dimension + j);

  /// should the cell be shown as flagged
  bool isMarked(int i, int j) => markedCells.contains(i * dimension + j);

  /// shows undetonated bomb on win
  bool isVisible(int i, int j) =>
      state == GameState.win && bombs.contains(i * dimension + j);
}
