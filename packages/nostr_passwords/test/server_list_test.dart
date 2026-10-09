import 'package:ndk/ndk.dart';
import 'package:nostr_passwords/nostr_passwords.dart';
import 'package:test/test.dart';

void main() {
  const signerFactory = Bip340EventSignerFactory();
  late EventSigner vault;

  setUp(() => vault = signerFactory.createWithNewKeyPair());

  test('public servers go in the tags, private ones in the content', () async {
    final event = await signServerList(
      const ServerList(
        public: ['https://blossom.nmail.li', 'https://nostr.download'],
        private: ['https://files.alice.example'],
      ),
      vault,
    );

    expect(event.kind, 10063);
    expect(event.pubKey, vault.getPublicKey());
    expect(event.tags, [
      ['server', 'https://blossom.nmail.li'],
      ['server', 'https://nostr.download'],
    ]);
    expect(event.content, isNot(contains('files.alice.example')));
  });

  test('the vault reads its servers back, in order', () async {
    const servers = ServerList(
      public: ['https://nostr.download', 'https://blossom.nmail.li'],
      private: ['https://files.bob.example', 'https://files.alice.example'],
    );

    final list = await readServerList(
      await signServerList(servers, vault),
      vault,
    );

    expect(list.public, servers.public);
    expect(list.private, servers.private);
  });

  test('without private servers, the content is empty', () async {
    final event = await signServerList(
      const ServerList(public: ['https://blossom.nmail.li']),
      vault,
    );

    expect(event.content, isEmpty);
    expect((await readServerList(event, vault)).private, isEmpty);
  });

  test('a server list signed by another key is rejected', () async {
    final other = signerFactory.createWithNewKeyPair();
    final event = await signServerList(
      const ServerList(public: ['https://blossom.nmail.li']),
      other,
    );

    expect(readServerList(event, vault), throwsFormatException);
  });

  group('changing a list', () {
    const list = ServerList(
      public: ['https://blossom.nmail.li', 'https://Nostr.Download/'],
      private: ['https://files.alice.example'],
    );

    test('urls lists the public servers, then the private ones', () {
      expect(list.urls, [
        'https://blossom.nmail.li',
        'https://Nostr.Download/',
        'https://files.alice.example',
      ]);
    });

    test('contains compares normalized URLs', () {
      expect(list.contains('nostr.download'), isTrue);
      expect(list.contains('https://blossom.example.com'), isFalse);
    });

    test('withServer adds a public or a private server, normalized', () {
      final added = list
          .withServer(' HTTPS://Blossom.Example.com/ ')
          .withServer('files.bob.example', private: true);

      expect(added.public, [...list.public, 'https://blossom.example.com']);
      expect(added.private, [...list.private, 'https://files.bob.example']);
    });

    test('withServer moves a server already listed', () {
      final changed = list.withServer('nostr.download', private: true);

      expect(changed.public, ['https://blossom.nmail.li']);
      expect(changed.private, [
        'https://files.alice.example',
        'https://nostr.download',
      ]);
    });

    test('withServer refuses what parseServerUrl refuses', () {
      expect(
        () => list.withServer('wss://relay.example.com'),
        throwsArgumentError,
      );
      expect(() => list.withServer('https://typo'), throwsArgumentError);
    });

    test('without removes a public or a private server', () {
      final removed = list
          .without('https://nostr.download')
          .without('https://files.alice.example');

      expect(removed.public, ['https://blossom.nmail.li']);
      expect(removed.private, isEmpty);
      expect(removed.without('blossom.nmail.li').isEmpty, isTrue);
    });
  });

  group('parseServerUrl', () {
    test('normalizes a server URL', () {
      expect(
        parseServerUrl(' HTTPS://Blossom.Example.com:443/ '),
        'https://blossom.example.com',
      );
      expect(
        parseServerUrl('https://files.example.com/blossom/'),
        'https://files.example.com/blossom',
      );
      expect(
        parseServerUrl('http://192.168.1.10:3000'),
        'http://192.168.1.10:3000',
      );
      expect(parseServerUrl('http://localhost:3000'), 'http://localhost:3000');
    });

    test('takes an address without a scheme for https://', () {
      expect(
        parseServerUrl('blossom.example.com'),
        'https://blossom.example.com',
      );
    });

    test('refuses what is not an http URL', () {
      expect(parseServerUrl('wss://blossom.example.com'), isNull);
      expect(parseServerUrl('https://blossom.example.com/?a=1'), isNull);
      expect(parseServerUrl('https://alice@blossom.example.com'), isNull);
      expect(parseServerUrl(''), isNull);
    });

    test('refuses a host without a dot', () {
      expect(parseServerUrl('typo'), isNull);
      expect(parseServerUrl('https://typo'), isNull);
    });
  });
}
