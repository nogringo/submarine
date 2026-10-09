import 'package:flutter/material.dart';

import '../context.dart';
import '../vaults/vaults.dart';

/// The colors a vault can take, [selected] checked.
class VaultColorPicker extends StatelessWidget {
  const VaultColorPicker({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final Color selected;
  final ValueChanged<Color> onSelected;

  @override
  Widget build(BuildContext context) => Wrap(
    children: [
      for (final color in VaultColor.values)
        _ColorSwatch(
          color: color.color,
          label: _name(context.l10n, color),
          selected: color.color == selected,
          onTap: () => onSelected(color.color),
        ),
    ],
  );
}

String _name(AppLocalizations l10n, VaultColor color) => switch (color) {
  VaultColor.blue => l10n.vaultColorBlue,
  VaultColor.orange => l10n.vaultColorOrange,
  VaultColor.green => l10n.vaultColorGreen,
  VaultColor.purple => l10n.vaultColorPurple,
  VaultColor.pink => l10n.vaultColorPink,
  VaultColor.gray => l10n.vaultColorGray,
};

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
    required this.color,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    selected: selected,
    button: true,
    child: InkResponse(
      onTap: onTap,
      radius: 24,
      // 48 to tap, around the 36 that shows.
      child: SizedBox.square(
        dimension: 48,
        child: Center(
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: selected
                  ? Border.all(color: context.palette.text, width: 2.5)
                  : null,
            ),
            child: selected
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                : null,
          ),
        ),
      ),
    ),
  );
}
