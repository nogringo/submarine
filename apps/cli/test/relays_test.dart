import 'package:nostr_passwords/nostr_passwords.dart';
import 'package:submarine_cli/src/relays.dart';
import 'package:submarine_cli/submarine_cli.dart';
import 'package:test/test.dart';

void main() {
  const list = RelayList(
    public: {
      'wss://relay.primal.net': ReadWriteMarker.readWrite,
      'wss://relay.nos.social/': ReadWriteMarker.readOnly,
    },
    private: {'wss://relay.alice.example': ReadWriteMarker.writeOnly},
  );

  test('relayUrl normalizes a relay URL', () {
    expect(relayUrl(' WSS://Relay.Example.com/ '), 'wss://relay.example.com');
  });

  test('relayUrl refuses what is not a websocket URL', () {
    expect(() => relayUrl('https://relay.example.com'), throwsCliException);
    expect(() => relayUrl('wss://typo'), throwsCliException);
  });

  test('withoutRelay removes a relay relayUrl refuses, or without wss://', () {
    const typo = RelayList(
      public: {
        'wss://typo': ReadWriteMarker.readWrite,
        'wss://relay.primal.net': ReadWriteMarker.readWrite,
      },
    );

    expect(withoutRelay(typo, 'wss://typo').urls, {'wss://relay.primal.net'});
    expect(withoutRelay(typo, 'relay.primal.net').urls, {'wss://typo'});
  });

  test('withoutRelay removes a public or a private relay', () {
    final removed = withoutRelay(
      withoutRelay(list, 'wss://relay.nos.social'),
      'wss://relay.alice.example',
    );

    expect(removed.public, {
      'wss://relay.primal.net': ReadWriteMarker.readWrite,
    });
    expect(removed.private, isEmpty);
  });

  test('withoutRelay refuses a relay not listed', () {
    expect(
      () => withoutRelay(list, 'wss://relay.example.com'),
      throwsCliException,
    );
  });

  test('withoutRelay refuses to remove the last relay', () {
    const single = RelayList(
      public: {'wss://relay.primal.net': ReadWriteMarker.readWrite},
    );

    expect(
      () => withoutRelay(single, 'wss://relay.primal.net'),
      throwsCliException,
    );
  });

  test('relaysJson lists the public relays, then the private ones', () {
    expect(relaysJson(list), [
      {
        'url': 'wss://relay.primal.net',
        'read': true,
        'write': true,
        'private': false,
      },
      {
        'url': 'wss://relay.nos.social/',
        'read': true,
        'write': false,
        'private': false,
      },
      {
        'url': 'wss://relay.alice.example',
        'read': false,
        'write': true,
        'private': true,
      },
    ]);
  });
}

final throwsCliException = throwsA(isA<CliException>());
