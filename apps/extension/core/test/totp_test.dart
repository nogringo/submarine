import 'package:submarine_extension_core/core.dart';
import 'package:submarine_extension_core/totp.dart';
import 'package:test/test.dart';

void main() {
  test('gives the code of a key at a time, and its period', () {
    // RFC 6238's SHA-1 test vector, at 59 s.
    final at = DateTime.fromMillisecondsSinceEpoch(59000, isUtc: true);

    expect(totp('GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ', at), {
      'code': '287082',
      'period': 30,
    });
    expect(
      totp('otpauth://totp/x?secret=GEZDGNBVGY3TQOJQ&period=60', at),
      containsPair('period', 60),
    );
  });

  test('refuses a key it cannot read', () {
    expect(
      () => totp('otpauth://totp/x?digits=6', DateTime.now()),
      throwsA(
        isA<CoreException>().having(
          (error) => error.code,
          'code',
          'totpInvalid',
        ),
      ),
    );
  });
}
