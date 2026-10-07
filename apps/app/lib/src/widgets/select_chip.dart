import 'package:flutter/material.dart';

import '../context.dart';

/// A pill filled with the accent while selected.
class SelectChip extends StatelessWidget {
  const SelectChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.semanticsLabel,
  });

  final String label;
  final bool selected;

  /// Null keeps the chip as it is.
  final VoidCallback? onTap;

  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final chip = SizedBox(
      height: 36,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 48),
        child: Material(
          color: selected ? palette.accent : Colors.transparent,
          shape: StadiumBorder(
            side: BorderSide(
              color: selected ? palette.accent : palette.outline,
            ),
          ),
          child: InkWell(
            onTap: onTap,
            customBorder: const StadiumBorder(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Center(
                widthFactor: 1,
                child: Text(
                  label,
                  semanticsLabel: semanticsLabel,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: selected ? palette.onAccent : palette.text,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    return Semantics(
      container: true,
      selected: selected,
      button: true,
      // 48 high to tap, around the 36 that shows.
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        child: SizedBox(height: 48, child: Center(widthFactor: 1, child: chip)),
      ),
    );
  }
}
