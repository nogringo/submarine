import 'dart:convert';
import 'dart:io';

/// Prints what a command returns the way the Bitwarden CLI does, so scripts
/// written for `bw` read Submarine alike.
class Output {
  Output({this.pretty = false, this.raw = false, this.quiet = false});

  /// `--pretty`: JSON indented with two spaces.
  final bool pretty;

  /// `--raw`: a message's raw value instead of its text.
  final bool raw;

  /// `--quiet`: nothing at all, errors included.
  final bool quiet;

  void json(Object? value) => _write(stdout, formatJson(value, pretty: pretty));

  void string(String? value) {
    if (value != null) _write(stdout, value);
  }

  /// Under `--raw`, bw prints the message's [rawValue] instead, nothing when
  /// it has none.
  void message(String text, {String? rawValue}) {
    if (!raw) {
      _write(stdout, text);
    } else if (rawValue != null) {
      _write(stdout, rawValue);
    }
  }

  void error(String message) => _write(stderr, message);

  void _write(Stdout stream, String text) {
    if (quiet) return;
    // As bw does, so that `get password` pipes the bare password.
    if (Platform.isWindows || !stream.hasTerminal) {
      stream.write(text);
    } else {
      stream.writeln(text);
    }
  }
}

String formatJson(Object? value, {bool pretty = false}) =>
    JsonEncoder.withIndent(pretty ? '  ' : null).convert(value);
