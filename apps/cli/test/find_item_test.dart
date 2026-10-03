import 'package:nostr_passwords/nostr_passwords.dart';
import 'package:submarine_cli/src/find_item.dart';
import 'package:submarine_cli/submarine_cli.dart';
import 'package:test/test.dart';

Item item(String id, Cipher cipher) => Item([
  Envelope(
    id: id,
    type: 'item',
    rev: 'rev',
    parents: const [],
    modifiedAt: DateTime.utc(2026),
    data: cipher.toJson(),
  ),
]);

Cipher login(
  String name, {
  String? username,
  String? password,
  String? uri,
  String? notes,
}) => Cipher(
  type: CipherType.login,
  name: name,
  notes: notes,
  login: Login(
    username: username,
    password: password,
    uris: [if (uri != null) LoginUri(uri)],
  ),
);

void main() {
  final societe = item(
    'aaaaaaaa11111111aaaaaaaa11111111',
    login(
      'Société Générale',
      username: 'alice@example.com',
      password: 'hunter2',
      uri: 'https://particuliers.sg.fr/login',
    ),
  );
  final github = item(
    'bbbbbbbb22222222bbbbbbbb22222222',
    login('GitHub', username: 'alice', password: 'octocat'),
  );
  final githubCodes = item(
    'cccccccc33333333cccccccc33333333',
    Cipher(
      type: CipherType.secureNote,
      name: 'GitHub recovery codes',
      notes: 'abcd-efgh',
    ),
  );
  final items = [societe, github, githubCodes];

  group('findItem', () {
    Matcher fails(String message) => throwsA(
      isA<CliException>().having((error) => error.message, 'message', message),
    );

    test('finds an item by id, in any case', () {
      expect(findItem(items, 'BBBBBBBB22222222BBBBBBBB22222222'), github);
    });

    test('finds the only search result', () {
      expect(findItem(items, 'société'), societe);
    });

    test('reports no result', () {
      expect(() => findItem(items, 'gitlab'), fails('Not found.'));
      expect(() => findItem(items, ' '), fails('Not found.'));
    });

    test('lists the ids of several results', () {
      expect(
        () => findItem(items, 'github'),
        fails(
          'More than one result was found. Try getting a specific object by '
          '`id` instead. The following objects were found:\n'
          'bbbbbbbb22222222bbbbbbbb22222222\n'
          'cccccccc33333333cccccccc33333333',
        ),
      );
    });

    test('keeps the results isWanted accepts', () {
      expect(
        findItem(
          items,
          'github',
          isWanted: (item) => item.cipher.login?.password != null,
        ),
        github,
      );
      expect(
        () => findItem(items, 'société', isWanted: (_) => false),
        fails('Not found.'),
      );
    });

    test('searches only items neither deleted nor archived', () {
      final deleted = item(
        'eeeeeeee55555555eeeeeeee55555555',
        login('Deleted')..deletedDate = DateTime.utc(2026),
      );
      final archived = item(
        'ffffffff66666666ffffffff66666666',
        login('Archived')..archivedDate = DateTime.utc(2026),
      );

      expect(() => findItem([deleted], 'deleted'), fails('Not found.'));
      expect(() => findItem([archived], 'archived'), fails('Not found.'));
      expect(findItem([deleted], deleted.id), deleted);
    });
  });
}
