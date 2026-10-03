import 'package:nostr_passwords/nostr_passwords.dart';
import 'package:test/test.dart';

Envelope version(
  String rev, {
  List<String> parents = const [],
  int minute = 0,
  String id = 'item-1',
  String type = 'item',
}) => Envelope(
  id: id,
  type: type,
  rev: rev,
  parents: parents,
  modifiedAt: DateTime.utc(2026, 10, 3, 12, minute),
  data: {'type': 1, 'name': rev},
);

List<String> headRevs(Item item) => [for (final head in item.heads) head.rev];

void main() {
  test('the end of a chain is the only head', () {
    final [item] = resolveItems([
      version('v3', parents: ['v2'], minute: 3),
      version('v1', minute: 1),
      version('v2', parents: ['v1'], minute: 2),
    ]);

    expect(headRevs(item), ['v3']);
    expect(item.hasConflict, isFalse);
    expect(item.cipher.name, 'v3');
  });

  test('concurrent edits are all heads, the latest first', () {
    final [item] = resolveItems([
      version('v1', minute: 1),
      version('b', parents: ['v1'], minute: 2),
      version('a', parents: ['v1'], minute: 3),
    ]);

    expect(headRevs(item), ['a', 'b']);
    expect(item.hasConflict, isTrue);
    expect(item.current.rev, 'a');
  });

  test('a tie on modified_at is broken by the greatest rev', () {
    final [item] = resolveItems([
      version('v1', minute: 1),
      version('a', parents: ['v1'], minute: 2),
      version('b', parents: ['v1'], minute: 2),
    ]);

    expect(headRevs(item), ['b', 'a']);
  });

  test('an edit naming every head resolves the conflict', () {
    final [item] = resolveItems([
      version('v1', minute: 1),
      version('a', parents: ['v1'], minute: 2),
      version('b', parents: ['v1'], minute: 3),
      version('merge', parents: ['a', 'b'], minute: 4),
    ]);

    expect(headRevs(item), ['merge']);
  });

  test('versions are grouped by item and counted once', () {
    final items = resolveItems([
      version('v1', id: 'boulanger'),
      version('v1', id: 'boulanger'),
      version('v1', id: 'github'),
      version('f1', id: 'folder', type: 'folder'),
    ]);

    expect([for (final item in items) item.id], ['boulanger', 'github']);
    expect(headRevs(items.first), ['v1']);
  });
}
