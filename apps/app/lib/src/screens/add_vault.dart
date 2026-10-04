import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nostr_passwords/nostr_passwords.dart';

import '../context.dart';
import '../router.dart';
import '../theme/theme.dart';
import '../vaults/vault_controller.dart';
import '../vaults/vault_storage.dart';
import '../vaults/vaults.dart';
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
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _VaultKeyDialog(vault: vault),
    );
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

class _VaultFormDialog extends StatefulWidget {
  const _VaultFormDialog({required this.choice});

  final AddVaultChoice choice;

  @override
  State<_VaultFormDialog> createState() => _VaultFormDialogState();
}

class _VaultFormDialogState extends State<_VaultFormDialog> {
  final _key = TextEditingController();
  final _name = TextEditingController();
  Color? _color;
  var _keyHidden = true;
  var _saving = false;
  String? _keyError;
  String? _nameError;
  String? _saveError;

  bool get _opening => widget.choice == AddVaultChoice.open;

  @override
  void dispose() {
    _key.dispose();
    _name.dispose();
    super.dispose();
  }

  Color _defaultColor(Vaults vaults) =>
      vaultColors[vaults.all.length % vaultColors.length];

  Future<void> _submit() async {
    if (_saving) return;
    final l10n = context.l10n;
    final vaults = Vaults.of(context);
    String? privateKey;
    String? keyError;
    if (_opening) {
      privateKey = parseVaultKey(_key.text);
      final existing = privateKey == null
          ? null
          : vaults.byPubkey(vaults.publicKeyOf(privateKey));
      keyError = privateKey == null
          ? l10n.vaultKeyInvalid
          : existing == null
          ? null
          : l10n.vaultAlreadyOpen(existing.name);
    }
    final name = _name.text.trim();
    setState(() {
      _keyError = keyError;
      _nameError = name.isEmpty ? l10n.vaultNameRequired : null;
      _saveError = null;
    });
    if (_keyError != null || _nameError != null) return;

    setState(() => _saving = true);
    try {
      final vault = await vaults.add(
        VaultRecord(
          privateKey: privateKey ?? vaults.newKey(),
          name: name,
          color: _color ?? _defaultColor(vaults),
        ),
      );
      if (mounted) Navigator.pop(context, vault);
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _saveError = l10n.vaultSaveFailed;
        });
      }
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
                TextField(
                  controller: _key,
                  autofocus: true,
                  obscureText: _keyHidden,
                  autocorrect: false,
                  enableSuggestions: false,
                  style: monoStyle,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: l10n.vaultKey,
                    hintText: 'nsec1...',
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
                    onPressed: _saving ? null : _submit,
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
}

class _VaultKeyDialog extends StatelessWidget {
  const _VaultKeyDialog({required this.vault});

  final VaultController vault;

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
              VaultKeyBox(vault: vault),
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
