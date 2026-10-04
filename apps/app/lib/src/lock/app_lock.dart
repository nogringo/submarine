import 'dart:async';
import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:local_auth/local_auth.dart';

import '../secure_storage.dart';

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

/// Keeps the app behind the check of the device once locked, by hand or after
/// a while. Nothing gets encrypted further: the vault keys stay in the secure
/// storage of the device, and the vaults keep syncing.
class AppLock extends ChangeNotifier {
  AppLock._(this._settings, this._auth) : _locked = _settings.enabled;

  /// Locked from the start when the lock is on.
  static Future<AppLock> load({DeviceAuth auth = const DeviceAuth()}) async =>
      AppLock._(await LockSettings.read(), auth);

  static AppLock of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppLockScope>()!.notifier!;

  final DeviceAuth _auth;
  LockSettings _settings;

  bool get enabled => _settings.enabled;
  LockTimeout get timeout => _settings.timeout;

  bool get locked => _locked;
  bool _locked;

  /// Whether the device is checking who uses it.
  bool get checking => _checking;
  var _checking = false;

  var _lastUse = clock.now();
  Timer? _idleTimer;

  Future<bool> isAvailable() => _auth.isAvailable();

  /// Turns the lock on once the device checked the user, which proves it can
  /// unlock the app later. Throws a [LocalAuthException] when the device could
  /// not check.
  Future<void> enable(String reason) async {
    if (!await _check(() => _auth.authenticate(reason))) return;
    await _save(_settings.copyWith(enabled: true));
    used();
  }

  Future<void> disable() async {
    _stopIdleTimer();
    await _save(_settings.copyWith(enabled: false));
  }

  Future<void> setTimeout(LockTimeout timeout) async {
    _stopIdleTimer();
    await _save(_settings.copyWith(timeout: timeout));
    used();
  }

  void lock() {
    if (!enabled || _locked) return;
    _stopIdleTimer();
    _locked = true;
    notifyListeners();
  }

  /// Asks the device to check the user, and unlocks if it is them. Throws a
  /// [LocalAuthException] the user should hear about.
  Future<void> unlock(String reason) async {
    if (!_locked || _checking) return;
    try {
      if (await _check(() => _auth.authenticate(reason))) _open();
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
          // for good, while holding it is all a lock could check.
          if (!await _auth.isAvailable()) return _open();
          rethrow;
        default:
          rethrow;
      }
    }
  }

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

  void _open() {
    _locked = false;
    used();
    notifyListeners();
  }

  Future<bool> _check(Future<bool> Function() authenticate) async {
    _checking = true;
    notifyListeners();
    try {
      return await authenticate();
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

class AppLockScope extends InheritedNotifier<AppLock> {
  const AppLockScope({super.key, required AppLock lock, required super.child})
    : super(notifier: lock);
}
