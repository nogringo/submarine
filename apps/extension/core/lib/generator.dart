import 'package:nostr_passwords/nostr_passwords.dart';

/// A value generated with [settings], the generator's settings as the app
/// saves them, a username with [username], and those settings as the
/// generator applied them: the defaults in place of what they lack, the
/// password's length raised to fit its minimums.
Map<String, Object> generate(
  Map<String, dynamic> settings, {
  bool username = false,
}) {
  Map<String, dynamic> options(String key) =>
      settings[key] as Map<String, dynamic>? ?? const {};
  final read = PasswordGeneratorOptions.fromJson(options('password'));
  final password = read.copyWith(
    length: read.effectiveLength,
    minNumber: read.minNumber.clamp(1, PasswordGeneratorOptions.maxMinCount),
    minSpecial: read.minSpecial.clamp(1, PasswordGeneratorOptions.maxMinCount),
  );
  final readPassphrase = PassphraseGeneratorOptions.fromJson(
    options('passphrase'),
  );
  final passphrase = readPassphrase.copyWith(
    numWords: readPassphrase.numWords.clamp(
      PassphraseGeneratorOptions.minWords,
      PassphraseGeneratorOptions.maxWords,
    ),
  );
  final usernameOptions = UsernameGeneratorOptions.fromJson(
    options('username'),
  );
  final isPassphrase = settings['type'] == 'passphrase';
  return {
    'value': username
        ? generateUsername(usernameOptions)
        : isPassphrase
        ? generatePassphrase(passphrase)
        : generatePassword(password),
    'settings': {
      'type': isPassphrase ? 'passphrase' : 'password',
      'password': password.toJson(),
      'passphrase': passphrase.toJson(),
      'username': usernameOptions.toJson(),
    },
  };
}
