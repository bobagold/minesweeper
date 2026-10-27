// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minesweeper/main.dart';
import 'package:minesweeper/models/game.dart';
import 'package:minesweeper/models/game_bloc.dart';
import 'package:minesweeper/screens/game_screen.dart';
import 'package:minesweeper/widgets/board.dart';
import 'package:minesweeper/widgets/score.dart';

void main() {
  group('GameBloc', () {
    testWidgets(
        'consecutive moves use current state and completed games freeze',
        (tester) async {
      var game = Game(dimension: 3, bombs: {1, 3});
      var saved = <Game>[];
      var bloc = GameBloc(load: () async => game, save: saved.add);
      addTearDown(bloc.dispose);
      await tester.pump();
      bloc.update((game) => game.mark(0, 1));
      bloc.update((game) => game.mark(1, 0));
      await tester.pump();
      expect(bloc.initialData.state, GameState.win);
      expect(bloc.initialData.markedCells, {1, 3});
      expect(saved.length, 2);
      bloc.update((game) => game.mark(2, 2));
      await tester.pump();
      expect(bloc.initialData.markedCells, {1, 3});
      expect(saved.length, 2);
    });

    testWidgets('timer starts on play, survives updates, and resets on restart',
        (tester) async {
      var game = Game(dimension: 3, bombs: {1, 3});
      var bloc = GameBloc(load: () async => game, save: (_) {});
      addTearDown(bloc.dispose);
      var times = <int>[];
      var subscription = bloc.timeStream.listen(times.add);
      addTearDown(subscription.cancel);
      await tester.pump();
      await tester.pump(Duration(seconds: 2));
      expect(times.where((seconds) => seconds > 0), isEmpty);

      bloc.board.add(game.move(0, 0));
      await tester.pump();
      await tester.pump(Duration(seconds: 2));
      expect(times.last, 2);
      bloc.board.add(game.move(0, 0).mark(2, 2));
      await tester.pump();
      await tester.pump(Duration(seconds: 6));
      expect(times.last, 8);

      bloc.newGameStream.add(null);
      await tester.pump();
      expect(times.last, 0);
      await tester.pump(Duration(seconds: 2));
      expect(times.last, 0);
    });

    for (var win in [false, true]) {
      testWidgets('timer stops on ${win ? 'win' : 'loss'}', (tester) async {
        var game = Game(dimension: 3, bombs: {1, 3}).move(0, 0);
        var bloc = GameBloc(load: () async => game, save: (_) {});
        addTearDown(bloc.dispose);
        var times = <int>[];
        var subscription = bloc.timeStream.listen(times.add);
        addTearDown(subscription.cancel);
        await tester.pump();
        await tester.pump(Duration(seconds: 3));
        expect(times.last, 3);
        bloc.board.add(win ? game.mark(0, 1).mark(1, 0) : game.move(0, 1));
        await tester.pump();
        await tester.pump(Duration(seconds: 3));
        expect(times.last, 3);
      });
    }

    testWidgets('settings restart and save when no saved game exists',
        (tester) async {
      var saved = <Game>[];
      var bloc = GameBloc(load: () async => null, save: saved.add);
      addTearDown(bloc.dispose);
      await tester.pump();
      bloc.dimension.add(5);
      await tester.pump();
      expect(saved.last.dimension, 5);
      bloc.difficulty.add(0.12);
      await tester.pump();
      expect(saved.last.bombs.length, 3);
      bloc.dimension.add(6);
      await tester.pump();
      bloc.dimension.add(10);
      await tester.pump();
      expect(saved.last.bombs.length, 12);
      expect(bloc.currentDifficulty, 0.12);
    });

    testWidgets('late saved game cannot overwrite user changes',
        (tester) async {
      var loading = Completer<Game?>();
      var saved = <Game>[];
      var bloc = GameBloc(load: () => loading.future, save: saved.add);
      addTearDown(bloc.dispose);
      var played = Game(dimension: 3, bombs: {1, 3}).move(0, 0);
      bloc.board.add(played);
      await tester.pump();
      loading.complete(Game(dimension: 5, bombs: {0}));
      await tester.pump();
      bloc.newGameStream.add(null);
      await tester.pump();
      expect(saved.last.dimension, played.dimension);
    });

    testWidgets('disposing before loading finishes is safe', (tester) async {
      var loading = Completer<Game?>();
      var bloc = GameBloc(load: () => loading.future, save: (_) {});
      bloc.dispose();
      loading.complete(Game(dimension: 3, bombs: {1, 3}));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });
  testWidgets('timer survives rebuilding and switching screen layouts',
      (tester) async {
    var game = Game(dimension: 5, bombs: {1, 3, 10}).move(0, 0);
    var bloc = GameBloc(load: () async => game, save: (_) {});
    addTearDown(bloc.dispose);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = Size(800, 600);
    await tester.pumpWidget(
        MaterialApp(home: GameScreen(title: 'Minesweeper', bloc: bloc)));
    await tester.pump();
    await tester.pump(Duration(seconds: 3));
    expect(find.text('0:00:03'), findsOneWidget);

    tester.view.physicalSize = Size(700, 600);
    await tester.pump();
    await tester.pump();
    expect(find.text('0:00:03'), findsOneWidget);
    await tester.pump(Duration(seconds: 2));
    expect(find.text('0:00:05'), findsOneWidget);
    await tester.tap(find.byKey(Key('restart')));
    await tester.pump();
    expect(find.text('0:00:00'), findsOneWidget);
    await tester.pumpWidget(SizedBox.shrink());
  });
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
      await tester.longPress(find.byKey(Key('bombTap')).first);
      expect(score(), initialScore - 1);
      await tester.longPress(find.byKey(Key('bombTap')).first);
      expect(score(), initialScore - 2);
      expect(find.byKey(Key('restart')).hitTestable(), findsOneWidget);
      await tester.tap(find.byKey(Key('restart')));
      await tester.pump();
      expect(score(), initialScore);
    });
  });
  group('Score', () {
    testWidgets('score shows score', (tester) async {
      await tester
          .pumpWidget(MaterialApp(home: Scaffold(body: Score(score: 2))));
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
        onDoubleTap: onTap,
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
        onDoubleTap: onTap,
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

int? score() {
  var score = find
      .descendant(of: find.byKey(Key('score')), matching: find.byType(Text))
      .evaluate()
      .first
      .widget;
  return int.tryParse(score is Text && score.data != null ? score.data! : '-1');
}
