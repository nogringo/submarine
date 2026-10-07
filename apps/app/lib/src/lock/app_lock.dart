import 'dart:async';
import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:local_auth/local_auth.dart';
import 'package:nostr_passwords/nostr_passwords.dart';

import '../secure_storage.dart';
import '../vaults/vault_storage.dart';
import '../vaults/vaults.dart';
import 'device_key.dart';

/// When the app locks itself, as Bitwarden's vault timeout offers it.
enum LockTimeout {
  /// As soon as the app leaves the screen.
  immediately(null),
  oneMinute(Duration(minutes: 1)),
  fiveMinutes(Duration(minutes: 5)),
  fifteenMinutes(Duration(minutes: 15)),
  thirtyMinutes(Duration(minutes: 30)),
  oneHour(Duration(hours: 1)),
  fourHours(Duration(hours: 4)),
  onRestart(null);

  const LockTimeout(this.idle);

  /// How long the app may go unused before it locks, if that locks it.
  final Duration? idle;
}

class LockSettings {
  const LockSettings({
    this.enabled = false,
    this.timeout = LockTimeout.fiveMinutes,
  });

  factory LockSettings.fromJson(Map<String, dynamic> json) => LockSettings(
    enabled: json['enabled'] as bool? ?? false,
    timeout:
        LockTimeout.values.asNameMap()[json['timeout']] ??
        LockTimeout.fiveMinutes,
  );

  static const _key = 'lock';

  static Future<LockSettings> read() async {
    final json = await secureStorage.read(key: _key);
    if (json == null) return const LockSettings();
    return LockSettings.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  Future<void> write() =>
      secureStorage.write(key: _key, value: jsonEncode(toJson()));

  /// Whether the device unlocks the app: biometrics, or its code or password.
  final bool enabled;
  final LockTimeout timeout;

  LockSettings copyWith({bool? enabled, LockTimeout? timeout}) => LockSettings(
    enabled: enabled ?? this.enabled,
    timeout: timeout ?? this.timeout,
  );

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'timeout': timeout.name,
  };
}

/// The check of the device itself: biometrics, or its code or password.
class DeviceAuth {
  const DeviceAuth();

  static final _auth = LocalAuthentication();

  /// Whether local_auth runs on this platform, which Linux and the web lack.
  static bool get supportedPlatform =>
      !kIsWeb &&
      switch (defaultTargetPlatform) {
        TargetPlatform.android ||
        TargetPlatform.iOS ||
        TargetPlatform.macOS ||
        TargetPlatform.windows => true,
        _ => false,
      };

  /// Whether this device has a way to check who uses it.
  Future<bool> isAvailable() async {
    if (!supportedPlatform) return false;
    try {
      return await _auth.isDeviceSupported();
    } on PlatformException {
      return false;
    }
  }

  /// Whether the owner of the device is the one using it. Throws a
  /// [LocalAuthException] when the device could not tell.
  Future<bool> authenticate(String reason) => _auth.authenticate(
    localizedReason: reason,
    persistAcrossBackgrounding: true,
  );
}

/// As Bitwarden asks of a master password.
const minLockPasswordLength = 12;

/// Keeps the app behind the lock password or the check of the device once
/// locked, by hand or after a while. Locking closes the vaults, whose keys and
/// items leave the memory and which stop syncing. Unlocking opens them again
/// with the key of the device, which the password protects when there is one.
class AppLock extends ChangeNotifier {
  AppLock._(
    this._settings,
    this._protected,
    this._auth,
    this._keys,
    this._vaults,
  ) : _locked = _settings.enabled || _protected != null;

  /// Locked from the start when the lock is on, [vaults] open otherwise.
  /// Throws a [VaultsUnreadableException] when the key of the device does not
  /// open them.
  static Future<AppLock> load({
    required Vaults vaults,
    DeviceAuth auth = const DeviceAuth(),
    DeviceKeyStorage? keys,
  }) async {
    keys ??= DeviceKeyStorage();
    final settings = await LockSettings.read();
    final protected = await keys.readProtected();
    // Left by a change stopped halfway: next to a password, only biometrics
    // keep the key in clear.
    if (protected != null && !settings.enabled) await keys.delete();
    final lock = AppLock._(settings, protected, auth, keys, vaults);
    if (!lock.locked) await lock._open(await lock._clearKey());
    return lock;
  }

  static AppLock of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppLockScope>()!.notifier!;

  final DeviceAuth _auth;
  final DeviceKeyStorage _keys;
  final Vaults _vaults;
  LockSettings _settings;
  PasswordProtectedKey? _protected;

  /// The key of the device while unlocked, which a new password protects.
  SymmetricCryptoKey? _key;

  /// Whether the app locks at all.
  bool get enabled => biometrics || hasPassword;

  /// Whether the device unlocks the app: biometrics, or its code or password.
  bool get biometrics => _settings.enabled;

  /// Whether the lock password unlocks the app.
  bool get hasPassword => _protected != null;

  LockTimeout get timeout => _settings.timeout;

  bool get locked => _locked;
  bool _locked;

  /// Whether the device is checking who uses it, a password is being checked
  /// or protected, or the vaults are opening.
  bool get checking => _checking;
  var _checking = false;

  var _lastUse = clock.now();
  Timer? _idleTimer;

  Future<bool> isAvailable() => _auth.isAvailable();

  /// Lets the device unlock the app once it checked the user, which proves it
  /// can later. Throws a [LocalAuthException] when the device could not check.
  Future<void> enableBiometrics(String reason) async {
    if (!await _check(() => _auth.authenticate(reason))) return;
    if (hasPassword) await _keys.write(_key!);
    await _save(_settings.copyWith(enabled: true));
    used();
  }

  Future<void> disableBiometrics() async {
    if (!hasPassword) _stopIdleTimer();
    await _save(_settings.copyWith(enabled: false));
    if (hasPassword) await _keys.delete();
  }

  /// Protects the key of the device with [password], which then unlocks the
  /// app. The key stays in clear only for biometrics.
  Future<void> setPassword(String password) => _check(() async {
    final protected = await compute(_protect, (_key!.bytes, password));
    await _keys.writeProtected(protected);
    if (!biometrics) await _keys.delete();
    _protected = protected;
    used();
  });

  /// Whether [current] is the lock password, which [password] then replaces.
  Future<bool> changePassword(String current, String password) =>
      _check(() async {
        if (await _unprotect(current) == null) return false;
        final protected = await compute(_protect, (_key!.bytes, password));
        await _keys.writeProtected(protected);
        _protected = protected;
        return true;
      });

  /// Whether [current] is the lock password, which then no longer locks the
  /// app.
  Future<bool> removePassword(String current) => _check(() async {
    if (await _unprotect(current) == null) return false;
    await _keys.write(_key!);
    await _keys.deleteProtected();
    _protected = null;
    if (!enabled) _stopIdleTimer();
    return true;
  });

  Future<void> setTimeout(LockTimeout timeout) async {
    _stopIdleTimer();
    await _save(_settings.copyWith(timeout: timeout));
    used();
  }

  void lock() {
    if (!enabled || _locked) return;
    _stopIdleTimer();
    _locked = true;
    _key = null;
    _vaults.close();
    notifyListeners();
  }

  /// Asks the device to check the user, and opens the vaults if it is them.
  /// Throws a [LocalAuthException] the user should hear about, and a
  /// [VaultsUnreadableException] when the key of the device does not open the
  /// vaults.
  Future<void> unlock(String reason) async {
    if (!_locked || _checking) return;
    try {
      await _check(() async {
        if (await _auth.authenticate(reason)) await _open(await _clearKey());
      });
    } on LocalAuthException catch (error) {
      switch (error.code) {
        case LocalAuthExceptionCode.userCanceled ||
            LocalAuthExceptionCode.systemCanceled ||
            LocalAuthExceptionCode.timeout ||
            LocalAuthExceptionCode.authInProgress ||
            LocalAuthExceptionCode.userRequestedFallback:
          return;
        case LocalAuthExceptionCode.noCredentialsSet ||
            LocalAuthExceptionCode.noBiometricsEnrolled ||
            LocalAuthExceptionCode.noBiometricHardware:
          // A device that no longer checks anyone would lock its owner out
          // for good, while holding it is all a lock could check. A password
          // still lets them in.
          if (!hasPassword && !await _auth.isAvailable()) {
            return _check(() async => _open(await _clearKey()));
          }
          rethrow;
        default:
          rethrow;
      }
    }
  }

  /// Whether [password] is the lock password, which then opens the vaults.
  /// Throws a [VaultsUnreadableException] when the key it opens does not open
  /// them.
  Future<bool> unlockWithPassword(String password) async {
    if (!_locked || _checking) return !_locked;
    return _check(() async {
      final key = await _unprotect(password);
      if (key == null) return false;
      await _open(key);
      return true;
    });
  }

  /// Removes every vault from this device, for a forgotten password, and
  /// leaves it unlocked without a lock, under a new key.
  Future<void> forget() => _check(() async {
    await _vaults.forget();
    await _keys.deleteProtected();
    await _keys.delete();
    _protected = null;
    await _save(_settings.copyWith(enabled: false));
    await _open(await _keys.create());
  });

  /// Counts as a use of the app, which restarts the wait before it locks.
  void used() {
    _lastUse = clock.now();
    final idle = timeout.idle;
    if (!enabled || _locked || idle == null || _idleTimer != null) return;
    _idleTimer = Timer(idle, _checkIdle);
  }

  /// The app left the screen.
  void hidden() {
    if (timeout == LockTimeout.immediately) lock();
  }

  /// The app is back on screen, where the idle timer may have been frozen
  /// while it was away.
  void shown() {
    final idle = timeout.idle;
    if (idle != null && clock.now().difference(_lastUse) >= idle) lock();
  }

  /// One timer for every use, checking when it ends whether a later use
  /// pushed the lock back.
  void _checkIdle() {
    _idleTimer = null;
    final idle = timeout.idle;
    if (!enabled || _locked || idle == null) return;
    final unused = clock.now().difference(_lastUse);
    if (unused >= idle) return lock();
    _idleTimer = Timer(idle - unused, _checkIdle);
  }

  void _stopIdleTimer() {
    _idleTimer?.cancel();
    _idleTimer = null;
  }

  /// The key kept in clear, which is new while there is none and no password
  /// either.
  Future<SymmetricCryptoKey> _clearKey() async =>
      await _keys.read() ??
      (hasPassword
          ? throw const VaultsUnreadableException()
          : await _keys.create());

  /// The key of the device, if [password] is the lock password.
  Future<SymmetricCryptoKey?> _unprotect(String password) async {
    final bytes = await compute(_openProtected, (_protected!, password));
    return bytes == null ? null : SymmetricCryptoKey(bytes);
  }

  Future<void> _open(SymmetricCryptoKey key) async {
    await _vaults.open(key);
    _key = key;
    _locked = false;
    used();
    notifyListeners();
  }

  Future<T> _check<T>(Future<T> Function() check) async {
    _checking = true;
    notifyListeners();
    try {
      return await check();
    } finally {
      _checking = false;
      notifyListeners();
    }
  }

  Future<void> _save(LockSettings settings) async {
    await settings.write();
    _settings = settings;
    notifyListeners();
  }

  @override
  void dispose() {
    _stopIdleTimer();
    super.dispose();
  }
}

/// On an isolate of its own where there is one, as Argon2id takes a moment.
Future<PasswordProtectedKey> _protect((Uint8List, String) key) {
  final (bytes, password) = key;
  return PasswordProtectedKey.protect(SymmetricCryptoKey(bytes), password);
}

Future<Uint8List?> _openProtected((PasswordProtectedKey, String) key) async {
  final (protected, password) = key;
  return (await protected.open(password))?.bytes;
}

class AppLockScope extends InheritedNotifier<AppLock> {
  const AppLockScope({super.key, required AppLock lock, required super.child})
    : super(notifier: lock);
}
