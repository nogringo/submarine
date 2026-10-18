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
import '../widgets/address_list.dart';
import '../widgets/context_menus.dart';
import '../widgets/copy_button.dart';
import '../widgets/encrypt_vault_key_dialog.dart';
import '../widgets/selectable_area.dart';
import '../widgets/settings_tile.dart';
import '../widgets/spinning_icon.dart';
import '../widgets/sync_status.dart';
import '../widgets/vault_avatar.dart';
import '../widgets/vault_color_picker.dart';
import '../widgets/vault_key_box.dart';
import 'vault_navigation.dart';

class VaultSettingsScreen extends StatelessWidget {
  const VaultSettingsScreen({super.key, required this.vaultId});

  final String vaultId;

  @override
  Widget build(BuildContext context) {
    final vault = Vaults.of(context).byPubkey(vaultId);
    return _VaultSettingsFrame(
      vaultId: vaultId,
      back: vaultPath(vaultId),
      child: vault == null
          ? const SizedBox.shrink()
          // Keeps its state when the layout changes, and is new for each vault.
          : _VaultSettings(key: GlobalObjectKey(vault), vault: vault),
    );
  }
}

/// The lists of a vault that its settings open, each on a page of its own.
enum VaultList { relays, servers }

/// A list of a vault, whose draft takes a Save of its own.
class VaultListScreen extends StatefulWidget {
  const VaultListScreen({super.key, required this.vaultId, required this.list});

  final String vaultId;
  final VaultList list;

  @override
  State<VaultListScreen> createState() => _VaultListScreenState();
}

class _VaultListScreenState extends State<VaultListScreen> {
  /// Keeps the draft when the layout changes.
  final _listKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final vaultId = widget.vaultId;
    return _VaultSettingsFrame(
      vaultId: vaultId,
      back: vaultSettingsPath(vaultId),
      child: switch ((Vaults.of(context).byPubkey(vaultId), widget.list)) {
        (null, _) => const SizedBox.shrink(),
        (final vault?, VaultList.relays) => _Relays(
          key: _listKey,
          vault: vault,
        ),
        (final vault?, VaultList.servers) => _Servers(
          key: _listKey,
          vault: vault,
        ),
      },
    );
  }
}

/// A page of the settings of a vault: next to the rail in the wide layout, on
/// a screen of its own in the narrow one.
class _VaultSettingsFrame extends StatelessWidget {
  const _VaultSettingsFrame({
    required this.vaultId,
    required this.back,
    required this.child,
  });

  final String vaultId;

  /// Where going back leads when no page is under this one.
  final String back;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!context.isWide) {
      return Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: () => _goBack(context, back)),
        ),
        body: child,
      );
    }
    return Scaffold(
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            VaultRail(selectedVaultId: vaultId, selectedItemId: null),
            const VerticalDivider(width: 1),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

void _goBack(BuildContext context, String fallback) =>
    context.canPop() ? context.pop() : context.go(fallback);

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
      child: SettingsWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(
              vault: vault,
              title: vault.name,
              subtitle: l10n.vaultSettings,
            ),
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
                          contextMenuBuilder: textFieldMenu,
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
                    subtitle: SelectableArea(
                      child: Text(
                        npub,
                        style: monoStyle.copyWith(fontSize: 13),
                      ),
                    ),
                    trailing: CopyButton(value: npub),
                  ),
                  switch (vault.record.login) {
                    KeyLogin(:final privateKey) => SettingsTile(
                      title: Text(l10n.vaultKey),
                      subtitle: Text(l10n.vaultKeyDescription),
                      below: VaultKeyBox(privateKey: privateKey),
                    ),
                    SignerLogin login => SettingsTile(
                      title: Text(signerName(l10n, login)),
                      subtitle: Text(l10n.vaultSignerDescription),
                    ),
                  },
                  if (vault.record.login case KeyLogin(:final privateKey))
                    _EncryptedKeyTile(privateKey: privateKey),
                  if (vault.record.login is SignerLogin)
                    _AskSignerTile(vault: vault),
                ],
              ),
            ),
            SettingsSection(
              title: l10n.sync,
              child: FieldCard(
                children: [
                  _SyncTile(vault: vault),
                  _FullSyncTile(vault: vault),
                  _RelayConnections(
                    vault: vault,
                    builder: (context, connected) {
                      final urls = vault.relayList?.urls;
                      return _VaultListTile(
                        vault: vault,
                        list: VaultList.relays,
                        summary: urls == null
                            ? null
                            : l10n.relaysConnected(
                                urls.where(connected).length,
                                urls.length,
                              ),
                      );
                    },
                  ),
                  _VaultListTile(
                    vault: vault,
                    list: VaultList.servers,
                    summary: switch (vault.serverList) {
                      final list? => l10n.fileServerCount(
                        list.public.length + list.private.length,
                      ),
                      null => null,
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 28),
              child: FieldCard(children: [_RemoveTile(vault: vault)]),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.vault,
    required this.title,
    required this.subtitle,
    this.back,
  });

  final VaultController vault;
  final String title;
  final String subtitle;

  /// Where the back button leads in the wide layout, which has no app bar.
  final String? back;

  @override
  Widget build(BuildContext context) {
    final back = this.back;
    return Row(
      children: [
        if (back != null && context.isWide) ...[
          BackButton(onPressed: () => _goBack(context, back)),
          const SizedBox(width: 8),
        ],
        VaultAvatar(vault: vault, size: 56),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14, color: context.palette.muted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A list of [vault] in its settings, opening its page.
class _VaultListTile extends StatelessWidget {
  const _VaultListTile({
    required this.vault,
    required this.list,
    required this.summary,
  });

  final VaultController vault;
  final VaultList list;
  final String? summary;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final summary = this.summary;
    return SettingsTile(
      title: Text(switch (list) {
        VaultList.relays => l10n.relays,
        VaultList.servers => l10n.fileServers,
      }),
      subtitle: summary != null ? Text(summary) : null,
      trailing: Icon(Icons.chevron_right_rounded, color: context.palette.muted),
      onTap: () => context.push(vaultListPath(vault.pubkey, list)),
    );
  }
}

class _EncryptedKeyTile extends StatelessWidget {
  const _EncryptedKeyTile({required this.privateKey});

  /// In hex.
  final String privateKey;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SettingsTile(
      title: Text(l10n.encryptedVaultKey),
      subtitle: Text(l10n.encryptedVaultKeyDescription),
      trailing: OutlinedButton.icon(
        onPressed: () => showDialog<void>(
          context: context,
          builder: (context) => EncryptVaultKeyDialog(
            privateKey: privateKey,
            title: l10n.exportEncryptedVaultKey,
          ),
        ),
        style: settingsButtonStyle,
        icon: const Icon(Icons.lock_outline_rounded, size: 18),
        label: Text(l10n.exportButton),
      ),
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
        icon: SpinningIcon(
          Icons.sync_rounded,
          spinning: summary.syncing,
          counterclockwise: true,
          size: 18,
          color: summary.syncing ? palette.muted : null,
        ),
        label: Text(l10n.syncNow),
      ),
    );
  }
}

/// Its result shows here, and the reason of each relay left out in its row of
/// the relays.
class _FullSyncTile extends StatefulWidget {
  const _FullSyncTile({required this.vault});

  final VaultController vault;

  @override
  State<_FullSyncTile> createState() => _FullSyncTileState();
}

class _FullSyncTileState extends State<_FullSyncTile> {
  var _failed = false;

  Future<void> _reconcile() async {
    setState(() => _failed = false);
    try {
      await widget.vault.reconcile();
    } on SignerRequestCancelledException {
      // Cancelled by the user, from the requests the signer waits for.
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final vault = widget.vault;
    final (result, wrong) = switch (vault.leftOut) {
      _ when vault.reconciling => (null, false),
      _ when _failed => (l10n.fullSyncFailed, true),
      null => (null, false),
      final leftOut when leftOut.isEmpty => (l10n.fullSyncDone, false),
      final leftOut => (l10n.fullSyncLeftOut(leftOut.length), true),
    };
    return SettingsTile(
      title: Text(l10n.fullSync),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.fullSyncDescription),
          if (result != null)
            Text(
              result,
              style: wrong ? TextStyle(color: palette.danger) : null,
            ),
        ],
      ),
      trailing: OutlinedButton.icon(
        // Opening what it shares takes the key, which a locked vault has not.
        onPressed: vault.reconciling || vault.locked ? null : _reconcile,
        style: settingsButtonStyle,
        icon: SpinningIcon(
          Icons.sync_rounded,
          spinning: vault.reconciling,
          counterclockwise: true,
          size: 18,
          color: vault.reconciling ? palette.muted : null,
        ),
        label: Text(l10n.fullSyncStart),
      ),
    );
  }
}

class _RemoveTile extends StatefulWidget {
  const _RemoveTile({required this.vault});

  final VaultController vault;

  @override
  State<_RemoveTile> createState() => _RemoveTileState();
}

class _RemoveTileState extends State<_RemoveTile> {
  var _removing = false;
  String? _error;

  Future<void> _remove() async {
    final l10n = context.l10n;
    final vaults = Vaults.of(context);
    // These settings leave the tree with the vault, before the removal ends.
    final router = GoRouter.of(context);
    if (!await _confirmRemove(context, widget.vault) || !mounted) return;
    setState(() {
      _removing = true;
      _error = null;
    });
    try {
      await vaults.remove(widget.vault);
    } catch (_) {
      if (mounted) {
        setState(() {
          _removing = false;
          _error = l10n.removeVaultFailed;
        });
        return;
      }
    }
    router.go(vaultPath(allVaultsId));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final error = _error;
    return SettingsTile(
      title: Text(l10n.removeVault),
      subtitle: error != null
          ? Text(error, style: TextStyle(color: palette.danger))
          : Text(l10n.removeVaultDescription),
      trailing: OutlinedButton(
        onPressed: _removing ? null : _remove,
        style: OutlinedButton.styleFrom(foregroundColor: palette.danger)
            .merge(settingsButtonStyle),
        child: Text(l10n.removeVaultConfirm),
      ),
    );
  }
}

Future<bool> _confirmRemove(BuildContext context, VaultController vault) async {
  final l10n = context.l10n;
  final colors = Theme.of(context).colorScheme;
  final remove = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.removeVaultTitle(vault.name)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Text(l10n.removeVaultBody),
          if (vault.record.login is KeyLogin) Text(l10n.removeVaultKeyWarning),
          if (vault.unsent > 0)
            Text(
              l10n.removeVaultUnsent(vault.unsent),
              style: TextStyle(color: context.palette.danger),
            ),
        ],
      ),
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
          child: Text(l10n.removeVaultConfirm),
        ),
      ],
    ),
  );
  return remove ?? false;
}

/// Rebuilds with whether this device is connected to each relay of [vault].
class _RelayConnections extends StatefulWidget {
  const _RelayConnections({required this.vault, required this.builder});

  final VaultController vault;
  final Widget Function(
    BuildContext context,
    bool Function(String url) connected,
  )
  builder;

  @override
  State<_RelayConnections> createState() => _RelayConnectionsState();
}

class _RelayConnectionsState extends State<_RelayConnections> {
  late final _connections =
      widget.vault.vault.ndk.connectivity.relayConnectivityChanges;

  @override
  Widget build(BuildContext context) => StreamBuilder<List<RelayConnectivity>>(
    stream: _connections,
    builder: (context, snapshot) {
      final connected = {
        for (final connection in snapshot.data ?? <RelayConnectivity>[])
          if (connection.isConnected) connection.url,
      };
      return widget.builder(
        context,
        (url) => connected.contains(cleanRelayUrl(url) ?? url),
      );
    },
  );
}

/// The relays of the vault, and whether this device is connected to each.
class _Relays extends StatelessWidget {
  const _Relays({super.key, required this.vault});

  final VaultController vault;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final list = vault.relayList;
    if (list == null) return const SizedBox.shrink();
    final markers = {...list.public, ...list.private};
    ReadWriteMarker markerOf(String url) =>
        markers[url] ?? ReadWriteMarker.readWrite;
    return _RelayConnections(
      vault: vault,
      builder: (context, connected) => AddressList(
        header: _Header(
          vault: vault,
          title: l10n.relays,
          subtitle: vault.name,
          back: vaultSettingsPath(vault.pubkey),
        ),
        public: list.public.keys.toList(),
        private: list.private.keys.toList(),
        editable: vault.relaysEditable,
        parse: parseRelayUrl,
        icon: Icons.cell_tower_rounded,
        hint: 'wss://relay.example.com',
        texts: (
          title: l10n.relays,
          description: l10n.relaysDescription,
          add: l10n.addRelay,
          address: l10n.relayAddress,
          invalid: l10n.relayAddressInvalid,
          alreadyListed: l10n.relayAlreadyListed,
          remove: l10n.removeRelay,
          keep: l10n.keepRelay,
          private: l10n.relayPrivate,
          added: l10n.relayAdded,
          removed: l10n.relayRemoved,
          keepPrivate: (
            title: l10n.relayKeepPrivate,
            description: l10n.relayKeepPrivateDescription,
          ),
          saveFailed: l10n.relaysSaveFailed,
          waitForSync: l10n.relaysWaitForSync,
          needOne: l10n.relaysNeedOne,
        ),
        status: (url) => connected(url)
            ? (l10n.relayConnected, Icons.check_circle_outline_rounded)
            : (l10n.relayNotConnected, Icons.circle_outlined),
        problem: (url) => switch (vault.leftOut?[url]) {
          final reason? => l10n.relayLeftOut(reason),
          null => null,
        },
        save: (public, private) => vault.setRelayList(
          RelayList(
            public: {for (final url in public) url: markerOf(url)},
            private: {for (final url in private) url: markerOf(url)},
          ),
        ),
      ),
    );
  }
}

/// The Blossom servers of the vault.
class _Servers extends StatelessWidget {
  const _Servers({super.key, required this.vault});

  final VaultController vault;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final list = vault.serverList;
    if (list == null) return const SizedBox.shrink();
    return AddressList(
      header: _Header(
        vault: vault,
        title: l10n.fileServers,
        subtitle: vault.name,
        back: vaultSettingsPath(vault.pubkey),
      ),
      public: list.public,
      private: list.private,
      editable: vault.serversEditable,
      parse: parseServerUrl,
      icon: Icons.dns_rounded,
      hint: 'https://blossom.example.com',
      texts: (
        title: l10n.fileServers,
        description: l10n.fileServersDescription,
        add: l10n.addServer,
        address: l10n.serverAddress,
        invalid: l10n.serverAddressInvalid,
        alreadyListed: l10n.serverAlreadyListed,
        remove: l10n.removeServer,
        keep: l10n.keepServer,
        private: l10n.serverPrivate,
        added: l10n.serverAdded,
        removed: l10n.serverRemoved,
        keepPrivate: (
          title: l10n.serverKeepPrivate,
          description: l10n.serverKeepPrivateDescription,
        ),
        saveFailed: l10n.serversSaveFailed,
        waitForSync: l10n.serversWaitForSync,
        needOne: l10n.serversNeedOne,
      ),
      moveLabel: l10n.moveServer,
      save: (public, private) =>
          vault.setServerList(ServerList(public: public, private: private)),
    );
  }
}
