import 'package:ndk/ndk.dart';
import 'package:submarine_extension_core/core.dart';
import 'package:submarine_extension_core/device_key.dart';
import 'package:submarine_extension_core/vaults.dart';
import 'package:test/test.dart';

import 'memory_store.dart';

const privateKey =
    '3501454135014541350145413501453fefb02227e449e57cf4d3a3ce05378683';
const password = 'correct horse battery';
const signers = Bip340EventSignerFactory();

void main() {
  late MemoryStore local;
  late MemoryStore session;
  late DeviceKey deviceKey;
  late Vaults vaults;

  setUp(() {
    local = MemoryStore();
    session = MemoryStore();
    deviceKey = DeviceKey(local, session);
    vaults = Vaults(local, signers, deviceKey);
  });

  final throwsLocked = throwsA(
    isA<CoreException>().having((error) => error.code, 'code', 'locked'),
  );

  test('keeps the key in clear without a lock password', () async {
    final key = await deviceKey.read();
    expect((await deviceKey.read()).bytes, key.bytes);
    expect(local.values, contains('deviceKey'));
    expect(await deviceKey.hasPassword, isFalse);
    expect(await deviceKey.locked, isFalse);
    await deviceKey.lock();
    expect(await deviceKey.locked, isFalse);
  });

  test('protects the key with the lock password, and stays unlocked', () async {
    final key = await deviceKey.read();

    await deviceKey.setPassword(password);

    expect(local.values, isNot(contains('deviceKey')));
    expect(local.values, contains('deviceKeyProtected'));
    expect(await deviceKey.hasPassword, isTrue);
    expect(await deviceKey.locked, isFalse);
    expect((await deviceKey.read()).bytes, key.bytes);
  });

  test('refuses a lock password under 12 characters', () async {
    await expectLater(
      deviceKey.setPassword('a' * 11),
      throwsA(
        isA<CoreException>().having(
          (error) => error.code,
          'code',
          'lockPasswordTooShort',
        ),
      ),
    );
    expect(await deviceKey.hasPassword, isFalse);
  });

  test('locks the vaults, which the lock password alone opens', () async {
    await vaults.add(key: privateKey, name: 'Home', color: 1);
    await deviceKey.setPassword(password);

    await deviceKey.lock();

    expect(await deviceKey.locked, isTrue);
    await expectLater(vaults.list(), throwsLocked);
    expect(await deviceKey.unlock('not the password'), isFalse);
    expect(await deviceKey.locked, isTrue);
    expect(await deviceKey.unlock(password), isTrue);
    expect([for (final vault in await vaults.list()) vault['name']], ['Home']);
  });

  test('is locked once the browser empties the session storage', () async {
    await deviceKey.setPassword(password);

    final restarted = DeviceKey(local, MemoryStore());

    expect(await restarted.locked, isTrue);
    await expectLater(restarted.read(), throwsLocked);
  });

  test('changes the lock password, once given the current one', () async {
    final key = await deviceKey.read();
    await deviceKey.setPassword(password);

    expect(
      await deviceKey.changePassword('not the password', 'another password'),
      isFalse,
    );
    expect(
      await deviceKey.changePassword(password, 'another password'),
      isTrue,
    );

    await deviceKey.lock();
    expect(await deviceKey.unlock(password), isFalse);
    expect(await deviceKey.unlock('another password'), isTrue);
    expect((await deviceKey.read()).bytes, key.bytes);
  });

  test('removes the lock password, once given the current one', () async {
    await vaults.add(key: privateKey, name: 'Home', color: 1);
    final key = await deviceKey.read();
    await deviceKey.setPassword(password);

    expect(await deviceKey.removePassword('not the password'), isFalse);
    expect(await deviceKey.hasPassword, isTrue);
    expect(await deviceKey.removePassword(password), isTrue);

    expect(await deviceKey.hasPassword, isFalse);
    final restarted = DeviceKey(local, MemoryStore());
    expect(await restarted.locked, isFalse);
    expect((await restarted.read()).bytes, key.bytes);
    expect(await Vaults(local, signers, restarted).list(), hasLength(1));
  });

  test('forgets the key and the vaults, for a forgotten password', () async {
    await vaults.add(key: privateKey, name: 'Home', color: 1);
    final key = await deviceKey.read();
    await deviceKey.setPassword(password);
    await deviceKey.lock();

    await vaults.forget();
    await deviceKey.forget();

    expect(await deviceKey.hasPassword, isFalse);
    expect(await deviceKey.locked, isFalse);
    expect(await vaults.list(), isEmpty);
    expect((await deviceKey.read()).bytes, isNot(key.bytes));
  });

  test('removes a key left in clear next to a lock password', () async {
    final key = await deviceKey.read();
    await deviceKey.setPassword(password);
    local.values['deviceKey'] = 'left by a password set halfway';

    expect((await deviceKey.read()).bytes, key.bytes);
    expect(local.values, isNot(contains('deviceKey')));
  });
}
