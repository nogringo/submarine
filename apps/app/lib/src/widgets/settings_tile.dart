import 'package:flutter/material.dart';

import '../context.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection({
    super.key,
    required this.title,
    this.description,
    required this.child,
  });

  final String title;
  final String? description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final description = this.description;
    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          if (description != null) ...[
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(fontSize: 13, color: context.palette.muted),
            ),
          ],
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

/// A row of a settings card, [below] spanning it whole.
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.below,
    this.onTap,
  });

  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final Widget? below;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final leading = this.leading;
    final subtitle = this.subtitle;
    final trailing = this.trailing;
    final below = this.below;
    final tile = Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (leading != null) ...[leading, const SizedBox(width: 14)],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DefaultTextStyle.merge(
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      child: title,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      DefaultTextStyle.merge(
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: context.palette.muted,
                        ),
                        child: subtitle,
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 12), trailing],
            ],
          ),
          if (below != null) ...[const SizedBox(height: 12), below],
        ],
      ),
    );
    if (onTap == null) return tile;
    // The card's color would hide the ink of the Material below it.
    return Material(
      type: MaterialType.transparency,
      child: InkWell(onTap: onTap, child: tile),
    );
  }
}

final settingsButtonStyle = OutlinedButton.styleFrom(
  minimumSize: const Size(0, 40),
  padding: const EdgeInsets.symmetric(horizontal: 16),
);
