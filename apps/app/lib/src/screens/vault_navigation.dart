import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../context.dart';
import '../lock/app_lock.dart';
import '../lock/lock_screen.dart';
import '../router.dart';
import '../vaults/vaults.dart';
import '../widgets/selectable_row.dart';
import '../widgets/signer_requests.dart';
import '../widgets/spoken_status.dart';
import '../widgets/vault_avatar.dart';
import 'add_vault.dart';
import 'app_navigation.dart';

/// Wide layout: the vaults in a rail, as Discord shows its servers, what the
/// signers wait for, the generator, the settings and the lock at the bottom.
class VaultRail extends StatelessWidget {
  const VaultRail({
    super.key,
    required this.selectedVaultId,
    required this.selectedItemId,
    this.destination = AppDestination.vaults,
  });

  final String? selectedVaultId;
  final String? selectedItemId;
  final AppDestination destination;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final vaults = Vaults.of(context);
    final lock = AppLock.of(context);
    final signerRequests = signerRequestCount(vaults);
    void select(String vaultId) =>
        context.go(vaultPathKeeping(vaults, vaultId, itemId: selectedItemId));
    return SizedBox(
      width: 76,
      child: Column(
        children: [
          const SizedBox(height: 16),
          _RailTile(
            tooltip: l10n.allVaults,
            selected: selectedVaultId == allVaultsId,
            onTap: () => select(allVaultsId),
            builder: (highlighted) => AllVaultsAvatar(selected: highlighted),
          ),
          Container(
            width: 32,
            height: 2,
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: palette.line,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 16),
              children: [
                for (final vault in vaults.all)
                  _RailTile(
                    tooltip: vault.name,
                    selected: selectedVaultId == vault.pubkey,
                    onTap: () => select(vault.pubkey),
                    builder: (highlighted) =>
                        VaultAvatar(vault: vault, selected: highlighted),
                  ),
                _RailTile(
                  tooltip: l10n.addVault,
                  selected: false,
                  onTap: () => addVault(context),
                  builder: (_) => const AddVaultMark(size: 48),
                ),
              ],
            ),
          ),
          if (signerRequests > 0)
            SpokenStatus(
              message: l10n.signerWaiting(signerRequests),
              child: _RailButton(
                icon: Icons.pending_actions_rounded,
                tooltip: l10n.signerWaiting(signerRequests),
                badge: signerRequests,
                onPressed: () => showSignerRequests(context),
              ),
            ),
          _RailButton(
            icon: Icons.casino_outlined,
            tooltip: l10n.generator,
            selected: destination == AppDestination.generator,
            onPressed: () => context.go(generatorPath),
          ),
          _RailButton(
            icon: Icons.tune_rounded,
            tooltip: l10n.settings,
            selected: destination == AppDestination.settings,
            onPressed: () => context.go(settingsPath),
          ),
          if (lock.enabled)
            _RailButton(
              icon: Icons.lock_outline_rounded,
              tooltip: l10n.lockWithShortcut(lockShortcut.label),
              onPressed: lock.lock,
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _RailButton extends StatelessWidget {
  const _RailButton({
    required this.icon,
    required this.tooltip,
    this.selected = false,
    this.badge,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final bool selected;

  /// A count to catch the eye with.
  final int? badge;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final badge = this.badge;
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: IconButton(
        tooltip: tooltip,
        isSelected: selected,
        onPressed: onPressed,
        style: IconButton.styleFrom(
          fixedSize: const Size.square(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          foregroundColor: badge != null
              ? palette.signal
              : selected
              ? palette.text
              : palette.muted,
          backgroundColor: selected ? palette.selected : null,
        ),
        icon: badge == null
            ? Icon(icon)
            : Badge(
                label: Text('$badge'),
                backgroundColor: palette.accent,
                textColor: palette.onAccent,
                child: Icon(icon),
              ),
      ),
    );
  }
}

class _RailTile extends StatefulWidget {
  const _RailTile({
    required this.tooltip,
    required this.selected,
    required this.onTap,
    required this.builder,
  });

  final String tooltip;
  final bool selected;
  final VoidCallback onTap;
  final Widget Function(bool highlighted) builder;

  @override
  State<_RailTile> createState() => _RailTileState();
}

class _RailTileState extends State<_RailTile> {
  var _hovered = false;
  var _focused = false;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final pointed = _hovered || _focused;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            width: 4,
            height: widget.selected ? 36 : (pointed ? 18 : 0),
            decoration: BoxDecoration(
              color: palette.text,
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Tooltip(
            message: widget.tooltip,
            preferBelow: false,
            child: Semantics(
              button: true,
              selected: widget.selected,
              child: InkWell(
                onTap: widget.onTap,
                onHover: (hovered) => setState(() => _hovered = hovered),
                onFocusChange: (focused) => setState(() => _focused = focused),
                customBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                hoverColor: Colors.transparent,
                focusColor: Colors.transparent,
                child: widget.builder(widget.selected || pointed),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Narrow layout: the vaults in a drawer, with their item counts.
class VaultDrawer extends StatelessWidget {
  const VaultDrawer({
    super.key,
    required this.selectedVaultId,
    required this.onAddVault,
  });

  final String selectedVaultId;

  /// Called once the drawer is closed, from a context that outlives it.
  final VoidCallback onAddVault;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final vaults = Vaults.of(context);
    void select(String vaultId) {
      Navigator.pop(context);
      context.go(vaultPath(vaultId));
    }

    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
              child: Text(
                l10n.vaults,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            _DrawerTile(
              leading: const AllVaultsAvatar(size: 40),
              title: l10n.allVaults,
              subtitle: l10n.itemCount(vaults.itemsOf(allVaultsId).length),
              selected: selectedVaultId == allVaultsId,
              onTap: () => select(allVaultsId),
            ),
            for (final vault in vaults.all)
              _DrawerTile(
                leading: VaultAvatar(vault: vault, size: 40),
                title: vault.name,
                subtitle: l10n.itemCount(vaults.itemsOf(vault.pubkey).length),
                selected: selectedVaultId == vault.pubkey,
                onTap: () => select(vault.pubkey),
                trailing: IconButton(
                  tooltip: l10n.vaultSettings,
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    Navigator.pop(context);
                    context.push(vaultSettingsPath(vault.pubkey));
                  },
                  icon: const Icon(Icons.settings_outlined),
                ),
              ),
            _DrawerTile(
              leading: const AddVaultMark(size: 40),
              title: l10n.addVault,
              selected: false,
              onTap: () {
                Navigator.pop(context);
                onAddVault();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.leading,
    required this.title,
    this.subtitle,
    required this.selected,
    required this.onTap,
    this.trailing,
  });

  final Widget leading;
  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final subtitle = this.subtitle;
    final trailing = this.trailing;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: SelectableRow(
        selected: selected,
        onTap: onTap,
        radius: 14,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              leading,
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 13, color: palette.muted),
                      ),
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}
