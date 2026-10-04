import 'dart:convert';

import 'package:nostr_passwords/nostr_passwords.dart';
import 'package:submarine_cli/src/item_json.dart';
import 'package:submarine_cli/src/templates.dart';
import 'package:submarine_cli/submarine_cli.dart';
import 'package:test/test.dart';

void main() {
  test('prints the item template as bw does', () {
    expect(
      jsonEncode(template('item')),
      '{"type":1,"name":"Item name","favorite":false,"reprompt":0,'
      '"notes":"Some notes about this item.","fields":[],'
      '"passwordHistory":[]}',
    );
  });

  test('ignores case', () {
    expect(template('Item.Login.URI'), {'uri': 'https://google.com'});
  });

  test('templates make an item, as in the bw documentation', () {
    final item = {
      ...template('item') as Map<String, Object?>,
      'name': 'My Login Item',
      'login': {
        ...template('item.login') as Map<String, Object?>,
        'uris': [template('item.login.uri')],
      },
      'fields': [template('item.field')],
    };

    final cipher = decodeItemJson(base64.encode(utf8.encode(jsonEncode(item))));

    expect(cipher.type, CipherType.login);
    expect(cipher.name, 'My Login Item');
    expect(cipher.login?.password, 'myp@ssword123');
    expect(cipher.login?.uris.single.uri, 'https://google.com');
    expect(cipher.fields.single.value, 'Some value');
  });

  test('fails for the templates Submarine does not support, or bw lacks', () {
    for (final (object, message) in [
      ('folder', 'Submarine does not support `get template folder`.'),
      ('send.text', 'Submarine does not support `get template send.text`.'),
      ('item.sshkey', 'Unknown template object.'),
      ('nope', 'Unknown template object.'),
    ]) {
      expect(
        () => template(object),
        throwsA(
          isA<CliException>().having(
            (error) => error.message,
            'message',
            message,
          ),
        ),
        reason: object,
      );
    }
  });
}
