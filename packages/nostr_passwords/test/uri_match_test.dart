import 'package:nostr_passwords/nostr_passwords.dart';
import 'package:test/test.dart';

Item item(String id, Cipher cipher) => Item([
  Envelope(
    id: id,
    type: 'item',
    rev: 'rev',
    parents: const [],
    modifiedAt: DateTime.utc(2026),
    data: cipher.toJson(),
  ),
]);

Cipher login(String name, List<LoginUri> uris) => Cipher(
  type: CipherType.login,
  name: name,
  login: Login(uris: uris),
);

void main() {
  bool matches(String saved, String url, [UriMatchStrategy? match]) =>
      uriMatches(LoginUri(saved, match: match), url);

  group('by base domain, without a match detection', () {
    test('matches every host of the domain, whatever the scheme or path', () {
      expect(matches('https://github.com', 'https://gist.github.com/a'), true);
      expect(matches('github.com', 'http://www.github.com:8080/login'), true);
      expect(matches('https://GitHub.com/login', 'https://github.com/'), true);
      expect(matches('https://github.com', 'https://github.io'), false);
      expect(matches('https://github.com', 'https://notgithub.com'), false);
    });

    test('reads the domain under its public suffix', () {
      expect(matches('https://www.bbc.co.uk', 'https://bbc.co.uk/news'), true);
      expect(matches('https://bbc.co.uk', 'https://itv.co.uk'), false);
      expect(matches('http://nas.home.arpa', 'http://router.home.arpa'), false);
      expect(matches('http://shop.example.ck', 'http://example.ck'), false);
      expect(matches('http://a.www.ck', 'http://b.www.ck'), true);
    });

    test('tells the private domains of the list apart', () {
      expect(
        matches('https://alice.github.io', 'https://bob.github.io'),
        false,
      );
      expect(
        matches('https://alice.github.io', 'https://www.alice.github.io'),
        true,
      );
    });

    test('takes an unknown top-level domain as a public suffix', () {
      expect(matches('http://nas.lan', 'http://files.nas.lan'), true);
      expect(matches('http://intranet', 'http://intranet/'), false);
    });

    test('matches localhost and an IP address on their own', () {
      expect(matches('http://localhost:3000', 'http://localhost:8080'), true);
      expect(matches('localhost', 'http://app.localhost'), true);
      expect(matches('192.168.1.1', 'http://192.168.1.1:5000/'), true);
      expect(matches('192.168.1.1', 'http://192.168.1.2/'), false);
      expect(matches('http://[::1]', 'http://[::1]:8080/'), true);
    });

    test('reads an internationalized domain as the browser gives it', () {
      expect(matches('https://bücher.de', 'https://xn--bcher-kva.de/'), true);
      expect(
        matches('https://пример.рф', 'https://xn--e1afmkfd.xn--p1ai'),
        true,
      );
    });

    test('leaves out script.google.com, where anyone runs a script', () {
      expect(matches('accounts.google.com', 'https://mail.google.com'), true);
      expect(
        matches('accounts.google.com', 'https://script.google.com'),
        false,
      );
    });

    test('matches nothing without a host', () {
      expect(matches('', 'https://github.com'), false);
      expect(matches('https://github.com', ''), false);
      expect(matches('about:blank', 'about:blank'), false);
      expect(matches('data:text/plain,a', 'data:text/plain,a'), false);
    });
  });

  test('by host, matches its port too, unless the default one', () {
    const host = UriMatchStrategy.host;
    expect(
      matches(
        'https://a.example.com:4000',
        'https://a.example.com:4000/x',
        host,
      ),
      true,
    );
    expect(
      matches('a.example.com:4000', 'https://a.example.com:4000', host),
      true,
    );
    expect(
      matches('https://a.example.com:4000', 'https://a.example.com:5000', host),
      false,
    );
    expect(
      matches('https://a.example.com:4000', 'https://example.com:4000', host),
      false,
    );
    expect(
      matches('https://example.com', 'https://example.com:443/x', host),
      true,
    );
    expect(
      matches('https://example.com', 'https://www.example.com', host),
      false,
    );
    expect(matches('localhost', 'http://localhost/', host), false);
  });

  test('by start, compares the text as it is', () {
    const startsWith = UriMatchStrategy.startsWith;
    expect(
      matches(
        'https://example.com/app',
        'https://example.com/app/login',
        startsWith,
      ),
      true,
    );
    expect(
      matches('https://example.com/app', 'https://example.com/', startsWith),
      false,
    );
    expect(matches('example.com', 'https://example.com', startsWith), false);
  });

  test('exactly, compares the whole text', () {
    const exact = UriMatchStrategy.exact;
    expect(
      matches('https://example.com/a', 'https://example.com/a', exact),
      true,
    );
    expect(
      matches('https://example.com', 'https://example.com/', exact),
      false,
    );
  });

  test(
    'by regular expression, ignores case, and an invalid one matches nothing',
    () {
      const regex = UriMatchStrategy.regularExpression;
      expect(
        matches(
          r'^https://(www\.)?example\.com/',
          'https://WWW.example.com/a',
          regex,
        ),
        true,
      );
      expect(
        matches(r'^https://example\.com/$', 'https://example.com/a', regex),
        false,
      );
      expect(matches('(', 'https://example.com', regex), false);
    },
  );

  test('never matches with Never', () {
    expect(
      matches(
        'https://example.com',
        'https://example.com',
        UriMatchStrategy.never,
      ),
      false,
    );
  });

  test('suggests the logins out of the trash and the archive with a URI that matches', () {
    final items = [
      item(
        '1',
        login('GitHub', [
          LoginUri('https://example.org'),
          LoginUri('github.com'),
        ]),
      ),
      item('2', login('GitHub work', [LoginUri('https://github.com/acme')])),
      item(
        '3',
        login('Old GitHub', [LoginUri('github.com')])
          ..deletedDate = DateTime.utc(2026),
      ),
      item(
        '4',
        login('Archived GitHub', [LoginUri('github.com')])
          ..archivedDate = DateTime.utc(2026),
      ),
      item('5', login('GitLab', [LoginUri('gitlab.com')])),
      item(
        '6',
        login('Never', [LoginUri('github.com', match: UriMatchStrategy.never)]),
      ),
      item(
        '7',
        Cipher(
          type: CipherType.secureNote,
          name: 'github.com',
          notes: 'github.com',
        ),
      ),
    ];
    expect(
      [
        for (final item in itemsForUrl(items, 'https://github.com/login'))
          item.cipher.name,
      ],
      ['GitHub', 'GitHub work'],
    );
  });
}
