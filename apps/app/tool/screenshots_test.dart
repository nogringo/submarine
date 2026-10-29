// Renders the screenshots of the READMEs into screenshots/, and those of the
// Android stores into fastlane/:
// flutter test tool/screenshots_test.dart
import 'dart:io' show File;

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'demo_app.dart';

// Fastlane screenshots are at most twice as tall as wide.
const android = Size(412, 824);
const store = 'fastlane/metadata/android/en-US/images/phoneScreenshots';

void main() {
  final demo = DemoApp();

  setUpAll(demo.setUp);
  tearDownAll(demo.tearDown);

  Future<void> capture(
    WidgetTester tester,
    String name, {
    String folder = 'screenshots',
  }) async {
    await settle(tester);
    await demo.capture(tester, File('$folder/$name.png'));
  }

  /// Opens GitHub at the start of a TOTP period, for its ring to read full.
  Future<void> openGitHub(WidgetTester tester) async {
    final left = 30 - clock.now().second % 30;
    if (left < 25) await tester.pump(Duration(seconds: left));
    await tester.tap(find.text('GitHub'));
  }

  for (final theme in [ThemeMode.light, ThemeMode.dark]) {
    final suffix = theme.name;

    testWidgets('desktop, $suffix', (tester) async {
      await demo.start(tester, desktop, theme);
      await openGitHub(tester);
      await capture(tester, 'desktop-$suffix');
      await demo.close(tester);
    });

    testWidgets('phone welcome, $suffix', (tester) async {
      await demo.start(tester, phone, theme, empty: true);
      await capture(tester, 'phone-welcome-$suffix');
      await demo.close(tester);
    });

    testWidgets('phone list, $suffix', (tester) async {
      await demo.start(tester, phone, theme);
      await capture(tester, 'phone-list-$suffix');
      await demo.close(tester);
    });

    testWidgets('phone generator, $suffix', (tester) async {
      await demo.start(tester, phone, theme);
      await tester.tap(find.text('Generator'));
      await capture(tester, 'phone-generator-$suffix');
      await demo.close(tester);
    });
  }

  for (final (index, theme, screen) in [
    (1, ThemeMode.light, 'list'),
    (2, ThemeMode.light, 'item'),
    (3, ThemeMode.light, 'generator'),
    (4, ThemeMode.dark, 'list'),
    (5, ThemeMode.light, 'welcome'),
  ]) {
    testWidgets('store $screen, ${theme.name}', (tester) async {
      await demo.start(tester, android, theme, empty: screen == 'welcome');
      switch (screen) {
        case 'item':
          await openGitHub(tester);
        case 'generator':
          await tester.tap(find.text('Generator'));
      }
      await capture(tester, '$index', folder: store);
      await demo.close(tester);
    });
  }
}
