import 'dart:io';

import 'package:submarine_cli/src/vault_session.dart';
import 'package:submarine_cli/submarine_cli.dart';
import 'package:test/test.dart';

void main() {
  late VaultSession session;

  setUp(() async {
    final cache = await Directory.systemTemp.createTemp('submarine_test');
    addTearDown(() => cache.delete(recursive: true));
    session = VaultSession(
      privateKey: 'ab' * 32,
      relays: const [],
      cacheDirectory: cache,
    );
    addTearDown(session.close);
  });

  test('a vault never synced has no last sync', () async {
    expect(await session.lastSync(), isNull);
  });

  test('items refuses to read a vault never synced', () async {
    await expectLater(
      session.items(),
      throwsA(
        isA<CliException>().having(
          (error) => error.message,
          'message',
          contains('submarine sync'),
        ),
      ),
    );
  });
}
