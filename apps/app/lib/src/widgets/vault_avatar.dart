import 'package:flutter/material.dart';

import '../context.dart';
import '../vaults/vault_controller.dart';

/// A vault's tile: its initial on its color. Rounder when not [selected], as
/// Discord does with servers.
class VaultAvatar extends StatelessWidget {
  const VaultAvatar({
    super.key,
    required this.vault,
    this.size = 48,
    this.selected = true,
  });

  final VaultController vault;
  final double size;
  final bool selected;

  @override
  Widget build(BuildContext context) => _AvatarTile(
    color: vault.color,
    size: size,
    selected: selected,
    child: Text(
      initialOf(vault.name),
      style: TextStyle(
        color: Colors.white,
        fontSize: size * 0.4,
        fontWeight: FontWeight.w700,
        height: 1,
      ),
    ),
  );
}

class AllVaultsAvatar extends StatelessWidget {
  const AllVaultsAvatar({super.key, this.size = 48, this.selected = true});

  final double size;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return _AvatarTile(
      color: palette.accent,
      size: size,
      selected: selected,
      child: Icon(
        Icons.layers_rounded,
        color: palette.onAccent,
        size: size * 0.5,
      ),
    );
  }
}

class _AvatarTile extends StatelessWidget {
  const _AvatarTile({
    required this.color,
    required this.size,
    required this.selected,
    required this.child,
  });

  final Color color;
  final double size;
  final bool selected;
  final Widget child;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 180),
    curve: Curves.easeOut,
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(size * (selected ? 0.3 : 0.5)),
    ),
    child: child,
  );
}

/// The small mark of a vault on an item, where several vaults are shown.
class VaultBadge extends StatelessWidget {
  const VaultBadge({super.key, required this.vault, this.size = 16});

  final VaultController vault;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: vault.color,
      borderRadius: BorderRadius.circular(size * 0.28),
      border: Border.all(color: context.palette.background, width: 1.5),
    ),
    child: Text(
      initialOf(vault.name),
      style: TextStyle(
        color: Colors.white,
        fontSize: size * 0.5,
        fontWeight: FontWeight.w700,
        height: 1,
      ),
    ),
  );
}

String initialOf(String name) {
  final trimmed = name.trim();
  return trimmed.isEmpty ? '?' : trimmed.characters.first.toUpperCase();
}
