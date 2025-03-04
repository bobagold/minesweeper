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

  /// new
  created,
}

/// game state
class Game {
  /// state
  final GameState state;

  /// dimension
  final int dimension;

  /// plain array with coordinates of bombs
  final Set<int> bombs;

  /// open cells - plain array
  final Set<int> openCells;

  /// marked cells - plain array
  final Set<int> markedCells;

  late List<List<int>> _cells;

  Game._({
    required this.dimension,
    required this.bombs,
    required List<List<int>> cells,
    required this.state,
    required this.openCells,
    required this.markedCells,
  }) : _cells = cells;

  /// constructor
  Game({
    required this.dimension,
    required this.bombs,
    this.openCells = const {},
    this.markedCells = const {},
  }) : state = GameState.created {
    _cells = List.generate(
        dimension,
        (i) => List.generate(
            dimension, (j) => (_isBomb(i, j) ? 10 : _cntBombs(i, j))));
  }

  /// cells with numbers of bombs or 10 if it is a bomb
  List<List<int>> get cells => _cells;

  /// calculate score
  int get score =>
      state == GameState.win ? 0 : bombs.length - markedCells.length;

  bool _isBomb(int i, int j) => bombs.contains(i * dimension + j);

  int _cntBombs(int i, int j) => _cnt(i, j, (i, j) => _isBomb(i, j) ? 1 : 0);

  int _cntMarked(int i, int j) => _cnt(i, j, (i, j) => isMarked(i, j) ? 1 : 0);

  int _cnt(int i, int j, int Function(int, int) f) {
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
          s += f(ni, nj);
        }
      }
    }
    return s;
  }

  /// move (open a cell)
  Game move(int i, int j) {
    var newState = state;
    var newOpen = Set.of(openCells);
    if (_isBomb(i, j) && state == GameState.created) {
      return _moveBomb(i, j);
    }
    if (state == GameState.created) {
      newState = GameState.playing;
    }
    if (_isBomb(i, j)) {
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
    var setOfBombs = Set.of(bombs);
    if (newState == GameState.playing &&
        newOpen.length + setOfBombs.length == dimension * dimension) {
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

  Game _moveBomb(int i, int j) {
    final random = Random();
    var newBomb = random.nextInt(dimension * dimension);
    var newBombs = Set.of(bombs);
    while (newBombs.contains(newBomb)) {
      newBomb = random.nextInt(dimension * dimension);
    }
    newBombs.remove(i * dimension + j);
    newBombs.add(newBomb);
    final newGame = Game(
      dimension: dimension,
      bombs: newBombs,
      openCells: openCells,
      markedCells: markedCells,
    );
    return newGame.move(i, j);
  }

  void _openAdjustmentCells(
      Queue stackOfZeroAdjustmentCells, Set<int> newOpen) {
    while (stackOfZeroAdjustmentCells.isNotEmpty) {
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
    if (newState == GameState.created) {
      newState = GameState.playing;
    }
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
      markedCells: newMarked,
    );
  }

  /// randomise bombs
  static Set<int> random({required int dimension, required int numOfBombs}) {
    var list = List.generate(dimension * dimension, (i) => i);
    var random = Random();
    var ret = <int>{};
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

  /// reveal neighbours of an open cell
  Game reveal(int i, int j) {
    if (!_open(i, j)) {
      return this;
    }
    if (_cntMarked(i, j) != _cntBombs(i, j)) {
      return this;
    }
    var game = this;
    _cnt(i, j, (i, j) {
      if (!_open(i, j) && !isMarked(i, j)) {
        game = game.move(i, j);
      }
      return 1;
    });
    return game;
  }

  /// difficulty
  double get difficulty => bombs.length / (dimension * dimension);

  /// load from string
  static Game loadFromString(String board) {
    var parsed = board
        .split('|')
        .map((part) =>
            part.split(',').where((s) => s.isNotEmpty).map(int.parse).toSet())
        .toList();
    var marked = parsed.removeLast();
    var open = parsed.removeLast();
    var bombs = parsed.removeLast();
    var dimension = parsed.removeLast().first;
    var game = Game(
      dimension: dimension,
      bombs: bombs,
    );
    for (var move in open) {
      game = game.move(move ~/ dimension, move % dimension);
    }
    for (var mark in marked) {
      game = game.mark(mark ~/ dimension, mark % dimension);
    }
    return game;
  }

  /// save to string
  String saveToString() => [
        [dimension, dimension],
        bombs,
        openCells,
        markedCells
      ].map((l) => l.join(',')).join('|');
}
