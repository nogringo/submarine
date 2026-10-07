import 'package:flutter/material.dart';

import '../context.dart';

/// A row of a list, filled and marked at its edge while selected, as the rail
/// marks its vault: the fill alone is too faint to tell (WCAG 1.4.11).
class SelectableRow extends StatelessWidget {
  const SelectableRow({
    super.key,
    required this.selected,
    required this.onTap,
    this.onLongPress,
    this.onSecondaryTapUp,
    this.radius = 12,
    required this.child,
  });

  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final GestureTapUpCallback? onSecondaryTapUp;
  final double radius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final borderRadius = BorderRadius.circular(radius);
    return Semantics(
      container: true,
      button: true,
      selected: selected,
      child: Material(
        color: selected ? palette.selected : Colors.transparent,
        borderRadius: borderRadius,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          onSecondaryTapUp: onSecondaryTapUp,
          borderRadius: borderRadius,
          child: Stack(
            children: [
              child,
              if (selected)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Container(
                      width: 3,
                      height: 18,
                      decoration: BoxDecoration(
                        color: palette.text,
                        borderRadius: const BorderRadius.horizontal(
                          right: Radius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
