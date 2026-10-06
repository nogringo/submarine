import 'dart:math';

import 'eff_long_wordlist.dart';
import 'english_names.dart';

/// What [generatePassword] builds a password from, with the defaults of
/// Bitwarden's apps and `bw generate`. The JSON keys are those of Bitwarden's
/// SDK.
class PasswordGeneratorOptions {
  const PasswordGeneratorOptions({
    this.length = 14,
    this.uppercase = true,
    this.lowercase = true,
    this.numbers = true,
    this.special = false,
    this.minNumber = 1,
    this.minSpecial = 1,
    this.avoidAmbiguous = false,
  });

  factory PasswordGeneratorOptions.fromJson(Map<String, dynamic> json) {
    const defaults = PasswordGeneratorOptions();
    return PasswordGeneratorOptions(
      length: json['length'] as int? ?? defaults.length,
      uppercase: json['uppercase'] as bool? ?? defaults.uppercase,
      lowercase: json['lowercase'] as bool? ?? defaults.lowercase,
      numbers: json['numbers'] as bool? ?? defaults.numbers,
      special: json['special'] as bool? ?? defaults.special,
      minNumber: json['minNumber'] as int? ?? defaults.minNumber,
      minSpecial: json['minSpecial'] as int? ?? defaults.minSpecial,
      avoidAmbiguous:
          json['avoidAmbiguous'] as bool? ?? defaults.avoidAmbiguous,
    );
  }

  static const minLength = 5;
  static const maxLength = 128;

  /// The most [minNumber] and [minSpecial] can ask for.
  static const maxMinCount = 9;

  /// See [effectiveLength].
  final int length;

  final bool uppercase;

  final bool lowercase;

  final bool numbers;

  /// `!@#$%^&*`
  final bool special;

  /// The fewest digits, from 1 to [maxMinCount], when [numbers] is set.
  final int minNumber;

  /// The fewest special characters, from 1 to [maxMinCount], when [special]
  /// is set.
  final int minSpecial;

  /// Leaves out I, O, l, 0 and 1.
  final bool avoidAmbiguous;

  /// The length of the passwords: [length], between [minLength] and
  /// [maxLength], raised to fit the fewest characters of each set.
  int get effectiveLength =>
      length.clamp(max(minLength, _requiredCount), maxLength);

  int get _requiredCount => _requiredSets.fold(0, (sum, set) => sum + set.$2);

  /// Each enabled character set, with how many of its characters a password
  /// has at least.
  List<(String, int)> get _requiredSets {
    String usable(String set) =>
        avoidAmbiguous ? set.replaceAll(RegExp('[IOl01]'), '') : set;
    int count(int min) => min.clamp(1, maxMinCount);
    return [
      if (uppercase) (usable('ABCDEFGHIJKLMNOPQRSTUVWXYZ'), 1),
      if (lowercase) (usable('abcdefghijklmnopqrstuvwxyz'), 1),
      if (numbers) (usable('0123456789'), count(minNumber)),
      if (special) (r'!@#$%^&*', count(minSpecial)),
    ];
  }

  PasswordGeneratorOptions copyWith({
    int? length,
    bool? uppercase,
    bool? lowercase,
    bool? numbers,
    bool? special,
    int? minNumber,
    int? minSpecial,
    bool? avoidAmbiguous,
  }) => PasswordGeneratorOptions(
    length: length ?? this.length,
    uppercase: uppercase ?? this.uppercase,
    lowercase: lowercase ?? this.lowercase,
    numbers: numbers ?? this.numbers,
    special: special ?? this.special,
    minNumber: minNumber ?? this.minNumber,
    minSpecial: minSpecial ?? this.minSpecial,
    avoidAmbiguous: avoidAmbiguous ?? this.avoidAmbiguous,
  );

  Map<String, dynamic> toJson() => {
    'length': length,
    'uppercase': uppercase,
    'lowercase': lowercase,
    'numbers': numbers,
    'special': special,
    'minNumber': minNumber,
    'minSpecial': minSpecial,
    'avoidAmbiguous': avoidAmbiguous,
  };
}

/// What [generatePassphrase] builds a passphrase from, with the defaults of
/// Bitwarden's apps and `bw generate`. The JSON keys are those of Bitwarden's
/// SDK.
class PassphraseGeneratorOptions {
  const PassphraseGeneratorOptions({
    this.numWords = 6,
    this.wordSeparator = '-',
    this.capitalize = false,
    this.includeNumber = false,
  });

  factory PassphraseGeneratorOptions.fromJson(Map<String, dynamic> json) {
    const defaults = PassphraseGeneratorOptions();
    return PassphraseGeneratorOptions(
      numWords: json['numWords'] as int? ?? defaults.numWords,
      wordSeparator: json['wordSeparator'] as String? ?? defaults.wordSeparator,
      capitalize: json['capitalize'] as bool? ?? defaults.capitalize,
      includeNumber: json['includeNumber'] as bool? ?? defaults.includeNumber,
    );
  }

  static const minWords = 3;
  static const maxWords = 20;

  /// Kept between [minWords] and [maxWords].
  final int numWords;

  final String wordSeparator;

  /// Capitalizes the first letter of each word.
  final bool capitalize;

  /// Adds a digit at the end of one of the words.
  final bool includeNumber;

  PassphraseGeneratorOptions copyWith({
    int? numWords,
    String? wordSeparator,
    bool? capitalize,
    bool? includeNumber,
  }) => PassphraseGeneratorOptions(
    numWords: numWords ?? this.numWords,
    wordSeparator: wordSeparator ?? this.wordSeparator,
    capitalize: capitalize ?? this.capitalize,
    includeNumber: includeNumber ?? this.includeNumber,
  );

  Map<String, dynamic> toJson() => {
    'numWords': numWords,
    'wordSeparator': wordSeparator,
    'capitalize': capitalize,
    'includeNumber': includeNumber,
  };
}

/// What [generateUsername] builds a username from, with the defaults of
/// Bitwarden's apps. The JSON keys are those of [PassphraseGeneratorOptions].
class UsernameGeneratorOptions {
  const UsernameGeneratorOptions({
    this.capitalize = false,
    this.includeNumber = false,
  });

  factory UsernameGeneratorOptions.fromJson(Map<String, dynamic> json) {
    const defaults = UsernameGeneratorOptions();
    return UsernameGeneratorOptions(
      capitalize: json['capitalize'] as bool? ?? defaults.capitalize,
      includeNumber: json['includeNumber'] as bool? ?? defaults.includeNumber,
    );
  }

  final bool capitalize;

  /// Adds 4 digits at the end.
  final bool includeNumber;

  UsernameGeneratorOptions copyWith({bool? capitalize, bool? includeNumber}) =>
      UsernameGeneratorOptions(
        capitalize: capitalize ?? this.capitalize,
        includeNumber: includeNumber ?? this.includeNumber,
      );

  Map<String, dynamic> toJson() => {
    'capitalize': capitalize,
    'includeNumber': includeNumber,
  };
}

final _random = Random.secure();

/// A random password, as Bitwarden generates it: the fewest characters of each
/// enabled set, the rest from all of them, shuffled.
///
/// Throws an [ArgumentError] when no character set is enabled.
String generatePassword([
  PasswordGeneratorOptions options = const PasswordGeneratorOptions(),
]) {
  final sets = options._requiredSets;
  if (sets.isEmpty) {
    throw ArgumentError.value(options, 'options', 'No character set enabled.');
  }
  final all = sets.map((set) => set.$1).join();
  final characters = [
    for (final (set, count) in sets)
      for (var i = 0; i < count; i++) _pick(set),
    for (var i = options._requiredCount; i < options.effectiveLength; i++)
      _pick(all),
  ]..shuffle(_random);
  return characters.join();
}

/// A random passphrase of words from EFF's long wordlist, as Bitwarden
/// generates it.
String generatePassphrase([
  PassphraseGeneratorOptions options = const PassphraseGeneratorOptions(),
]) {
  final count = options.numWords.clamp(
    PassphraseGeneratorOptions.minWords,
    PassphraseGeneratorOptions.maxWords,
  );
  final words = [for (var i = 0; i < count; i++) _pickFrom(effLongWordlist)];
  if (options.includeNumber) {
    words[_random.nextInt(count)] += '${_random.nextInt(10)}';
  }
  return [
    for (final word in words) options.capitalize ? _capitalize(word) : word,
  ].join(options.wordSeparator);
}

/// A random word of EFF's long wordlist, as Bitwarden generates a username.
String generateUsername([
  UsernameGeneratorOptions options = const UsernameGeneratorOptions(),
]) {
  final word = _pickFrom(effLongWordlist);
  return [
    options.capitalize ? _capitalize(word) : word,
    if (options.includeNumber) '${_random.nextInt(10000)}'.padLeft(4, '0'),
  ].join();
}

/// A common English first name, to give a site instead of a real one.
String generateFirstName() => _pickFrom(englishFirstNames);

/// A common English surname, to give a site instead of a real one.
String generateLastName() => _pickFrom(englishLastNames);

/// The birth date of someone from 18 to 60 years old on [today] (by default,
/// now), as an ISO 8601 date like `1987-04-12`.
String generateBirthDate({DateTime? today}) {
  today ??= DateTime.now();
  final latest = _yearsBefore(today, 18);
  final earliest = _yearsBefore(today, 61).add(const Duration(days: 1));
  final days = latest.difference(earliest).inDays + 1;
  final date = earliest.add(Duration(days: _random.nextInt(days)));
  return date.toIso8601String().substring(0, 10);
}

/// The same day [years] earlier, in UTC so that every day lasts 24 hours.
/// February 29 becomes February 28 in a year without it.
DateTime _yearsBefore(DateTime day, int years) {
  final date = DateTime.utc(day.year - years, day.month, day.day);
  return date.month == day.month
      ? date
      : DateTime.utc(date.year, date.month, 0);
}

String _pick(String characters) =>
    characters[_random.nextInt(characters.length)];

String _pickFrom(List<String> list) => list[_random.nextInt(list.length)];

String _capitalize(String word) => word[0].toUpperCase() + word.substring(1);
