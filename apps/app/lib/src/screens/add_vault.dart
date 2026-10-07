import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ndk/ndk.dart' show Ndk, Nip19, NostrConnect;
import 'package:nostr_passwords/nostr_passwords.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:url_launcher/url_launcher.dart';

import '../context.dart';
import '../router.dart';
import '../theme/theme.dart';
import '../vaults/vault_controller.dart';
import '../vaults/vault_logins.dart';
import '../vaults/vault_storage.dart';
import '../vaults/vaults.dart';
import '../widgets/copy_button.dart';
import '../widgets/vault_color_picker.dart';
import '../widgets/vault_key_box.dart';

enum AddVaultChoice { create, open }

/// Asks whether to create a vault or to open one, then adds it.
Future<void> addVault(BuildContext context) async {
  final choice = await showDialog<AddVaultChoice>(
    context: context,
    builder: (context) => const _ChoiceDialog(),
  );
  if (choice != null && context.mounted) await addVaultWith(context, choice);
}

/// Adds a vault, shows the key of a vault just created, then goes to it.
Future<void> addVaultWith(BuildContext context, AddVaultChoice choice) async {
  final vault = await showDialog<VaultController>(
    context: context,
    builder: (context) => _VaultFormDialog(choice: choice),
  );
  if (vault == null || !context.mounted) return;
  if (choice == AddVaultChoice.create) {
    if (vault.record.login case KeyLogin(:final privateKey)) {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => _VaultKeyDialog(privateKey: privateKey),
      );
    }
  }
  if (context.mounted) context.go(vaultPath(vault.pubkey));
}

class _ChoiceDialog extends StatelessWidget {
  const _ChoiceDialog();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                child: Text(
                  l10n.addVault,
                  style: Theme.of(context).dialogTheme.titleTextStyle,
                ),
              ),
              _ChoiceTile(
                icon: Icons.add_rounded,
                title: l10n.createVault,
                description: l10n.createVaultDescription,
                onTap: () => Navigator.pop(context, AddVaultChoice.create),
              ),
              _ChoiceTile(
                icon: Icons.key_rounded,
                title: l10n.openVault,
                description: l10n.openVaultDescription,
                onTap: () => Navigator.pop(context, AddVaultChoice.open),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: palette.muted),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(fontSize: 13, color: palette.muted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Runs in an isolate where there is one: scrypt would freeze the dialog.
Future<String?> _decryptVaultKey((String, String) key) =>
    decryptVaultKey(key.$1, key.$2);

IconData _signerIcon(SignerLogin login) => switch (login) {
  ExtensionLogin() => Icons.extension_outlined,
  BunkerLogin() => Icons.dns_outlined,
  SignerAppLogin() => Icons.phone_android_rounded,
};

class _VaultFormDialog extends StatefulWidget {
  const _VaultFormDialog({required this.choice});

  final AddVaultChoice choice;

  @override
  State<_VaultFormDialog> createState() => _VaultFormDialogState();
}

class _VaultFormDialogState extends State<_VaultFormDialog> {
  final _key = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  Color? _color;
  var _keyHidden = true;
  var _passwordHidden = true;
  var _signersShown = false;
  var _busy = false;

  /// What the dialog waits for while [_busy].
  String? _status;

  /// Given by a signer, in place of a key.
  SignerLogin? _signer;
  String? _authUrl;
  String? _keyError;
  String? _passwordError;
  String? _signerError;
  String? _nameError;
  String? _saveError;

  bool get _opening => widget.choice == AddVaultChoice.open;

  bool get _encrypted => isEncryptedVaultKey(_key.text);

  @override
  void dispose() {
    _key.dispose();
    _password.dispose();
    _name.dispose();
    super.dispose();
  }

  Color _defaultColor(Vaults vaults) =>
      vaultColors[vaults.all.length % vaultColors.length];

  void _showAuthUrl(String url) {
    if (mounted) setState(() => _authUrl = url);
  }

  Future<void> _submit() async {
    if (_busy) return;
    final l10n = context.l10n;
    final vaults = Vaults.of(context);
    final text = _key.text;
    final privateKey = parseVaultKey(text);
    final keyLike = privateKey != null || _encrypted || isBunkerUrl(text);
    final name = _name.text.trim();
    setState(() {
      _keyError = _opening && _signer == null && !keyLike
          ? l10n.vaultKeyInvalid
          : null;
      _passwordError = null;
      _signerError = null;
      _nameError = name.isEmpty ? l10n.vaultNameRequired : null;
      _saveError = null;
    });
    if (_keyError != null || _nameError != null) return;

    setState(() => _busy = true);
    try {
      final login = !_opening
          ? KeyLogin(vaults.newKey())
          : _signer ??
                (privateKey != null
                    ? KeyLogin(privateKey)
                    : await _openKey(text, vaults.ndk));
      if (login == null || !mounted) return;
      if (vaults.byPubkey(vaults.pubkeyOf(login)) case final existing?) {
        final error = l10n.vaultAlreadyOpen(existing.name);
        setState(() {
          if (_signer == null) {
            _keyError = error;
          } else {
            _signerError = error;
          }
        });
        return;
      }
      final vault = await vaults.add(
        VaultRecord(
          login: login,
          name: name,
          color: _color ?? _defaultColor(vaults),
        ),
      );
      if (mounted) Navigator.pop(context, vault);
    } catch (_) {
      if (mounted) setState(() => _saveError = l10n.vaultSaveFailed);
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _status = null;
        });
      }
    }
  }

  /// Decrypts or connects what the key field holds, or shows why it cannot.
  Future<VaultLogin?> _openKey(String text, Ndk ndk) async {
    final l10n = context.l10n;
    if (_encrypted) {
      setState(() => _status = l10n.vaultKeyDecrypting);
      final privateKey = await compute(_decryptVaultKey, (
        text,
        _password.text,
      ));
      if (privateKey == null && mounted) {
        setState(() => _passwordError = l10n.vaultKeyPasswordWrong);
      }
      return privateKey == null ? null : KeyLogin(privateKey);
    }
    setState(() => _status = l10n.waitingForAnswer);
    String? error;
    try {
      final login = await loginWithBunker(ndk, text, onAuthUrl: _showAuthUrl);
      if (login != null) return login;
      error = l10n.bunkerNoAnswer;
    } on ArgumentError {
      error = l10n.bunkerUrlInvalid;
    } on FormatException {
      error = l10n.bunkerUrlInvalid;
    } catch (_) {
      error = l10n.bunkerNoAnswer;
    }
    if (mounted) setState(() => _keyError = error);
    return null;
  }

  /// [missing] says that this device has no such signer.
  Future<void> _connectSigner(
    Future<SignerLogin?> Function() connect,
    String missing,
  ) async {
    if (_busy) return;
    final l10n = context.l10n;
    setState(() {
      _busy = true;
      _status = l10n.waitingForAnswer;
      _signerError = null;
    });
    String? error;
    SignerLogin? login;
    try {
      login = await connect();
      if (login == null) error = l10n.signerRefused;
    } on NoSignerException {
      error = missing;
    } catch (_) {
      error = l10n.signerRefused;
    }
    if (!mounted) return;
    setState(() {
      _busy = false;
      _status = null;
      _signer = login;
      _signerError = error;
    });
  }

  Future<void> _nostrConnect() async {
    final login = await showDialog<BunkerLogin>(
      context: context,
      builder: (context) => _NostrConnectDialog(ndk: Vaults.of(context).ndk),
    );
    if (login != null && mounted) {
      setState(() {
        _signer = login;
        _signerError = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final color = _color ?? _defaultColor(Vaults.of(context));
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _opening ? l10n.openVaultTitle : l10n.createVault,
                style: Theme.of(context).dialogTheme.titleTextStyle,
              ),
              const SizedBox(height: 20),
              if (_opening) ...[
                if (_signer case final signer?)
                  _SignerBox(
                    login: signer,
                    onClear: _busy
                        ? null
                        : () => setState(() {
                            _signer = null;
                            _signerError = null;
                          }),
                  )
                else
                  ..._keyFields(),
                if (_signerError case final error?) ...[
                  const SizedBox(height: 8),
                  Text(
                    error,
                    style: TextStyle(fontSize: 13, color: palette.danger),
                  ),
                ],
                if (_authUrl case final url?) _Approval(url: url),
                const SizedBox(height: 16),
              ],
              TextField(
                controller: _name,
                autofocus: !_opening,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  labelText: l10n.vaultName,
                  helperText: l10n.vaultNameHelper,
                  helperMaxLines: 3,
                  errorText: _nameError,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.vaultColor,
                style: TextStyle(fontSize: 13, color: palette.muted),
              ),
              const SizedBox(height: 10),
              VaultColorPicker(
                selected: color,
                onSelected: (color) => setState(() => _color = color),
              ),
              if (_saveError case final error?) ...[
                const SizedBox(height: 16),
                Text(error, style: TextStyle(color: palette.danger)),
              ],
              if (_status case final status? when _busy) ...[
                const SizedBox(height: 16),
                _Waiting(status: status),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.cancel),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _busy ? null : _submit,
                    child: Text(_opening ? l10n.open : l10n.create),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _keyFields() {
    final l10n = context.l10n;
    final palette = context.palette;
    return [
      TextField(
        controller: _key,
        autofocus: true,
        obscureText: _keyHidden,
        autocorrect: false,
        enableSuggestions: false,
        style: monoStyle,
        textInputAction: TextInputAction.next,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          labelText: l10n.vaultKey,
          hintText: 'nsec1...',
          helperText: l10n.vaultKeyHelper,
          helperMaxLines: 3,
          errorText: _keyError,
          errorMaxLines: 3,
          suffixIcon: IconButton(
            tooltip: _keyHidden ? l10n.show : l10n.hide,
            onPressed: () => setState(() => _keyHidden = !_keyHidden),
            icon: Icon(
              _keyHidden
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
          ),
        ),
      ),
      if (_encrypted) ...[
        const SizedBox(height: 16),
        TextField(
          controller: _password,
          autofocus: true,
          obscureText: _passwordHidden,
          autocorrect: false,
          enableSuggestions: false,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: l10n.vaultKeyPassword,
            errorText: _passwordError,
            suffixIcon: IconButton(
              tooltip: _passwordHidden ? l10n.show : l10n.hide,
              onPressed: () =>
                  setState(() => _passwordHidden = !_passwordHidden),
              icon: Icon(
                _passwordHidden
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            ),
          ),
        ),
      ],
      const SizedBox(height: 8),
      InkWell(
        onTap: () => setState(() => _signersShown = !_signersShown),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.otherWaysToOpen,
                  style: TextStyle(fontSize: 13, color: palette.muted),
                ),
              ),
              AnimatedRotation(
                turns: _signersShown ? 0.5 : 0,
                duration: const Duration(milliseconds: 180),
                child: Icon(Icons.expand_more_rounded, color: palette.muted),
              ),
            ],
          ),
        ),
      ),
      if (_signersShown) ...[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            l10n.signersDescription,
            style: TextStyle(fontSize: 13, color: palette.muted),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // TODO: when no extension or signer app is found, hide its button or
            // link to a neutral list of them, not to one we would vouch for.
            if (canUseExtension)
              OutlinedButton.icon(
                onPressed: _busy
                    ? null
                    : () => _connectSigner(
                        loginWithExtension,
                        l10n.noBrowserExtension,
                      ),
                icon: const Icon(Icons.extension_outlined, size: 18),
                label: Text(l10n.browserExtension),
              ),
            if (canUseSignerApp)
              OutlinedButton.icon(
                onPressed: _busy
                    ? null
                    : () =>
                          _connectSigner(loginWithSignerApp, l10n.noSignerApp),
                icon: const Icon(Icons.phone_android_rounded, size: 18),
                label: Text(l10n.signerApp),
              ),
            OutlinedButton.icon(
              onPressed: _busy ? null : _nostrConnect,
              icon: const Icon(Icons.qr_code_2_rounded, size: 18),
              label: Text(l10n.nostrConnect),
            ),
          ],
        ),
      ],
    ];
  }
}

/// The signer holding the key of the vault to open.
class _SignerBox extends StatelessWidget {
  const _SignerBox({required this.login, required this.onClear});

  final SignerLogin login;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 4, 10),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.line),
      ),
      child: Row(
        children: [
          Icon(_signerIcon(login), color: palette.muted),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  signerName(context.l10n, login),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  Nip19.encodePubKey(login.pubkey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: monoStyle.copyWith(fontSize: 12, color: palette.muted),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: context.l10n.useAnotherKey,
            onPressed: onClear,
            icon: const Icon(Icons.close_rounded, size: 20),
          ),
        ],
      ),
    );
  }
}

/// The page where a bunker asks to approve the app (NIP-46 `auth_url`).
class _Approval extends StatelessWidget {
  const _Approval({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final uri = Uri.tryParse(url);
    // Opened on a tap only, and only as a web page: the bunker chose it.
    if (uri == null || !{'https', 'http'}.contains(uri.scheme)) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              context.l10n.bunkerApproval,
              style: TextStyle(fontSize: 13, color: context.palette.muted),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () =>
                launchUrl(uri, mode: LaunchMode.externalApplication),
            child: Text(context.l10n.openApprovalPage),
          ),
        ],
      ),
    );
  }
}

class _Waiting extends StatelessWidget {
  const _Waiting({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Row(
      children: [
        SizedBox.square(
          dimension: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: palette.muted,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            status,
            style: TextStyle(fontSize: 13, color: palette.muted),
          ),
        ),
      ],
    );
  }
}

/// Shows a code for a bunker or a signer app to scan, and gives its login
/// once it connects.
class _NostrConnectDialog extends StatefulWidget {
  const _NostrConnectDialog({required this.ndk});

  final Ndk ndk;

  @override
  State<_NostrConnectDialog> createState() => _NostrConnectDialogState();
}

class _NostrConnectDialogState extends State<_NostrConnectDialog> {
  final _connect = NostrConnect(
    relays: nostrConnectRelays,
    clientMetadata: bunkerClient,
  );
  String? _authUrl;
  var _failed = false;

  @override
  void initState() {
    super.initState();
    unawaited(_wait());
  }

  Future<void> _wait() async {
    BunkerLogin? login;
    try {
      login = await loginWithNostrConnect(
        widget.ndk,
        _connect,
        onAuthUrl: (url) {
          if (mounted) setState(() => _authUrl = url);
        },
      );
    } catch (_) {}
    if (!mounted) return;
    if (login != null) {
      Navigator.pop(context, login);
    } else {
      setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final url = _connect.nostrConnectURL;
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.nostrConnect,
                style: Theme.of(context).dialogTheme.titleTextStyle,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.nostrConnectBody,
                style: TextStyle(color: palette.muted),
              ),
              const SizedBox(height: 20),
              Center(
                // Dark on light whatever the theme, for every scanner to read.
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SizedBox.square(
                    dimension: 220,
                    child: PrettyQrView.data(
                      data: url,
                      decoration: const PrettyQrDecoration(
                        shape: PrettyQrSmoothSymbol(color: Color(0xFF0B1E2D)),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 4, 8),
                decoration: BoxDecoration(
                  color: palette.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: palette.line),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        url,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: monoStyle.copyWith(fontSize: 12),
                      ),
                    ),
                    // Whoever answers with its secret becomes the vault.
                    CopyButton(value: url, sensitive: true),
                  ],
                ),
              ),
              if (_authUrl case final url?) _Approval(url: url),
              const SizedBox(height: 16),
              if (_failed)
                Text(
                  l10n.nothingConnected,
                  style: TextStyle(fontSize: 13, color: palette.danger),
                )
              else
                _Waiting(status: l10n.waitingForAnswer),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.cancel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VaultKeyDialog extends StatelessWidget {
  const _VaultKeyDialog({required this.privateKey});

  final String privateKey;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.saveVaultKeyTitle,
                style: Theme.of(context).dialogTheme.titleTextStyle,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.saveVaultKeyBody,
                style: TextStyle(color: palette.muted),
              ),
              const SizedBox(height: 20),
              VaultKeyBox(privateKey: privateKey),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.done),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
