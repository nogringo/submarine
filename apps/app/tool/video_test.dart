// Films the app for the video of apps/video, frame by frame into its
// public/footage/, the times of each take matching the video's timeline:
// flutter test tool/video_test.dart
import 'dart:io' show Directory, File;

import 'package:clock/clock.dart';
import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/services.dart' show MethodChannel;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'demo_app.dart';

const fps = 30;
const footage = '../video/public/footage';
// The 4K video shows the window at twice its size, then zooms in up to twice.
const pixelRatio = 4.0;
// Near an icon button's corner, for its icon to show beside the pointer.
const edge = Offset(10, 12);

void main() {
  final demo = DemoApp();

  setUpAll(demo.setUp);
  tearDownAll(demo.tearDown);

  testWidgets('desktop', (tester) async {
    // The app's own clipboard plugin, which a test has not.
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('submarine/clipboard'),
      (_) async => null,
    );
    final camera = Camera(tester, demo, 'desktop');
    await demo.start(tester, desktop, ThemeMode.dark, wrap: camera.wrap);
    await camera.enter(const Offset(700, 560));

    await camera.until(0.6);
    for (final vault in ['Personal', 'Family', 'Work']) {
      await camera.point(find.byTooltip(vault));
      await camera.click();
      await camera.hold(1);
    }
    await camera.point(find.byTooltip('All vaults'));
    await camera.click();
    await camera.until(7.5);

    await camera.point(find.text('Search'));
    await camera.click();
    await camera.type(find.byType(TextField).first, 'git');
    await camera.hold(0.4);
    await camera.point(find.text('GitHub').last, offset: const Offset(40, 8));
    // The code reads its ring full, as it starts its period.
    await camera.waitForTotpPeriod();
    await camera.click();
    await camera.hold(0.6);
    await camera.point(
      find.text('Verification code'),
      offset: const Offset(240, 24),
    );
    await camera.until(15);

    await camera.point(find.byTooltip('Show'), offset: edge);
    await camera.click();
    await camera.hold(1.2);
    await camera.point(find.byTooltip('Copy').at(1), offset: edge);
    await camera.click();
    await camera.until(21);

    await camera.point(find.byTooltip('Generator'), seconds: 0.9);
    await camera.click();
    await camera.hold(0.8);
    await camera.point(find.byTooltip('Increase'), offset: edge);
    for (var i = 0; i < 6; i++) {
      await camera.click();
      await camera.hold(0.15);
    }
    await camera.point(find.byTooltip('Regenerate'), offset: edge);
    await camera.click();
    await camera.hold(0.6);
    await camera.click();
    await camera.hold(0.6);
    await camera.point(find.text('Passphrase'));
    await camera.click();
    await camera.until(29);
    await demo.close(tester);
  });

  testWidgets('phone', (tester) async {
    final camera = Camera(tester, demo, 'phone', touch: true);
    await demo.start(tester, phone, ThemeMode.light, wrap: camera.wrap);
    await camera.enter(const Offset(200, 600));

    await camera.until(1);
    await camera.swipe(const Offset(0, -260));
    await camera.hold(0.8);
    await camera.swipe(const Offset(0, 260));
    await camera.hold(0.6);
    await camera.point(find.text('GitHub'));
    await camera.waitForTotpPeriod();
    await camera.click();
    await camera.until(9);
    await demo.close(tester);
  });
}

/// Films the app as a person uses it, with a mouse whose pointer it draws, or
/// with a finger whose touches it shows.
class Camera {
  Camera(this.tester, this.demo, String take, {this.touch = false})
    : folder = Directory('$footage/$take');

  final WidgetTester tester;
  final DemoApp demo;
  final Directory folder;
  final bool touch;
  final _pointer = ValueNotifier<Offset?>(null);
  final _pressed = ValueNotifier(false);
  TestGesture? _gesture;
  int _frames = 0;

  Widget wrap(Widget app) => Stack(
    textDirection: TextDirection.ltr,
    children: [
      app,
      IgnorePointer(
        child: ListenableBuilder(
          listenable: Listenable.merge([_pointer, _pressed]),
          builder: (context, _) => CustomPaint(
            size: Size.infinite,
            painter: touch
                ? _Touch(_pointer.value, pressed: _pressed.value)
                : _Arrow(_pointer.value, pressed: _pressed.value),
          ),
        ),
      ),
    ],
  );

  Offset get _at => _pointer.value!;

  Future<void> frame() async {
    await tester.pump(const Duration(microseconds: 1000000 ~/ fps));
    final name = '${_frames++}'.padLeft(4, '0');
    await demo.capture(
      tester,
      File('${folder.path}/$name.png'),
      pixelRatio: pixelRatio,
    );
  }

  Future<void> hold(double seconds) async {
    for (var i = 0; i < seconds * fps; i++) {
      await frame();
    }
  }

  /// Holds until [seconds] into the take.
  Future<void> until(double seconds) async {
    final end = (seconds * fps).round();
    if (_frames > end) {
      throw StateError('The take is at ${_frames / fps} s, past $seconds s');
    }
    while (_frames < end) {
      await frame();
    }
  }

  Future<void> enter(Offset at) async {
    if (folder.existsSync()) folder.deleteSync(recursive: true);
    if (!touch) {
      _gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await _gesture!.addPointer(location: at);
    }
    _pointer.value = at;
  }

  /// Moves the pointer onto the middle of [finder], or [offset] from it.
  Future<void> point(
    Finder finder, {
    Offset offset = Offset.zero,
    double seconds = 0.7,
  }) async {
    final to = tester.getCenter(finder.first) + offset;
    await _move(to, seconds, (at) async => _gesture?.moveTo(at));
  }

  Future<void> _move(
    Offset to,
    double seconds,
    Future<void> Function(Offset at) send,
  ) async {
    final from = _at;
    final steps = (seconds * fps).round();
    for (var i = 1; i <= steps; i++) {
      final t = Curves.easeInOutCubic.transform(i / steps);
      final at = Offset.lerp(from, to, t)!;
      await send(at);
      _pointer.value = at;
      await frame();
    }
  }

  Future<void> click() async {
    final TestGesture gesture;
    if (touch) {
      gesture = await tester.startGesture(_at);
    } else {
      gesture = _gesture!;
      await gesture.down(_at);
    }
    _pressed.value = true;
    await frame();
    await frame();
    await gesture.up();
    _pressed.value = false;
    await frame();
  }

  /// Drags the finger by [by], as a person scrolls a list.
  Future<void> swipe(Offset by, {double seconds = 0.5}) async {
    final gesture = await tester.startGesture(_at);
    _pressed.value = true;
    await frame();
    await _move(_at + by, seconds, gesture.moveTo);
    await gesture.up();
    _pressed.value = false;
    await frame();
  }

  Future<void> type(Finder field, String text) async {
    for (var i = 1; i <= text.length; i++) {
      await tester.enterText(field, text.substring(0, i));
      await hold(0.12);
    }
  }

  /// Lets the time pass, without filming, until the next TOTP period starts.
  Future<void> waitForTotpPeriod() async {
    final now = clock.now();
    final left = 30000 - (now.second % 30 * 1000 + now.millisecond);
    await tester.pump(Duration(milliseconds: left + 100));
  }
}

/// An arrow pointer whose tip is at [at], a little smaller while [pressed].
class _Arrow extends CustomPainter {
  _Arrow(this.at, {required this.pressed});

  final Offset? at;
  final bool pressed;

  static final _path = Path()
    ..moveTo(0, 0)
    ..lineTo(0, 18)
    ..lineTo(4.5, 13.8)
    ..lineTo(7.6, 20.6)
    ..lineTo(10.6, 19.3)
    ..lineTo(7.6, 12.6)
    ..lineTo(13.4, 12.6)
    ..close();

  @override
  void paint(Canvas canvas, Size size) {
    final at = this.at;
    if (at == null) return;
    canvas
      ..save()
      ..translate(at.dx, at.dy)
      ..scale(pressed ? 1.05 : 1.2)
      ..drawShadow(_path, Colors.black, 2, false)
      ..drawPath(_path, Paint()..color = Colors.black)
      ..drawPath(
        _path,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..strokeJoin = StrokeJoin.round,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_Arrow old) => old.at != at || old.pressed != pressed;
}

/// A finger's touch at [at], shown while [pressed].
class _Touch extends CustomPainter {
  _Touch(this.at, {required this.pressed});

  final Offset? at;
  final bool pressed;

  @override
  void paint(Canvas canvas, Size size) {
    final at = this.at;
    if (at == null || !pressed) return;
    canvas
      ..drawCircle(at, 22, Paint()..color = const Color(0x55808890))
      ..drawCircle(
        at,
        22,
        Paint()
          ..color = const Color(0xCCFFFFFF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
  }

  @override
  bool shouldRepaint(_Touch old) => old.at != at || old.pressed != pressed;
}
