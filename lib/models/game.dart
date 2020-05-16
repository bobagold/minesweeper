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

  List<List<int>> _cells;

  Game._({
    this.dimension,
    this.bombs,
    List<List<int>> cells,
    this.state,
    this.openCells,
  }) : _cells = cells;

  /// constructor
  Game({this.dimension, this.bombs, this.openCells = const []})
      : state = GameState.playing {
    _cells = List.generate(
        dimension,
        (i) =>
            List.generate(dimension, (j) => (_b(i, j) == 1 ? 10 : _cnt(i, j))));
  }

  /// cells with numbers of bombs or 10 if it is a bomb
  List<List<int>> get cells => _cells;

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
    return Game._(
      dimension: dimension,
      bombs: bombs,
      cells: cells,
      state: newState,
      openCells: newOpen,
    );
  }
}
