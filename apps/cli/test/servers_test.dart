import 'package:nostr_passwords/nostr_passwords.dart';
import 'package:submarine_cli/src/servers.dart';
import 'package:submarine_cli/submarine_cli.dart';
import 'package:test/test.dart';

void main() {
  const list = ServerList(
    public: ['https://blossom.nmail.li', 'https://nostr.download/'],
    private: ['https://files.alice.example'],
  );

  test('serverUrl normalizes a server URL', () {
    expect(
      serverUrl(' HTTPS://Blossom.Example.com/ '),
      'https://blossom.example.com',
    );
    expect(serverUrl('blossom.example.com'), 'https://blossom.example.com');
  });

  test('serverUrl refuses what is not an http URL', () {
    expect(() => serverUrl('wss://relay.example.com'), throwsCliException);
    expect(() => serverUrl('https://typo'), throwsCliException);
  });

  test('withoutServer removes a server serverUrl refuses', () {
    const typo = ServerList(
      public: ['https://typo', 'https://blossom.nmail.li'],
    );

    expect(withoutServer(typo, 'https://typo').urls, [
      'https://blossom.nmail.li',
    ]);
    expect(withoutServer(typo, 'blossom.nmail.li').urls, ['https://typo']);
  });

  test('withoutServer removes a public or a private server', () {
    final removed = withoutServer(
      withoutServer(list, 'nostr.download'),
      'https://files.alice.example',
    );

    expect(removed.public, ['https://blossom.nmail.li']);
    expect(removed.private, isEmpty);
  });

  test('withoutServer refuses a server not listed', () {
    expect(
      () => withoutServer(list, 'https://blossom.example.com'),
      throwsCliException,
    );
  });

  test('withoutServer refuses to remove the last server', () {
    const single = ServerList(public: ['https://blossom.nmail.li']);

    expect(
      () => withoutServer(single, 'https://blossom.nmail.li'),
      throwsCliException,
    );
  });

  test('serversJson lists the public servers, then the private ones', () {
    expect(serversJson(list), [
      {'url': 'https://blossom.nmail.li', 'private': false},
      {'url': 'https://nostr.download/', 'private': false},
      {'url': 'https://files.alice.example', 'private': true},
    ]);
  });
}

final throwsCliException = throwsA(isA<CliException>());
