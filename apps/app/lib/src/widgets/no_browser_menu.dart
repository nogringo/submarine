import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Keeps the browser's context menu away while the mouse is over [child], on
/// the web, where a right click opens a menu of the app's own.
class NoBrowserMenu extends StatefulWidget {
  const NoBrowserMenu({super.key, required this.child});

  final Widget child;

  @override
  State<NoBrowserMenu> createState() => _NoBrowserMenuState();
}

class _NoBrowserMenuState extends State<NoBrowserMenu> {
  var _hovered = false;

  void _hover(bool hovered) {
    _hovered = hovered;
    unawaited(
      hovered
          ? BrowserContextMenu.disableContextMenu()
          : BrowserContextMenu.enableContextMenu(),
    );
  }

  @override
  void dispose() {
    // MouseRegion leaves out the exit of a region that goes away.
    if (_hovered) _hover(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => kIsWeb
      ? MouseRegion(
          onEnter: (_) => _hover(true),
          onExit: (_) => _hover(false),
          child: widget.child,
        )
      : widget.child;
}
