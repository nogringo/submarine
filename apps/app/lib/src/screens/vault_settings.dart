import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ndk/ndk.dart' show Nip19;

import '../context.dart';
import '../items/field_tile.dart';
import '../router.dart';
import '../theme/theme.dart';
import '../vaults/vault_controller.dart';
import '../vaults/vaults.dart';
import '../widgets/copy_button.dart';
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
        : _VaultSettings(key: ValueKey(vaultId), vault: vault);
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
              _Section(
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
              _Section(
                title: l10n.vaultKey,
                child: FieldCard(
                  children: [
                    _Tile(
                      title: Text(l10n.vaultPublicKey),
                      subtitle: SelectableText(
                        npub,
                        style: monoStyle.copyWith(fontSize: 13),
                      ),
                      trailing: CopyButton(value: npub),
                    ),
                    _VaultKeyTile(vault: vault),
                  ],
                ),
              ),
              _Section(
                title: l10n.sync,
                child: FieldCard(children: [_SyncTile(vault: vault)]),
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

class _Section extends StatelessWidget {
  const _Section({required this.title, this.description, required this.child});

  final String title;
  final String? description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final description = this.description;
    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          if (description != null) ...[
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(fontSize: 13, color: context.palette.muted),
            ),
          ],
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

/// A row of a settings card, [below] spanning it whole.
class _Tile extends StatelessWidget {
  const _Tile({required this.title, this.subtitle, this.trailing, this.below});

  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final Widget? below;

  @override
  Widget build(BuildContext context) {
    final subtitle = this.subtitle;
    final trailing = this.trailing;
    final below = this.below;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DefaultTextStyle.merge(
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      child: title,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      DefaultTextStyle.merge(
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: context.palette.muted,
                        ),
                        child: subtitle,
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 12), trailing],
            ],
          ),
          if (below != null) ...[const SizedBox(height: 12), below],
        ],
      ),
    );
  }
}

final _tileButtonStyle = OutlinedButton.styleFrom(
  minimumSize: const Size(0, 40),
  padding: const EdgeInsets.symmetric(horizontal: 16),
);

/// Hides the key until asked, as a password field does.
class _VaultKeyTile extends StatefulWidget {
  const _VaultKeyTile({required this.vault});

  final VaultController vault;

  @override
  State<_VaultKeyTile> createState() => _VaultKeyTileState();
}

class _VaultKeyTileState extends State<_VaultKeyTile> {
  var _shown = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _Tile(
      title: Text(l10n.vaultKey),
      subtitle: Text(l10n.vaultKeyDescription),
      trailing: OutlinedButton(
        onPressed: () => setState(() => _shown = !_shown),
        style: _tileButtonStyle,
        child: Text(_shown ? l10n.hide : l10n.show),
      ),
      below: _shown ? VaultKeyBox(vault: widget.vault) : null,
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
        summary.lastSync != null && summary.unsent == 0 && !summary.failed;
    return _Tile(
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
        style: _tileButtonStyle,
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
