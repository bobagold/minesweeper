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
    var game = Game(dimension: 3, bombs: [1, 3]);
    onTap(i, j) {}
    ;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: Board(
      board: game,
      onTap: onTap,
      onLongPress: onTap,
    ))));
    expect(find.byKey(Key('cell0x0')), findsOneWidget);
    expect(find.byKey(Key('cell0x1')), findsOneWidget);
    expect(
        find.ancestor(
          of: find.byKey(Key('secret2')),
          matching: find.byKey(Key('cell0x0')),
        ),
        findsOneWidget);
    expect(
        find.ancestor(
          of: find.byType(InkWell),
          matching: find.byKey(Key('cell0x0')),
        ),
        findsOneWidget);
    expect(
        find.ancestor(
          of: find.byKey(Key('secret10')),
          matching: find.byKey(Key('cell0x1')),
        ),
        findsOneWidget);
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: Board(
      board: game,
      onTap: onTap,
      onLongPress: onTap,
    ))));
    tester.tap(find.byKey(Key('cell0x0')));
  });
  testWidgets('Minesweeper board smoke test with opened cell', (tester) async {
    var game = Game(
      dimension: 3,
      bombs: [1, 3],
      openCells: [0],
      markedCells: [8],
    );
    onTap(i, j) {}
    ;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: Board(
      board: game,
      onTap: onTap,
      onLongPress: onTap,
    ))));
    expect(
        find.ancestor(
          of: find.text('2'),
          matching: find.byKey(Key('cell0x0')),
        ),
        findsOneWidget);
    expect(
        find.ancestor(
          of: find.text('🚩'),
          matching: find.byKey(Key('cell2x2')),
        ),
        findsOneWidget);
  });
}
