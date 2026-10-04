import 'dart:convert';

import 'package:nostr_passwords/nostr_passwords.dart';
import 'package:submarine_cli/src/item_json.dart';
import 'package:test/test.dart';

Item item(Map<String, dynamic> data) => Item([
  Envelope(
    id: 'aaaaaaaa11111111aaaaaaaa11111111',
    type: 'item',
    rev: 'rev',
    parents: const [],
    modifiedAt: DateTime.utc(2026),
    data: data,
  ),
]);

void main() {
  test('adds the fields bw prints around the cipher', () {
    final json = itemJson(
      item(
        Cipher(
          type: CipherType.login,
          name: 'GitHub',
          login: Login(username: 'alice', password: 'octocat'),
        ).toJson(),
      ),
    );

    expect(json, containsPair('object', 'item'));
    expect(json, containsPair('id', 'aaaaaaaa11111111aaaaaaaa11111111'));
    expect(json, containsPair('organizationId', null));
    expect(json, containsPair('collectionIds', isEmpty));
    expect(json, containsPair('name', 'GitHub'));
    expect(json['login'], containsPair('password', 'octocat'));
  });

  test('replaces the ids an item imported from Bitwarden carries', () {
    final json = itemJson(
      item({
        'type': 1,
        'name': 'GitHub',
        'id': '2f6b3c1e-0000-4000-8000-000000000000',
        'organizationId': '7a1d9e2f-0000-4000-8000-000000000000',
        'collectionIds': ['9c8b7a6d-0000-4000-8000-000000000000'],
      }),
    );

    expect(json, containsPair('id', 'aaaaaaaa11111111aaaaaaaa11111111'));
    expect(json, containsPair('organizationId', null));
    expect(json, containsPair('collectionIds', isEmpty));
  });

  group('decodeItemJson', () {
    String encode(Object? json) => base64.encode(utf8.encode(jsonEncode(json)));

    final printed = itemJson(
      item(
        Cipher(
          type: CipherType.login,
          name: 'Boulanger',
          login: Login(username: 'alice', password: 'hunter2'),
        ).toJson(),
      ),
    );

    test('reads back the cipher itemJson printed', () {
      final cipher = decodeItemJson(encode(printed));

      expect(cipher.name, 'Boulanger');
      expect(cipher.login?.password, 'hunter2');
      expect(
        cipher.toJson().keys,
        isNot(
          anyOf(contains('object'), contains('id'), contains('collectionIds')),
        ),
      );
    });

    test('skips line breaks, as bw does', () {
      final encoded = encode(printed);
      final wrapped = [
        for (var start = 0; start < encoded.length; start += 76)
          encoded.substring(start, (start + 76).clamp(0, encoded.length)),
      ].join('\n');

      expect(decodeItemJson('$wrapped\n').name, 'Boulanger');
    });

    test('throws a FormatException when it is not an item', () {
      for (final encoded in [
        'not base64!',
        base64.encode(utf8.encode('{not json')),
        encode(['an', 'array']),
        encode({'type': 'login', 'name': 'Boulanger'}),
      ]) {
        expect(
          () => decodeItemJson(encoded),
          throwsFormatException,
          reason: encoded,
        );
      }
    });
  });
}
