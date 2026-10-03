import 'dart:io';

import 'package:ndk/ndk.dart';
import 'package:path/path.dart' as p;
import 'package:submarine_cli/src/settings.dart';
import 'package:submarine_cli/submarine_cli.dart';
import 'package:test/test.dart';

void main() {
  group('vaultPrivateKey', () {
    final hexKey = 'ab' * 32;

    test('decodes an nsec', () {
      final nsec = Nip19.encodePrivateKey(hexKey);

      expect(vaultPrivateKey({'SUBMARINE_NSEC': ' $nsec\n'}), hexKey);
    });

    test('accepts a hex key', () {
      expect(vaultPrivateKey({'SUBMARINE_NSEC': hexKey}), hexKey);
    });

    test('rejects a missing, malformed or public key', () {
      for (final value in [
        null,
        '',
        'nsec1invalid',
        Nip19.encodePubKey(hexKey),
      ]) {
        expect(
          () => vaultPrivateKey({'SUBMARINE_NSEC': ?value}),
          throwsA(isA<CliException>()),
          reason: '$value',
        );
      }
    });
  });

  group('configuredRelays', () {
    late Directory directory;
    late File config;

    setUp(() {
      directory = Directory.systemTemp.createTempSync();
      config = File(p.join(directory.path, 'config.json'));
    });

    tearDown(() => directory.deleteSync(recursive: true));

    test('falls back to the default relays', () {
      expect(configuredRelays(config), defaultRelays);
    });

    test('reads the relays of the config file', () {
      config.writeAsStringSync('{"relays": ["wss://relay.example.com"]}');

      expect(configuredRelays(config), ['wss://relay.example.com']);
    });

    test('rejects a malformed config file', () {
      config.writeAsStringSync('{"relays": "wss://relay.example.com"}');

      expect(() => configuredRelays(config), throwsA(isA<CliException>()));
    });
  });

  test('configFile follows XDG_CONFIG_HOME, then HOME', () {
    expect(
      configFile({'XDG_CONFIG_HOME': '/xdg', 'HOME': '/home/alice'}).path,
      p.join('/xdg', 'submarine', 'config.json'),
    );
    expect(
      configFile({'HOME': '/home/alice'}).path,
      p.join('/home/alice', '.config', 'submarine', 'config.json'),
    );
  });

  test('cacheDirectory follows XDG_CACHE_HOME, then HOME', () {
    expect(
      cacheDirectory({'XDG_CACHE_HOME': '/xdg', 'HOME': '/home/alice'}).path,
      p.join('/xdg', 'submarine'),
    );
    expect(
      cacheDirectory({'HOME': '/home/alice'}).path,
      p.join('/home/alice', '.cache', 'submarine'),
    );
  });
}
