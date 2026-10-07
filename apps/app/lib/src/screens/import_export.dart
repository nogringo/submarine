import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ndk/ndk.dart' show SignerRequestCancelledException;
import 'package:intl/intl.dart';
import 'package:nostr_passwords/nostr_passwords.dart';

import '../context.dart';
import '../items/field_tile.dart';
import '../theme/theme.dart';
import '../vaults/vault_controller.dart';
import '../vaults/vaults.dart';
import '../widgets/settings_tile.dart';
import '../widgets/vault_dropdown.dart';

/// Imports a Bitwarden JSON export into a vault, and exports a vault the same
/// way.
class ImportExportSection extends StatelessWidget {
  const ImportExportSection({super.key});

  @override
  Widget build(BuildContext context) => SettingsSection(
    title: context.l10n.importExport,
    child: const FieldCard(children: [_ImportTile(), _ExportTile()]),
  );
}

class _ImportTile extends StatefulWidget {
  const _ImportTile();

  @override
  State<_ImportTile> createState() => _ImportTileState();
}

class _ImportTileState extends State<_ImportTile> {
  String? _error;

  Future<void> _import() async {
    final l10n = context.l10n;
    setState(() => _error = null);
    final String fileName;
    final String source;
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: const ['json'],
      );
      if (file == null) return;
      fileName = file.name;
      source = utf8.decode(await file.readAsBytes(), allowMalformed: true);
    } catch (_) {
      return _fail(l10n.importReadFailed);
    }
    final List<Cipher> ciphers;
    try {
      final opened = await _open(source);
      if (opened == null) return;
      ciphers = opened;
    } on EncryptedExportException {
      return _fail(l10n.importEncrypted);
    } on FormatException {
      return _fail(l10n.importNotBitwarden);
    }
    if (ciphers.isEmpty) return _fail(l10n.importEmpty);
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ImportDialog(fileName: fileName, ciphers: ciphers),
    );
  }

  /// The items of [source], once its password is entered if it has one. Null
  /// when the user gives up.
  Future<List<Cipher>?> _open(String source) async {
    try {
      return parseBitwardenExport(source);
    } on PasswordProtectedExportException {
      if (!mounted) return null;
      return showDialog<List<Cipher>>(
        context: context,
        builder: (context) => _FilePasswordDialog(source: source),
      );
    }
  }

  void _fail(String error) {
    if (mounted) setState(() => _error = error);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final error = _error;
    return SettingsTile(
      title: Text(l10n.importFromBitwarden),
      subtitle: error != null
          ? Text(error, style: TextStyle(color: context.palette.danger))
          : Text(l10n.importFromBitwardenDescription),
      trailing: OutlinedButton(
        onPressed: _import,
        style: settingsButtonStyle,
        child: Text(l10n.importButton),
      ),
    );
  }
}

/// Asks for the password of a password protected export, and returns its
/// items once the password opens it.
class _FilePasswordDialog extends StatefulWidget {
  const _FilePasswordDialog({required this.source});

  final String source;

  @override
  State<_FilePasswordDialog> createState() => _FilePasswordDialogState();
}

class _FilePasswordDialogState extends State<_FilePasswordDialog> {
  final _password = TextEditingController();
  var _hidden = true;
  var _opening = false;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _open() async {
    if (_opening || _password.text.isEmpty) return;
    final l10n = context.l10n;
    setState(() {
      _opening = true;
      _error = null;
    });
    String? error;
    try {
      final ciphers = await compute(_openExport, (
        widget.source,
        _password.text,
      ));
      if (mounted) return Navigator.pop(context, ciphers);
    } on WrongExportPasswordException {
      error = l10n.wrongFilePassword;
    } catch (_) {
      error = l10n.importNotBitwarden;
    }
    if (mounted) {
      setState(() {
        _opening = false;
        _error = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PopScope(
      canPop: !_opening,
      child: Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.importFromBitwarden,
                  style: Theme.of(context).dialogTheme.titleTextStyle,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.importPasswordBody,
                  style: TextStyle(color: context.palette.muted),
                ),
                const SizedBox(height: 20),
                _FilePasswordField(
                  controller: _password,
                  label: l10n.filePassword,
                  hidden: _hidden,
                  onToggleHidden: () => setState(() => _hidden = !_hidden),
                  autofocus: true,
                  errorText: _error,
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) => _open(),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _opening ? null : () => Navigator.pop(context),
                      child: Text(l10n.cancel),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _opening || _password.text.isEmpty
                          ? null
                          : _open,
                      child: _opening
                          ? const _ButtonProgress()
                          : Text(l10n.open),
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

/// On an isolate of its own where there is one: the key derivation of a
/// password protected export takes seconds.
Future<List<Cipher>> _openExport((String, String) file) async {
  final (source, password) = file;
  return parseBitwardenExport(await decryptBitwardenExport(source, password));
}

Future<String> _protectExport((String, String) file) {
  final (export, password) = file;
  return encryptBitwardenExport(export, password);
}

class _FilePasswordField extends StatelessWidget {
  const _FilePasswordField({
    required this.controller,
    required this.label,
    required this.hidden,
    this.onToggleHidden,
    this.autofocus = false,
    this.errorText,
    this.helperText,
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final bool hidden;
  final VoidCallback? onToggleHidden;
  final bool autofocus;
  final String? errorText;
  final String? helperText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final onToggleHidden = this.onToggleHidden;
    return TextField(
      controller: controller,
      autofocus: autofocus,
      obscureText: hidden,
      autocorrect: false,
      enableSuggestions: false,
      keyboardType: TextInputType.visiblePassword,
      style: monoStyle,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        errorMaxLines: 3,
        helperText: helperText,
        helperMaxLines: 3,
        suffixIcon: onToggleHidden == null
            ? null
            : IconButton(
                tooltip: hidden ? l10n.show : l10n.hide,
                onPressed: onToggleHidden,
                icon: Icon(
                  hidden
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
      ),
    );
  }
}

class _ButtonProgress extends StatelessWidget {
  const _ButtonProgress();

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: 16,
    child: CircularProgressIndicator(
      strokeWidth: 2,
      color: context.palette.muted,
    ),
  );
}

/// Asks for the vault, then imports into it, the progress in view. It stays
/// open until the import ends.
class _ImportDialog extends StatefulWidget {
  const _ImportDialog({required this.fileName, required this.ciphers});

  final String fileName;
  final List<Cipher> ciphers;

  @override
  State<_ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends State<_ImportDialog> {
  String? _chosenVaultId;

  /// Null until the import starts.
  int? _saved;
  var _finished = false;
  var _failed = false;

  bool get _importing => _saved != null && !_finished;

  /// Null while the lock keeps the vaults closed.
  VaultController? _vaultOf(Vaults vaults) =>
      vaults.byPubkey(_chosenVaultId ?? '') ?? vaults.all.firstOrNull;

  Future<void> _import() async {
    final vault = _vaultOf(Vaults.of(context));
    if (vault == null) return;
    setState(() => _saved = 0);
    try {
      await vault.importItems(
        widget.ciphers,
        onSaved: (saved) {
          if (mounted) setState(() => _saved = saved);
        },
      );
    } on SignerRequestCancelledException {
      // Stopped by the user, with what was saved so far.
    } catch (_) {
      _failed = true;
    }
    if (mounted) setState(() => _finished = true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final vaults = Vaults.of(context);
    final vault = _vaultOf(vaults);
    if (vault == null) return const SizedBox.shrink();
    final total = widget.ciphers.length;
    final saved = _saved;
    return PopScope(
      canPop: !_importing,
      child: Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.importFromBitwarden,
                  style: Theme.of(context).dialogTheme.titleTextStyle,
                ),
                const SizedBox(height: 12),
                if (saved == null) ...[
                  Text(
                    l10n.importFound(total, widget.fileName),
                    style: TextStyle(color: palette.muted),
                  ),
                  if (vaults.all.length > 1) ...[
                    const SizedBox(height: 20),
                    VaultDropdown(
                      value: vault,
                      onChanged: (vault) =>
                          setState(() => _chosenVaultId = vault.pubkey),
                    ),
                  ],
                ] else if (!_finished) ...[
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: saved / total),
                  const SizedBox(height: 12),
                  Text(
                    l10n.importProgress(saved, total),
                    style: TextStyle(color: palette.muted),
                  ),
                ] else if (_failed)
                  Text(
                    l10n.importFailed(saved, total),
                    style: TextStyle(color: palette.danger),
                  )
                else
                  Text(l10n.importDone(total, vault.name)),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (saved == null) ...[
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(l10n.cancel),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: _import,
                        child: Text(l10n.importButton),
                      ),
                    ] else
                      FilledButton(
                        onPressed: _finished
                            ? () => Navigator.pop(context)
                            : null,
                        child: Text(l10n.done),
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

class _ExportTile extends StatefulWidget {
  const _ExportTile();

  @override
  State<_ExportTile> createState() => _ExportTileState();
}

class _ExportTileState extends State<_ExportTile> {
  String? _error;

  Future<void> _export() async {
    final l10n = context.l10n;
    setState(() => _error = null);
    final file = await showDialog<_ExportFile>(
      context: context,
      builder: (context) => const _ExportDialog(),
    );
    if (file == null) return;
    try {
      await FilePicker.saveFile(
        fileName: _exportFileName(DateTime.now(), protected: file.protected),
        bytes: utf8.encode(file.content),
        mimeType: 'application/json',
      );
    } catch (_) {
      if (mounted) setState(() => _error = l10n.exportFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final error = _error;
    return SettingsTile(
      title: Text(l10n.exportVault),
      subtitle: error != null
          ? Text(error, style: TextStyle(color: context.palette.danger))
          : Text(l10n.exportVaultDescription),
      trailing: OutlinedButton(
        onPressed: _export,
        style: settingsButtonStyle,
        child: Text(l10n.exportButton),
      ),
    );
  }
}

typedef _ExportFile = ({String content, bool protected});

/// As Bitwarden names its exports.
String _exportFileName(DateTime now, {required bool protected}) =>
    'submarine_${protected ? 'encrypted_' : ''}export_'
    '${DateFormat('yyyyMMddHHmmss').format(now)}.json';

/// Asks for the vault to export and for a password to protect the file with,
/// then returns the file.
class _ExportDialog extends StatefulWidget {
  const _ExportDialog();

  @override
  State<_ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<_ExportDialog> {
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  String? _chosenVaultId;
  var _protected = true;
  var _hidden = true;
  var _exporting = false;
  String? _passwordError;
  String? _confirmationError;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  Future<void> _export(VaultController vault) async {
    if (_exporting) return;
    final l10n = context.l10n;
    final password = _password.text;
    setState(() {
      _passwordError = _protected && password.isEmpty
          ? l10n.filePasswordRequired
          : null;
      _confirmationError =
          _protected && password.isNotEmpty && _confirmation.text != password
          ? l10n.filePasswordMismatch
          : null;
      _error = null;
    });
    if (_passwordError != null || _confirmationError != null) return;

    setState(() => _exporting = true);
    final export = writeBitwardenExport(vault.items);
    try {
      final content = _protected
          ? await compute(_protectExport, (export, password))
          : export;
      if (mounted) {
        Navigator.pop(context, (content: content, protected: _protected));
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _exporting = false;
          _error = l10n.exportFailed;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final vaults = Vaults.of(context);
    final vault =
        vaults.byPubkey(_chosenVaultId ?? '') ?? vaults.all.firstOrNull;
    // Closed by the lock.
    if (vault == null) return const SizedBox.shrink();
    final count = vault.items.where((item) => !item.cipher.isDeleted).length;
    return PopScope(
      canPop: !_exporting,
      child: Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.exportVault,
                  style: Theme.of(context).dialogTheme.titleTextStyle,
                ),
                const SizedBox(height: 20),
                if (vaults.all.length > 1) ...[
                  VaultDropdown(
                    value: vault,
                    onChanged: (vault) =>
                        setState(() => _chosenVaultId = vault.pubkey),
                  ),
                  const SizedBox(height: 16),
                ],
                Text(
                  l10n.exportCount(count),
                  style: TextStyle(color: palette.muted),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.exportProtect,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Switch(
                      value: _protected,
                      onChanged: _exporting
                          ? null
                          : (protected) =>
                                setState(() => _protected = protected),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_protected) ...[
                  _FilePasswordField(
                    controller: _password,
                    label: l10n.filePassword,
                    hidden: _hidden,
                    onToggleHidden: () => setState(() => _hidden = !_hidden),
                    autofocus: true,
                    errorText: _passwordError,
                  ),
                  const SizedBox(height: 16),
                  _FilePasswordField(
                    controller: _confirmation,
                    label: l10n.confirmFilePassword,
                    hidden: _hidden,
                    errorText: _confirmationError,
                    helperText: l10n.filePasswordHelper,
                    onSubmitted: (_) => _export(vault),
                  ),
                ] else
                  Text(l10n.exportWarning),
                if (_error case final error?) ...[
                  const SizedBox(height: 16),
                  Text(error, style: TextStyle(color: palette.danger)),
                ],
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _exporting
                          ? null
                          : () => Navigator.pop(context),
                      child: Text(l10n.cancel),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: count == 0 || _exporting
                          ? null
                          : () => _export(vault),
                      child: _exporting
                          ? const _ButtonProgress()
                          : Text(l10n.exportButton),
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
