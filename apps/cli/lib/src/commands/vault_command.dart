import 'dart:io';

import 'package:args/command_runner.dart';

import '../cli_exception.dart';
import '../output.dart';
import '../settings.dart';
import '../vault_session.dart';

/// bw's global flags, also accepted after the command as bw allows.
const outputFlags = {
  'pretty': 'Format output. JSON is tabbed with two spaces.',
  'raw': 'Return raw output instead of a descriptive message.',
  'quiet': "Don't return anything to stdout.",
};

abstract class VaultCommand extends Command<void> {
  VaultCommand() {
    for (final flag in outputFlags.keys) {
      argParser.addFlag(flag, negatable: false, hide: true);
    }
  }

  late final output = Output(
    pretty: _flag('pretty'),
    raw: _flag('raw'),
    quiet: _flag('quiet'),
  );

  bool _flag(String name) =>
      globalResults!.flag(name) || argResults!.flag(name);

  /// Does the work of [run], which reports a [CliException] as bw would.
  Future<void> execute();

  @override
  Future<void> run() async {
    try {
      await execute();
    } on CliException catch (error) {
      output.error(error.message);
      exitCode = 1;
    }
  }

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
