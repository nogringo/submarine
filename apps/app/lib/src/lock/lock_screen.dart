import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

import '../context.dart';
import '../theme/theme.dart';
import '../vaults/vault_storage.dart';
import '../widgets/sonar.dart';
import 'app_lock.dart';

/// [child] while unlocked, the lock screen otherwise. [child] keeps its state
/// underneath, out of sight and out of focus, so that unlocking finds the app
/// as it was left. Every pointer or key counts as a use of the app.
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
    widget.lock.used();
    return false;
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
            if (locked) LockScreen(lock: widget.lock),
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
  String? _error;

  Future<void> _unlock() async {
    final l10n = context.l10n;
    setState(() => _error = null);
    try {
      await widget.lock.unlock(l10n.unlockReason);
    } on LocalAuthException catch (error) {
      if (mounted) setState(() => _error = authErrorMessage(l10n, error));
    } on PlatformException {
      if (mounted) setState(() => _error = l10n.storageReadFailed);
    } on VaultsUnreadableException {
      if (mounted) setState(() => _error = l10n.storageReadFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final error = _error;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Column(
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
                  ListenableBuilder(
                    listenable: widget.lock,
                    builder: (context, _) => FilledButton.icon(
                      autofocus: true,
                      onPressed: widget.lock.checking ? null : _unlock,
                      icon: const Icon(Icons.lock_open_rounded),
                      label: Text(l10n.unlock),
                    ),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      error,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: palette.danger),
                    ),
                  ],
                ],
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
