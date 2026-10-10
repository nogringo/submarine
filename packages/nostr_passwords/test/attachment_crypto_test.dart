import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:nostr_passwords/nostr_passwords.dart';
import 'package:test/test.dart';

void main() {
  final file = utf8.encode('Passport number 12AB34567');

  test('decrypts what it encrypted', () async {
    final (attachment, encrypted) = await encryptAttachment(
      'passport.txt',
      file,
    );

    expect(await decryptAttachment(attachment, encrypted), file);
  });

  test('describes the encrypted file, 28 bytes larger', () async {
    final (attachment, encrypted) = await encryptAttachment(
      'passport.txt',
      file,
    );

    expect(attachment.fileName, 'passport.txt');
    expect(attachment.id, matches(RegExp(r'^[0-9a-f]{32}$')));
    expect(base64Decode(attachment.key), hasLength(32));
    expect(encrypted, hasLength(file.length + 28));
    expect(attachment.size, '${encrypted.length}');
    expect(attachment.sha256, sha256.convert(encrypted).toString());
  });

  test('encrypts each file under a key of its own', () async {
    final (first, _) = await encryptAttachment('a.txt', file);
    final (second, _) = await encryptAttachment('a.txt', file);

    expect(second.key, isNot(first.key));
    expect(second.sha256, isNot(first.sha256));
    expect(second.id, isNot(first.id));
  });

  test('reads the nonce, the cipher text, then the tag', () async {
    // Test case 14 of the GCM specification: a zero key, nonce and block.
    final attachment = Attachment(
      id: 'id',
      fileName: 'zeros',
      key: base64Encode(List.filled(32, 0)),
      size: '44',
      sha256: '',
    );
    final encrypted = [
      ...List.filled(12, 0),
      ..._hex('cea7403d4d606b6e074ec5d3baf39d18'),
      ..._hex('d0d1c8a799996bf0265b98b5d48ab919'),
    ];

    expect(await decryptAttachment(attachment, encrypted), List.filled(16, 0));
  });

  test('opens nothing under the key of another file', () async {
    final (_, encrypted) = await encryptAttachment('a.txt', file);
    final (other, _) = await encryptAttachment('a.txt', file);

    expect(await decryptAttachment(other, encrypted), isNull);
  });

  test('opens nothing altered or cut short', () async {
    final (attachment, encrypted) = await encryptAttachment('a.txt', file);
    final altered = [...encrypted]..[20] ^= 1;

    expect(await decryptAttachment(attachment, altered), isNull);
    expect(
      await decryptAttachment(attachment, encrypted.sublist(0, 27)),
      isNull,
    );
  });

  test('opens nothing with a key that is not one', () async {
    final (attachment, encrypted) = await encryptAttachment('a.txt', file);

    expect(
      await decryptAttachment(attachment..key = 'not base64', encrypted),
      isNull,
    );
    expect(
      await decryptAttachment(
        attachment..key = base64Encode([1, 2]),
        encrypted,
      ),
      isNull,
    );
  });
}

List<int> _hex(String text) => [
  for (var i = 0; i < text.length; i += 2)
    int.parse(text.substring(i, i + 2), radix: 16),
];
