import 'package:flutter/material.dart';

/// Submarine's color tokens. [accent] is a fill, for the main action and the
/// selection. [signal] is the accent as readable text, for digits and the TOTP
/// ring. In a password, digits use [signal] and special characters [symbol].
/// [outline] edges a control at 3:1 (WCAG 1.4.11), where [line] only divides.
@immutable
class Palette extends ThemeExtension<Palette> {
  const Palette({
    required this.background,
    required this.surface,
    required this.raised,
    required this.selected,
    required this.line,
    required this.outline,
    required this.text,
    required this.muted,
    required this.accent,
    required this.onAccent,
    required this.signal,
    required this.symbol,
    required this.danger,
  });

  static const dark = Palette(
    background: Color(0xFF0B1E2D),
    surface: Color(0xFF10283B),
    raised: Color(0xFF183652),
    selected: Color(0xFF1E4163),
    line: Color(0xFF284B6B),
    outline: Color(0xFF648098),
    text: Color(0xFFEAF0F4),
    muted: Color(0xFFA0B5C5),
    accent: Color(0xFFFFD23F),
    onAccent: Color(0xFF0B1E2D),
    signal: Color(0xFFFFD23F),
    symbol: Color(0xFF8CC8FF),
    danger: Color(0xFFFF9585),
  );

  static const light = Palette(
    background: Color(0xFFE4EBEF),
    surface: Color(0xFFF3F6F8),
    raised: Color(0xFFFFFFFF),
    selected: Color(0xFFD2DEE6),
    line: Color(0xFFC3D0D9),
    outline: Color(0xFF6E8391),
    text: Color(0xFF0B1E2D),
    muted: Color(0xFF4B6374),
    accent: Color(0xFFFFD23F),
    onAccent: Color(0xFF0B1E2D),
    signal: Color(0xFF8A5300),
    symbol: Color(0xFF1F5FA8),
    danger: Color(0xFFB3261E),
  );

  final Color background;
  final Color surface;
  final Color raised;
  final Color selected;
  final Color line;
  final Color outline;
  final Color text;
  final Color muted;
  final Color accent;
  final Color onAccent;
  final Color signal;
  final Color symbol;
  final Color danger;

  @override
  Palette copyWith({
    Color? background,
    Color? surface,
    Color? raised,
    Color? selected,
    Color? line,
    Color? outline,
    Color? text,
    Color? muted,
    Color? accent,
    Color? onAccent,
    Color? signal,
    Color? symbol,
    Color? danger,
  }) => Palette(
    background: background ?? this.background,
    surface: surface ?? this.surface,
    raised: raised ?? this.raised,
    selected: selected ?? this.selected,
    line: line ?? this.line,
    outline: outline ?? this.outline,
    text: text ?? this.text,
    muted: muted ?? this.muted,
    accent: accent ?? this.accent,
    onAccent: onAccent ?? this.onAccent,
    signal: signal ?? this.signal,
    symbol: symbol ?? this.symbol,
    danger: danger ?? this.danger,
  );

  @override
  Palette lerp(Palette? other, double t) {
    if (other == null) return this;
    return Palette(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      raised: Color.lerp(raised, other.raised, t)!,
      selected: Color.lerp(selected, other.selected, t)!,
      line: Color.lerp(line, other.line, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      text: Color.lerp(text, other.text, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      signal: Color.lerp(signal, other.signal, t)!,
      symbol: Color.lerp(symbol, other.symbol, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
    );
  }
}

extension PaletteOf on BuildContext {
  Palette get palette => Theme.of(this).extension<Palette>()!;
}
