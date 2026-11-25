// Renders the screenshots of the READMEs into screenshots/, and those of the
// stores into fastlane/:
// flutter test tool/screenshots_test.dart
import 'dart:io' show File;

import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:submarine/src/context.dart' show wideLayoutWidth;

import 'demo_app.dart';

// Fastlane screenshots are at most twice as tall as wide. The App Store takes
// only the exact sizes of its devices: the 6.9" iPhone and the 13" iPad.
const stores = [
  (
    name: 'android',
    platform: TargetPlatform.android,
    size: Size(412, 824),
    pixelRatio: 2.0,
    path: 'fastlane/metadata/android/en-US/images/phoneScreenshots/',
  ),
  (
    name: 'iphone',
    platform: TargetPlatform.iOS,
    size: Size(440, 956),
    pixelRatio: 3.0,
    path: 'fastlane/screenshots/en-US/iphone-',
  ),
  (
    name: 'ipad',
    platform: TargetPlatform.iOS,
    size: Size(1376, 1032),
    pixelRatio: 2.0,
    path: 'fastlane/screenshots/en-US/ipad-',
  ),
];

void main() {
  final demo = DemoApp();

  setUpAll(demo.setUp);
  tearDownAll(demo.tearDown);

  Future<void> capture(
    WidgetTester tester,
    String path, {
    double pixelRatio = 2,
  }) async {
    await settle(tester);
    await demo.capture(tester, File('$path.png'), pixelRatio: pixelRatio);
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
      await capture(tester, 'screenshots/desktop-$suffix');
      await demo.close(tester);
    });

    testWidgets('phone welcome, $suffix', (tester) async {
      await demo.start(tester, phone, theme, empty: true);
      await capture(tester, 'screenshots/phone-welcome-$suffix');
      await demo.close(tester);
    });

    testWidgets('phone list, $suffix', (tester) async {
      await demo.start(tester, phone, theme);
      await capture(tester, 'screenshots/phone-list-$suffix');
      await demo.close(tester);
    });

    testWidgets('phone generator, $suffix', (tester) async {
      await demo.start(tester, phone, theme);
      await tester.tap(find.text('Generator'));
      await capture(tester, 'screenshots/phone-generator-$suffix');
      await demo.close(tester);
    });
  }

  for (final store in stores) {
    for (final (index, theme, screen) in [
      (1, ThemeMode.light, 'list'),
      (2, ThemeMode.light, 'item'),
      (3, ThemeMode.light, 'generator'),
      (4, ThemeMode.dark, 'list'),
      (5, ThemeMode.light, 'welcome'),
    ]) {
      testWidgets('${store.name} $screen, ${theme.name}', (tester) async {
        await demo.start(tester, store.size, theme, empty: screen == 'welcome');
        switch (screen) {
          case 'item':
            await openGitHub(tester);
          case 'generator':
            await tester.tap(
              store.size.width >= wideLayoutWidth
                  ? find.byTooltip('Generator')
                  : find.text('Generator'),
            );
        }
        await capture(
          tester,
          '${store.path}$index',
          pixelRatio: store.pixelRatio,
        );
        await demo.close(tester);
      }, variant: TargetPlatformVariant.only(store.platform));
    }
  }
}
