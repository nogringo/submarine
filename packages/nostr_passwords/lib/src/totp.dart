import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

class TotpCode {
  const TotpCode(this.code, this.period);

  final String code;

  /// How long a code lasts.
  final Duration period;
}

/// The TOTP code of [key] at [time], now by default, as Bitwarden computes it.
/// [key] is a base32 secret, an `otpauth://` URI or a `steam://` URI.
///
/// Throws a [FormatException] for an `otpauth://` URI it cannot read.
TotpCode generateTotp(String key, {DateTime? time}) {
  final totp = _Totp.parse(key);
  final seconds = (time ?? DateTime.now()).millisecondsSinceEpoch ~/ 1000;
  final counter = seconds ~/ totp.period;
  // ByteData.setUint64 is not supported on the web.
  final message = ByteData(8)
    ..setUint32(0, counter ~/ 0x100000000)
    ..setUint32(4, counter % 0x100000000);
  final hash = Hmac(
    totp.hash,
    totp.secret,
  ).convert(message.buffer.asUint8List()).bytes;
  final offset = hash.last & 0xf;
  final binary =
      (hash[offset] & 0x7f) << 24 |
      hash[offset + 1] << 16 |
      hash[offset + 2] << 8 |
      hash[offset + 3];
  final code = totp.steam
      ? _steamCode(binary, totp.digits)
      : (binary % pow(10, totp.digits).toInt()).toString().padLeft(
          totp.digits,
          '0',
        );
  return TotpCode(code, Duration(seconds: totp.period));
}

class _Totp {
  _Totp(
    this.secret, {
    this.hash = sha1,
    this.digits = 6,
    this.period = 30,
    this.steam = false,
  });

  /// Bitwarden's SDK reads the whole key lowercased, URI parameters included.
  factory _Totp.parse(String key) {
    key = key.toLowerCase();
    if (key.startsWith('otpauth://')) {
      final Map<String, String> parameters;
      try {
        parameters = Uri.parse(key).queryParameters;
      } on ArgumentError {
        throw FormatException('Invalid otpauth URI.', key);
      }
      final secret =
          parameters['secret'] ??
          (throw FormatException('The otpauth URI has no secret.', key));
      return _Totp(
        _decodeBase32(secret),
        hash: switch (parameters['algorithm']) {
          'sha256' => sha256,
          'sha512' => sha512,
          _ => sha1,
        },
        digits: _parseUnsigned(parameters['digits'])?.clamp(0, 10) ?? 6,
        period: max(_parseUnsigned(parameters['period']) ?? 30, 1),
      );
    }
    if (key.startsWith('steam://')) {
      return _Totp(
        _decodeBase32(key.substring('steam://'.length)),
        digits: 5,
        steam: true,
      );
    }
    return _Totp(_decodeBase32(key));
  }

  final List<int> secret;
  final Hash hash;
  final int digits;

  /// In seconds.
  final int period;

  final bool steam;
}

int? _parseUnsigned(String? text) => switch (int.tryParse(text ?? '')) {
  final value? when value >= 0 => value,
  _ => null,
};

const _base32Alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';

/// Bitwarden's lenient base32: skips the characters out of the alphabet, and
/// the bits left over after the last full byte.
List<int> _decodeBase32(String text) {
  final bytes = <int>[];
  var buffer = 0;
  var bits = 0;
  for (final char in text.toUpperCase().split('')) {
    final value = _base32Alphabet.indexOf(char);
    if (value < 0) continue;
    buffer = (buffer << 5 | value) & 0xffff;
    bits += 5;
    if (bits >= 8) {
      bits -= 8;
      bytes.add(buffer >> bits & 0xff);
    }
  }
  return bytes;
}

const _steamAlphabet = '23456789BCDFGHJKMNPQRTVWXY';

String _steamCode(int binary, int digits) {
  final code = StringBuffer();
  for (var i = 0; i < digits; i++) {
    code.write(_steamAlphabet[binary % _steamAlphabet.length]);
    binary ~/= _steamAlphabet.length;
  }
  return code.toString();
}
