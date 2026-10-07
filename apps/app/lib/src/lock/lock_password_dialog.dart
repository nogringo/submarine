import 'package:flutter/material.dart';
import 'package:nostr_passwords/nostr_passwords.dart';

import '../context.dart';
import '../widgets/dialog_buttons.dart';
import '../widgets/password_field.dart';
import 'app_lock.dart';

enum LockPasswordChange { set, change, remove }

/// Sets, changes or removes the lock password, asking for the current one
/// before changing or removing it.
class LockPasswordDialog extends StatefulWidget {
  const LockPasswordDialog({super.key, required this.change});

  final LockPasswordChange change;

  @override
  State<LockPasswordDialog> createState() => _LockPasswordDialogState();
}

class _LockPasswordDialogState extends State<LockPasswordDialog> {
  final _current = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  var _hidden = true;
  String? _currentError;
  String? _passwordError;
  String? _confirmationError;

  bool get _asksCurrent => widget.change != LockPasswordChange.set;
  bool get _asksNew => widget.change != LockPasswordChange.remove;

  @override
  void dispose() {
    _current.dispose();
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  void _generate() => setState(() {
    _password.text = _confirmation.text = generatePassphrase();
    _hidden = false;
    _passwordError = _confirmationError = null;
  });

  Future<void> _submit() async {
    final lock = AppLock.of(context);
    if (lock.checking) return;
    final l10n = context.l10n;
    final password = _password.text;
    setState(() {
      _currentError = null;
      _passwordError = _asksNew && password.length < minLockPasswordLength
          ? l10n.lockPasswordTooShort(minLockPasswordLength)
          : null;
      _confirmationError =
          _asksNew && _passwordError == null && _confirmation.text != password
          ? l10n.lockPasswordMismatch
          : null;
    });
    if (_passwordError != null || _confirmationError != null) return;
    final done = switch (widget.change) {
      LockPasswordChange.set =>
        await lock.setPassword(password).then((_) => true),
      LockPasswordChange.change => await lock.changePassword(
        _current.text,
        password,
      ),
      LockPasswordChange.remove => await lock.removePassword(_current.text),
    };
    if (!mounted) return;
    if (done) return Navigator.pop(context);
    setState(() => _currentError = l10n.wrongLockPassword);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final colors = Theme.of(context).colorScheme;
    final checking = AppLock.of(context).checking;
    final remove = widget.change == LockPasswordChange.remove;
    void toggleHidden() => setState(() => _hidden = !_hidden);
    const gap = SizedBox(height: 16);
    return PopScope(
      canPop: !checking,
      child: Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(switch (widget.change) {
                  LockPasswordChange.set => l10n.setLockPasswordTitle,
                  LockPasswordChange.change => l10n.changeLockPasswordTitle,
                  LockPasswordChange.remove => l10n.removeLockPasswordTitle,
                }, style: Theme.of(context).dialogTheme.titleTextStyle),
                if (remove) ...[
                  const SizedBox(height: 12),
                  Text(
                    l10n.removeLockPasswordBody,
                    style: TextStyle(color: palette.muted),
                  ),
                ],
                const SizedBox(height: 20),
                if (_asksCurrent) ...[
                  PasswordField(
                    controller: _current,
                    label: l10n.currentLockPassword,
                    hidden: _hidden,
                    onToggleHidden: toggleHidden,
                    autofocus: true,
                    errorText: _currentError,
                    onSubmitted: (_) => _submit(),
                  ),
                  if (_asksNew) gap,
                ],
                if (_asksNew) ...[
                  PasswordField(
                    controller: _password,
                    label: _asksCurrent
                        ? l10n.newLockPassword
                        : l10n.lockPassword,
                    hidden: _hidden,
                    onToggleHidden: toggleHidden,
                    autofocus: !_asksCurrent,
                    errorText: _passwordError,
                  ),
                  gap,
                  PasswordField(
                    controller: _confirmation,
                    label: l10n.confirmLockPassword,
                    hidden: _hidden,
                    errorText: _confirmationError,
                    helperText: l10n.lockPasswordHelper(minLockPasswordLength),
                    onSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TextButton.icon(
                      onPressed: checking ? null : _generate,
                      icon: const Icon(Icons.casino_outlined),
                      label: Text(l10n.generatePassphrase),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                DialogButtons(
                  children: [
                    TextButton(
                      onPressed: checking ? null : () => Navigator.pop(context),
                      child: Text(l10n.cancel),
                    ),
                    FilledButton(
                      onPressed: checking ? null : _submit,
                      style: remove
                          ? FilledButton.styleFrom(
                              backgroundColor: colors.error,
                              foregroundColor: colors.onError,
                            )
                          : null,
                      child: checking
                          ? SizedBox.square(
                              dimension: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: palette.muted,
                              ),
                            )
                          : Text(remove ? l10n.removeLockPassword : l10n.save),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
