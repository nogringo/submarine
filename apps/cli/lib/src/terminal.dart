import 'dart:convert';
import 'dart:io';

/// Reads a line from stdin, showing [label] only when a person is typing. As
/// in bw, the label goes to stderr, out of what stdout pipes.
String prompt(String label) {
  if (stdin.hasTerminal) stderr.write(label);
  return stdin.readLineSync(encoding: utf8)?.trim() ?? '';
}

/// Like [prompt], without echoing what is typed.
String promptSecret(String label) {
  if (!stdin.hasTerminal) return prompt(label);
  stdin.echoMode = false;
  try {
    return prompt(label);
  } finally {
    stdin.echoMode = true;
    stderr.writeln();
  }
}

/// All of stdin, up to its end.
Future<String> readStdin() =>
    stdin.transform(const Utf8Decoder(allowMalformed: true)).join();
