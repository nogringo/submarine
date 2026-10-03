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

void main() {
  final items = [
    item(
      'aaaaaaaa11111111aaaaaaaa11111111',
      Cipher(
        type: CipherType.login,
        name: 'Société Générale',
        login: Login(
          username: 'alice@example.com',
          uris: [LoginUri('https://particuliers.sg.fr/login')],
        ),
      ),
    ),
    item(
      'bbbbbbbb22222222bbbbbbbb22222222',
      Cipher(
        type: CipherType.login,
        name: 'GitHub',
        login: Login(username: 'alice'),
      ),
    ),
    item(
      'cccccccc33333333cccccccc33333333',
      Cipher(
        type: CipherType.secureNote,
        name: 'GitHub recovery codes',
        notes: 'abcd-efgh',
      ),
    ),
    item(
      'dddddddd44444444dddddddd44444444',
      Cipher(
        type: CipherType.card,
        name: 'Card',
        card: PaymentCard(brand: 'Amex', number: '378282246310005'),
      ),
    ),
  ];

  List<String> search(String query) => [
    for (final item in searchItems(items, query)) item.cipher.name,
  ];

  test('finds every word, in any order, ignoring case and accents', () {
    expect(search('generale SOCIETE'), ['Société Générale']);
    expect(search('github'), ['GitHub', 'GitHub recovery codes']);
    expect(search('github codes'), ['GitHub recovery codes']);
  });

  test('looks in the subtitle, hostnames and notes', () {
    expect(search('alice@'), ['Société Générale']);
    expect(search('*10005'), ['Card']);
    expect(search('sg.fr'), ['Société Générale']);
    expect(search('/login'), isEmpty);
    expect(search('efgh'), ['GitHub recovery codes']);
  });

  test('matches the start of an id from 8 characters', () {
    expect(search('bbbbbbbb2'), ['GitHub']);
    expect(search('bbbbbbb'), isEmpty);
  });

  test('ignores the hostname of a regex URI', () {
    final regex = item(
      'eeeeeeee55555555eeeeeeee55555555',
      Cipher(
        type: CipherType.login,
        name: 'Regex',
        login: Login(
          uris: [
            LoginUri(
              r'https://example\.com/.*',
              match: UriMatchStrategy.regularExpression,
            ),
          ],
        ),
      ),
    );

    expect(searchItems([regex], 'example'), isEmpty);
  });
}
