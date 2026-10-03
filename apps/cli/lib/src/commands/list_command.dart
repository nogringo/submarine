import 'dart:io';

import 'package:nostr_passwords/nostr_passwords.dart';

import 'vault_command.dart';

class ListCommand extends VaultCommand {
  @override
  final name = 'list';

  @override
  final description = 'List the items of the vault.';

  @override
  Future<void> run() async {
    final items = await withVault((session) => session.items());
    if (items.isEmpty) {
      stderr.writeln('The vault is empty.');
      return;
    }
    items.sort(
      (a, b) =>
          a.cipher.name.toLowerCase().compareTo(b.cipher.name.toLowerCase()),
    );
    for (final item in items) {
      stdout.writeln(describe(item));
    }
  }
}

String describe(Item item) => switch (item.cipher.login?.username) {
  final username? => '${item.cipher.name} ($username)',
  null => item.cipher.name,
};
