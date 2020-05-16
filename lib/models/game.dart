class Game {
  final int dimension;
  final List<int> bombs;

  Game(this.dimension, this.bombs);

  List<List<int>> get cells => List.generate(dimension,
      (i) => List.generate(dimension, (j) => (_b(i, j) == 1 ? 10 : cnt(i, j))));

  int _b(int i, int j) => bombs.contains(i * dimension + j) ? 1 : 0;

  int cnt(int i, int j) {
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
