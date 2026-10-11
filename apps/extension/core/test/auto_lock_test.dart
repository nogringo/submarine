import 'package:submarine_extension_core/auto_lock.dart';
import 'package:submarine_extension_core/device_key.dart';
import 'package:test/test.dart';

import 'memory_store.dart';

const password = 'correct horse battery';

class FakeAlarm implements LockAlarm {
  DateTime? scheduled;

  @override
  void schedule(DateTime when) => scheduled = when;

  @override
  void cancel() => scheduled = null;
}

void main() {
  late MemoryStore local;
  late MemoryStore session;
  late DeviceKey deviceKey;
  late FakeAlarm alarm;
  late DateTime now;
  late AutoLock autoLock;

  setUp(() {
    local = MemoryStore();
    session = MemoryStore();
    deviceKey = DeviceKey(local, session);
    alarm = FakeAlarm();
    now = DateTime.utc(2026, 10, 12, 9);
    autoLock = AutoLock(deviceKey, local, session, alarm, now: () => now);
  });

  test('waits 5 minutes by default, as the app does', () async {
    expect(await autoLock.timeout(), LockTimeout.fiveMinutes);
    await autoLock.setTimeout(LockTimeout.oneHour);
    expect(
      await AutoLock(deviceKey, local, session, alarm).timeout(),
      LockTimeout.oneHour,
    );
  });

  test('locks nothing without a lock password', () async {
    await autoLock.used();
    now = now.add(const Duration(hours: 5));

    expect(alarm.scheduled, isNull);
    expect(await autoLock.expired(), isFalse);
    expect(await autoLock.locksOnClose(), isFalse);
  });

  test('expires once unused for the timeout, a use pushing it back', () async {
    await deviceKey.setPassword(password);
    await autoLock.used();
    expect(alarm.scheduled, now.add(const Duration(minutes: 5)));

    now = now.add(const Duration(minutes: 4));
    expect(await autoLock.expired(), isFalse);
    await autoLock.used();
    expect(alarm.scheduled, now.add(const Duration(minutes: 5)));

    now = now.add(const Duration(minutes: 4));
    expect(await autoLock.expired(), isFalse);
    now = now.add(const Duration(minutes: 1));
    expect(await autoLock.expired(), isTrue);
  });

  test('never expires once locked, nor counts a use', () async {
    await deviceKey.setPassword(password);
    await autoLock.used();
    await deviceKey.lock();
    alarm.cancel();
    now = now.add(const Duration(hours: 1));

    expect(await autoLock.expired(), isFalse);
    await autoLock.used();
    expect(alarm.scheduled, isNull);
  });

  test('waits for no alarm to lock immediately or on restart', () async {
    await deviceKey.setPassword(password);
    await autoLock.used();

    await autoLock.setTimeout(LockTimeout.immediately);
    expect(alarm.scheduled, isNull);
    expect(await autoLock.locksOnClose(), isTrue);

    await autoLock.setTimeout(LockTimeout.onRestart);
    now = now.add(const Duration(days: 3));
    expect(await autoLock.expired(), isFalse);
    expect(await autoLock.locksOnClose(), isFalse);
  });
}
