import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
        _ when hidden && !_shown => _Mask(
          style: row.kind == FieldKind.password ? _passwordStyle : _secretStyle,
        ),
        FieldKind.password => PasswordText(row.value),
        FieldKind.secret ||
        FieldKind.mono => SelectableText(row.value, style: _secretStyle),
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
        if (row.copyable) CopyButton(value: row.value, sensitive: hidden),
      ],
    );
  }
}

const _valueStyle = TextStyle(fontSize: 16, height: 1.35);
final _passwordStyle = monoStyle.copyWith(fontSize: 17, height: 1.35);
final _secretStyle = monoStyle.copyWith(fontSize: 15, height: 1.4);

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

/// In the [style] of the value it hides, so that showing it moves nothing.
class _Mask extends StatelessWidget {
  const _Mask({required this.style});

  final TextStyle style;

  @override
  Widget build(BuildContext context) => Text(
    '••••••••••••',
    semanticsLabel: context.l10n.hiddenValue,
    style: style,
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
      style: _passwordStyle,
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

class _TotpTileState extends State<_TotpTile>
    with SingleTickerProviderStateMixin {
  final _clock = ValueNotifier(DateTime.now());
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((_) {
      final second = _clock.value.millisecondsSinceEpoch ~/ 1000;
      _clock.value = DateTime.now();
      if (_clock.value.millisecondsSinceEpoch ~/ 1000 != second) {
        setState(() {});
      }
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final TotpCode totp;
    try {
      totp = generateTotp(widget.totpKey, time: _clock.value);
    } on FormatException {
      return _TileLayout(
        label: widget.label,
        value: Text(
          context.l10n.totpInvalid,
          style: _valueStyle.copyWith(color: palette.danger),
        ),
      );
    }
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
          _TotpRing(clock: _clock, period: totp.period),
        ],
      ),
      actions: [CopyButton(value: totp.code, sensitive: true)],
    );
  }

  /// "892235" reads as "892 235".
  String _group(String code) => code.length < 6
      ? code
      : '${code.substring(0, code.length ~/ 2)} '
            '${code.substring(code.length ~/ 2)}';
}

/// Milliseconds before the code shown at [now] expires.
int _msLeft(DateTime now, Duration period) =>
    period.inMilliseconds - now.millisecondsSinceEpoch % period.inMilliseconds;

class _TotpRing extends StatelessWidget {
  const _TotpRing({required this.clock, required this.period});

  final ValueListenable<DateTime> clock;
  final Duration period;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final seconds = (_msLeft(clock.value, period) + 999) ~/ 1000;
    // Bitwarden's threshold, too short to paste the code before it changes.
    final expiring = seconds <= 7;
    return SizedBox.square(
      dimension: 30,
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _RingPainter(
            clock: clock,
            period: period,
            track: palette.line,
            color: expiring ? palette.danger : palette.signal,
          ),
          child: Center(
            child: Text(
              '$seconds',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: expiring ? palette.danger : palette.text,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.clock,
    required this.period,
    required this.track,
    required this.color,
  }) : super(repaint: clock);

  final ValueListenable<DateTime> clock;
  final Duration period;
  final Color track;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final fraction = _msLeft(clock.value, period) / period.inMilliseconds;
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
      old.clock != clock ||
      old.period != period ||
      old.track != track ||
      old.color != color;
}

/// The page to open for a login URI, none for what is not a web address.
Uri? websiteUri(String value) {
  final text = value.trim();
  final uri = Uri.tryParse(text.contains('://') ? text : 'https://$text');
  if (uri == null || uri.host.isEmpty) return null;
  return uri.scheme == 'http' || uri.scheme == 'https' ? uri : null;
}
