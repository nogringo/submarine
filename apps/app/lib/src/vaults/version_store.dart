import 'package:nostr_passwords/nostr_passwords.dart';
import 'package:sembast/sembast.dart';

/// The versions a vault opened, as its [VersionCache] encrypts them, in a
/// store of their own.
class SembastVersionStore implements VersionStore {
  SembastVersionStore(this._database, String pubkey)
    : _store = StoreRef('versions_$pubkey');

  final Database _database;
  final StoreRef<String, String> _store;

  @override
  Future<Map<String, String>> read() async => {
    for (final record in await _store.find(_database)) record.key: record.value,
  };

  @override
  Future<void> write(Map<String, String> entries) =>
      _store.records(entries.keys).put(_database, entries.values.toList());

  @override
  Future<void> remove(Iterable<String> wrapIds) =>
      _store.records(wrapIds).delete(_database);
}
