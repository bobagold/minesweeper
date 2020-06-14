import 'dart:async';

import 'bloc.dart';
import 'game.dart';
import 'tuple.dart';

/// game bloc logic
class GameBloc extends Bloc {
  /// dimension
  final StreamController<int> dimension = StreamController.broadcast();

  /// board
  final StreamController<Game> board = StreamController<Game>.broadcast();

  /// difficulty
  final StreamController<double> difficulty = StreamController.broadcast();

  /// score
  Stream<int> get scoreStream => board.stream.map((game) => game.score);

  /// game state
  Stream<GameState> get stateStream => board.stream.map((game) => game.state);

  /// new game stream
  final StreamController<void> newGameStream =
      StreamController<void>.broadcast();

  /// initial data
  final Game initialData = _defaultGame();

  /// load (second) initial state from external store
  final Future<Game> Function() load;

  /// save state to external store
  final Function(Game) save;

  /// constructor
  GameBloc({this.load, this.save}) {
    _load();
  }

  /// dispose the state
  void dispose() {
    dimension.close();
    board.close();
    difficulty.close();
  }

  void _load() async {
    var game = initialData;
    var lastDimension = game.dimension;
    var lastDifficulty = game.difficulty;
    var isLoading = true;
    dimension.sink.add(lastDimension);
    difficulty.sink.add(lastDifficulty);
    board.sink.add(game);
    board.stream.listen((event) {
      if (!isLoading) {
        if (save != null) {
          save(event);
        }
      } else {
        isLoading = false;
      }
    });
    latest2(dimension.stream, difficulty.stream).listen((tuple) {
      lastDimension = tuple.a;
      lastDifficulty = tuple.b;
      if (!isLoading) {
        newGameStream.add(null);
      }
    });

    newGameStream.stream.listen((_) {
      board.sink.add(
          _newGameBoard(dimension: lastDimension, difficulty: lastDifficulty));
    });
    if (load != null) {
      game = await load();
      if (game != null) {
        isLoading = true;
        dimension.sink.add(game.dimension);
        difficulty.sink.add(game.difficulty);
        board.sink.add(game);
      }
    }
  }

  Game _newGameBoard({int dimension, double difficulty}) {
    var numOfBombs = (dimension * dimension * difficulty).round();
    return Game(
      dimension: dimension,
      bombs: Game.random(dimension: dimension, numOfBombs: numOfBombs),
      // numOfBombs: numOfBombs,
    );
  }
}

Game _defaultGame() {
  var _dimension = 15;
  var _difficulty = 1 / 5;
  return Game(
    dimension: _dimension,
    bombs: Game.random(
        dimension: _dimension,
        numOfBombs: (_dimension * _dimension * _difficulty).round()),
  );
}
