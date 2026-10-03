import 'dart:io';

import 'package:args/command_runner.dart';

import '../settings.dart';
import '../vault_session.dart';

abstract class VaultCommand extends Command<void> {
  List<String> get relays {
    final fromOption = globalResults!.multiOption('relay');
    return fromOption.isNotEmpty
        ? fromOption
        : configuredRelays(configFile(Platform.environment));
  }

  String singleArgument(String name) {
    final arguments = argResults!.rest;
    if (arguments.length != 1) usageException('Expected one <$name>.');
    return arguments.single;
  }

  Future<T> withVault<T>(
    Future<T> Function(VaultSession session) action,
  ) async {
    final session = VaultSession(
      privateKey: vaultPrivateKey(Platform.environment),
      relays: relays,
      cacheDirectory: cacheDirectory(Platform.environment),
    );
    try {
      return await action(session);
    } finally {
      await session.close();
    }
  }
}
