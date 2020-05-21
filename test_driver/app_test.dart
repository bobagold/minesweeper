import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('Minesweeper app', () {
    FlutterDriver driver;
    setUpAll(() async {
      Directory('screenshots').create();
      driver = await FlutterDriver.connect();
    });
    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });
    takeScreenshot(String path) async {
//      var pixels = await driver.screenshot();
//      var file = File(path);
//      await file.writeAsBytes(pixels);
      print(path);
    }

    var timeout = Duration(seconds: 2);
    Future<void> longPress(SerializableFinder finder) =>
        driver.scroll(finder, 0, 0, Duration(milliseconds: 460));
    var scoreFinder = find.descendant(
        of: find.byValueKey('score'), matching: find.byType('Text'));
    var safeCellFinder = find.ancestor(
        of: find.byValueKey('safeTap'),
        matching: find.byType('InkWell'),
        matchRoot: true,
        firstMatchOnly: true);
    var bombFinder = find.ancestor(
        of: find.byValueKey('bombTap'),
        matching: find.byType('InkWell'),
        matchRoot: true,
        firstMatchOnly: true);
    setUp(() async {
      await driver.tap(find.byValueKey('restart'), timeout: timeout);
    });
    test('fast fail', () async {
      await takeScreenshot('screenshots/start.png');
      expect(await driver.getText(scoreFinder, timeout: timeout), '45');
      for (var i = 0; i < 5; i++) {
        await driver.tap(safeCellFinder, timeout: timeout);
      }
      await takeScreenshot('screenshots/move.png');
      await driver.tap(bombFinder, timeout: timeout);
      await takeScreenshot('screenshots/fail_fast.png');
    });
    test('last fail', () async {
      for (var i = 0; i < 40; i++) {
        await driver.tap(safeCellFinder, timeout: timeout);
      }
      for (var i = 0; i < 5; i++) {
        await longPress(bombFinder);
      }
      await driver.tap(bombFinder, timeout: timeout);
      await takeScreenshot('screenshots/fail_late.png');
    });
    test('win by opening all non-bombs', () async {
      for (var i = 0; i < 110; i++) {
        await driver.tap(safeCellFinder, timeout: timeout);
      }
      await takeScreenshot('screenshots/win_by_open.png');
    });
    test('win by marking all bombs', () async {
      for (var i = 0; i < 45; i++) {
        await longPress(bombFinder);
      }
      await takeScreenshot('screenshots/win_by_marked.png');
    });
  },
      skip: Platform.environment['VM_SERVICE_URL'] == null,
      timeout: Timeout.factor(2));
}
