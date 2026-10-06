import 'package:ndk/ndk.dart';
import 'package:nostr_passwords/nostr_passwords.dart';
import 'package:test/test.dart';

void main() {
  final hexKey = 'ab' * 32;

  test('decodes an nsec', () {
    final nsec = Nip19.encodePrivateKey(hexKey);

    expect(parseVaultKey(' $nsec\n'), hexKey);
    expect(parseVaultKey(nsec.toUpperCase()), hexKey);
  });

  test('accepts a hex key', () {
    expect(parseVaultKey(hexKey), hexKey);
    expect(parseVaultKey(hexKey.toUpperCase()), hexKey);
  });

  test('rejects a malformed or public key', () {
    for (final text in [
      '',
      'nsec1invalid',
      'ab' * 31,
      Nip19.encodePubKey(hexKey),
    ]) {
      expect(parseVaultKey(text), isNull, reason: text);
    }
  });

  group('encrypted vault key', () {
    // The test vector of NIP-49.
    const ncryptsec =
        'ncryptsec1qgg9947rlpvqu76pj5ecreduf9jxhselq2nae2kghhvd5g7dgjtcxfqtd67p9m0w57lspw8gsq6yphnm8623nsl8xn9j4jdzz84zm3frztj3z7s35vpzmqf6ksu8r89qk5z2zxfmu5gv8th8wclt0h4p';

    test('is told apart from other keys', () {
      expect(isEncryptedVaultKey(' $ncryptsec\n'), isTrue);
      expect(isEncryptedVaultKey(ncryptsec.toUpperCase()), isTrue);
      for (final text in [
        '',
        'ncryptsec1invalid',
        ncryptsec.substring(0, ncryptsec.length - 1),
        Nip19.encodePrivateKey(hexKey),
        hexKey,
      ]) {
        expect(isEncryptedVaultKey(text), isFalse, reason: text);
      }
      expect(parseVaultKey(ncryptsec), isNull);
    });

    test('opens with its password only', () async {
      expect(
        await decryptVaultKey(' $ncryptsec\n', 'nostr'),
        '3501454135014541350145413501453fefb02227e449e57cf4d3a3ce05378683',
      );
      expect(await decryptVaultKey(ncryptsec, 'nostr '), isNull);
    });
  });
}
