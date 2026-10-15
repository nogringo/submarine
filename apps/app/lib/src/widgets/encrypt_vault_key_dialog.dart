import 'package:flutter/material.dart';
import 'package:nostr_passwords/nostr_passwords.dart';

import '../context.dart';
import '../theme/theme.dart';
import 'copy_button.dart';
import 'dialog_buttons.dart';
import 'password_field.dart';
import 'selectable_area.dart';

/// Encrypts a vault key with a password the user picks, then shows the
/// ncryptsec, which can be kept anywhere since only that password opens it.
class EncryptVaultKeyDialog extends StatefulWidget {
  const EncryptVaultKeyDialog({
    super.key,
    required this.privateKey,
    required this.title,
    this.dismissLabel,
  });

  /// In hex.
  final String privateKey;
  final String title;

  /// Labels the button closing the dialog unencrypted, Cancel by default.
  final String? dismissLabel;

  @override
  State<EncryptVaultKeyDialog> createState() => _EncryptVaultKeyDialogState();
}

class _EncryptVaultKeyDialogState extends State<EncryptVaultKeyDialog> {
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  var _hidden = true;
  var _encrypting = false;
  String? _passwordError;
  String? _confirmationError;
  String? _ncryptsec;

  @override
  void dispose() {
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  void _generate() => setState(() {
    _password.text = _confirmation.text = generatePassphrase();
    _hidden = false;
    _passwordError = _confirmationError = null;
  });

  Future<void> _encrypt() async {
    if (_encrypting) return;
    final l10n = context.l10n;
    final password = _password.text;
    setState(() {
      _passwordError = password.length < minVaultKeyPasswordLength
          ? l10n.passwordMinLength(minVaultKeyPasswordLength)
          : null;
      _confirmationError =
          _passwordError == null && _confirmation.text != password
          ? l10n.passwordMismatch
          : null;
    });
    if (_passwordError != null || _confirmationError != null) return;
    setState(() => _encrypting = true);
    try {
      final ncryptsec = await encryptVaultKey(widget.privateKey, password);
      if (mounted) setState(() => _ncryptsec = ncryptsec);
    } finally {
      if (mounted) setState(() => _encrypting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final ncryptsec = _ncryptsec;
    return PopScope(
      canPop: !_encrypting,
      child: Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.title,
                  style: Theme.of(context).dialogTheme.titleTextStyle,
                ),
                const SizedBox(height: 12),
                Text(
                  ncryptsec == null
                      ? l10n.encryptVaultKeyBody
                      : l10n.encryptedVaultKeyBody,
                  style: TextStyle(color: palette.muted),
                ),
                const SizedBox(height: 20),
                if (ncryptsec == null)
                  ..._passwordFields()
                else
                  _EncryptedKeyBox(ncryptsec: ncryptsec),
                const SizedBox(height: 24),
                DialogButtons(
                  children: [
                    if (ncryptsec != null)
                      FilledButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(l10n.done),
                      )
                    else ...[
                      TextButton(
                        onPressed: _encrypting
                            ? null
                            : () => Navigator.pop(context),
                        child: Text(widget.dismissLabel ?? l10n.cancel),
                      ),
                      FilledButton(
                        onPressed: _encrypting ? null : _encrypt,
                        child: _encrypting
                            ? SizedBox.square(
                                dimension: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: palette.muted,
                                ),
                              )
                            : Text(l10n.encryptKey),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _passwordFields() {
    final l10n = context.l10n;
    return [
      PasswordField(
        controller: _password,
        label: l10n.vaultKeyPassword,
        hidden: _hidden,
        onToggleHidden: () => setState(() => _hidden = !_hidden),
        autofocus: true,
        errorText: _passwordError,
      ),
      const SizedBox(height: 16),
      PasswordField(
        controller: _confirmation,
        label: l10n.confirmPassword,
        hidden: _hidden,
        errorText: _confirmationError,
        helperText: l10n.passwordMinLength(minVaultKeyPasswordLength),
        onSubmitted: (_) => _encrypt(),
      ),
      const SizedBox(height: 8),
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: TextButton.icon(
          onPressed: _encrypting ? null : _generate,
          icon: const Icon(Icons.casino_outlined),
          label: Text(l10n.generatePassphrase),
        ),
      ),
    ];
  }
}

class _EncryptedKeyBox extends StatelessWidget {
  const _EncryptedKeyBox({required this.ncryptsec});

  final String ncryptsec;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 4, 8),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.line),
      ),
      child: Row(
        children: [
          Expanded(
            child: SelectableArea(
              child: Text(
                ncryptsec,
                style: monoStyle.copyWith(fontSize: 13, height: 1.4),
              ),
            ),
          ),
          // Meant to be pasted anywhere, so not dropped from the clipboard.
          CopyButton(value: ncryptsec),
        ],
      ),
    );
  }
}
