// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minesweeper/main.dart';
import 'package:minesweeper/models/game.dart';

import 'package:minesweeper/widgets/board.dart';

void main() {
  testWidgets('Minesweeper smoke app test', (tester) async {
    await tester.pumpWidget(MyApp());

    var finderPlay = find.byIcon(Icons.play_arrow);
    expect(finderPlay, findsOneWidget);
  });
  testWidgets('Minesweeper board smoke test', (tester) async {
    var game = Game(15, [10 * 15 + 10]);
    await tester
        .pumpWidget(MaterialApp(home: Scaffold(body: Board(board: game))));
    expect(find.byKey(Key('cell0x0')), findsOneWidget);
    expect(find.byKey(Key('cell10x10')), findsOneWidget);
    expect(
        find.ancestor(
          of: find.byKey(Key('secret0')),
          matching: find.byKey(Key('cell0x0')),
        ),
        findsOneWidget);
    expect(
        find.ancestor(
          of: find.byKey(Key('secret10')),
          matching: find.byKey(Key('cell10x10')),
        ),
        findsOneWidget);
  });
}
