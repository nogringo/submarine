import 'package:nostr_passwords/nostr_passwords.dart';

import 'vault_command.dart';

/// `bw generate`, options and defaults included. Needs no vault.
class GenerateCommand extends VaultCommand {
  GenerateCommand() {
    argParser
      ..addFlag(
        'uppercase',
        abbr: 'u',
        negatable: false,
        help: 'Include uppercase characters.',
      )
      ..addFlag(
        'lowercase',
        abbr: 'l',
        negatable: false,
        help: 'Include lowercase characters.',
      )
      ..addFlag(
        'number',
        abbr: 'n',
        negatable: false,
        help: 'Include numeric characters.',
      )
      ..addFlag(
        'special',
        abbr: 's',
        negatable: false,
        help: 'Include special characters.',
      )
      ..addFlag(
        'passphrase',
        abbr: 'p',
        negatable: false,
        help: 'Generate a passphrase.',
      )
      ..addOption('length', help: 'Length of the password.')
      ..addOption('words', help: 'Number of words.')
      ..addOption('minNumber', help: 'Minimum number of numeric characters.')
      ..addOption('minSpecial', help: 'Minimum number of special characters.')
      ..addOption('separator', help: 'Word separator.')
      ..addFlag(
        'capitalize',
        abbr: 'c',
        negatable: false,
        help: 'Title case passphrase.',
      )
      ..addFlag(
        'includeNumber',
        negatable: false,
        help: 'Passphrase includes number.',
      )
      ..addFlag(
        'ambiguous',
        negatable: false,
        help: 'Avoid ambiguous characters.',
      );
  }

  @override
  final name = 'generate';

  @override
  final description = 'Generate a password/passphrase.';

  @override
  String get usageFooter =>
      '\nDefault options are `-uln --length 14`. Minimum `length` is 5. '
      'Minimum `words` is 3.';

  @override
  Future<void> execute() async {
    final args = argResults!;
    if (args.flag('passphrase')) {
      const defaults = PassphraseGeneratorOptions();
      output.string(
        generatePassphrase(
          PassphraseGeneratorOptions(
            numWords: _number('words') ?? defaults.numWords,
            wordSeparator: switch (args.option('separator')) {
              null => defaults.wordSeparator,
              'space' => ' ',
              'empty' || '' => '',
              final separator => String.fromCharCode(separator.runes.first),
            },
            capitalize: args.flag('capitalize'),
            includeNumber: args.flag('includeNumber'),
          ),
        ),
      );
      return;
    }
    final sets = ['uppercase', 'lowercase', 'number', 'special'];
    // As bw does, no character set means the default ones.
    final noSet = !sets.any(args.flag);
    const defaults = PasswordGeneratorOptions();
    output.string(
      generatePassword(
        PasswordGeneratorOptions(
          length: _number('length') ?? defaults.length,
          uppercase: noSet || args.flag('uppercase'),
          lowercase: noSet || args.flag('lowercase'),
          numbers: noSet || args.flag('number'),
          special: args.flag('special'),
          minNumber: _number('minNumber') ?? defaults.minNumber,
          minSpecial: _number('minSpecial') ?? defaults.minSpecial,
          avoidAmbiguous: args.flag('ambiguous'),
        ),
      ),
    );
  }

  /// bw falls back to the default of a number it cannot read.
  int? _number(String option) => int.tryParse(argResults!.option(option) ?? '');
}
