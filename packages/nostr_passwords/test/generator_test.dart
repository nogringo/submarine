import 'package:nostr_passwords/nostr_passwords.dart';
import 'package:nostr_passwords/src/eff_long_wordlist.dart';
import 'package:nostr_passwords/src/english_names.dart';
import 'package:test/test.dart';

void main() {
  int count(String text, String pattern) =>
      RegExp(pattern).allMatches(text).length;

  group('password', () {
    test('defaults to 14 letters and digits, with each kind', () {
      for (var i = 0; i < 100; i++) {
        final password = generatePassword();
        expect(password, matches(RegExp(r'^[A-Za-z0-9]{14}$')));
        expect(password, contains(RegExp('[A-Z]')));
        expect(password, contains(RegExp('[a-z]')));
        expect(password, contains(RegExp('[0-9]')));
      }
    });

    test('takes only the enabled characters', () {
      const options = PasswordGeneratorOptions(
        uppercase: false,
        numbers: false,
        special: true,
      );
      for (var i = 0; i < 100; i++) {
        final password = generatePassword(options);
        expect(password, matches(RegExp(r'^[a-z!@#$%^&*]{14}$')));
        expect(password, contains(RegExp(r'[!@#$%^&*]')));
      }
    });

    test('has the fewest digits and special characters asked for', () {
      const options = PasswordGeneratorOptions(
        length: 20,
        special: true,
        minNumber: 4,
        minSpecial: 6,
      );
      for (var i = 0; i < 100; i++) {
        final password = generatePassword(options);
        expect(count(password, '[0-9]'), greaterThanOrEqualTo(4));
        expect(count(password, r'[!@#$%^&*]'), greaterThanOrEqualTo(6));
      }
    });

    test('leaves out the ambiguous characters when asked', () {
      const options = PasswordGeneratorOptions(
        length: 128,
        avoidAmbiguous: true,
      );
      for (var i = 0; i < 20; i++) {
        expect(generatePassword(options), isNot(contains(RegExp('[IOl01]'))));
      }
    });

    test('keeps the length between 5 and 128', () {
      expect(
        generatePassword(const PasswordGeneratorOptions(length: 1)),
        hasLength(5),
      );
      expect(
        generatePassword(const PasswordGeneratorOptions(length: 500)),
        hasLength(128),
      );
    });

    test('raises the length to fit the fewest characters asked for', () {
      const options = PasswordGeneratorOptions(
        length: 8,
        special: true,
        minNumber: 9,
        minSpecial: 9,
      );
      expect(options.effectiveLength, 20);
      expect(generatePassword(options), hasLength(20));
    });

    test('asks for at least 1 and at most 9 of an enabled set', () {
      const options = PasswordGeneratorOptions(
        length: 5,
        uppercase: false,
        lowercase: false,
        special: true,
        minNumber: 0,
        minSpecial: 12,
      );
      expect(options.effectiveLength, 10);
      final password = generatePassword(options);
      expect(count(password, '[0-9]'), 1);
      expect(count(password, r'[!@#$%^&*]'), 9);
    });

    test('refuses options without any character set', () {
      expect(
        () => generatePassword(
          const PasswordGeneratorOptions(
            uppercase: false,
            lowercase: false,
            numbers: false,
          ),
        ),
        throwsArgumentError,
      );
    });

    test('reads back its JSON, and defaults what is missing', () {
      const options = PasswordGeneratorOptions(
        length: 30,
        special: true,
        minSpecial: 3,
        avoidAmbiguous: true,
      );
      final json = options.toJson();
      expect(PasswordGeneratorOptions.fromJson(json).toJson(), json);
      expect(
        PasswordGeneratorOptions.fromJson({}).toJson(),
        const PasswordGeneratorOptions().toJson(),
      );
    });
  });

  group('passphrase', () {
    test('defaults to 6 words of the EFF list joined by hyphens', () {
      final words = generatePassphrase().split('-');
      expect(words, hasLength(6));
      expect(words, everyElement(isIn(effLongWordlist)));
    });

    test('capitalizes the words and adds a digit to one when asked', () {
      final passphrase = generatePassphrase(
        const PassphraseGeneratorOptions(
          numWords: 4,
          wordSeparator: ' ',
          capitalize: true,
          includeNumber: true,
        ),
      );
      final words = passphrase.split(' ');
      expect(words, hasLength(4));
      expect(words, everyElement(matches(RegExp('^[A-Z][a-z]+[0-9]?\$'))));
      expect(count(passphrase, '[0-9]'), 1);
    });

    test('keeps between 3 and 20 words', () {
      String words(int count) => generatePassphrase(
        PassphraseGeneratorOptions(numWords: count, wordSeparator: ' '),
      );
      expect(words(1).split(' '), hasLength(3));
      expect(words(50).split(' '), hasLength(20));
    });

    test('reads back its JSON, and defaults what is missing', () {
      const options = PassphraseGeneratorOptions(
        numWords: 8,
        wordSeparator: '_',
        includeNumber: true,
      );
      final json = options.toJson();
      expect(PassphraseGeneratorOptions.fromJson(json).toJson(), json);
      expect(
        PassphraseGeneratorOptions.fromJson({}).toJson(),
        const PassphraseGeneratorOptions().toJson(),
      );
    });

    test("uses Bitwarden's list: the EFF long wordlist minus its 4 hyphenated words", () {
      expect(effLongWordlist, hasLength(7772));
      expect(effLongWordlist.toSet(), hasLength(7772));
      expect(effLongWordlist.first, 'abacus');
      expect(effLongWordlist.last, 'zoom');
      expect(effLongWordlist, isNot(contains('yo-yo')));
    });
  });

  group('username', () {
    test('defaults to a word of the EFF list', () {
      expect(generateUsername(), isIn(effLongWordlist));
    });

    test('capitalizes it and adds 4 digits when asked', () {
      const options = UsernameGeneratorOptions(
        capitalize: true,
        includeNumber: true,
      );
      for (var i = 0; i < 100; i++) {
        expect(
          generateUsername(options),
          matches(RegExp(r'^[A-Z][a-z]+[0-9]{4}$')),
        );
      }
    });

    test('reads back its JSON, and defaults what is missing', () {
      const options = UsernameGeneratorOptions(includeNumber: true);
      final json = options.toJson();
      expect(UsernameGeneratorOptions.fromJson(json).toJson(), json);
      expect(
        UsernameGeneratorOptions.fromJson({}).toJson(),
        const UsernameGeneratorOptions().toJson(),
      );
    });
  });

  group('names', () {
    test('picks a first name and a surname from the English lists', () {
      expect(generateFirstName(), isIn(englishFirstNames));
      expect(generateLastName(), isIn(englishLastNames));
    });

    test('has the 500 top names of each sex, and 1000 surnames', () {
      expect(englishFirstNames, hasLength(977));
      expect(englishFirstNames.toSet(), hasLength(977));
      expect(englishFirstNames, containsAll(['Jessica', 'Michael', 'Taylor']));
      expect(englishLastNames, hasLength(1000));
      expect(englishLastNames.toSet(), hasLength(1000));
      expect(
        englishLastNames,
        containsAll(['Smith', "O'Brien", 'McDonald', 'De La Cruz', 'LeBlanc']),
      );
    });
  });

  group('birth date', () {
    Matcher between(String first, String last) => predicate<String>(
      (date) => date.compareTo(first) >= 0 && date.compareTo(last) <= 0,
      'between $first and $last',
    );

    test('is an ISO date of someone from 18 to 60 years old', () {
      final today = DateTime(2026, 10, 6);
      for (var i = 0; i < 1000; i++) {
        final date = generateBirthDate(today: today);
        expect(date, matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')));
        expect(date, between('1965-10-07', '2008-10-06'));
      }
    });

    test('reaches both ends of the range', () {
      final today = DateTime(2026, 10, 6);
      final dates = {
        for (var i = 0; i < 300000; i++) generateBirthDate(today: today),
      };
      expect(dates, containsAll(['1965-10-07', '2008-10-06']));
    });

    test('turns February 29 into February 28 in a year without it', () {
      final today = DateTime(2028, 2, 29);
      for (var i = 0; i < 1000; i++) {
        expect(
          generateBirthDate(today: today),
          between('1967-03-01', '2010-02-28'),
        );
      }
    });

    test('defaults to today', () {
      final year = int.parse(generateBirthDate().substring(0, 4));
      final now = DateTime.now().year;
      expect(year, inInclusiveRange(now - 61, now - 18));
    });
  });
}
