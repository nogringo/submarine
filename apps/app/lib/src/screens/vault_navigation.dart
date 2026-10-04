import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../context.dart';
import '../router.dart';
import '../vaults/vaults.dart';
import '../widgets/vault_avatar.dart';
import 'add_vault.dart';

/// Wide layout: the vaults in a rail, as Discord shows its servers.
class VaultRail extends StatelessWidget {
  const VaultRail({super.key, required this.selectedVaultId});

  final String selectedVaultId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final vaults = Vaults.of(context);
    return SizedBox(
      width: 76,
      child: Column(
        children: [
          const SizedBox(height: 16),
          _RailTile(
            tooltip: l10n.allVaults,
            selected: selectedVaultId == allVaultsId,
            onTap: () => context.go(vaultPath(allVaultsId)),
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
                    onTap: () => context.go(vaultPath(vault.pubkey)),
                    builder: (highlighted) =>
                        VaultAvatar(vault: vault, selected: highlighted),
                  ),
                _RailTile(
                  tooltip: l10n.addVault,
                  selected: false,
                  onTap: () => addVault(context),
                  builder: (_) => const _AddVaultMark(size: 48),
                ),
              ],
            ),
          ),
        ],
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

class _AddVaultMark extends StatelessWidget {
  const _AddVaultMark({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: palette.line, width: 1.5),
      ),
      child: Icon(Icons.add_rounded, color: palette.signal, size: size * 0.5),
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
              ),
            _DrawerTile(
              leading: const _AddVaultMark(size: 40),
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
  });

  final Widget leading;
  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final subtitle = this.subtitle;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: selected ? palette.selected : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
