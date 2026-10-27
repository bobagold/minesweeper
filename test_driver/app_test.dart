import 'dart:convert';
import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('Minesweeper app', () {
    late FlutterDriver driver;
    var timeout = Duration(seconds: 10);
    var scoreFinder = find.descendant(
        of: find.byValueKey('score'), matching: find.byType('Text'));

    Future<Map<String, dynamic>> state() async =>
        jsonDecode(await driver.requestData('state', timeout: timeout))
            as Map<String, dynamic>;

    SerializableFinder closedCell(int index, String key) => find.descendant(
        of: find.byValueKey('cell${index ~/ 15}x${index % 15}'),
        matching: find.byValueKey(key));

    Future<void> tapCell(int index, {bool bomb = false}) async {
      var finder = closedCell(index, bomb ? 'bombTap' : 'safeTap');
      await driver.tap(finder, timeout: timeout);
      await driver.waitForAbsent(finder, timeout: timeout);
    }

    Future<void> markCell(int index) async {
      var finder = closedCell(index, 'bombTap');
      await driver.scroll(finder, 0, 0, Duration(milliseconds: 600),
          timeout: timeout);
      await driver.waitForAbsent(finder, timeout: timeout);
    }

    Future<void> openSafeCells({int? except}) async {
      var game = await state();
      var bombs = (game['bombs'] as List).cast<int>().toSet();
      for (var index = 0; index < 225; index++) {
        if (bombs.contains(index) || index == except) continue;
        game = await state();
        if ((game['openCells'] as List).contains(index)) continue;
        await tapCell(index);
      }
    }

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });
    tearDownAll(() async {
      await driver.close();
    });
    setUp(() async {
      await driver.runUnsynchronized(() async {
        await driver.tap(find.byValueKey('restart'), timeout: timeout);
        await driver.requestData('reset', timeout: timeout);
        await driver.waitFor(find.text('45'), timeout: timeout);
        expect(await driver.getText(scoreFinder, timeout: timeout), '45');
        expect((await state())['state'], 'created');
      });
    });
    test('fast fail', () async {
      await driver.runUnsynchronized(() async {
        await tapCell(0);
        await tapCell(1, bomb: true);
        expect((await state())['state'], 'lost');
      });
    });
    test('last fail', () async {
      await driver.runUnsynchronized(() async {
        await openSafeCells(except: 0);
        expect((await state())['state'], 'playing');
        expect((await state())['openCells'], hasLength(179));
        await tapCell(1, bomb: true);
        expect((await state())['state'], 'lost');
      });
    });
    test('win by opening all non-bombs', () async {
      await driver.runUnsynchronized(() async {
        await openSafeCells();
        expect((await state())['state'], 'win');
        expect((await state())['openCells'], hasLength(180));
        expect(await driver.getText(scoreFinder, timeout: timeout), '0');
      });
    });
    test('win by marking all bombs', () async {
      await driver.runUnsynchronized(() async {
        var bombs = ((await state())['bombs'] as List).cast<int>();
        for (var index in bombs) {
          await markCell(index);
        }
        expect((await state())['state'], 'win');
        expect((await state())['markedCells'], hasLength(45));
        expect(await driver.getText(scoreFinder, timeout: timeout), '0');
      });
    });
  },
      skip: Platform.environment['VM_SERVICE_URL'] == null,
      timeout: Timeout.factor(2));
}
