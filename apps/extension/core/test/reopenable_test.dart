import 'dart:async';

import 'package:submarine_extension_core/reopenable.dart';
import 'package:test/test.dart';

void main() {
  late List<String> log;
  late Completer<void> closed;
  late Reopenable<int> resource;
  var opened = 0;

  setUp(() {
    log = [];
    closed = Completer<void>();
    opened = 0;
    resource = Reopenable(
      () async {
        log.add('open ${++opened}');
        return opened;
      },
      (value) async {
        log.add('closing $value');
        await closed.future;
        log.add('closed $value');
      },
    );
  });

  test('opens once, on demand', () async {
    expect(resource.current, isNull);
    expect(await resource.open(), 1);
    expect(await resource.open(), 1);
    expect(log, ['open 1']);
  });

  test('opens again only once the closing ended', () async {
    await resource.open();
    final closing = resource.close();
    final reopening = resource.open();
    await pumpEventQueue();
    expect(log, ['open 1', 'closing 1']);

    closed.complete();
    await closing;

    expect(await reopening, 2);
    expect(log, ['open 1', 'closing 1', 'closed 1', 'open 2']);
  });

  test('runs what follows a closing before the next opening', () async {
    closed.complete();
    await resource.open();
    final closing = resource.close(() async => log.add('deleted'));
    await resource.open();
    await closing;

    expect(log, ['open 1', 'closing 1', 'closed 1', 'deleted', 'open 2']);
  });

  test('opens again after a closing that failed', () async {
    final failing = Reopenable<int>(
      () async => 1,
      (_) async => throw StateError('boom'),
    );
    await failing.open();

    await expectLater(failing.close(), throwsStateError);

    expect(await failing.open(), 1);
  });
}
