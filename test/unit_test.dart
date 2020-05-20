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
  test('Game model move() can open 0', () {
    var game = Game(dimension: 3, bombs: [1, 3]);
//    for (var i in game.cells) print(i);
    var move = game.move(2, 2);
    expect(move.state, GameState.playing);
    expect(move.openCells, [8, 4, 5, 7]);
  });
  test('Game model move() can open 0 and adjustment cells', () {
    var game = Game(dimension: 4, bombs: [1, 3]);
//    for (var i in game.cells) print(i);
    var move = game.move(3, 3);
    expect(move.state, GameState.playing);
    var expectedOpenCells = [15, 10, 11, 14, 5, 6, 7, 9, 13, 4, 8, 12];
    expect(move.openCells, expectedOpenCells);
  });
  test('Game model move() can mark cell', () {
    var game = Game(dimension: 3, bombs: [1, 3]);
//    for (var i in game.cells) print(i);
    var move = game.mark(2, 2);
    expect(move.state, GameState.playing);
    expect(move.openCells, []);
    expect(move.markedCells, [8]);
  });
  test('Game model move() can unmark cell', () {
    var game = Game(dimension: 3, bombs: [1, 3], markedCells: [8]);
//    for (var i in game.cells) print(i);
    var move = game.mark(2, 2);
    expect(move.state, GameState.playing);
    expect(move.openCells, []);
    expect(move.markedCells, []);
  });
  test('Game score counts bombs', () {
    var game = Game(dimension: 3, bombs: [1, 3]);
    expect(game.score, 2);
  });
  test('Game score counts bombs minus marked bombs', () {
    var game = Game(dimension: 3, bombs: [1, 3], markedCells: [1]);
    expect(game.score, 1);
  });
  test('Game detects win by marked bombs', () {
    var game = Game(dimension: 3, bombs: [1, 3]);
    expect(game.state, GameState.playing);
    game = game.mark(0, 1);
    expect(game.state, GameState.playing);
    game = game.mark(1, 0);
    expect(game.score, 0);
    expect(game.state, GameState.win);
  });
  test('Game detects win by opened non-bombs', () {
    var game = Game(dimension: 3, bombs: [0, 2, 3, 4, 5, 6, 7, 8]);
    expect(game.state, GameState.playing);
    game = game.move(0, 1);
    expect(game.state, GameState.win);
    expect(game.isOpen(0, 0), false);
    expect(game.isVisible(0, 0), true);
    expect(game.score, 0);
  });
  test('Game shows all the bombs on loose', () {
    var game = Game(dimension: 3, bombs: [0, 3]);
    expect(game.state, GameState.playing);
    game = game.move(0, 0);
    expect(game.state, GameState.lost);
    expect(game.isOpen(0, 3), true);
  });
  test('Game random', () {
    expect(Game.random(dimension: 15, numOfBombs: 3).length, 3);
    expect(
        Game.random(dimension: 15, numOfBombs: 3)
            .every((element) => element != null),
        true);
  });
}
