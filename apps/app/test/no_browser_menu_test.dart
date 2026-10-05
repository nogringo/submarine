@TestOn('browser')
library;

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:submarine/src/widgets/no_browser_menu.dart';

void main() {
  testWidgets('keeps the browser menu away while the mouse is over it', (
    tester,
  ) async {
    final calls = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.contextMenu,
      (call) async => calls.add(call.method),
    );
    await tester.pumpWidget(
      const Column(
        children: [
          SizedBox(height: 100),
          Expanded(child: NoBrowserMenu(child: SizedBox.expand())),
        ],
      ),
    );
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: const Offset(10, 10));
    await mouse.moveTo(const Offset(10, 200));
    expect(calls, ['disableContextMenu']);
    await mouse.moveTo(const Offset(10, 10));
    expect(calls, ['disableContextMenu', 'enableContextMenu']);

    await mouse.moveTo(const Offset(10, 200));
    await tester.pumpWidget(const SizedBox());
    expect(calls, [
      'disableContextMenu',
      'enableContextMenu',
      'disableContextMenu',
      'enableContextMenu',
    ]);
    await mouse.removePointer();
  });
}
