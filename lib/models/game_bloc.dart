import 'dart:async';

import 'bloc.dart';
import 'game.dart';

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

  /// time state
  Stream<int> get timeStream => _time.stream;

  /// elapsed seconds for the current game
  int get elapsedSeconds => _elapsedSeconds;

  /// selected difficulty before rounding the bomb count
  double get currentDifficulty => _difficulty;

  /// new game stream
  final StreamController<void> newGameStream =
      StreamController<void>.broadcast();

  /// current data for newly mounted listeners
  Game get initialData => _game;

  final StreamController<int> _time = StreamController<int>.broadcast();
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  final Set<Game> _publishedGames = {};
  Game _game = _defaultGame();
  late int _dimension = _game.dimension;
  late double _difficulty = _game.difficulty;
  Timer? _timer;
  int _elapsedSeconds = 0;
  int _revision = 0;
  bool _disposed = false;

  /// load (second) initial state from external store
  final Future<Game?> Function() load;

  /// save state to external store
  final Function(Game) save;

  /// constructor
  GameBloc({required this.load, required this.save}) {
    _subscriptions.add(board.stream.listen((game) {
      if (!_publishedGames.remove(game) && !identical(game, _game)) {
        _difficulty = game.difficulty;
        _updateGame(game);
      }
    }));
    _subscriptions.add(dimension.stream.listen((value) {
      if (value != _dimension) {
        _dimension = value;
        _restart();
      }
    }));
    _subscriptions.add(difficulty.stream.listen((value) {
      if (value != _difficulty) {
        _difficulty = value;
        _restart();
      }
    }));
    _subscriptions.add(newGameStream.stream.listen((_) => _restart()));
    _load();
  }

  /// apply a move to the latest game
  void update(Game Function(Game) move) {
    if (_disposed ||
        _game.state == GameState.win ||
        _game.state == GameState.lost) {
      return;
    }
    var game = move(_game);
    if (identical(game, _game)) return;
    _updateGame(game);
    _publish(game);
  }

  /// dispose the state
  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _timer?.cancel();
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    dimension.close();
    board.close();
    difficulty.close();
    newGameStream.close();
    _time.close();
  }

  Future<void> _load() async {
    var revision = _revision;
    try {
      var game = await load();
      if (_disposed || revision != _revision || game == null) return;
      _difficulty = game.difficulty;
      _updateGame(game, persist: false);
      dimension.add(_dimension);
      difficulty.add(_difficulty);
      _publish(game);
    } on Object catch (error, stackTrace) {
      if (!_disposed) board.addError(error, stackTrace);
    }
  }

  void _restart() {
    var game = _newGameBoard(dimension: _dimension, difficulty: _difficulty);
    _updateGame(game);
    _publish(game);
  }

  void _publish(Game game) {
    _publishedGames.add(game);
    board.add(game);
  }

  void _updateGame(Game game, {bool persist = true}) {
    _revision++;
    _game = game;
    _dimension = game.dimension;
    if (game.state == GameState.created) {
      _timer?.cancel();
      _timer = null;
      _elapsedSeconds = 0;
      _time.add(_elapsedSeconds);
    } else if (game.state == GameState.playing) {
      if (_timer == null) {
        var previousTick = 0;
        _timer = Timer.periodic(Duration(seconds: 1), (timer) {
          _elapsedSeconds += timer.tick - previousTick;
          previousTick = timer.tick;
          _time.add(_elapsedSeconds);
        });
      }
    } else {
      _timer?.cancel();
      _timer = null;
    }
    if (persist) save(game);
  }

  Game _newGameBoard({required int dimension, required double difficulty}) {
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
