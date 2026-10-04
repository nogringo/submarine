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
}
