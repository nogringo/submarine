import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

import '../command_shortcut.dart';
import '../context.dart';
import '../theme/theme.dart';
import '../vaults/vault_storage.dart';
import '../widgets/password_field.dart';
import '../widgets/sonar.dart';
import '../widgets/spoken_status.dart';
import 'app_lock.dart';

const lockShortcut = CommandShortcut(LogicalKeyboardKey.keyL);

/// [child] while unlocked, the lock screen otherwise. [child] keeps its state
/// underneath, out of sight and out of focus, so that unlocking finds the app
/// as it was left. Every pointer or key counts as a use of the app, and
/// [lockShortcut] locks it from anywhere.
class LockGate extends StatefulWidget {
  const LockGate({super.key, required this.lock, required this.child});

  final AppLock lock;
  final Widget child;

  @override
  State<LockGate> createState() => _LockGateState();
}

class _LockGateState extends State<LockGate> {
  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_onKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    super.dispose();
  }

  bool _onKey(KeyEvent event) {
    final lock = widget.lock;
    lock.used();
    if (!lock.enabled || lock.locked || !lockShortcut.accepts(event)) {
      return false;
    }
    lock.lock();
    return true;
  }

  void _onPointer(PointerEvent event) => widget.lock.used();

  @override
  Widget build(BuildContext context) => Listener(
    behavior: HitTestBehavior.translucent,
    onPointerDown: _onPointer,
    onPointerMove: _onPointer,
    onPointerHover: _onPointer,
    onPointerSignal: _onPointer,
    child: ListenableBuilder(
      listenable: widget.lock,
      builder: (context, child) {
        final locked = widget.lock.locked;
        return Stack(
          fit: StackFit.expand,
          children: [
            Visibility(
              visible: !locked,
              maintainState: true,
              child: ExcludeFocus(excluding: locked, child: child!),
            ),
            // Its own navigator, for its dialog and the overlay of its field:
            // the app's lies underneath.
            if (locked)
              Navigator(
                pages: [MaterialPage(child: LockScreen(lock: widget.lock))],
                onDidRemovePage: (_) {},
              ),
          ],
        );
      },
      child: widget.child,
    ),
  );
}

class LockScreen extends StatefulWidget {
  const LockScreen({super.key, required this.lock});

  final AppLock lock;

  @override
  State<LockScreen> createState() => _LockScreenState();
}

/// Asks the device only when the user says so: a window focused back by
/// accident must not raise the system prompt.
class _LockScreenState extends State<LockScreen> {
  final _password = TextEditingController();
  var _hidden = true;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  /// Runs [unlock], which tells what the user should hear if it did not
  /// unlock.
  Future<void> _try(
    Future<String?> Function(AppLocalizations l10n) unlock,
  ) async {
    final l10n = context.l10n;
    setState(() => _error = null);
    String? error;
    try {
      error = await unlock(l10n);
    } on LocalAuthException catch (exception) {
      error = authErrorMessage(l10n, exception);
    } on PlatformException {
      error = l10n.storageReadFailed;
    } on VaultsUnreadableException {
      error = l10n.storageReadFailed;
    }
    if (mounted) setState(() => _error = error);
  }

  Future<void> _unlockWithDevice() => _try((l10n) async {
    await widget.lock.unlock(l10n.unlockReason);
    return null;
  });

  Future<void> _unlockWithPassword() => _try((l10n) async {
    if (_password.text.isEmpty) return null;
    return await widget.lock.unlockWithPassword(_password.text)
        ? null
        : l10n.wrongLockPassword;
  });

  Future<void> _forget() async {
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;
    final forget = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.forgetVaultsTitle),
        content: Text(l10n.forgetVaultsBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: colors.error,
              foregroundColor: colors.onError,
            ),
            child: Text(l10n.forgetVaults),
          ),
        ],
      ),
    );
    if (forget ?? false) await widget.lock.forget();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final lock = widget.lock;
    final error = _error;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: ListenableBuilder(
                listenable: lock,
                builder: (context, _) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: Sonar(size: 180)),
                    const SizedBox(height: 32),
                    Text(
                      'SUBMARINE',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: wordmarkFont,
                        fontSize: 40,
                        letterSpacing: 3,
                        color: palette.text,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.vaultsLocked,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: palette.muted),
                    ),
                    const SizedBox(height: 40),
                    if (lock.hasPassword) ...[
                      PasswordField(
                        controller: _password,
                        label: l10n.lockPassword,
                        hidden: _hidden,
                        onToggleHidden: () =>
                            setState(() => _hidden = !_hidden),
                        autofocus: !lock.biometrics,
                        onSubmitted: (_) => _unlockWithPassword(),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: lock.checking ? null : _unlockWithPassword,
                        icon: const Icon(Icons.lock_open_rounded),
                        label: Text(l10n.unlock),
                      ),
                      if (lock.biometrics) ...[
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          autofocus: true,
                          onPressed: lock.checking ? null : _unlockWithDevice,
                          icon: const Icon(Icons.fingerprint_rounded),
                          label: Text(l10n.unlockWithBiometrics),
                        ),
                      ],
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: lock.checking ? null : _forget,
                        child: Text(l10n.forgotLockPassword),
                      ),
                    ] else
                      FilledButton.icon(
                        autofocus: true,
                        onPressed: lock.checking ? null : _unlockWithDevice,
                        icon: const Icon(Icons.lock_open_rounded),
                        label: Text(l10n.unlock),
                      ),
                    if (error != null) ...[
                      const SizedBox(height: 16),
                      SpokenStatus(
                        message: error,
                        child: Text(
                          error,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: palette.danger),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// What to tell the user when the device could not check them, if anything.
String? authErrorMessage(AppLocalizations l10n, LocalAuthException error) =>
    switch (error.code) {
      LocalAuthExceptionCode.userCanceled ||
      LocalAuthExceptionCode.systemCanceled ||
      LocalAuthExceptionCode.timeout ||
      LocalAuthExceptionCode.authInProgress ||
      LocalAuthExceptionCode.userRequestedFallback => null,
      LocalAuthExceptionCode.noCredentialsSet ||
      LocalAuthExceptionCode.noBiometricsEnrolled ||
      LocalAuthExceptionCode.noBiometricHardware => l10n.lockNeedsScreenLock,
      LocalAuthExceptionCode.temporaryLockout ||
      LocalAuthExceptionCode.biometricLockout => l10n.authLockedOut,
      _ => l10n.authFailed,
    };
