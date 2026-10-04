import 'package:nostr_passwords/nostr_passwords.dart';
import 'package:test/test.dart';

void main() {
  // The cases of Bitwarden's SDK, bitwarden-vault/src/totp.rs.
  final time = DateTime.utc(2023);

  test('reads a base32 secret leniently, as Bitwarden does', () {
    const cases = {
      'WQIQ25BRKZYCJVYP': '194506',
      'wqiq25brkzycjvyp': '194506',
      'PIUDISEQYA': '829846',
      'PIUDISEQYA======': '829846',
      'PIUD1IS!EQYA=': '829846',
      'ddfdf': '932653',
      'HJSGFJHDFDJDJKSDFD': '000034',
      'xvdsfasdfasdasdghsgsdfg': '403786',
      'KAKFJWOSFJ12NWL': '093430',
    };
    for (final MapEntry(key: key, value: code) in cases.entries) {
      final totp = generateTotp(key, time: time);
      expect(totp.code, code, reason: key);
      expect(totp.period, const Duration(seconds: 30));
    }
  });

  test('reads a steam URI', () {
    const cases = {
      'steam://HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ': '7W6CJ',
      'StEam://HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ': '7W6CJ',
      'steam://ABCD123': 'N26DF',
    };
    for (final MapEntry(key: key, value: code) in cases.entries) {
      expect(generateTotp(key, time: time).code, code, reason: key);
    }
  });

  group('otpauth URI', () {
    test('defaults to SHA-1, 6 digits and 30 seconds', () {
      for (final key in [
        'otpauth://totp/test-account?secret=WQIQ25BRKZYCJVYP',
        'OTPauth://totp/test-account?secret=WQIQ25BRKZYCJVYP',
      ]) {
        final totp = generateTotp(key, time: time);
        expect(totp.code, '194506', reason: key);
        expect(totp.period, const Duration(seconds: 30));
      }
    });

    test('reads the period', () {
      final totp = generateTotp(
        'otpauth://totp/test-account?secret=WQIQ25BRKZYCJVYP&period=60',
        time: time,
      );

      expect(totp.code, '730364');
      expect(totp.period, const Duration(seconds: 60));
    });

    test('reads the algorithm', () {
      expect(
        generateTotp(
          'otpauth://totp/test-account?secret=WQIQ25BRKZYCJVYP&algorithm=SHA256',
          time: time,
        ).code,
        '842615',
      );
    });

    test('reads the digits', () {
      // RFC 6238, appendix B: SHA-512 at 59 seconds.
      expect(
        generateTotp(
          'otpauth://totp/rfc?algorithm=SHA512&digits=8&secret='
          'GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ'
          'GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQGEZDGNA',
          time: DateTime.fromMillisecondsSinceEpoch(59000, isUtc: true),
        ).code,
        '90693936',
      );
    });

    test('throws a FormatException without a secret', () {
      expect(
        () => generateTotp('otpauth://totp/test-account?issuer=Example'),
        throwsFormatException,
      );
    });
  });
}
