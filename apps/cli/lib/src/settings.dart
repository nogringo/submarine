import 'dart:convert';
import 'dart:io';

import 'package:nostr_passwords/nostr_passwords.dart';
import 'package:path/path.dart' as p;

import 'cli_exception.dart';

const defaultRelays = [
  'wss://relay.nmail.li',
  'wss://nos.lol',
  'wss://nostr.mom',
  'wss://relay.primal.net',
  'wss://relay.nos.social',
  'wss://offchain.pub',
  'wss://relay.coinos.io',
  'wss://nostr-pub.wellorder.net',
  'wss://relay.ditto.pub',
];

/// Whether `SUBMARINE_NSEC` is set, valid or not.
bool hasVaultKey(Map<String, String> environment) =>
    environment['SUBMARINE_NSEC']?.trim().isNotEmpty ?? false;

/// The vault's private key, in hex, from `SUBMARINE_NSEC` (an nsec or hex).
String vaultPrivateKey(Map<String, String> environment) {
  final value = environment['SUBMARINE_NSEC']?.trim() ?? '';
  if (value.isEmpty) {
    throw CliException('Set SUBMARINE_NSEC to the nsec of your vault key.');
  }
  return parseVaultKey(value) ??
      (throw CliException('SUBMARINE_NSEC is not a valid nsec.'));
}

File configFile(Map<String, String> environment) {
  final configHome =
      environment['XDG_CONFIG_HOME'] ??
      environment['APPDATA'] ??
      p.join(environment['HOME'] ?? '.', '.config');
  return File(p.join(configHome, 'submarine', 'config.json'));
}

Directory cacheDirectory(Map<String, String> environment) {
  final cacheHome =
      environment['XDG_CACHE_HOME'] ??
      environment['LOCALAPPDATA'] ??
      p.join(environment['HOME'] ?? '.', '.cache');
  return Directory(p.join(cacheHome, 'submarine'));
}

/// The relays listed in [config] (`{"relays": [...]}`), or [defaultRelays].
List<String> configuredRelays(File config) {
  if (!config.existsSync()) return defaultRelays;
  try {
    final json = jsonDecode(config.readAsStringSync()) as Map<String, dynamic>;
    return (json['relays'] as List).cast<String>();
  } catch (_) {
    throw CliException(
      '${config.path} must look like {"relays": ["wss://..."]}.',
    );
  }
}
