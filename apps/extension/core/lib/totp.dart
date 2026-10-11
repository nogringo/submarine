import 'package:nostr_passwords/nostr_passwords.dart';

import 'core.dart';

/// The code of the verification key [key] at [at], with how long a code lasts,
/// in seconds: the popup counts down the rest.
Map<String, Object> totp(String key, DateTime at) {
  try {
    final code = generateTotp(key, time: at);
    return {'code': code.code, 'period': code.period.inSeconds};
  } on FormatException {
    throw CoreException('totpInvalid');
  }
}
