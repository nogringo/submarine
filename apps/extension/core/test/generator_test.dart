import 'package:submarine_extension_core/generator.dart';
import 'package:test/test.dart';

void main() {
  Map<String, dynamic> settingsOf(Map<String, Object> generated) =>
      generated['settings'] as Map<String, dynamic>;

  test("generates a password with Bitwarden's defaults at first", () {
    final generated = generate({});

    expect(generated['value'], matches(RegExp(r'^[A-Za-z0-9]{14}$')));
    expect(settingsOf(generated), {
      'type': 'password',
      'password': {
        'length': 14,
        'uppercase': true,
        'lowercase': true,
        'numbers': true,
        'special': false,
        'minNumber': 1,
        'minSpecial': 1,
        'avoidAmbiguous': false,
      },
      'passphrase': {
        'numWords': 6,
        'wordSeparator': '-',
        'capitalize': false,
        'includeNumber': false,
      },
      'username': {'capitalize': false, 'includeNumber': false},
    });
  });

  test('raises the length to fit the minimums, and keeps it', () {
    final generated = generate({
      'password': {
        'length': 5,
        'special': true,
        'minNumber': 9,
        'minSpecial': 12,
      },
    });

    // A capital, a lowercase letter, 9 digits and 9 special characters.
    expect(generated['value'], hasLength(20));
    expect(settingsOf(generated)['password'], {
      'length': 20,
      'uppercase': true,
      'lowercase': true,
      'numbers': true,
      'special': true,
      'minNumber': 9,
      'minSpecial': 9,
      'avoidAmbiguous': false,
    });
  });

  test('generates a passphrase of the words asked for', () {
    final generated = generate({
      'type': 'passphrase',
      'passphrase': {'numWords': 4, 'wordSeparator': '.'},
    });

    expect((generated['value'] as String).split('.'), hasLength(4));
    expect(settingsOf(generated)['type'], 'passphrase');
  });

  test('generates a username, whatever the type chosen', () {
    final generated = generate({
      'type': 'passphrase',
      'username': {'includeNumber': true},
    }, username: true);

    expect(generated['value'], matches(RegExp(r'^[a-z-]+\d{4}$')));
    expect(settingsOf(generated)['type'], 'passphrase');
  });
}
