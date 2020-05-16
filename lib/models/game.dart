/// game state
class Game {
  /// dimension
  final int dimension;

  /// plain array with coordinates of bombs
  final List<int> bombs;

  /// constructor
  Game(this.dimension, this.bombs);

  /// cells with numbers of bombs or 10 if it is a bomb
  List<List<int>> get cells => List.generate(
      dimension,
      (i) =>
          List.generate(dimension, (j) => (_b(i, j) == 1 ? 10 : _cnt(i, j))));

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
}
