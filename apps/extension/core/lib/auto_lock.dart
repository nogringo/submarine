import 'device_key.dart';
import 'vaults.dart';

/// When the vaults lock themselves once a lock password protects them, as the
/// app offers it.
enum LockTimeout {
  /// As soon as the last popup closes.
  immediately(null),
  oneMinute(Duration(minutes: 1)),
  fiveMinutes(Duration(minutes: 5)),
  fifteenMinutes(Duration(minutes: 15)),
  thirtyMinutes(Duration(minutes: 30)),
  oneHour(Duration(hours: 1)),
  fourHours(Duration(hours: 4)),

  /// Once the browser closes, which empties the session storage.
  onRestart(null);

  const LockTimeout(this.idle);

  /// How long the vaults may go unused before they lock, if that locks them.
  final Duration? idle;
}

/// Wakes the background at a given time, through the browser's alarms.
abstract interface class LockAlarm {
  void schedule(DateTime when);
  void cancel();
}

/// Tells when the vaults went unused for the timeout chosen. Their last use
/// stays in the session storage, as the background stops and starts again.
class AutoLock {
  AutoLock(
    this._deviceKey,
    this._local,
    this._session,
    this._alarm, {
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final DeviceKey _deviceKey;
  final KeyValueStore _local;
  final KeyValueStore _session;
  final LockAlarm _alarm;
  final DateTime Function() _now;

  static const _timeoutKey = 'lockTimeout';
  static const _lastUseKey = 'lastUse';

  Future<LockTimeout> timeout() async =>
      LockTimeout.values.asNameMap()[await _local.read(_timeoutKey)] ??
      LockTimeout.fiveMinutes;

  Future<void> setTimeout(LockTimeout timeout) async {
    await _local.write(_timeoutKey, timeout.name);
    await used();
  }

  /// Counts as a use of the vaults, which pushes their lock back.
  Future<void> used() async {
    if (!await _deviceKey.hasPassword || await _deviceKey.locked) return;
    final now = _now();
    await _session.write(_lastUseKey, '${now.millisecondsSinceEpoch}');
    switch ((await timeout()).idle) {
      case final idle?:
        _alarm.schedule(now.add(idle));
      case null:
        _alarm.cancel();
    }
  }

  /// Whether the vaults, unlocked, went unused for the timeout.
  Future<bool> expired() async {
    if (!await _deviceKey.hasPassword || await _deviceKey.locked) return false;
    final idle = (await timeout()).idle;
    final lastUse = int.tryParse(await _session.read(_lastUseKey) ?? '');
    if (idle == null || lastUse == null) return false;
    final unused = _now().difference(
      DateTime.fromMillisecondsSinceEpoch(lastUse),
    );
    return unused >= idle;
  }

  /// Whether the last popup closing locks the vaults.
  Future<bool> locksOnClose() async =>
      await _deviceKey.hasPassword &&
      await timeout() == LockTimeout.immediately;

  void cancel() => _alarm.cancel();
}
