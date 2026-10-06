import 'dart:convert';

import 'package:nostr_passwords/nostr_passwords.dart';

import '../secure_storage.dart';

enum GeneratorType { password, passphrase }

/// The generator's last options, which it opens with next time, as in
/// Bitwarden.
class GeneratorSettings {
  const GeneratorSettings({
    this.type = GeneratorType.password,
    this.password = const PasswordGeneratorOptions(),
    this.passphrase = const PassphraseGeneratorOptions(),
    this.username = const UsernameGeneratorOptions(),
  });

  factory GeneratorSettings.fromJson(Map<String, dynamic> json) =>
      GeneratorSettings(
        type:
            GeneratorType.values.asNameMap()[json['type']] ??
            GeneratorType.password,
        password: PasswordGeneratorOptions.fromJson(
          json['password'] as Map<String, dynamic>? ?? const {},
        ),
        passphrase: PassphraseGeneratorOptions.fromJson(
          json['passphrase'] as Map<String, dynamic>? ?? const {},
        ),
        username: UsernameGeneratorOptions.fromJson(
          json['username'] as Map<String, dynamic>? ?? const {},
        ),
      );

  static const _key = 'generator';

  static Future<GeneratorSettings> read() async {
    final json = await secureStorage.read(key: _key);
    if (json == null) return const GeneratorSettings();
    return GeneratorSettings.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  Future<void> write() =>
      secureStorage.write(key: _key, value: jsonEncode(toJson()));

  final GeneratorType type;
  final PasswordGeneratorOptions password;
  final PassphraseGeneratorOptions passphrase;
  final UsernameGeneratorOptions username;

  String generate() => switch (type) {
    GeneratorType.password => generatePassword(password),
    GeneratorType.passphrase => generatePassphrase(passphrase),
  };

  GeneratorSettings copyWith({
    GeneratorType? type,
    PasswordGeneratorOptions? password,
    PassphraseGeneratorOptions? passphrase,
    UsernameGeneratorOptions? username,
  }) => GeneratorSettings(
    type: type ?? this.type,
    password: password ?? this.password,
    passphrase: passphrase ?? this.passphrase,
    username: username ?? this.username,
  );

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'password': password.toJson(),
    'passphrase': passphrase.toJson(),
    'username': username.toJson(),
  };
}
