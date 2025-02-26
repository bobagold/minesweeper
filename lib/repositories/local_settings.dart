import 'package:shared_preferences/shared_preferences.dart';

import '../models/game.dart';

/// load from SharedPreferences
Future<Game?> loadStateFromSettings() async {
  try {
    var p = await SharedPreferences.getInstance();
    var board = p.getString('board');
    if (board != null) {
      return Game.loadFromString(board);
    }
  } finally {}
  return null;
}

/// save to SharedPreferences
void saveStateToSettings(Game board) async {
  var p = await SharedPreferences.getInstance();
  p.setString('board', board.saveToString());
}
