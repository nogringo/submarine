import 'cipher/cipher.dart';
import 'envelope.dart';

class Item {
  Item(this.heads);

  /// Versions no other version names as a parent, the current one first.
  final List<Envelope> heads;

  String get id => current.id;
  Envelope get current => heads.first;
  bool get hasConflict => heads.length > 1;
  late final Cipher cipher = Cipher.fromJson(current.data);
}

/// Orders items by name, ignoring case, then by id for the same name, as a
/// list shows them.
int compareItemsByName(Item a, Item b) {
  final byName = a.cipher.name.toLowerCase().compareTo(
    b.cipher.name.toLowerCase(),
  );
  return byName != 0 ? byName : a.id.compareTo(b.id);
}

/// Groups [versions] by item and keeps the heads of each. Concurrent heads are
/// ordered by `modified_at`, then by `rev`, latest first.
List<Item> resolveItems(Iterable<Envelope> versions) {
  final revsById = <String, Map<String, Envelope>>{};
  for (final version in versions) {
    if (version.type == 'item') {
      (revsById[version.id] ??= {})[version.rev] = version;
    }
  }
  return [
    for (final revs in revsById.values)
      if (_headsOf(revs.values) case final heads when heads.isNotEmpty)
        Item(heads),
  ];
}

List<Envelope> _headsOf(Iterable<Envelope> versions) {
  final parents = {for (final version in versions) ...version.parents};
  return [
    for (final version in versions)
      if (!parents.contains(version.rev)) version,
  ]..sort((a, b) {
    final byDate = b.modifiedAt.compareTo(a.modifiedAt);
    return byDate != 0 ? byDate : b.rev.compareTo(a.rev);
  });
}
