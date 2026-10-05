import 'package:flutter/material.dart';

import 'palette.dart';

const textFont = 'Atkinson Hyperlegible Next';
const monoFont = 'Atkinson Hyperlegible Mono';
const wordmarkFont = 'Saira Stencil One';

/// Secrets, keys and codes, where every character must read unambiguously.
const monoStyle = TextStyle(fontFamily: monoFont);

/// Material widgets underneath, themed into Submarine's own look.
ThemeData buildTheme(Palette palette, Brightness brightness) {
  final scheme = ColorScheme(
    brightness: brightness,
    primary: palette.accent,
    onPrimary: palette.onAccent,
    primaryContainer: palette.selected,
    onPrimaryContainer: palette.text,
    secondary: palette.symbol,
    onSecondary: palette.background,
    error: palette.danger,
    onError: palette.background,
    surface: palette.background,
    onSurface: palette.text,
    onSurfaceVariant: palette.muted,
    surfaceContainerLowest: palette.background,
    surfaceContainerLow: palette.surface,
    surfaceContainer: palette.surface,
    surfaceContainerHigh: palette.surface,
    surfaceContainerHighest: palette.raised,
    outline: palette.line,
    outlineVariant: palette.line,
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: palette.text,
    onInverseSurface: palette.background,
  );
  final rounded = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  );
  const buttonText = TextStyle(
    fontFamily: textFont,
    fontSize: 15,
    fontWeight: FontWeight.w700,
  );
  OutlineInputBorder inputBorder(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width),
      );

  return ThemeData(
    colorScheme: scheme,
    brightness: brightness,
    fontFamily: textFont,
    scaffoldBackgroundColor: palette.background,
    canvasColor: palette.background,
    dividerColor: palette.line,
    splashFactory: InkSparkle.splashFactory,
    extensions: [palette],
    dividerTheme: DividerThemeData(color: palette.line, thickness: 1, space: 1),
    appBarTheme: AppBarTheme(
      backgroundColor: palette.background,
      foregroundColor: palette.text,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: palette.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titleTextStyle: TextStyle(
        fontFamily: textFont,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: palette.text,
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: palette.raised,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: palette.line),
      ),
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(fontFamily: textFont, fontSize: 15, color: palette.text),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: palette.surface,
      surfaceTintColor: Colors.transparent,
      dragHandleColor: palette.line,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
    drawerTheme: DrawerThemeData(
      backgroundColor: palette.surface,
      surfaceTintColor: Colors.transparent,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: palette.accent,
        foregroundColor: palette.onAccent,
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 22),
        shape: rounded,
        textStyle: buttonText,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: palette.text,
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 22),
        side: BorderSide(color: palette.line),
        shape: rounded,
        textStyle: buttonText,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: palette.text,
        minimumSize: const Size(0, 44),
        shape: rounded,
        textStyle: buttonText,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(foregroundColor: palette.muted),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? palette.raised
              : Colors.transparent,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? palette.text
              : palette.muted,
        ),
        side: WidgetStatePropertyAll(BorderSide(color: palette.line)),
        textStyle: const WidgetStatePropertyAll(
          TextStyle(
            fontFamily: textFont,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: palette.background,
      labelStyle: TextStyle(color: palette.muted),
      floatingLabelStyle: TextStyle(color: palette.text),
      hintStyle: TextStyle(color: palette.muted),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: inputBorder(palette.line),
      enabledBorder: inputBorder(palette.line),
      focusedBorder: inputBorder(palette.text, 1.5),
      errorBorder: inputBorder(palette.danger),
      focusedErrorBorder: inputBorder(palette.danger, 1.5),
      errorStyle: TextStyle(color: palette.danger),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: palette.text,
      selectionColor: palette.accent.withValues(alpha: 0.4),
      selectionHandleColor: palette.accent,
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: palette.text,
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: TextStyle(
        fontFamily: textFont,
        fontSize: 13,
        color: palette.background,
      ),
      waitDuration: const Duration(milliseconds: 400),
    ),
    // Signal rather than accent: a slider is read, not filled.
    sliderTheme: SliderThemeData(
      activeTrackColor: palette.signal,
      inactiveTrackColor: palette.line,
      thumbColor: palette.signal,
      overlayColor: palette.signal.withValues(alpha: 0.12),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: palette.muted),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: palette.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      indicatorColor: palette.accent,
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? palette.onAccent
              : palette.muted,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? TextStyle(
                fontFamily: textFont,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: palette.text,
              )
            : TextStyle(
                fontFamily: textFont,
                fontSize: 13,
                color: palette.muted,
              ),
      ),
    ),
  );
}
