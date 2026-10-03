import 'dart:convert';
import 'dart:io';

import 'package:ndk/ndk.dart';
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

final _hexKey = RegExp(r'^[0-9a-f]{64}$');

/// The vault's private key, in hex, from `SUBMARINE_NSEC` (an nsec or hex).
String vaultPrivateKey(Map<String, String> environment) {
  final value = environment['SUBMARINE_NSEC']?.trim().toLowerCase() ?? '';
  if (value.isEmpty) {
    throw CliException('Set SUBMARINE_NSEC to the nsec of your vault key.');
  }
  // Nip19.decode decodes an npub too, and returns '' when it fails.
  final key = value.startsWith('nsec1') ? Nip19.decode(value) : value;
  if (!_hexKey.hasMatch(key)) {
    throw CliException('SUBMARINE_NSEC is not a valid nsec.');
  }
  return key;
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
