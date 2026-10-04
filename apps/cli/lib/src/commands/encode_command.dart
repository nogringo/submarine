import 'dart:convert';
import 'dart:io';

import '../cli_exception.dart';
import '../terminal.dart';
import 'vault_command.dart';

class EncodeCommand extends VaultCommand {
  @override
  final name = 'encode';

  @override
  final description = 'Base 64 encode stdin.';

  @override
  Future<void> execute() async {
    if (stdin.hasTerminal) throw CliException('No stdin was piped in.');
    output.string(base64.encode(utf8.encode(await readStdin())));
  }
}
