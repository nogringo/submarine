import 'dart:async';

import 'package:flutter/material.dart';

/// [icon], turning while [spinning], as a refresh or sync button shows its
/// work. It ends its turn rather than stop askew, and stays still when the
/// device asks for fewer animations.
class SpinningIcon extends StatefulWidget {
  const SpinningIcon(
    this.icon, {
    super.key,
    required this.spinning,
    this.counterclockwise = false,
    this.size,
    this.color,
  });

  final IconData icon;
  final bool spinning;

  /// The way the arrows of [Icons.sync_rounded] point.
  final bool counterclockwise;

  final double? size;
  final Color? color;

  @override
  State<SpinningIcon> createState() => _SpinningIconState();
}

class _SpinningIconState extends State<SpinningIcon>
    with SingleTickerProviderStateMixin {
  late final _turns = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  );
  late final _backwards = Tween<double>(begin: 0, end: -1).animate(_turns);
  var _repeating = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _follow();
  }

  @override
  void didUpdateWidget(SpinningIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    _follow();
  }

  void _follow() {
    final spin = widget.spinning && !MediaQuery.disableAnimationsOf(context);
    if (spin == _repeating) return;
    _repeating = spin;
    unawaited(spin ? _turns.repeat() : _turns.forward(from: _turns.value));
  }

  @override
  void dispose() {
    _turns.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RotationTransition(
    turns: widget.counterclockwise ? _backwards : _turns,
    child: Icon(widget.icon, size: widget.size, color: widget.color),
  );
}
