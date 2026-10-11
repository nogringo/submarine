import 'dart:convert';

import 'package:submarine_extension_core/core.dart';
import 'package:test/test.dart';

void main() {
  final core = Core({
    'echo': (args) async => args,
    'refuse': (args) async => throw CoreException('wrongPassword'),
    'crash': (args) async => throw StateError('boom'),
  });

  Future<Object?> call(String method, [Object args = const {}]) async =>
      jsonDecode(await core.handle(method, jsonEncode(args)));

  test('answers with the result of the method', () async {
    expect(await call('echo', {'a': 1}), {
      'result': {'a': 1},
    });
  });

  test('answers an unknown method with an error', () async {
    expect(await call('nope'), {
      'error': {'code': 'unknownMethod', 'message': 'nope'},
    });
  });

  test('answers a CoreException with its code', () async {
    expect(await call('refuse'), {
      'error': {'code': 'wrongPassword', 'message': null},
    });
  });

  test('runs before each method what it is given', () async {
    final ran = <String>[];
    final watched = Core({
      'echo': (args) async {
        ran.add('echo');
        return args;
      },
    }, before: () async => ran.add('before'));

    await watched.handle('echo', '{}');

    expect(ran, ['before', 'echo']);
  });

  test('answers any other error as internal', () async {
    expect(await call('crash'), {
      'error': {'code': 'internal', 'message': 'Bad state: boom'},
    });
  });
}
