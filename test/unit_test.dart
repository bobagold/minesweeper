// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:test/test.dart';
import 'package:minesweeper/models/game.dart';

void main() {
  test('Game model can calculate cells', () {
    var game = Game(dimension: 3, bombs: [1, 3]);
    expect(game.cells[2][2], 0);
    expect(game.cells[0][1], 10);
    expect(game.cells[1][0], 10);
    expect(game.cells[0][0], 2);
    expect(game.cells[1][1], 2);
    expect(game.state, GameState.playing);
  });
  test('Game model move() can expole bombs', () {
    var game = Game(dimension: 3, bombs: [1, 3]);
//    for (var i in game.cells) print(i);
    var move = game.move(0, 1);
    expect(move.state, GameState.lost);
    expect(move.openCells, [1]);
  });
  test('Game model move() can open number', () {
    var game = Game(dimension: 3, bombs: [1, 3]);
//    for (var i in game.cells) print(i);
    var move = game.move(0, 0);
    expect(move.state, GameState.playing);
    expect(move.openCells, [0]);
  });
}
