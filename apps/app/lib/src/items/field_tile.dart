import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:nostr_passwords/nostr_passwords.dart';
import 'package:url_launcher/url_launcher.dart';

import '../context.dart';
import '../theme/theme.dart';
import '../widgets/copy_button.dart';
import 'item_fields.dart';

/// Rows sharing one rounded card, as the fields of an item do.
class FieldCard extends StatelessWidget {
  const FieldCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (index, child) in children.indexed) ...[
            if (index > 0) const Divider(),
            child,
          ],
        ],
      ),
    );
  }
}

class FieldTile extends StatefulWidget {
  const FieldTile({super.key, required this.row});

  final FieldRow row;

  @override
  State<FieldTile> createState() => _FieldTileState();
}

class _FieldTileState extends State<FieldTile> {
  var _shown = false;

  @override
  Widget build(BuildContext context) {
    final row = widget.row;
    if (row.kind == FieldKind.totp) {
      return _TotpTile(label: row.label, totpKey: row.value);
    }
    final l10n = context.l10n;
    final hidden =
        row.kind == FieldKind.secret || row.kind == FieldKind.password;
    final website = row.kind == FieldKind.url ? websiteUri(row.value) : null;
    return _TileLayout(
      label: row.label,
      value: switch (row.kind) {
        _ when hidden && !_shown => const _Mask(),
        FieldKind.password => PasswordText(row.value),
        FieldKind.secret || FieldKind.mono => SelectableText(
          row.value,
          style: monoStyle.copyWith(fontSize: 15, height: 1.4),
        ),
        _ => SelectableText(row.value, style: _valueStyle),
      },
      actions: [
        if (hidden)
          IconButton(
            tooltip: _shown ? l10n.hide : l10n.show,
            onPressed: () => setState(() => _shown = !_shown),
            icon: Icon(
              _shown
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
            ),
          ),
        if (website != null)
          IconButton(
            tooltip: l10n.openWebsite,
            onPressed: () =>
                launchUrl(website, mode: LaunchMode.externalApplication),
            icon: const Icon(Icons.open_in_new_rounded, size: 20),
          ),
        if (row.copyable) CopyButton(value: row.value),
      ],
    );
  }
}

const _valueStyle = TextStyle(fontSize: 16, height: 1.35);

class _TileLayout extends StatelessWidget {
  const _TileLayout({
    required this.label,
    required this.value,
    this.actions = const [],
  });

  final String label;
  final Widget value;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (label.isNotEmpty) ...[
                Text(
                  label,
                  style: TextStyle(fontSize: 13, color: context.palette.muted),
                ),
                const SizedBox(height: 4),
              ],
              value,
            ],
          ),
        ),
        ...actions,
      ],
    ),
  );
}

class _Mask extends StatelessWidget {
  const _Mask();

  @override
  Widget build(BuildContext context) => const Text(
    '••••••••••••',
    style: TextStyle(fontSize: 16, letterSpacing: 2, height: 1.35),
  );
}

/// Digits in signal, special characters in symbol, so that look-alike
/// characters cannot be mistaken for one another.
class PasswordText extends StatelessWidget {
  const PasswordText(this.value, {super.key});

  final String value;

  static final _letter = RegExp(r'\p{L}', unicode: true);
  static final _digit = RegExp(r'\p{Nd}', unicode: true);

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return SelectableText.rich(
      TextSpan(
        children: [
          for (final character in value.characters)
            TextSpan(
              text: character,
              style: TextStyle(
                color: _digit.hasMatch(character)
                    ? palette.signal
                    : _letter.hasMatch(character)
                    ? palette.text
                    : palette.symbol,
              ),
            ),
        ],
      ),
      style: monoStyle.copyWith(fontSize: 17, height: 1.35),
    );
  }
}

/// The current code of a TOTP key, renewed as it expires.
class _TotpTile extends StatefulWidget {
  const _TotpTile({required this.label, required this.totpKey});

  final String label;
  final String totpKey;

  @override
  State<_TotpTile> createState() => _TotpTileState();
}

class _TotpTileState extends State<_TotpTile> {
  late final Timer _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(
      const Duration(milliseconds: 500),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final TotpCode totp;
    try {
      totp = generateTotp(widget.totpKey);
    } on FormatException {
      return _TileLayout(
        label: widget.label,
        value: Text(
          context.l10n.totpInvalid,
          style: _valueStyle.copyWith(color: palette.danger),
        ),
      );
    }
    final period = totp.period.inSeconds;
    final elapsed = DateTime.now().millisecondsSinceEpoch ~/ 1000 % period;
    return _TileLayout(
      label: widget.label,
      value: Row(
        children: [
          Text(
            _group(totp.code),
            style: monoStyle.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              letterSpacing: 1,
              height: 1.2,
            ),
          ),
          const SizedBox(width: 12),
          _TotpRing(remaining: period - elapsed, period: period),
        ],
      ),
      actions: [CopyButton(value: totp.code)],
    );
  }

  /// "892235" reads as "892 235".
  String _group(String code) => code.length < 6
      ? code
      : '${code.substring(0, code.length ~/ 2)} '
            '${code.substring(code.length ~/ 2)}';
}

class _TotpRing extends StatelessWidget {
  const _TotpRing({required this.remaining, required this.period});

  final int remaining;
  final int period;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return SizedBox.square(
      dimension: 30,
      child: CustomPaint(
        painter: _RingPainter(
          fraction: remaining / period,
          track: palette.line,
          color: palette.signal,
        ),
        child: Center(
          child: Text(
            '$remaining',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: palette.text,
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.fraction,
    required this.track,
    required this.color,
  });

  final double fraction;
  final Color track;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(1.5);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawOval(rect, stroke..color = track);
    canvas.drawArc(
      rect,
      -pi / 2,
      2 * pi * fraction,
      false,
      stroke
        ..color = color
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.fraction != fraction || old.track != track || old.color != color;
}

/// The page to open for a login URI, none for what is not a web address.
Uri? websiteUri(String value) {
  final text = value.trim();
  final uri = Uri.tryParse(text.contains('://') ? text : 'https://$text');
  if (uri == null || uri.host.isEmpty) return null;
  return uri.scheme == 'http' || uri.scheme == 'https' ? uri : null;
}
