import 'dart:convert';
import 'dart:io';

/// Reads a line from stdin, showing [label] only when a person is typing.
String prompt(String label) {
  if (stdin.hasTerminal) stdout.write(label);
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
    stdout.writeln();
  }
}

/// All of stdin, up to its end.
Future<String> readStdin() =>
    stdin.transform(const Utf8Decoder(allowMalformed: true)).join();
