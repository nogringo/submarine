import 'package:flutter/material.dart';

class AreaView extends StatelessWidget {
  final double padding;
  final String? title;
  final List<Widget> children;

  const AreaView({
    super.key,
    this.title,
    required this.children,
    this.padding = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.primaryContainer.withValues(alpha: 0.1),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null)
            Text(title!, style: Theme.of(context).textTheme.titleLarge),
          ...children,
        ],
      ),
    );
  }
}
