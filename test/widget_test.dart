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
import 'package:minesweeper/widgets/score.dart';

void main() {
  group('Minesweeper smoke app test', () {
    testWidgets('MyApp with score and board', (tester) async {
      await tester.pumpWidget(MyApp());

      var finderPlay = find.byIcon(Icons.refresh);
      expect(finderPlay, findsOneWidget);
      expect(find.byKey(Key('score')), findsOneWidget);
      var initialScore = 45;
      expect(score(), initialScore);
      expect(find.byKey(Key('secret0')), findsWidgets);
      await tester.tap(find.byKey(Key('secret0')).first);
      expect(score(), initialScore);
      await tester.longPress(find.byKey(Key('secret10')).first);
      expect(score(), initialScore - 1);
      expect(find.byKey(Key('restart')).hitTestable(), findsOneWidget);
      await tester.tap(find.byKey(Key('restart')));
      await tester.pump();
      expect(score(), initialScore);
    });
  });
  group('Score', () {
    testWidgets('equals to count of bombs', (tester) async {
      var game = Game(dimension: 3, bombs: {1, 3});
      await tester
          .pumpWidget(MaterialApp(home: Scaffold(body: Score(board: game))));
      expect(
          find.ancestor(
            of: find.text('2'),
            matching: find.byKey(Key('score')),
          ),
          findsOneWidget);
    });
  });
  group('Game', () {
    testWidgets('Read the board', (tester) async {
      var game = Game(dimension: 3, bombs: {1, 3});
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
    });
    testWidgets('Read marked cell', (tester) async {
      var game = Game(
        dimension: 3,
        bombs: {1, 3},
        openCells: {0},
        markedCells: {8},
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
  });
}

int score() {
  var score = find
      .descendant(of: find.byKey(Key('score')), matching: find.byType(Text))
      .evaluate()
      .first
      .widget;
  return int.tryParse(score is Text ? score.data : '-1');
}
