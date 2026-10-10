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
import '../widgets/dialog_buttons.dart';
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

/// [child] centered, at most as wide as the settings.
class _SettingsWidth extends StatelessWidget {
  const _SettingsWidth({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 720),
      child: child,
    ),
  );
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
      child: _SettingsWidth(
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
      builder: (context, connected) => _AddressList(
        vault: vault,
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
          keepPrivate: l10n.relayKeepPrivate,
          keepPrivateDescription: l10n.relayKeepPrivateDescription,
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
    return _AddressList(
      vault: vault,
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
        keepPrivate: l10n.serverKeepPrivate,
        keepPrivateDescription: l10n.serverKeepPrivateDescription,
        saveFailed: l10n.serversSaveFailed,
        waitForSync: l10n.serversWaitForSync,
        needOne: l10n.serversNeedOne,
      ),
      save: (public, private) =>
          vault.setServerList(ServerList(public: public, private: private)),
    );
  }
}

/// What an [_AddressList] says, of relays or of servers.
typedef _AddressTexts = ({
  String title,
  String description,
  String add,
  String address,
  String invalid,
  String alreadyListed,
  String remove,
  String keep,
  String private,
  String added,
  String removed,
  String keepPrivate,
  String keepPrivateDescription,
  String saveFailed,
  String waitForSync,
  String needOne,
});

/// The page of the addresses of a list of the vault, public or private. Keeps
/// the changes in a draft, published as a single list on save.
class _AddressList extends StatefulWidget {
  const _AddressList({
    required this.vault,
    required this.public,
    required this.private,
    required this.editable,
    required this.parse,
    required this.icon,
    required this.hint,
    required this.texts,
    this.status,
    this.problem,
    required this.save,
  });

  final VaultController vault;
  final List<String> public;
  final List<String> private;

  /// Whether saving cannot replace a newer list.
  final bool editable;

  /// An address as the user types it, normalized, or null if invalid.
  final String? Function(String text) parse;
  final IconData icon;
  final String hint;
  final _AddressTexts texts;

  /// What a listed address shows while the draft keeps it, if anything.
  final (String, IconData) Function(String url)? status;

  /// What went wrong with a listed address, if anything.
  final String? Function(String url)? problem;
  final Future<void> Function(List<String> public, List<String> private) save;

  @override
  State<_AddressList> createState() => _AddressListState();
}

class _AddressListState extends State<_AddressList> {
  final _removed = <String>{};

  /// Whether each address to add is private.
  final _added = <String, bool>{};
  var _saving = false;
  String? _saveError;

  bool get _changed => _removed.isNotEmpty || _added.isNotEmpty;

  List<String> _draft(List<String> listed, {required bool private}) => [
    for (final url in listed)
      if (!_removed.contains(url)) url,
    for (final MapEntry(key: url, value: isPrivate) in _added.entries)
      if (isPrivate == private) url,
  ];

  void _discard() => setState(() {
    _removed.clear();
    _added.clear();
    _saveError = null;
  });

  Future<void> _save(List<String> public, List<String> private) async {
    final failed = widget.texts.saveFailed;
    setState(() {
      _saving = true;
      _saveError = null;
    });
    try {
      await widget.save(public, private);
      if (mounted) {
        setState(() {
          _removed.clear();
          _added.clear();
        });
      }
    } on SignerRequestCancelledException {
      // Cancelled by the user: the draft stays, to save again.
    } catch (_) {
      if (mounted) setState(() => _saveError = failed);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _add(List<String> draft) async {
    final added = await showDialog<(String, bool)>(
      context: context,
      builder: (context) => _AddAddressDialog(
        texts: widget.texts,
        hint: widget.hint,
        parse: widget.parse,
        listed: (url) =>
            draft.any((listed) => (widget.parse(listed) ?? listed) == url),
      ),
    );
    if (added case (final url, final private) when mounted) {
      setState(() => _added[url] = private);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final texts = widget.texts;
    final editable = widget.editable && !_saving;
    final public = _draft(widget.public, private: false);
    final private = _draft(widget.private, private: true);
    final empty = public.isEmpty && private.isEmpty;
    final message =
        _saveError ??
        (!widget.editable
            ? texts.waitForSync
            : empty
            ? texts.needOne
            : null);
    IconButton removeButton(VoidCallback remove) => IconButton(
      tooltip: texts.remove,
      onPressed: editable ? () => setState(remove) : null,
      icon: const Icon(Icons.close_rounded, size: 20),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: _SettingsWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Header(
                    vault: widget.vault,
                    title: texts.title,
                    subtitle: widget.vault.name,
                    back: vaultSettingsPath(widget.vault.pubkey),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    texts.description,
                    style: TextStyle(fontSize: 13, color: palette.muted),
                  ),
                  const SizedBox(height: 12),
                  FieldCard(
                    children: [
                      for (final (listed, isPrivate) in [
                        (widget.public, false),
                        (widget.private, true),
                      ])
                        for (final url in listed)
                          if (_removed.contains(url))
                            _AddressTile(
                              url: url,
                              icon: widget.icon,
                              note: isPrivate ? texts.private : null,
                              status: (
                                texts.removed,
                                Icons.remove_circle_outline_rounded,
                              ),
                              removed: true,
                              action: IconButton(
                                tooltip: texts.keep,
                                onPressed: editable
                                    ? () => setState(() => _removed.remove(url))
                                    : null,
                                icon: const Icon(Icons.undo_rounded, size: 20),
                              ),
                            )
                          else
                            _AddressTile(
                              url: url,
                              icon: widget.icon,
                              note: isPrivate ? texts.private : null,
                              status: widget.status?.call(url),
                              problem: widget.problem?.call(url),
                              action: removeButton(() => _removed.add(url)),
                            ),
                      for (final MapEntry(key: url, value: isPrivate)
                          in _added.entries)
                        _AddressTile(
                          url: url,
                          icon: widget.icon,
                          note: isPrivate ? texts.private : null,
                          status: (
                            texts.added,
                            Icons.add_circle_outline_rounded,
                          ),
                          action: removeButton(() => _added.remove(url)),
                        ),
                      SettingsTile(
                        leading: Icon(
                          Icons.add_rounded,
                          size: 20,
                          color: editable ? palette.signal : palette.muted,
                        ),
                        title: Text(
                          texts.add,
                          style: editable
                              ? null
                              : TextStyle(color: palette.muted),
                        ),
                        onTap: editable
                            ? () => _add([...public, ...private])
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const Divider(),
        Padding(
          // Clear of the system navigation bar, the app drawing edge to edge.
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            12 + MediaQuery.paddingOf(context).bottom,
          ),
          child: _SettingsWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Next to the buttons it explains, wherever the list scrolled.
                if (message != null) ...[
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 13,
                      color: _saveError == null
                          ? palette.muted
                          : palette.danger,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                DialogButtons(
                  children: [
                    TextButton(
                      onPressed: _changed && !_saving ? _discard : null,
                      child: Text(context.l10n.cancel),
                    ),
                    FilledButton(
                      onPressed: _changed && editable && !empty
                          ? () => _save(public, private)
                          : null,
                      child: Text(context.l10n.save),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// The draft shows in [status], so that the row keeps its height.
class _AddressTile extends StatelessWidget {
  const _AddressTile({
    required this.url,
    required this.icon,
    this.note,
    this.status,
    this.problem,
    this.removed = false,
    required this.action,
  });

  final String url;
  final IconData icon;

  /// Under the address, that it is private.
  final String? note;
  final (String, IconData)? status;

  /// Under the address and [note].
  final String? problem;
  final bool removed;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final note = this.note;
    final problem = this.problem;
    return SettingsTile(
      leading: Icon(icon, size: 20, color: palette.muted),
      title: Text(
        url.replaceFirst(RegExp('^(wss|https)://'), ''),
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: removed ? palette.muted : null,
          decoration: removed ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: note == null && problem == null
          ? null
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (note != null) Text(note),
                if (problem != null)
                  Text(problem, style: TextStyle(color: palette.danger)),
              ],
            ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (status case (final text, final statusIcon)) ...[
            // Spelled out in the wide layout, a tooltip in the narrow one.
            if (context.isWide) ...[
              Icon(statusIcon, size: 16, color: palette.muted),
              const SizedBox(width: 6),
              Text(text, style: TextStyle(fontSize: 13, color: palette.muted)),
            ] else
              Tooltip(
                message: text,
                child: Icon(statusIcon, size: 16, color: palette.muted),
              ),
            const SizedBox(width: 4),
          ],
          action,
        ],
      ),
    );
  }
}

/// Gives the address to add, and whether it is private.
class _AddAddressDialog extends StatefulWidget {
  const _AddAddressDialog({
    required this.texts,
    required this.hint,
    required this.parse,
    required this.listed,
  });

  final _AddressTexts texts;
  final String hint;
  final String? Function(String text) parse;

  /// Whether the draft lists the normalized address.
  final bool Function(String url) listed;

  @override
  State<_AddAddressDialog> createState() => _AddAddressDialogState();
}

class _AddAddressDialogState extends State<_AddAddressDialog> {
  final _url = TextEditingController();
  var _private = false;
  String? _error;

  @override
  void dispose() {
    _url.dispose();
    super.dispose();
  }

  void _submit() {
    final texts = widget.texts;
    final url = widget.parse(_url.text);
    final error = url == null
        ? texts.invalid
        : widget.listed(url)
        ? texts.alreadyListed
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
    final texts = widget.texts;
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
                texts.add,
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
                  labelText: texts.address,
                  hintText: widget.hint,
                  errorText: _error,
                ),
              ),
              const SizedBox(height: 16),
              // The switch takes its name from the text.
              MergeSemantics(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            texts.keepPrivate,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            texts.keepPrivateDescription,
                            style: TextStyle(
                              fontSize: 13,
                              color: palette.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Switch(
                      value: _private,
                      onChanged: (private) =>
                          setState(() => _private = private),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              DialogButtons(
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.cancel),
                  ),
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
