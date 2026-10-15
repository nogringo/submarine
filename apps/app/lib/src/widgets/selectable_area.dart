import 'package:flutter/material.dart';

import 'context_menus.dart';

/// Makes the text in [child] selectable, in place of SelectableText, whose
/// hidden <textarea> on the web lays the text out in another font: a triple
/// click there copies another paragraph.
class SelectableArea extends StatelessWidget {
  const SelectableArea({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      SelectionArea(contextMenuBuilder: selectionMenu, child: child);
}
