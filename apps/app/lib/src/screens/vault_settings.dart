import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ndk/entities.dart' show RelayConnectivity;
import 'package:ndk/ndk.dart' show Nip19, SignerRequestCancelledException;
import 'package:ndk/shared/helpers/relay_helper.dart';
import 'package:nostr_passwords/nostr_passwords.dart';

import '../context.dart';
import '../items/field_tile.dart';
import '../router.dart';
import '../theme/theme.dart';
import '../vaults/vault_controller.dart';
import '../vaults/vault_logins.dart';
import '../vaults/vault_storage.dart';
import '../vaults/vaults.dart';
import '../widgets/copy_button.dart';
import '../widgets/settings_tile.dart';
import '../widgets/sync_status.dart';
import '../widgets/vault_avatar.dart';
import '../widgets/vault_color_picker.dart';
import '../widgets/vault_key_box.dart';
import 'vault_navigation.dart';

/// The settings of a vault: next to the rail in the wide layout, on a screen
/// of their own in the narrow one.
class VaultSettingsScreen extends StatelessWidget {
  const VaultSettingsScreen({super.key, required this.vaultId});

  final String vaultId;

  @override
  Widget build(BuildContext context) {
    final vault = Vaults.of(context).byPubkey(vaultId);
    final settings = vault == null
        ? const SizedBox.shrink()
        // Keeps the draft when the layout changes, and is new for each vault.
        : _VaultSettings(key: GlobalObjectKey(vault), vault: vault);
    if (!context.isWide) {
      return Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () => context.canPop()
                ? context.pop()
                : context.go(vaultPath(vaultId)),
          ),
        ),
        body: settings,
      );
    }
    return Scaffold(
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            VaultRail(selectedVaultId: vaultId, selectedItemId: null),
            const VerticalDivider(width: 1),
            Expanded(child: settings),
          ],
        ),
      ),
    );
  }
}

class _VaultSettings extends StatefulWidget {
  const _VaultSettings({super.key, required this.vault});

  final VaultController vault;

  @override
  State<_VaultSettings> createState() => _VaultSettingsState();
}

/// Saves every change as it is made.
class _VaultSettingsState extends State<_VaultSettings> {
  late final _name = TextEditingController(text: widget.vault.name);
  String? _nameError;
  String? _saveError;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _rename(String text) {
    final name = text.trim();
    setState(
      () => _nameError = name.isEmpty ? context.l10n.vaultNameRequired : null,
    );
    if (name.isNotEmpty) _edit(name: name);
  }

  Future<void> _edit({String? name, Color? color}) async {
    final l10n = context.l10n;
    setState(() => _saveError = null);
    try {
      await Vaults.of(context).edit(widget.vault, name: name, color: color);
    } catch (_) {
      if (mounted) setState(() => _saveError = l10n.vaultSaveFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final vault = widget.vault;
    final npub = Nip19.encodePubKey(vault.pubkey);
    return SingleChildScrollView(
      // Clear of the system navigation bar, the app drawing edge to edge.
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        32 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(vault: vault),
              SettingsSection(
                title: l10n.vaultNameAndColor,
                description: l10n.vaultNameHelper,
                child: FieldCard(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _name,
                            textCapitalization: TextCapitalization.sentences,
                            onChanged: _rename,
                            decoration: InputDecoration(
                              labelText: l10n.vaultName,
                              errorText: _nameError,
                            ),
                          ),
                          const SizedBox(height: 16),
                          VaultColorPicker(
                            selected: vault.color,
                            onSelected: (color) => _edit(color: color),
                          ),
                          if (_saveError case final error?) ...[
                            const SizedBox(height: 16),
                            Text(
                              error,
                              style: TextStyle(color: context.palette.danger),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SettingsSection(
                title: l10n.vaultKey,
                child: FieldCard(
                  children: [
                    SettingsTile(
                      title: Text(l10n.vaultPublicKey),
                      subtitle: SelectableText(
                        npub,
                        style: monoStyle.copyWith(fontSize: 13),
                      ),
                      trailing: CopyButton(value: npub),
                    ),
                    switch (vault.record.login) {
                      KeyLogin(:final privateKey) => _VaultKeyTile(
                        privateKey: privateKey,
                      ),
                      SignerLogin login => SettingsTile(
                        title: Text(signerName(l10n, login)),
                        subtitle: Text(l10n.vaultSignerDescription),
                      ),
                    },
                    if (vault.record.login is SignerLogin)
                      _AskSignerTile(vault: vault),
                  ],
                ),
              ),
              SettingsSection(
                title: l10n.sync,
                child: FieldCard(children: [_SyncTile(vault: vault)]),
              ),
              SettingsSection(
                title: l10n.relays,
                description: l10n.relaysDescription,
                child: _Relays(vault: vault),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.vault});

  final VaultController vault;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      VaultAvatar(vault: vault, size: 56),
      const SizedBox(width: 16),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              vault.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
            Text(
              context.l10n.vaultSettings,
              style: TextStyle(fontSize: 14, color: context.palette.muted),
            ),
          ],
        ),
      ),
    ],
  );
}

/// Hides the key until asked, as a password field does.
class _VaultKeyTile extends StatefulWidget {
  const _VaultKeyTile({required this.privateKey});

  final String privateKey;

  @override
  State<_VaultKeyTile> createState() => _VaultKeyTileState();
}

class _VaultKeyTileState extends State<_VaultKeyTile> {
  var _shown = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SettingsTile(
      title: Text(l10n.vaultKey),
      subtitle: Text(l10n.vaultKeyDescription),
      trailing: OutlinedButton(
        onPressed: () => setState(() => _shown = !_shown),
        style: settingsButtonStyle,
        child: Text(_shown ? l10n.hide : l10n.show),
      ),
      below: _shown ? VaultKeyBox(privateKey: widget.privateKey) : null,
    );
  }
}

/// Whether the signer opens the cache of the vault at each start, rather than
/// a key kept on this device.
class _AskSignerTile extends StatefulWidget {
  const _AskSignerTile({required this.vault});

  final VaultController vault;

  @override
  State<_AskSignerTile> createState() => _AskSignerTileState();
}

class _AskSignerTileState extends State<_AskSignerTile> {
  var _saving = false;
  String? _error;

  Future<void> _toggle(bool sealed) async {
    final l10n = context.l10n;
    final vaults = Vaults.of(context);
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await vaults.setCacheKeySealed(widget.vault, sealed);
    } on SignerRequestCancelledException {
      // Cancelled by the user, from the requests the signer waits for.
    } catch (_) {
      if (mounted) setState(() => _error = l10n.askSignerFailed);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final vault = widget.vault;
    final error = _error;
    return SettingsTile(
      title: Text(l10n.askSignerAtStart),
      subtitle: error != null
          ? Text(error, style: TextStyle(color: context.palette.danger))
          : Text(l10n.askSignerAtStartDescription),
      trailing: Switch(
        value: vault.record.cacheKeySealed,
        // Moving the key takes it at hand, which a locked vault has not.
        onChanged: _saving || vault.locked ? null : _toggle,
      ),
    );
  }
}

class _SyncTile extends StatelessWidget {
  const _SyncTile({required this.vault});

  final VaultController vault;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final summary = SyncSummary([vault]);
    final allSent =
        summary.lastSync != null &&
        summary.unsent == 0 &&
        !summary.failed &&
        !summary.locked;
    return SettingsTile(
      title: SyncStatusText(
        vaults: [vault],
        maxLines: 2,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: palette.text,
        ),
      ),
      subtitle: allSent ? Text(l10n.syncAllSent) : null,
      trailing: OutlinedButton.icon(
        onPressed: summary.syncing ? null : vault.sync,
        style: settingsButtonStyle,
        icon: summary.syncing
            ? SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: palette.muted,
                ),
              )
            : const Icon(Icons.sync_rounded, size: 18),
        label: Text(l10n.syncNow),
      ),
    );
  }
}

/// Keeps the changes in a draft, published as a single relay list on save.
class _Relays extends StatefulWidget {
  const _Relays({required this.vault});

  final VaultController vault;

  @override
  State<_Relays> createState() => _RelaysState();
}

class _RelaysState extends State<_Relays> {
  late final _connections =
      widget.vault.vault.ndk.connectivity.relayConnectivityChanges;
  final _removed = <String>{};

  /// Whether each relay to add is private.
  final _added = <String, bool>{};
  var _saving = false;
  String? _saveError;

  bool get _changed => _removed.isNotEmpty || _added.isNotEmpty;

  RelayList _draft(RelayList list) {
    var draft = list;
    for (final url in _removed) {
      draft = draft.without(url);
    }
    for (final MapEntry(key: url, value: private) in _added.entries) {
      draft = draft.withRelay(url, private: private);
    }
    return draft;
  }

  void _discard() => setState(() {
    _removed.clear();
    _added.clear();
    _saveError = null;
  });

  Future<void> _save(RelayList draft) async {
    final l10n = context.l10n;
    setState(() {
      _saving = true;
      _saveError = null;
    });
    try {
      await widget.vault.setRelayList(draft);
      if (mounted) {
        setState(() {
          _removed.clear();
          _added.clear();
        });
      }
    } on SignerRequestCancelledException {
      // Cancelled by the user: the draft stays, to save again.
    } catch (_) {
      if (mounted) setState(() => _saveError = l10n.relaysSaveFailed);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _add(RelayList draft) async {
    final added = await showDialog<(String, bool)>(
      context: context,
      builder: (context) => _AddRelayDialog(draft: draft),
    );
    if (added case (final url, final private) when mounted) {
      setState(() => _added[url] = private);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final vault = widget.vault;
    final list = vault.relayList;
    if (list == null) return const SizedBox.shrink();
    final editable = vault.relaysEditable && !_saving;
    final draft = _draft(list);
    final message =
        _saveError ??
        (!vault.relaysEditable
            ? l10n.relaysWaitForSync
            : draft.isEmpty
            ? l10n.relaysNeedOne
            : null);
    IconButton removeButton(VoidCallback remove) => IconButton(
      tooltip: l10n.removeRelay,
      onPressed: editable ? () => setState(remove) : null,
      icon: const Icon(Icons.close_rounded, size: 20),
    );
    return StreamBuilder<List<RelayConnectivity>>(
      stream: _connections,
      builder: (context, snapshot) {
        final connected = {
          for (final connection in snapshot.data ?? <RelayConnectivity>[])
            if (connection.isConnected) connection.url,
        };
        bool isConnected(String url) =>
            connected.contains(cleanRelayUrl(url) ?? url);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FieldCard(
              children: [
                for (final (relays, private) in [
                  (list.public, false),
                  (list.private, true),
                ])
                  for (final url in relays.keys)
                    if (_removed.contains(url))
                      _RelayTile(
                        url: url,
                        private: private,
                        status: l10n.relayRemoved,
                        statusIcon: Icons.remove_circle_outline_rounded,
                        removed: true,
                        action: IconButton(
                          tooltip: l10n.keepRelay,
                          onPressed: editable
                              ? () => setState(() => _removed.remove(url))
                              : null,
                          icon: const Icon(Icons.undo_rounded, size: 20),
                        ),
                      )
                    else
                      _RelayTile(
                        url: url,
                        private: private,
                        status: isConnected(url)
                            ? l10n.relayConnected
                            : l10n.relayNotConnected,
                        statusIcon: isConnected(url)
                            ? Icons.check_circle_outline_rounded
                            : Icons.circle_outlined,
                        action: removeButton(() => _removed.add(url)),
                      ),
                for (final MapEntry(key: url, value: private) in _added.entries)
                  _RelayTile(
                    url: url,
                    private: private,
                    status: l10n.relayAdded,
                    statusIcon: Icons.add_circle_outline_rounded,
                    action: removeButton(() => _added.remove(url)),
                  ),
                SettingsTile(
                  leading: Icon(
                    Icons.add_rounded,
                    size: 20,
                    color: editable ? palette.signal : palette.muted,
                  ),
                  title: Text(
                    l10n.addRelay,
                    style: editable ? null : TextStyle(color: palette.muted),
                  ),
                  onTap: editable ? () => _add(draft) : null,
                ),
              ],
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message,
                style: TextStyle(
                  fontSize: 13,
                  color: _saveError == null ? palette.muted : palette.danger,
                ),
              ),
            ],
            const SizedBox(height: 12),
            // Always there: the page would scroll by itself as they go.
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _changed && !_saving ? _discard : null,
                  child: Text(l10n.cancel),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _changed && editable && !draft.isEmpty
                      ? () => _save(draft)
                      : null,
                  child: Text(l10n.save),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

/// The draft shows in [status], so that the row keeps its height.
class _RelayTile extends StatelessWidget {
  const _RelayTile({
    required this.url,
    required this.private,
    required this.status,
    required this.statusIcon,
    this.removed = false,
    required this.action,
  });

  final String url;
  final bool private;
  final String status;
  final IconData statusIcon;
  final bool removed;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final icon = Icon(statusIcon, size: 16, color: palette.muted);
    return SettingsTile(
      leading: Icon(Icons.cell_tower_rounded, size: 20, color: palette.muted),
      title: Text(
        url.startsWith('wss://') ? url.substring(6) : url,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: removed ? palette.muted : null,
          decoration: removed ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: private ? Text(context.l10n.relayPrivate) : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Spelled out in the wide layout, a tooltip in the narrow one.
          if (context.isWide) ...[
            icon,
            const SizedBox(width: 6),
            Text(status, style: TextStyle(fontSize: 13, color: palette.muted)),
          ] else
            Tooltip(message: status, child: icon),
          const SizedBox(width: 4),
          action,
        ],
      ),
    );
  }
}

/// Gives the relay to add, and whether it is private.
class _AddRelayDialog extends StatefulWidget {
  const _AddRelayDialog({required this.draft});

  final RelayList draft;

  @override
  State<_AddRelayDialog> createState() => _AddRelayDialogState();
}

class _AddRelayDialogState extends State<_AddRelayDialog> {
  final _url = TextEditingController();
  var _private = false;
  String? _error;

  @override
  void dispose() {
    _url.dispose();
    super.dispose();
  }

  void _submit() {
    final l10n = context.l10n;
    final url = parseRelayUrl(_url.text);
    final error = url == null
        ? l10n.relayAddressInvalid
        : widget.draft.contains(url)
        ? l10n.relayAlreadyListed
        : null;
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    Navigator.pop(context, (url!, _private));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
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
                l10n.addRelay,
                style: Theme.of(context).dialogTheme.titleTextStyle,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _url,
                autofocus: true,
                autocorrect: false,
                enableSuggestions: false,
                keyboardType: TextInputType.url,
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  labelText: l10n.relayAddress,
                  hintText: 'wss://relay.example.com',
                  errorText: _error,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.relayKeepPrivate,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.relayKeepPrivateDescription,
                          style: TextStyle(fontSize: 13, color: palette.muted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Switch(
                    value: _private,
                    onChanged: (private) => setState(() => _private = private),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.cancel),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(onPressed: _submit, child: Text(l10n.add)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
