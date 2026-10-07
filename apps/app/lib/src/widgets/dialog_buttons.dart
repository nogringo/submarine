import 'package:flutter/widgets.dart';

/// A dialog's buttons at its end, stacked once they no longer fit side by
/// side, as with large text.
class DialogButtons extends StatelessWidget {
  const DialogButtons({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => OverflowBar(
    alignment: MainAxisAlignment.end,
    spacing: 8,
    overflowAlignment: OverflowBarAlignment.end,
    overflowSpacing: 8,
    children: children,
  );
}
